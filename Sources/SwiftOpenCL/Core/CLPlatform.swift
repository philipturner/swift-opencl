//
//  CLPlatform.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL

public struct CLPlatform: CLReferenceCountable {
  @usableFromInline
  var wrapper: CLReferenceWrapper<Self>
  
  @_transparent
  public var clPlatformID: cl_platform_id { wrapper.object }
  
  // Does not retain the platform.
  @inline(__always) // Force-inline this internally, but not externally.
  public init?(_ clPlatformID: cl_platform_id, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(clPlatformID, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  @usableFromInline
  static func retain(_ object: OpaquePointer) -> Int32 {
    return CL_SUCCESS
  }
  
  @usableFromInline
  static func release(_ object: OpaquePointer) -> Int32 {
    return CL_SUCCESS
  }
  
  public static var defaultPlatform: CLPlatform? = {
    var n: UInt32 = 0
    var err = clGetPlatformIDs(0, nil, &n)
    guard CLError.setCode(err) else {
      return nil
    }
    if n == 0 {
      CLError.setCode(CL_INVALID_PLATFORM)
      return nil
    }
    
    return withUnsafeTemporaryAllocation(
      of: cl_platform_id?.self, capacity: Int(n)
    ) { bufferPointer in
      let ids = bufferPointer.baseAddress.unsafelyUnwrapped
      err = clGetPlatformIDs(n, ids, nil)
      guard CLError.setCode(err) else {
        return nil
      }
      return CLPlatform(ids[0]!)
    }
  }()
}

extension CLPlatform {
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetPlatformInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var profile: String? {
    getInfo_String(CL_PLATFORM_PROFILE, getInfo)
  }
  
  public var version: String? {
    getInfo_String(CL_PLATFORM_VERSION, getInfo)
  }
  
  public var name: String? {
    getInfo_String(CL_PLATFORM_NAME, getInfo)
  }
  
  public var vendor: String? {
    getInfo_String(CL_PLATFORM_VENDOR, getInfo)
  }
  
  public var extensions: String? {
    getInfo_String(CL_PLATFORM_EXTENSIONS, getInfo)
  }
  
  // OpenCL 2.1
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.1.")
  public var hostTimerResolution: UInt64? {
    let name: Int32 = 0x0905
    #if !canImport(Darwin)
    assert(CL_PLATFORM_HOST_TIMER_RESOLUTION == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  // OpenCL 3.0
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
  public var numericVersion: CLVersion? {
    let name: Int32 = 0x0906
    #if !canImport(Darwin)
    assert(CL_PLATFORM_NUMERIC_VERSION == name)
    #endif
    if let rawVersion: cl_version = getInfo_Int(name, getInfo) {
      return CLVersion(version: rawVersion)
    } else {
      return nil
    }
  }
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
  public var extensionsWithVersion: [CLNameVersion]? {
    let name: Int32 = 0x0907
    #if !canImport(Darwin)
    assert(CL_PLATFORM_EXTENSIONS_WITH_VERSION == name)
    #endif
    return getInfo_ArrayOfCLNameVersion(name, getInfo)
  }
}

