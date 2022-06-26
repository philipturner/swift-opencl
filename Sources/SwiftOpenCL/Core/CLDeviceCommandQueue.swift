//
//  CLDeviceCommandQueue.swift
//  
//
//  Created by Philip Turner on 6/26/22.
//

import COpenCL

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public struct CLDeviceCommandQueue {
  public var clCommandQueue: CLCommandQueue
  
  /// `CLDeviceCommandQueue` is a subset of `CLCommandQueue`. The first
  /// parameter is unsafe because it is not checked internally to ensure it is a
  /// device command queue. You can check it manually by querying
  /// `CLCommandQueue.propertiesArray`.
  @_transparent
  public init(unsafeCLCommandQueue clCommandQueue: CLCommandQueue) {
    self.clCommandQueue = clCommandQueue
  }
  
  public static func setDefault(
    _ queue: CLDeviceCommandQueue,
    context: CLContext,
    device: CLDevice
  ) throws {
    #if !canImport(Darwin)
    let err = clSetDefaultDeviceCommandQueue(
      context.context, device.deviceID, queue.clCommandQueue.commandQueue)
    try CLError.throwCode(err, "__SET_DEFAULT_DEVICE_COMMAND_QUEUE_ERR")
    #endif
  }
  
  public init?(
    context: CLContext,
    device: CLDevice,
    properties: CLCommandQueueProperties = [],
    size queueSize: UInt32? = nil
  ) {
    var error: Int32 = CL_SUCCESS
    let mergedProperties: CLCommandQueueProperties = [
      .outOfOrderExecutionModeEnable, .onDevice, properties
    ]
    
    var object_: cl_command_queue?
    if let queueSize = queueSize {
      #if !canImport(Darwin)
      withUnsafeTemporaryAllocation(
        of: cl_queue_properties.self, capacity: 5
      ) { queueProperties in
        queueProperties[0] = cl_queue_properties(CL_QUEUE_PROPERTIES)
        queueProperties[1] = cl_queue_properties(mergedProperties.rawValue)
        queueProperties[2] = cl_queue_properties(CL_QUEUE_SIZE)
        queueProperties[3] = cl_queue_properties(queueSize)
        queueProperties[4] = 0
        object_ = clCreateCommandQueueWithProperties(
          context.context, device.deviceID, queueProperties.baseAddress, &error)
      }
      #endif
    } else {
      #if !canImport(Darwin)
      withUnsafeTemporaryAllocation(
        of: cl_queue_properties.self, capacity: 3
      ) { queueProperties in
        queueProperties[0] = cl_queue_properties(CL_QUEUE_PROPERTIES)
        queueProperties[1] = cl_queue_properties(mergedProperties.rawValue)
        queueProperties[2] = 0
        object_ = clCreateCommandQueueWithProperties(
          context.context, device.deviceID, queueProperties.baseAddress, &error)
      }
      #endif
    }
    
    let message = "__CREATE_COMMAND_QUEUE_WITH_PROPERTIES_ERR"
    guard CLError.setCode(error, message),
          let object_ = object_,
          let queue = CLCommandQueue(object_) else {
      return nil
    }
    self.init(unsafeCLCommandQueue: queue)
  }
  
  // The following two initializers differ from the C++ bindings. Instead of
  // fetching `CLDevice.deviceDefault`, they retrieve the device like in
  // `CLCommandQueue.init(properties:)`. This ensures that the regular and
  // device command queues have similar APIs. You can still emulate the behavior
  // of the C++ bindings by manually fetching `CLDevice.deviceDefault`.
  
  @inlinable
  public init?(
    context: CLContext,
    properties: CLCommandQueueProperties = [],
    size queueSize: UInt32? = nil
  ) {
    guard let device = context.devices?[0] else {
      return nil
    }
    self.init(
      context: context, device: device, properties: properties, size: queueSize)
  }
  
  @inlinable
  public init?(
    properties: CLCommandQueueProperties = [],
    size queueSize: UInt32? = nil
  ) {
    guard let context = CLContext.defaultContext,
          let device = context.devices?[0] else {
      return nil
    }
    self.init(
      context: context, device: device, properties: properties, size: queueSize)
  }
}