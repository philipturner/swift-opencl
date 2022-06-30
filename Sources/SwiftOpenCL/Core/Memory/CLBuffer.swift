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
  
  // After changing to a dynamic linking mechanism, make `[CLMemoryProperty]` an
  // argument. Do the same for image and pipe objects.
  public init?(
    context: CLContext,
    flags: CLMemoryFlags,
    size: Int,
    hostPointer: UnsafeMutableRawPointer? = nil
  ) {
    var error: Int32 = CL_SUCCESS
    let object_ = clCreateBuffer(
      context.clContext, flags.rawValue, size, hostPointer, &error)
    guard CLError.setCode(error, "__CREATE_BUFFER_ERR"),
          let object_ = object_,
          let memory = CLMemory(object_) else {
      return nil
    }
    self.init(_unsafeMemory: memory)
  }
  
  // Removing the initializer with `IteratorType`. SwiftOpenCL exposes the bare
  // functionality of OpenCL, and does not create new higher-level functions for
  // convenience. The developer must explicitly specify the commands for sharing
  // or copying host memory.
}
