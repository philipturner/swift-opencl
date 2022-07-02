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

// This file is not properly documented. For a full explanation of what each
// code section does, look at the counterpart in PythonKit.

// Based on `PythonLibrary` from PythonKit. This lets the user query whether the
// OpenCL library can be loaded at runtime, and specify the path for loading it.
// All other functionality is internal, just like in PythonKit.
public struct OpenCLLibrary {
  public enum Error: Swift.Error, Equatable, CustomStringConvertible {
    case openclLibraryNotFound
    case cannotFetchPlatforms
    case platformsNotFound
    
    public var description: String {
      switch self {
      case .openclLibraryNotFound:
        return """
          OpenCL library not found. Set the \(Environment.library.rawValue) \
          environment variable with the path to a Python library.
          """
        
      case .cannotFetchPlatforms:
        return """
          Could not load symbol `clGetPlatformIDs` from the OpenCL library,
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
          The OpenCL library was found, but no OpenCL platforms exist. Ensure
          that an OpenCL driver is installed and visible to the ICD loader.
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
  private static var _openclLibraryHandle: UnsafeMutableRawPointer?
//  private static var openclLibraryHandle: UnsafeMutableRawPointer? {
//    try! OpenCLLibrary.loadLibrary()
//    return self._openclLibraryHandle
//  }
  
  public static func loadLibrary() throws {
    guard !self.isOpenCLLibraryLoaded else {
      return
    }
    let openclLibraryHandle = self.loadOpenCLLibrary()
    guard self.isOpenCLLibraryLoaded(at: openclLibraryHandle) else {
      throw Error.openclLibraryNotFound
    }
    
    // TODO: add a test that the library works.
    // As a test that the opened library works, call
    // `clGetPlatformIDs(...)` and ensure it returns `CL_SUCCESS`. Then, ensure
    // the number of platforms > 0.
    //
    // Can't use the generic loadSymbol
    //
    // func platformsAreAvailable() -> Bool
    self.isOpenCLLibraryLoaded = true
    self._openclLibraryHandle = openclLibraryHandle
  }
  
  // Returns `nil` so you can provide a default value.
  internal static func loadSymbol<T>(
    name: StaticString, type: T.Type = T.self
  ) -> T? {
    // Force-inlined.
    _log("Loading symbol '\(name.description)' from the Python library...")
    
    // Did not force-inline `loadLibrary()` because it's so large.
    try! OpenCLLibrary.loadLibrary()
    
    // Force-inlined.
    let symbol = self._loadSymbol(self._openclLibraryHandle, name)
    return unsafeBitCast(symbol, to: T?.self)
  }
}

// Paths to OpenCL binaries across multiple platforms:
// macOS - /System/Library/Frameworks/OpenCL.framework/Versions/A/OpenCL
// Colab - /usr/lib/x86_64-linux-gnu/libOpenCL.so
// Windows - C:\Windows\System32\opencl.dll

// For Ubuntu: $(uname -m)-linux-gnu instead of $(gcc -dumpmachine). It takes
// ~1 second to load the GCC binary, while $(uname -m) returns instantaneously.
// `uname` is even callable C, eliminating the need to spawn a child process.
// Furthermore, GCC may return an incorrect architecture, such as i686 when the
// machine is i386:
// https://askubuntu.com/questions/872457/how-to-determine-the-host-multi-arch-default-folder

extension OpenCLLibrary {
  #if canImport(Darwin)
  // There isn't actually a file named "OpenCL" in "Versions/A". It must be some
  // trick with the library loading mechanism.
  private static var libraryNames = ["OpenCL.framework/Versions/A/OpenCL"]
  private static var librarySearchPaths = ["", "/System/Library/Frameworks/"]
  #elseif canImport(Glibc)
  private static var libraryNames = ["libOpenCL.so"]
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

// TODO: Heavily optimize the library/symbol loading mechanism, fetching stuff
// from the environment only at startup. But optimize after I've debugged this.
// Also provide a mechanism to reset everything during the Swift package tests.
// Can't reset the lazily loaded symbols in "OpenCLSymbols.swift", though.
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
  
  // For use in `loadSymbol<T>(name:type)`.
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
    let openclLibraryHandle = openclLibraryHandle ?? self.defaultLibraryHandle
    return self.loadSymbol(openclLibraryHandle, "clGetPlatformIDs") != nil
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
  // This partially duplicates the functionality of `CLVersion`, but it's a
  // private API.
  private struct OpenCLVersion {
    let major: Int?
    let minor: Int?
    
    static let versionSeparator: Character = "."
    
    init(major: Int?, minor: Int?) {
      precondition(!(major == nil && minor != nil), """
        Error: The OpenCL library minor version cannot be specified without the
        major version.
        """)
      self.major = major
      self.minor = minor
    }
    
    var versionString: String {
      guard let major = major else { return "" }
      var versionString = String(major)
      if let minor = minor {
        versionString += "\(OpenCLVersion.versionSeparator)\(minor)"
      }
      return versionString
    }
  }
}

// Added enum cases for only library, version, and loader logging. The
// environment variable `OPENCL_VERSION` should let you validate the
// automatically detected library version.
extension OpenCLLibrary {
  private enum Environment: String {
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
  @inline(__always)
  private static func _log(_ message: @autoclosure () -> String) {
    guard Environment.loaderLogging.value != nil else {
      return
    }
    fputs(message() + "\n", stderr)
  }
  
  // For use everywhere besides `loadSymbol<T>(name:type)`.
  @inline(never)
  private static func log(_ message: @autoclosure () -> String) {
    self._log(message())
  }
}
