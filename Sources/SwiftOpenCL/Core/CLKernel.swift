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
  // mutating func setArgumentSVMPointer(_: UnsafeMutableRawPointer, index: UInt32)
  
  // Create a protocol called `CLResource` to encapsulate every possible argument.
  // mutating func setArgument<T: CLResource>(_:index:)
  // mutating func setArgument(bytes:count/size:index:)
  
  // Should these be raw pointers? Or should they be a special kind of object?
  // mutating func setSVMPointers(_: [UnsafeMutableRawPointer])
  // mutating func setFineGrainedSystemSVM(enabled:)
}
