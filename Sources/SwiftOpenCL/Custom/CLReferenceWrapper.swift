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
final class CLReferenceWrapper<T: CLReferenceCountable> {
  @usableFromInline
  var object: OpaquePointer
  
  @usableFromInline
  var shouldRetain: Bool
  
  @usableFromInline @inline(never)
  func retainReturningSuccess() -> Bool {
    CLError.setCode(T.retain(object), "__RETAIN_ERR")
  }
  
  @inline(__always)
  init?(_ object: OpaquePointer, _ shouldRetain: Bool) {
    self.object = object
    self.shouldRetain = shouldRetain
    if shouldRetain {
      guard retainReturningSuccess() else {
        return nil
      }
    }
  }
  
  @usableFromInline @inline(never)
  func release() {
    CLError.setCode(T.release(object), "__RELEASE_ERR")
  }
  
  // I don't know whether `@inlinable` is required to force-inline `deinit` in
  // a module importing SwiftOpenCL, but I won't risk it.
  @inlinable @inline(__always)
  deinit {
    if shouldRetain {
      release()
    }
  }
}
