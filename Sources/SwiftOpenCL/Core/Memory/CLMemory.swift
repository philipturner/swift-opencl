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
  public var clMemory: cl_mem { wrapper.object }
  
  @inline(__always) // Force-inline this internally, but not externally.
  public init?(_ clMemory: cl_mem, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(clMemory, retain) else {
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
  
  public mutating func setDestructorCallback(
    _ notify: @escaping (_ memory: CLMemory) -> Void
  ) throws {
    let callback = CLMemoryDestructorCallback(notify)
    let error = clSetMemObjectDestructorCallback(
      wrapper.object, callback.callback, callback.passRetained())
    try CLError.throwCode(error, "__SET_MEM_OBJECT_DESTRUCTOR_CALLBACK_ERR")
  }
}

// Serves no purpose besides organization, ensuring all sub-types conform.
protocol CLMemoryProtocol {
  var memory: CLMemory { get }
  
  // TODO: Add comment explaining why this is unsafe.
  init(_unsafeMemory memory: CLMemory)
  
  init?(memory: CLMemory)
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
  
  public var flags: CLMemoryFlags? {
    getInfo_CLMacro(CL_MEM_FLAGS, getInfo)
  }
  
  public var size: Int? {
    getInfo_Int(CL_MEM_SIZE, getInfo)
  }
  
  public var hostPointer: UnsafeMutableRawPointer? {
    if let bitPattern: Int = getInfo_Int(CL_MEM_HOST_PTR, getInfo) {
      return UnsafeMutableRawPointer(bitPattern: bitPattern) as Optional
    } else {
      return nil
    }
  }
  
  public var mapCount: UInt32? {
    getInfo_Int(CL_MEM_MAP_COUNT, getInfo)
  }
  
  public var referenceCount: UInt32? {
    getInfo_Int(CL_MEM_REFERENCE_COUNT, getInfo)
  }
  
  public var context: CLContext? {
    getInfo_CLReferenceCountable(CL_MEM_CONTEXT, getInfo)
  }
  
  // OpenCL 1.1
  
  public var associatedMemoryObject: CLMemory? {
    getInfo_CLReferenceCountable(CL_MEM_ASSOCIATED_MEMOBJECT, getInfo)
  }
  
  public var offset: Int? {
    getInfo_Int(CL_MEM_OFFSET, getInfo)
  }
  
  // OpenCL 2.0
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public var usesSVMPointer: Bool? {
    let name: Int32 = 0x1109
    #if !canImport(Darwin)
    assert(CL_MEM_USES_SVM_POINTER == name)
    #endif
    return getInfo_Bool(name, getInfo)
  }
  
  // OpenCL 3.0
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
  public var properties: [CLMemoryProperty]? {
    let name: Int32 = 0x110A
    #if !canImport(Darwin)
    assert(CL_MEM_PROPERTIES == name)
    #endif
    return getInfo_ArrayOfCLProperty(name, getInfo)
  }
}
