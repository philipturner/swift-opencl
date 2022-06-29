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
  
  @usableFromInline
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainKernel(object)
  }
  
  @usableFromInline
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseKernel(object)
  }
  
  // Document how this name differs from the C++ bindings.
  // @available(macOS, unavailable, message: "...")
  // public mutating func setArgumentSVMPointer(_: UnsafeMutableRawPointer, index: UInt32)
  
  // Create a protocol called `CLResource` to encapsulate every possible argument.
  // public mutating func setArgument<T: CLResource>(_:index:)
  // public mutating func setArgument(bytes:count/size:index:)
  
  // Should these be raw pointers? Or should they be a special kind of object?
  // public mutating func setSVMPointers(_: [UnsafeMutableRawPointer])
  // public mutating func setFineGrainedSystemSVM(enabled:)
  
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
