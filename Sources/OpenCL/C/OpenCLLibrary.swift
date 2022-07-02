//
//  OpenCLLibrary.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(Windows)
import CRT
import WinSDK
#endif

// Based on `PythonLibrary` from PythonKit. This lets the user query whether the
// OpenCL library can be loaded at runtime, and specify the path for loading it.
// All other functionality is internal, just like in PythonKit.
public struct OpenCLLibrary {
  public enum Error: Swift.Error, Equatable, CustomStringConvertible {
    case openclLibraryNotFound
    case cannotGetPlatforms
    case platformsNotFound
    case incorrectOpenCLVersion(specified: CLVersion?, actual: CLVersion?)
    
    public var description: String {
      switch self {
      case .openclLibraryNotFound:
        return """
          OpenCL library not found. Set the \(Environment.library.rawValue) \
          environment variable with the path to a Python library.
          """
      case .cannotGetPlatforms:
        return """
          Could not load symbol `clGetPlatformIDs` from the OpenCL library, \
          which is needed to search for platforms.
          """
      
      // Windows has an `opencl.dll` that searches for the actual OpenCL
      // library. Khronos calls this mechanism "Installable Client Driver", or
      // ICD. If no client driver exists, the DLL is still opened and loads
      // symbols, but they return an error when calling into functions that
      // access the GPU.
      //
      // If `clGetPlatformIDs` returns no platforms, you have a Windows machine
      // that doesn't support OpenCL. One example is a Parallels VM on macOS,
      // which emulates OpenGL and DirectX 11, but not OpenCL. The error should
      // also happen on Google Colab when connected to a CPU-only runtime.
      case .platformsNotFound:
        return """
          OpenCL library was found, but no OpenCL platforms exist. Ensure that \
          an OpenCL driver is installed and visible to the ICD loader.
          """
      case .incorrectOpenCLVersion(let specified, let actual):
        let specifiedString = specified?.versionString ?? "could not parse"
        let actualString = actual?.versionString ?? "could not detect"
        return """
          OpenCL library version (\(actualString)) did not match specified \
          version (\(specifiedString)). Set the \(Environment.version.rawValue
          ) environment variable to MAJOR.MINOR or do not set it at all.
          """
      }
    }
  }
  
  #if canImport(Darwin)
  private static let defaultLibraryHandle: UnsafeMutableRawPointer? =
    .init(bitPattern: -2)
  #elseif canImport(Glibc)
  private static let defaultLibraryHandle: UnsafeMutableRawPointer? = nil
  #elseif os(Windows)
  private static let defaultLibraryHandle: UnsafeMutableRawPointer? = nil
  #endif
  
  private static var isOpenCLLibraryLoaded = false
  private static var isLoaderLoggingEnabled = false
  private static var _openclLibraryHandle: UnsafeMutableRawPointer?
  
  #if DEBUG
  // Provides a mechanism to reload the library from scratch during unit tests.
  // This doesn't reset the lazily loaded symbols in "OpenCLSymbols.swift", so
  // you must explicitly call `loadSymbol<T>(name:)`. Use `@testable import
  // OpenCL` to access this.
  static func unitTestClear() {
    isOpenCLLibraryLoaded = false
    isLoaderLoggingEnabled = false
    _openclLibraryHandle = nil
  }
  
  // Lets you disable the mechanism that searches for a pre-linked library
  // during the unit tests.
  static var unitTestUsingDefaultLibraryHandle = true
  
  static func unitTestGetEnvironment(_ key: Environment) -> String? {
    guard let cString = getenv(key.rawValue) else {
      return nil
    }
    return String(cString: cString)
  }
  
  static func unitTestSetEnvironment(_ key: Environment, _ path: String?) {
    guard let path = path else {
      #if canImport(Darwin) || canImport(Glibc)
      unsetenv(key.rawValue)
      #elseif os(Windows)
      key.set("")
      #endif
      return
    }
    key.set(path)
  }
  #endif
  
