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
  
  // Create a protocol called `CLResource` to encapsulate every possible argument.
  // public mutating func setArgument<T: CLResource>(_:index:)
  // public mutating func setArgument(bytes:count/size:index:)
  
  // Document how this name differs from the C++ bindings.
  // public mutating func setArgumentSVMPointer(_:index:)
  
  // Should these be raw pointers? Or should they be a special kind of object?
  // public mutating func setSVMPointers(_: [UnsafeMutableRawPointer])
  
  // Prepends `set` to the C++ function `enableFineGrainedSystemSVM`. This shows
  // that the argument is the object of the verb `set`. Look at the comment
  // above `CLEvent.setCallback` for more on this naming convention.
  public mutating func setEnableFineGrainedSystemSVM(
    _ svmEnabled: Bool
  ) throws {
    let svmEnabled_: cl_bool = svmEnabled ? 1 : 0
    #if !canImport(Darwin)
    let error = clSetKernelExecInfo(
      wrapper.object, UInt32(CL_KERNEL_EXEC_INFO_SVM_FINE_GRAIN_SYSTEM),
      MemoryLayout.stride(ofValue: svmEnabled_), &svmEnabled_)
    try CLError.throwCode(error)
    #endif
  }
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.1.")
  public func clone() -> CLKernel? {
    var error: Int32 = CL_SUCCESS
    var clKernel: cl_kernel?
    #if !canImport(Darwin)
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
    #else
    // Allow this to compile on macOS.
    return nil
    #endif
  }
}
