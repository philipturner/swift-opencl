//
//  CLReferenceWrapper.swift
//  
//
//  Created by Philip Turner on 4/26/22.
//

import COpenCL

// replace this with every wrapped type having a class it surrounds with zero
// cost

// a parameter called `retainObject`.
// For `CLDevice`, set that parameter beforehand based on the OpenCL version

//let version = getVersion(device: device)
//// Needs OpenCL 1.2 or higher
//if version.0 > 1 || version.1 >= 2 {
//  retainObject = true
//}

protocol CLReferenceCountable {
  static func retain(_ object: OpaquePointer) -> Int32
  static func release(_ object: OpaquePointer) -> Int32
}

class CLReferenceWrapper<T: CLReferenceCountable> {
  var object: OpaquePointer
  var shouldRetain: Bool
  
  init?(_ object: OpaquePointer, _ shouldRetain: Bool) {
    self.object = object
    self.shouldRetain = shouldRetain
    if shouldRetain {
      guard CLError.handleCode(T.retain(object), "__RETAIN_ERR") else {
        return nil
      }
    }
  }
  
  deinit {
    if shouldRetain {
      CLError.handleCode(T.release(object), "__RELEASE")
    }
  }
}
