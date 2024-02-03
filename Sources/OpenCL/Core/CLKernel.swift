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
  public var clKernel: cl_kernel { wrapper.object }
  
  @inline(__always) // Force-inline this internally, but not externally.
  public init?(_ clKernel: cl_kernel, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(clKernel, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  @usableFromInline @inline(__always)
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainKernel(object)
  }
  
  @usableFromInline @inline(__always)
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseKernel(object)
  }
  
  // This differs from the C API because putting the actual argument after
  // 'setArgument(' looks more like plain English.
  //
  // To create a null buffer in the OpenCL kernel, enter 'nil' for the memory.
  // This is the same as how null textures are specified in Metal.
  public mutating func setArgument(
    _ memory: CLMemoryProtocol?, index: Int
  ) throws {
    var clMemory: cl_mem?
    if let memory {
      clMemory = memory.memory.clMemory
    }
    
    let error = clSetKernelArg(
      wrapper.object, cl_uint(index), MemoryLayout<OpaquePointer>.stride,
      &clMemory)
    guard CLError.setCode(error, "__SET_KERNEL_ARGS_ERR") else {
      throw CLError.latest!
    }
  }
  
  // Use this function to set local memory: enter a null pointer and only the
  // size of the allocation.
  public mutating func setArgument(
    _ bytes: UnsafeRawPointer?, index: Int, size: Int
  ) throws {
    let error = clSetKernelArg(
      wrapper.object, cl_uint(index), size, bytes)
    guard CLError.setCode(error, "__SET_KERNEL_ARGS_ERR") else {
      throw CLError.latest!
    }
  }
  
  // Prepends `set` to the C++ function `enableFineGrainedSystemSVM`. This shows
  // that the argument is the object of the verb `set`. Look at the comment
  // above `CLEvent.setCallback` for more on this naming convention.
  public mutating func setEnableFineGrainedSystemSVM(
    _ svmEnabled: Bool
  ) throws {
    var svmEnabled_: cl_bool = svmEnabled ? 1 : 0
    let error = clSetKernelExecInfo(
      wrapper.object, UInt32(CL_KERNEL_EXEC_INFO_SVM_FINE_GRAIN_SYSTEM),
      MemoryLayout.stride(ofValue: svmEnabled_), &svmEnabled_)
    try CLError.throwCode(error)
  }
  
  public func clone() -> CLKernel? {
    var error: Int32 = CL_SUCCESS
    var clKernel: cl_kernel?
    clKernel = clCloneKernel(wrapper.object, &error)
    guard CLError.setCode(error, "__CLONE_KERNEL_ERR"),
          let clKernel = clKernel else {
      return nil
    }
    
    // In the C++ bindings, this is not retained. I suspect it's because the
    // kernel is created by the runtime. `CLKernel.init` could be
    // force-unwrapped (see the comment in `CLPlatform.availablePlatforms`), but
    // is not. Doing so would introduce an extra 1-cycle overhead, and the value
    // is cast back to `Optional<CLKernel>` anyway.
    return CLKernel(clKernel)
  }
}

