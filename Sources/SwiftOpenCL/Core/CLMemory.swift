//
//  CLMemory.swift
//  
//
//  Created by Philip Turner on 6/24/22.
//

import COpenCL

public struct CLMemory: CLReferenceCountable {
  @usableFromInline
  var wrapper: CLReferenceWrapper<Self>
  
  @_transparent
  public var memory: cl_mem { wrapper.object }
  
  public init?(_ memory: cl_mem, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(memory, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  @usableFromInline
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainMemObject(object)
  }
  
  @usableFromInline
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseMemObject(object)
  }
}

extension CLMemory {
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetMemObjectInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var type: CLMemoryObjectType? {
    getInfo_CLMacro(CL_MEM_TYPE, getInfo)
  }
}
