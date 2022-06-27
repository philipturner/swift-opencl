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
  public var clCommandQueue: cl_command_queue { wrapper.object }
  
  @inline(__always) // Force-inline this internally, but not externally.
  public init?(_ clCommandQueue: cl_command_queue, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(clCommandQueue, retain) else {
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
    var error: Int32 = CL_SUCCESS
    guard let context = CLContext.defaultContext,
          let device = CLDevice.defaultDevice else {
      return nil
    }
    return CLCommandQueue(context: context, device: device, properties: [])
  }()
  
  public init?(
    context: CLContext,
    device: CLDevice,
    properties: CLCommandQueueProperties
  ) {
    var error: Int32 = CL_SUCCESS
    var useWithProperties = false
    #if !canImport(Darwin)
    if let version = CLVersion(clContext: context.clContext) {
      useWithProperties = version.major >= 2
    }
    #endif
    
    var object_: cl_command_queue?
    if useWithProperties {
      #if !canImport(Darwin)
      CLQueueProperty.withUnsafeTemporaryAllocation(properties: [
        .properties: cl_queue_properties(properties.rawValue)
      ]) { queueProperties in
        // To make a queue that's on-device, use `CLDeviceCommandQueue`.
        if properties.contains(.onDevice) {
          error = CL_INVALID_QUEUE_PROPERTIES
        } else {
          object_ = clCreateCommandQueueWithProperties(
            context.clContext, device.clDeviceID, queueProperties.baseAddress,
            &error)
        }
      }
      let message = "__CREATE_COMMAND_QUEUE_WITH_PROPERTIES_ERR"
      guard CLError.setCode(error, message) else {
        return nil
      }
      #endif
    } else {
      object_ = clCreateCommandQueue(
        context.clContext, device.clDeviceID, properties.rawValue, &error)
      let message = "__CREATE_COMMAND_QUEUE_ERR"
      guard CLError.setCode(error, message) else {
        return nil
      }
    }
    self.init(object_!)
  }
  
  @inlinable
  public init?(context: CLContext, properties: CLCommandQueueProperties) {
    guard let device = context.firstDevice else {
      return nil
    }
    self.init(context: context, device: device, properties: properties)
  }
  
  // Does the same thing as calling `init(context:properties)` with the
  // default context.
  @inlinable
  public init?(properties: CLCommandQueueProperties) {
    guard let context = CLContext.defaultContext,
          let device = context.firstDevice else {
      return nil
    }
    
    // Skipping the call to `init(context:properties)` and going straight to
    // `init(context:device:properties)`. This prevents an unnecessary function
    // call.
    self.init(context: context, device: device, properties: properties)
  }
  
  public mutating func flush() throws {
    let error = clFlush(wrapper.object)
    try CLError.throwCode(error, "__FLUSH_ERR")
  }
  
  public mutating func finish() throws {
    let error = clFinish(wrapper.object)
    try CLError.throwCode(error, "__FLUSH_ERR")
  }
}

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
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.1.")
  public var deviceDefault: CLDeviceCommandQueue? {
    let name: Int32 = 0x1095
    #if !canImport(Darwin)
    assert(CL_QUEUE_DEVICE_DEFAULT == name)
    #endif
    if let queue: CLCommandQueue = getInfo_CLReferenceCountable(name, getInfo) {
      return CLDeviceCommandQueue(unsafeCommandQueue: queue)
    } else {
      return nil
    }
  }
  
  // OpenCL 3.0
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
  public var propertiesArray: [CLQueueProperty]? {
    let name: Int32 = 0x1098
    #if !canImport(Darwin)
    assert(CL_QUEUE_PROPERTIES_ARRAY == name)
    #endif
    return getInfo_ArrayOfCLProperty(name, getInfo)
  }
}
