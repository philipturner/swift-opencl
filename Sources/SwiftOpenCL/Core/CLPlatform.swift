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
  public var platformID: cl_platform_id { wrapper.object }
  
  // Document that it never actually retains in DocC.
  public init?(_ platformID: cl_platform_id, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(platformID, retain) else {
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
    
    var ids: UnsafeMutablePointer<cl_platform_id?> = .allocate(capacity: Int(n))
    defer { free(ids) }
    err = clGetPlatformIDs(n, ids, nil)
    guard CLError.setCode(err) else {
      return nil
    }
    
    return CLPlatform(ids[0]!)
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
}

