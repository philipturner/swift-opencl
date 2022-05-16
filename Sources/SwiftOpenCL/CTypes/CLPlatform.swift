//
//  CLPlatform.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL

public class CLPlatform {
  var object_: cl_platform_id? = nil
  
  private static var default_initialized: Bool = false
  private static var default_: CLPlatform? = nil
  private static var default_error_: Int32 = 0
  
  private static func makeDefault() {
    do {
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
      
      
    } catch let e as CLError {
      default_error_ = e.code
    }
  }
  
  init() {}
}