  public static func loadLibrary() throws {
    guard !self.isOpenCLLibraryLoaded else {
      return
    }
    let openclLibraryHandle = self.loadOpenCLLibrary()
    guard self.isOpenCLLibraryLoaded(at: openclLibraryHandle) else {
      throw Error.openclLibraryNotFound
    }
    
    // Can't use `loadSymbol<T>(name:)` because that causes a recursive function
    // call.
    let symbol = self.loadSymbol(openclLibraryHandle, "clGetPlatformIDs")
    guard let symbol = symbol else {
      throw Error.cannotGetPlatforms
    }
    
    let clGetPlatformIDs = unsafeBitCast(
      symbol, to: cl_api_clGetPlatformIDs.self)
    var numPlatforms: UInt32 = 0
    let error = clGetPlatformIDs(0, nil, &numPlatforms)
    guard error == CL_SUCCESS,
          numPlatforms > 0 else {
      throw Error.platformsNotFound
    }
    
    if let specifiedVersionString = Environment.version.value {
      let specifiedVersion = CLVersion(versionString: specifiedVersionString)
      let actualVersion = detectVersion(at: openclLibraryHandle)!
      
      guard specifiedVersion == actualVersion else {
        throw Error.incorrectOpenCLVersion(
          specified: specifiedVersion, actual: actualVersion)
      }
    }
    
    self.isOpenCLLibraryLoaded = true
    self.isLoaderLoggingEnabled = Environment.loaderLogging.value != nil
    self._openclLibraryHandle = openclLibraryHandle
  }
  
  // Returns `nil` so you can provide a default value.
  internal static func loadSymbol<T>(name: StaticString) -> T? {
    if self.isLoaderLoggingEnabled {
      log("Loading symbol '\(name.description)' from the Python library...")
    }
    
    if !self.isOpenCLLibraryLoaded {
      try! OpenCLLibrary.loadLibrary()
    }
    
    // Force-inlined.
    let symbol = self._loadSymbol(self._openclLibraryHandle, name)
    return unsafeBitCast(symbol, to: T?.self)
  }
}

// Paths to OpenCL binaries:
// macOS - "/System/Library/Frameworks/OpenCL.framework/Versions/A/OpenCL"
// Colab - "/usr/lib/x86_64-linux-gnu/libOpenCL.so"
// Windows - "C:\Windows\System32\opencl.dll"

extension OpenCLLibrary {
  #if canImport(Darwin)
  // There isn't actually a file named "OpenCL" in "Versions/A". It must be some
  // trick with the library loading mechanism.
  private static var libraryNames = ["OpenCL.framework/Versions/A/OpenCL"]
  private static var librarySearchPaths = ["", "/System/Library/Frameworks/"]
  #elseif canImport(Glibc)
  private static var libraryNames = ["libOpenCL.so"]
  
  // Using `$(uname -m)-linux-gnu` instead of `$(gcc -dumpmachine)`. It takes
  // ~1 second to load the GCC binary, while `$(uname -m)` returns
  // instantaneously. `uname` is callable from C, eliminating the need to spawn
  // a child process. Furthermore, GCC may return an incorrect architecture,
  // such as i686 when the machine is i386:
  // https://askubuntu.com/questions/872457/how-to-determine-the-host-multi-arch-default-folder
  private static var librarySearchPaths = [
    "", "/usr/lib/\(uname_m())-linux-gnu/"
  ]
  #elseif os(Windows)
  private static var libraryNames = "opencl.dll"
  private static var librarySearchPaths = ["", "C:\\Windows\\System32\\"]
  #endif
}

#if canImport(Darwin) || canImport(Glibc)
// Produces the same output as "uname -m" in the command line.
fileprivate func uname_m() -> String {
  var unameData = utsname()
  let error = uname(&unameData)
  guard error == 0 else {
    return ""
  }
  
  // Bypass the fact that Swift imports the C arrays as 256-element tuples.
  func extractString<T>(of member: UnsafePointer<T>) -> String {
    let rebound = UnsafeRawPointer(member).assumingMemoryBound(to: Int8.self)
    return String(cString: rebound)
  }
  return extractString(of: &unameData.machine)
}
#endif

extension OpenCLLibrary {
  private static let libraryPaths: [String] = {
    var libraryPaths: [String] = []
    for librarySearchPath in librarySearchPaths {
      for libraryName in libraryNames {
        let libraryPath = librarySearchPath + libraryName
        libraryPaths.append(libraryPath)
      }
    }
    return libraryPaths
  }()
  
