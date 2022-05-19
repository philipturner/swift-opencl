//
//  CLContext.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL

public struct CLContext: CLReferenceCountable {
  var wrapper: CLReferenceWrapper<Self>
  public var context: cl_context { wrapper.object }

  public init?(context: cl_context, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(context, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }

  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainContext(object)
  }

  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseContext(object)
  }  
}
