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
  
  @usableFromInline @inline(__always)
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainCommandQueue(object)
  }
  
  @usableFromInline @inline(__always)
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseCommandQueue(object)
  }
  
  public static var `default`: CLCommandQueue? = {
    var error: Int32 = CL_SUCCESS
    guard let context = CLContext.default,
          let device = CLDevice.default else {
      return nil
    }
    return CLCommandQueue(context: context, device: device, properties: [])
  }()
  
  public init?(
    context: CLContext,
    device: CLDevice,
    properties: CLCommandQueueProperties = []
  ) {
    var error: Int32 = CL_SUCCESS
    var object_: cl_command_queue?
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
    var message = "__CREATE_COMMAND_QUEUE_WITH_PROPERTIES_ERR"
    
    if error == CLErrorCode.symbolNotFound.rawValue {
      object_ = clCreateCommandQueue(
        context.clContext, device.clDeviceID, properties.rawValue, &error)
      message = "__CREATE_COMMAND_QUEUE_ERR"
    }
    guard CLError.setCode(error, message) else {
      return nil
    }
    self.init(object_!)
  }
  
  public func flush() throws {
    let error = clFlush(wrapper.object)
    try CLError.throwCode(error, "__FLUSH_ERR")
  }
  
  public func finish() throws {
    let error = clFinish(wrapper.object)
    try CLError.throwCode(error, "__FINISH_ERR")
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
  
  public var size: UInt32? {
    getInfo_Int(CL_QUEUE_SIZE, getInfo)
  }
  
  // OpenCL 2.1
  
  public var deviceDefault: CLDeviceCommandQueue? {
    let name = CL_QUEUE_DEVICE_DEFAULT
    if let queue: CLCommandQueue = getInfo_CLReferenceCountable(name, getInfo) {
      return CLDeviceCommandQueue(_unsafeCommandQueue: queue)
    } else {
      return nil
    }
  }
  
  // OpenCL 3.0
  
  public var propertiesArray: [CLQueueProperty]? {
    getInfo_ArrayOfCLProperty(CL_QUEUE_PROPERTIES_ARRAY, getInfo)
  }
}