  // For use in `loadSymbol<T>(name:)`.
  @inline(__always)
  private static func _loadSymbol(
    _ libraryHandle: UnsafeMutableRawPointer?, _ name: StaticString
  ) -> UnsafeMutableRawPointer? {
    #if os(Windows)
    guard let libraryHandle = libraryHandle else {
      return nil
    }
    #endif
    return name.withUTF8Buffer { nameCStringUInt8 in
      let baseAddress = nameCStringUInt8.baseAddress.unsafelyUnwrapped
      let name = UnsafeRawPointer(baseAddress)
        .assumingMemoryBound(to: Int8.self)
      #if canImport(Darwin) || canImport(Glibc)
      return dlsym(libraryHandle, name)
      #elseif os(Windows)
      let moduleHandle = libraryHandle.assumingMemoryBound(to: HINSTANCE__.self)
      let moduleSymbol = GetProcAddress(moduleHandle, name)
      return unsafeBitCast(moduleSymbol, to: UnsafeMutableRawPointer?.self)
      #endif
    }
  }
  
  // For use everywhere else.
  @inline(never)
  private static func loadSymbol(
    _ libraryHandle: UnsafeMutableRawPointer?, _ name: StaticString
  ) -> UnsafeMutableRawPointer? {
    self._loadSymbol(libraryHandle, name)
  }
  
  private static func isOpenCLLibraryLoaded(
    at openclLibraryHandle: UnsafeMutableRawPointer? = nil
  ) -> Bool {
    #if DEBUG
    if !unitTestUsingDefaultLibraryHandle {
      if openclLibraryHandle == nil {
        return false
      }
    }
    #endif
    let openclLibraryHandle = openclLibraryHandle ?? self.defaultLibraryHandle
    return self.loadSymbol(openclLibraryHandle, "clGetPlatformIDs") != nil
  }
  
  private static func detectVersion(
    at openclLibraryHandle: UnsafeMutableRawPointer?
  ) -> CLVersion? {
    func supportsVersion(_ symbol: StaticString) -> Bool {
      let symbol = self.loadSymbol(openclLibraryHandle, symbol)
      return symbol != nil
    }
    
    // A symbol introduced in each version.
    let v1_0: StaticString = "clGetPlatformIDs"
    let v1_1: StaticString = "clCreateSubBuffer"
    let v1_2: StaticString = "clCreateImage"
    
    let v2_0: StaticString = "clCreatePipe"
    let v2_1: StaticString = "clSetDefaultDeviceCommandQueue"
    let v2_2: StaticString = "clSetProgramReleaseCallback"
    
    let v3_0: StaticString = "clCreateBufferWithProperties"
    
    if supportsVersion(v3_0) {
      return .init(major: 3, minor: 0)
    } else if supportsVersion(v2_0) {
      if supportsVersion(v2_2) {
        return .init(major: 2, minor: 2)
      } else if supportsVersion(v2_1) {
        return .init(major: 2, minor: 1)
      } else {
        return .init(major: 2, minor: 0)
      }
    } else if supportsVersion(v1_0) {
      if supportsVersion(v1_2) {
        return .init(major: 1, minor: 2)
      } else if supportsVersion(v1_1) {
        return .init(major: 1, minor: 1)
      } else {
        return .init(major: 1, minor: 0)
      }
    } else {
      return nil
    }
  }
  
  private static func loadOpenCLLibrary() -> UnsafeMutableRawPointer? {
    if self.isOpenCLLibraryLoaded() {
      return self.defaultLibraryHandle
    }
    var libraryPaths: [String]
    if let openclLibraryPath = Environment.library.value {
      libraryPaths = [openclLibraryPath]
    } else {
      libraryPaths = self.libraryPaths
    }
    for libraryPath in libraryPaths {
      if let openclLibraryHandle = loadOpenCLLibrary(at: libraryPath) {
        return openclLibraryHandle
      }
    }
    return nil
  }
  
  private static func loadOpenCLLibrary(
    at path: String
  ) -> UnsafeMutableRawPointer? {
    self.log("Trying to load library at '\(path)'...")
    #if canImport(Darwin) || canImport(Glibc)
    let openclLibraryHandle = dlopen(path, RTLD_LAZY | RTLD_GLOBAL)
    #elseif os(Windows)
    let openclLibraryHandle = UnsafeMutableRawPointer(LoadLibraryA(path))
    #endif
    
    if openclLibraryHandle != nil {
      self.log("Library at path '\(path)' was successfully loaded.")
    }
    return openclLibraryHandle
  }
}

