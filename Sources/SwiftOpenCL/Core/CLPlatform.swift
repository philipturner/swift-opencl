//
//  CLPlatform.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL

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
}
