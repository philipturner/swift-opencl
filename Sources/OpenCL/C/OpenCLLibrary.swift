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

// macOS: /System/Library/Frameworks/OpenCL.framework/Versions/A/OpenCL
// Colab: /usr/lib/x86_64-linux-gnu/libOpenCL.so
// Windows: C:\Windows\System32\opencl.dll

// For Ubuntu: $(uname -m)-linux-gnu instead of $(gcc -dumpmachine). It takes
// ~1 second to load the GCC binary, while $(uname -m) returns instantaneously.
// Also, GCC may return an incorrect architecture, such as i686 when the machine
// is i386:
// https://askubuntu.com/questions/872457/how-to-determine-the-host-multi-arch-default-folder

// Based on `PythonLibrary` from PythonKit. This lets the user query whether the
// OpenCL library can be loaded at runtime, and specify the path for loading it.
// All other functionality is internal, just like in PythonKit.
public struct OpenCLLibrary {
  public enum Error: Swift.Error, Equatable, CustomStringConvertible {
    case openclLibraryNotFound
    case noPlatforms
    
    public var description: String {
      switch self {
      case .openclLibraryNotFound:
        return """
          OpenCL library not found. Set the \(Environment.library.key) \
          environment variable with the path to a Python library.
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
      case .noPlatforms:
        return """
          The OpenCL library was found, but no OpenCL platforms exist. Ensure
          that an OpenCL driver is installed and visible to the ICD loader.
          """
      }
    }
  }
  
  // As a test that the opened library works, call
  // `clGetPlatformIDs(...)` and ensure it returns `CL_SUCCESS`. Then, ensure
  // the number of platforms > 0.
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

// Added enum cases for only library, version, and loader logging. The case for
// version might be useful if it can't auto-detect the OpenCL version, or wants
// to validate the auto-detected version.
extension OpenCLLibrary {
  private enum Environment: String {
    private static let keyPrefix = "OPENCL"
    private static let keySeparator = "_"
    
    case library = "LIBRARY"
    case version = "VERSION"
    case loaderLogging = "LOADER_LOGGING"
    
    var key: String {
      Environment.keyPrefix + Environment.keySeparator + rawValue
    }
    
    var value: String? {
      guard let cString = getenv(key) else {
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
      setenv(key, value, 1)
      #elseif os(Windows)
      _putenv_s(key, value)
      #endif
    }
  }
}

extension OpenCLLibrary {
  private static func log(_ message: String) {
    guard Environment.loaderLogging.value != nil else {
      return
    }
    fputs(message + "\n", stderr)
  }
}
