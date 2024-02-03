//
//  CLBuffer.swift
//  
//
//  Created by Philip Turner on 6/29/22.
//

import COpenCL

public struct CLBuffer: CLMemoryProtocol {
  public let memory: CLMemory
  
  @_transparent
  public init(_unsafeMemory memory: CLMemory) {
    self.memory = memory
  }
  
  @inlinable
  public init?(memory: CLMemory) {
    guard let type = memory.type else {
      return nil
    }
    guard type == .buffer else {
      CLError.setCode(CLErrorCode.invalidMemoryObject.rawValue)
      return nil
    }
    self.init(_unsafeMemory: memory)
  }
  
  public init?(
    context: CLContext,
    properties: [CLMemoryProperty]? = nil,
    flags: CLMemoryFlags,
    size: Int,
    hostPointer: UnsafeMutableRawPointer? = nil
  ) {
    var error: Int32 = CL_SUCCESS
    var object_: cl_mem?
    CLMemoryProperty.withUnsafeTemporaryAllocation(
      properties: properties
    ) { properties in
      object_ = clCreateBufferWithProperties(
        context.clContext, properties.baseAddress, flags.rawValue, size,
        hostPointer, &error)
    }
    var message = "__CREATE_BUFFER_WITH_PROPERTIES_ERR"
    
    if error == CLErrorCode.symbolNotFound.rawValue {
      object_ = clCreateBuffer(
        context.clContext, flags.rawValue, size, hostPointer, &error)
      message = "__CREATE_BUFFER_ERR"
    }
    guard CLError.setCode(error, message),
          let object_ = object_,
          let memory = CLMemory(object_) else {
      return nil
    }
    self.init(_unsafeMemory: memory)
  }
}
