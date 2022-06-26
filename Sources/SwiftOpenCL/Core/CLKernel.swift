//
//  CLKernel.swift
//  
//
//  Created by Philip Turner on 6/22/22.
//

import COpenCL

public struct CLKernel: CLReferenceCountable {
  @usableFromInline
  var wrapper: CLReferenceWrapper<Self>
  
  @_transparent
  public var kernel: cl_kernel { wrapper.object }
  
  @inline(__always) // Force-inline this internally, but not externally.
  public init?(_ kernel: cl_kernel, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(kernel, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  @usableFromInline
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainKernel(object)
  }
  
  @usableFromInline
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseKernel(object)
  }
}
