//
//  CLSampler.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

public struct CLSampler: CLReferenceCountable {
  @usableFromInline
  var wrapper: CLReferenceWrapper<Self>
  
  @_transparent
  public var clSampler: cl_sampler { wrapper.object }
  
  @inline(__always) // Force-inline this internally, but not externally.
  public init?(_ clSampler: cl_sampler, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(clSampler, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  @usableFromInline
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainSampler(object)
  }
  
  @usableFromInline
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseSampler(object)
  }
}
