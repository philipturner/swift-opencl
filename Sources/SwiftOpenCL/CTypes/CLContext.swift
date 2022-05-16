//
//  CLContext.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL

public class CLContext {
  private static var default_initialized: Bool = false
  private static var default_: CLContext? = nil
  private static var default_error_: Int32 = 0
  
  private static func makeDefault() {
    fatalError("Not implemented")
  }
  
  private static func makeDefaultProvided(_ c: CLContext) {
    default_ = c
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
