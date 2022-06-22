//
//  CLReferenceWrapper.swift
//  
//
//  Created by Philip Turner on 4/26/22.
//

import COpenCL

@usableFromInline
protocol CLReferenceCountable {
  init?(_: OpaquePointer, retain: Bool)
  static func retain(_ object: OpaquePointer) -> Int32
  static func release(_ object: OpaquePointer) -> Int32
}

@usableFromInline
class CLReferenceWrapper<T: CLReferenceCountable> {
  @usableFromInline
  var object: OpaquePointer
  
  @usableFromInline
  var shouldRetain: Bool
  
  // Force-inline this.
  init?(_ object: OpaquePointer, _ shouldRetain: Bool) {
    self.object = object
    self.shouldRetain = shouldRetain
    if shouldRetain {
      guard CLError.setCode(T.retain(object), "__RETAIN_ERR") else {
        return nil
      }
    }
  }
  
  deinit {
    if shouldRetain {
      CLError.setCode(T.release(object), "__RELEASE")
    }
  }
}
