//
//  Wrapper.swift
//  
//
//  Created by Philip Turner on 4/26/22.
//

import COpenCL

protocol CommonWrapper {
  associatedtype Wrapped
  var object_: Wrapped? { get }
}

// TODO: Refactor this into protocol-oriented programming.
class Wrapper<T> {
  var object_: T?
  
  init() {}
  
  init(_ obj: T?, retainObject: Bool) throws {
    self.object_ = obj
    if (retainObject) {
      try errHandler(retain(), "Retain Object")
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

class CLDeviceWrapper {
  var object_: cl_device_id?
  var referenceCountable_: Bool = false
  
  static func isReferenceCountable(_ device: cl_device_id?) -> Bool {
    if let device = device {
      let version = getVersion(device: device)
      // Needs OpenCL 1.2 or higher
      if version.0 > 1 || version.1 >= 2 {
        return true
      }
    }
    return false
  }
  
  init(_ obj: cl_device_id?, retainObject: Bool) {
    self.object_ = obj
    self.referenceCountable_ = Self.isReferenceCountable(obj)
    if (retainObject) {
      // retain
    }
  }
  
  deinit {
    // release
  }
  
  func get() -> cl_device_id? {
    return object_
  }
  
  // func getInfoHelper
  
  func retain() -> Int32 {
    if object_ != nil && referenceCountable_ {
      // retain
      fatalError()
    } else {
      return CL_SUCCESS
    }
  }
  
  func release() -> Int32 {
    if object_ != nil && referenceCountable_ {
      // release
      fatalError()
    } else {
      return CL_SUCCESS
    }
  }
}

