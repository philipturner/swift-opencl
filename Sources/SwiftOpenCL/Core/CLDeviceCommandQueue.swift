//
//  CLDeviceCommandQueue.swift
//  
//
//  Created by Philip Turner on 6/26/22.
//

import COpenCL

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public struct CLDeviceCommandQueue {
  public let commandQueue: CLCommandQueue
  
  /// `CLDeviceCommandQueue` is a subset of `CLCommandQueue`. The first
  /// parameter is unsafe because it is not checked internally to ensure it is a
  /// device command queue. You can check it manually by querying
  /// `CLCommandQueue.propertiesArray`.
  @_transparent
  public init(_unsafeCommandQueue commandQueue: CLCommandQueue) {
    self.commandQueue = commandQueue
  }
  
  // Differs from the C++ bindings, which say `updateDefault`. This is just like
  // a property setter, and `setDefault` matches the underlying C function's
  // name.
  public static func setDefault(
    _ queue: CLDeviceCommandQueue,
    context: CLContext,
    device: CLDevice
  ) throws {
    #if !canImport(Darwin)
    let error = clSetDefaultDeviceCommandQueue(
      context.clContext, device.clDeviceID, queue.commandQueue.clCommandQueue)
    try CLError.throwCode(error, "__SET_DEFAULT_DEVICE_COMMAND_QUEUE_ERR")
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
      CLQueueProperty.withUnsafeTemporaryAllocation(properties: [
        .properties: cl_queue_properties(mergedProperties.rawValue),
        .size: cl_queue_properties(queueSize)
      ]) { queueProperties in
        object_ = clCreateCommandQueueWithProperties(
          context.clContext, device.clDeviceID, queueProperties.baseAddress,
          &error)
      }
      #endif
    } else {
      #if !canImport(Darwin)
      CLQueueProperty.withUnsafeTemporaryAllocation(properties: [
        .properties: cl_queue_properties(mergedProperties.rawValue)
      ]) { queueProperties in
        object_ = clCreateCommandQueueWithProperties(
          context.clContext, device.clDeviceID, queueProperties.baseAddress,
          &error)
      }
      #endif
    }
    
    let message = "__CREATE_COMMAND_QUEUE_WITH_PROPERTIES_ERR"
    guard CLError.setCode(error, message),
          let object_ = object_,
          let queue = CLCommandQueue(object_) else {
      return nil
    }
    self.init(_unsafeCommandQueue: queue)
  }
}
