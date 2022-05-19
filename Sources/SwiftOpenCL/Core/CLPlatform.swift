//
//  CLPlatform.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL

enum CLPlatformInfo: UInt32 {
  case profile
  case version
  case name
  case vendor
  case extensions
//  case hostTimerResolution
//  case numericVersionKHR
//  case extensionsWithVersionKHR
//  case numericVersion
//  case extensionsWithVersion
  
  var rawValue: UInt32 {
    var output: Int32
    switch self {
    case .profile: output = CL_PLATFORM_PROFILE
    case .version: output = CL_PLATFORM_VERSION
    case .name: output = CL_PLATFORM_NAME
    case .vendor: output = CL_PLATFORM_VENDOR
    case .extensions: output = CL_PLATFORM_EXTENSIONS
    }
    return UInt32(output)
  }
  
  enum ReturnValue {
    case profile(String)
    case version(String)
    case name(String)
    case vendor(String)
    case extensions(String)
  }
}

public class CLPlatform {
  var object_: cl_platform_id? = nil
  
  private static var default_initialized_ = false
  private static var default_ = CLPlatform()
  private static var default_error_: Int32 = 0
  
  private static func makeDefault() {
    var n: UInt32 = 0
    var err = clGetPlatformIDs(0, nil, &n)
    guard err == CL_SUCCESS else {
      default_error_ = err
      return
    }
    guard n > 0 else {
      default_error_ = CL_INVALID_PLATFORM
      return
    }
    
    var ids: [cl_platform_id?] = .init(repeating: nil, count: Int(n))
    err = clGetPlatformIDs(n, &ids, nil)
    guard err == CL_SUCCESS else {
      default_error_ = err
      return
    }
    
    do {
      default_ = try CLPlatform(ids[0])
    } catch {
      default_error_ = (error as! CLError).code
    }
  }
  
  private static func makeDefaultProvided(_ p: CLPlatform) {
    default_ = p
  }
  
  init() {}
  
  init(_ platform: cl_platform_id?, retainObject: Bool = false) throws {
    self.object_ = platform
  }
  
  static func getDefault(
    _ errResult: UnsafeMutablePointer<Int32>? = nil
  ) throws -> CLPlatform {
    callOnce(&default_initialized_, makeDefault())
    try CLError.handleCode(default_error_)
    if let errResult = errResult {
      errResult.pointee = default_error_
    }
    return default_
  }
  
  static func setDefault(_ default_platform: CLPlatform) throws -> CLPlatform {
    callOnce(&default_initialized_, makeDefaultProvided(default_platform))
    try CLError.handleCode(default_error_)
    return default_
  }
  
  func getInfo(_ name: CLPlatformInfo) throws -> CLPlatformInfo.ReturnValue {
    let f = GetInfoFunctor0(f_: clGetPlatformInfo, arg0_: object_)
    var param: String?
    let err = getInfoHelper(f, name.rawValue, &param)
    try CLError.handleCode(err)
    guard let param = param else {
      fatalError("This should never happen.")
    }
    switch name {
    case .profile: return .profile(param)
    case .version: return .version(param)
    case .name: return .name(param)
    case .vendor: return .vendor(param)
    case .extensions: return .extensions(param)
    }
  }
}