extension OpenCLLibrary {
  private static func enforceNonLoadedOpenCLLibrary(
    function: String = #function
  ) {
    precondition(!self.isOpenCLLibraryLoaded, """
      Error: \(function) should not be called after any OpenCL library has \
      already been loaded.
      """)
  }
  
  /// Returns `nil` if the library has not loaded or the version could not be detected.
  public static var version: CLVersion? {
    if self.isOpenCLLibraryLoaded {
      return detectVersion(at: _openclLibraryHandle)
    } else {
      return nil
    }
  }
  
  public static func setVersion(
    _ major: Int, _ minor: Int, _ patch: Int? = nil
  ) {
    self.enforceNonLoadedOpenCLLibrary()
    
    var castedPatch: UInt32?
    if let patch = patch {
      castedPatch = UInt32(patch)
    }
    let specifiedVersion = CLVersion(
      major: UInt32(major), minor: UInt32(minor), patch: castedPatch)
    OpenCLLibrary.Environment.version.set(specifiedVersion.versionString)
  }
  
  public static func versionEquals(_ specifiedVersion: CLVersion) {
    self.enforceNonLoadedOpenCLLibrary()
    OpenCLLibrary.Environment.version.set(specifiedVersion.versionString)
  }
  
  public static func useLibrary(at path: String?) {
    self.enforceNonLoadedOpenCLLibrary()
    OpenCLLibrary.Environment.library.set(path ?? "")
  }
}

// Remove this duplicate declaration when "CLVersion.swift" is enabled in the
// package manifest.
public struct CLVersion: Comparable {
  // Using `UInt32` instead of `Int` to halve CPU register usage. Also, it's a
  // standard type to represent things across the OpenCL API. `cl_version` is
  // even a typealias of `UInt32`.
  public var major: UInt32
  public var minor: UInt32
  public var patch: UInt32?
  
  @_transparent
  public init(major: UInt32, minor: UInt32, patch: UInt32? = nil) {
    self.major = major
    self.minor = minor
    self.patch = patch
  }
  
  @inlinable
  public static func < (lhs: CLVersion, rhs: CLVersion) -> Bool {
    if lhs.major != rhs.major {
      return lhs.major < rhs.major
    }
    if lhs.minor != rhs.minor {
      return lhs.minor < rhs.minor
    }
    
    // Not having a patch is considered being "0" of the patch. If one side has
    // a patch and another doesn't, the versions will already be counted as not
    // equal. So determine a convention for comparing them.
    let lhsPatch = lhs.patch ?? 0
    let rhsPatch = rhs.patch ?? 0
    return lhsPatch < rhsPatch
  }
}

extension CLVersion {
  init?(versionString: String) {
    let components = versionString.split(separator: ".")
    guard components.count >= 2,
          components.count <= 3 else {
      return nil
    }
    
    guard let major = UInt32(components[0]),
          let minor = UInt32(components[1]) else {
      return nil
    }
    self.major = major
    self.minor = minor
    
    if components.count == 3 {
      guard let patch = UInt32(components[2]) else {
        return nil
      }
      self.patch = patch
    }
  }

  var versionString: String {
    var versionString = String(major) + "." + String(minor)
    if let patch = patch {
      versionString += "." + String(patch)
    }
    return versionString
  }
}

// Added enum cases for only library, version, and loader logging. The
// environment variable `OPENCL_VERSION` should let you validate the
// automatically detected library version. Only use the version variable for
// debugging purposes
extension OpenCLLibrary {
  // Internal so that unit tests can access it.
  internal enum Environment: String {
    case library = "OPENCL_LIBRARY"
    case version = "OPENCL_VERSION"
    case loaderLogging = "OPENCL_LOADER_LOGGING"
    
    var value: String? {
      guard let cString = getenv(rawValue) else {
        return nil
      }
      let value = String(cString: cString)
      if value.isEmpty {
        return nil
      } else {
        return value
      }
    }
    
    func set(_ value: String) {
      #if canImport(Darwin) || canImport(Glibc)
      setenv(rawValue, value, 1)
      #elseif os(Windows)
      _putenv_s(rawValue, value)
      #endif
    }
  }
}

extension OpenCLLibrary {
  // `message` is an autoclosure so that it only materializes when something
  // should be logged. This improves performance when logging is disabled.
  private static func log(_ message: @autoclosure () -> String) {
    guard Environment.loaderLogging.value != nil else {
      return
    }
    fputs(message() + "\n", stderr)
  }
}
