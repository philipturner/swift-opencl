//
//  CLContext.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL

public class CLContext {
  private static var default_initialized: Bool = false
  private static var default_: CLDevice? = nil
  private static var default_error_: Int32 = 0
  
  // line 2143: declare Device::makeDefault
  // line 3211: implement Device::makeDefault
  private static func makeDefault() {
    
  }
  
  private static func makeDefaultProvided(_ p: CLDevice) {
    default_ = p
  }
}

// TODO: Refactor this into protocol-oriented programming.
class CLContextWrapper<T> {
  var object_: T?
  
  init() {}
  
  init(_ obj: T, retainObject: Bool) {
    if (retainObject) {
      // retain
    }
  }
  
  deinit {
    if object_ != nil {
      // release
    }
  }
  
  func get() -> T? {
    return object_
  }
  
  // func getInfoHelper
  
  func retain() -> Int32 {
    if object_ != nil {
      // retain
      fatalError()
    } else {
      return CL_SUCCESS
    }
  }
  
  func release() -> Int32 {
    if object_ != nil {
      // release
      fatalError()
    } else {
      return CL_SUCCESS
    }
  }
}
