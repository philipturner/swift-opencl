//
//  CLPlatform.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL

public struct CLPlatform: CLReferenceCountable {
  var wrapper: CLReferenceWrapper<Self>
  public var platformID: cl_platform_id { wrapper.object }
  
  // Document that it never actually retains in DocC.
  public init?(_ platformID: cl_platform_id, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(platformID, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  static func retain(_ object: OpaquePointer) -> Int32 { CL_SUCCESS }
  static func release(_ object: OpaquePointer) -> Int32 { CL_SUCCESS }
  
  public static var defaultPlatform: CLPlatform? = {
    var n: UInt32 = 0
    var err = clGetPlatformIDs(0, nil, &n)
    guard CLError.handleCode(err) else {
      return nil
    }
    if n == 0 {
      CLError.handleCode(CL_INVALID_PLATFORM)
      return nil
    }
    
    var ids: UnsafeMutablePointer<cl_platform_id?> = .allocate(capacity: Int(n))
    defer { free(ids) }
    err = clGetPlatformIDs(n, ids, nil)
    guard CLError.handleCode(err) else {
      return nil
    }
    
    return CLPlatform(ids[0]!)
  }()
  
  // OpenCL 1.0
  
  public var profile: String? {
    getInfo_String(name: CL_PLATFORM_PROFILE) {
      clGetPlatformInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var version: String? {
    getInfo_String(name: CL_PLATFORM_VERSION) {
      clGetPlatformInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var name: String? {
    getInfo_String(name: CL_PLATFORM_NAME) {
      clGetPlatformInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var vendor: String? {
    getInfo_String(name: CL_PLATFORM_VENDOR) {
      clGetPlatformInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var extensions: String? {
    getInfo_String(name: CL_PLATFORM_EXTENSIONS) {
      clGetPlatformInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  // TODO: change `CL_PLATFORM_EXTENSIONS`, etc. to its hard-coded number and
  // add additional macros not available on macOS, checking the OpenCL version
  // before accessing them if it doesn't cause a crash. Also note the OpenCL
  // version that supports each one in the DocC documentation
}
