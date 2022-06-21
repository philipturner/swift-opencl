//
//  CLCommandQueue.swift
//  
//
//  Created by Philip Turner on 6/21/22.
//

import COpenCL

public struct CLCommandQueue: CLReferenceCountable {
  var wrapper: CLReferenceWrapper<Self>
  public var commandQueue: cl_command_queue { wrapper.object }
  
  // Force-inline this internally, but not externally.
  public init?(_ commandQueue: cl_command_queue, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(commandQueue, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainCommandQueue(object)
  }
  
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
    properties: cl_command_queue_properties
  ) {
    var error: Int32 = 0
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
    
    var object_: cl_command_queue?
    if useWithProperties {
      // On Apple platforms, `cl_queue_properties` is `Int`. Everywhere else, it
      // is `UInt64`.
      #if canImport(Darwin)
      typealias cl_queue_properties = cl_queue_properties_APPLE
      #endif
      withUnsafeTemporaryAllocation(
        of: cl_queue_properties.self, capacity: 3
      ) { queue_properties in
        queue_properties[0] = cl_queue_properties(CL_QUEUE_PROPERTIES)
        queue_properties[1] = cl_queue_properties(properties)
        queue_properties[2] = 0
        #if canImport(Darwin)
        let CL_QUEUE_ON_DEVICE: Int32 = 1 << 2
        #endif
        if properties & UInt64(CL_QUEUE_ON_DEVICE) == 0 {
          #if canImport(Darwin)
          let clCreateCommandQueueWithProperties =
            clCreateCommandQueueWithPropertiesAPPLE
          #endif
          object_ = clCreateCommandQueueWithProperties(
            context.context, device.deviceID, queue_properties.baseAddress,
            &error)
        } else {
          error = CL_INVALID_QUEUE_PROPERTIES
        }
      }
      let message = "__CREATE_COMMAND_QUEUE_WITH_PROPERTIES_ERR"
      guard CLError.handleCode(error, message) else {
        return nil
      }
    } else {
      #if !canImport(Darwin)
      object_ = clCreateCommandQueue(
        context.context, device.deviceID, properties, &error)
      let message = "__CREATE_COMMAND_QUEUE_ERR"
      guard CLError.handleCode(error, message) else {
        return nil
      }
      #endif
    }
    guard let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
}

extension CLCommandQueue {
  
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetCommandQueueInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var context: CLContext? {
    getInfo_ReferenceCountable(CL_QUEUE_CONTEXT, getInfo)
  }
  
  public var device: CLDevice? {
    getInfo_ReferenceCountable(CL_QUEUE_DEVICE, getInfo)
  }
  
  public var referenceCount: UInt32? {
    getInfo_Int(CL_QUEUE_REFERENCE_COUNT, getInfo)
  }
  
  public var properties: cl_command_queue_properties? {
    getInfo_Int(CL_QUEUE_PROPERTIES, getInfo)
  }
  
}
