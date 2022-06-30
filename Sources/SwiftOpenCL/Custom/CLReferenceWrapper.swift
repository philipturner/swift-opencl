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
  func retain() -> Bool {
    CLError.setCode(T.retain(object), "__RETAIN_ERR")
  }
  
  @usableFromInline @inline(never)
  func release() -> Bool {
    CLError.setCode(T.release(object), "__RELEASE_ERR")
  }
  
  @inline(__always)
  init?(_ object: OpaquePointer, _ shouldRetain: Bool) {
    self.object = object
    self.shouldRetain = shouldRetain
    if _slowPath(shouldRetain) {
      guard retain() else {
        return nil
      }
    }
  }
  
  // I don't know whether `@inlinable` is required to force-inline `deinit` in
  // a module importing SwiftOpenCL, but I won't risk it.
  @inlinable @inline(__always)
  deinit {
    if _slowPath(shouldRetain) {
      _ = release()
    }
  }
}
