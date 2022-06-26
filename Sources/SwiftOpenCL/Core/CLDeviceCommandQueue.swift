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
  
//  public init?(
//    context: CLContext,
//    device: CLDevice,
//    properties: CLCommandQueueProperties = [],
//    // Should this argument label be renamed to `size`?
//    queueSize: UInt32? = nil
//  )
  
//  public init?(
//    context: CLContext,
//    device: CLDevice,
//    // Should this argument label be renamed to `size`?
//    queueSize: UInt32,
//    properties: CLCommandQueueProperties = []
//  ) {
//    fatalError()
//  }
}
