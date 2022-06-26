//
//  CLCommandQueue.swift
//  
//
//  Created by Philip Turner on 6/21/22.
//

import COpenCL

public struct CLCommandQueue: CLReferenceCountable {
  @usableFromInline
  var wrapper: CLReferenceWrapper<Self>
  
  @_transparent
  public var commandQueue: cl_command_queue { wrapper.object }
  
  // Force-inline this internally, but not externally.
  public init?(_ commandQueue: cl_command_queue, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(commandQueue, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  @usableFromInline
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainCommandQueue(object)
  }
  
  @usableFromInline
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseCommandQueue(object)
  }
  
  public static var defaultCommandQueue: CLCommandQueue? = {
    // Implementation requires one of the more complex initializers.
    nil
  }()
  
  // TODO: make a way to not duplicate this massive chunk of code that has
  // `withUnsafeTemporaryAllocation`. Then, finish the rest of the initializers.
  
  public init?(
    properties: CLCommandQueueProperties
  ) {
    var error: Int32 = CL_SUCCESS
    guard let context = CLContext.defaultContext else {
      return nil
    }
    guard let device = context.devices?[0] else {
      return nil
    }
    
    var useWithProperties: Bool
    #if canImport(Darwin)
    useWithProperties = true
    #else
    if let version = getVersion(context: context.context) {
      useWithProperties = version.0 >= 2
    } else {
      useWithProperties = false
    }
    #endif
    
    // TODO: Remove support for calling Apple's extension to creating command
    // queues with properties. The older function still allows passing
    // properties in.
    
    var object_: cl_command_queue?
    if useWithProperties {
      // On macOS, `cl_queue_properties` is `Int`. Everywhere else, it is
      // `UInt64`.
      #if canImport(Darwin)
      typealias cl_queue_properties = cl_queue_properties_APPLE
      let CL_QUEUE_ON_DEVICE: Int32 = 1 << 2
      let clCreateCommandQueueWithProperties =
        clCreateCommandQueueWithPropertiesAPPLE
      #endif
      withUnsafeTemporaryAllocation(
        of: cl_queue_properties.self, capacity: 3
      ) { queue_properties in
        queue_properties[0] = cl_queue_properties(CL_QUEUE_PROPERTIES)
        queue_properties[1] = cl_queue_properties(properties.rawValue)
        queue_properties[2] = 0
        
        if properties.rawValue & UInt64(CL_QUEUE_ON_DEVICE) == 0 {
          object_ = clCreateCommandQueueWithProperties(
            context.context, device.deviceID, queue_properties.baseAddress,
            &error)
        } else {
          error = CL_INVALID_QUEUE_PROPERTIES
        }
      }
      let message = "__CREATE_COMMAND_QUEUE_WITH_PROPERTIES_ERR"
      guard CLError.setCode(error, message) else {
        return nil
      }
    } else {
      #if !canImport(Darwin)
      object_ = clCreateCommandQueue(
        context.context, device.deviceID, properties.rawValue, &error)
      let message = "__CREATE_COMMAND_QUEUE_ERR"
      guard CLError.setCode(error, message) else {
        return nil
      }
      #endif
    }
    guard let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  public func flush() throws {
    let error = clFlush(wrapper.object)
    try CLError.throwCode(error, "__FLUSH_ERR")
  }
  
  public func finish() throws {
    let error = clFinish(wrapper.object)
    try CLError.throwCode(error, "__FLUSH_ERR")
  }
}

// Try merging the implementation of this with `CLCommandQueue`. Why does the
// C++ version have two types?
//@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
//class CLDeviceCommandQueue {}

extension CLCommandQueue {
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetCommandQueueInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var context: CLContext? {
    getInfo_CLReferenceCountable(CL_QUEUE_CONTEXT, getInfo)
  }
  
  public var device: CLDevice? {
    getInfo_CLReferenceCountable(CL_QUEUE_DEVICE, getInfo)
  }
  
  public var referenceCount: UInt32? {
    getInfo_Int(CL_QUEUE_REFERENCE_COUNT, getInfo)
  }
  
  public var properties: CLCommandQueueProperties? {
    getInfo_CLMacro(CL_QUEUE_PROPERTIES, getInfo)
  }
  
  // OpenCL 2.0
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public var size: UInt32? {
    let name: Int32 = 0x1094
    #if !canImport(Darwin)
    assert(CL_QUEUE_SIZE == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  // OpenCL 2.1
  
  // Can't create until `CLDeviceCommandQueue` is defined.
//  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.1.")
//  public var deviceDefault: CLDeviceCommandQueue? {}
  
  // OpenCL 3.0
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
  public var propertiesArray: [CLQueueProperties]? {
    let name: Int32 = 0x1094
    #if !canImport(Darwin)
    assert(CL_QUEUE_PROPERTIES_ARRAY == name)
    #endif
    return getInfo_Array(name, getInfo)
  }
}
