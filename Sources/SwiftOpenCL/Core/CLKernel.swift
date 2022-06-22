//
//  CLKernel.swift
//  
//
//  Created by Philip Turner on 6/22/22.
//

import COpenCL

public struct CLKernel: CLReferenceCountable {
  var wrapper: CLReferenceWrapper<Self>
  public var kernel: cl_kernel { wrapper.object }
  
  public init?(_ kernel: cl_kernel, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(kernel, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainKernel(object)
  }
  
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseKernel(object)
  }
  
}
