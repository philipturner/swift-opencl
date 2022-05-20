//
//  CLContext.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL

public struct CLContext: CLReferenceCountable {
  var wrapper: CLReferenceWrapper<Self>
  public var context: cl_context { wrapper.object }

  // Force-inline this internally, but not externally.
  public init?(_ context: cl_context, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(context, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }

  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainContext(object)
  }

  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseContext(object)
  }
  
  public static var defaultContext: CLContext? = {
    #if !canImport(Darwin)
    guard let p = CLPlatform.defaultPlatform else {
      return nil
    }
    let defaultPlatform = p.platformID
    return withUnsafeTemporaryAllocation(
      of: cl_context_properties.self, capacity: 3
    ) { properties in
      properties[0] = Int(CL_CONTEXT_PLATFORM)
      properties[1] = Int(bitPattern: defaultPlatform)
      properties[2] = 0
      return CLContext(
        type: UInt64(CL_DEVICE_TYPE_DEFAULT),
        properties: properties.baseAddress, notifyFptr: nil, data: nil)
    }
    #else
    return CLContext(
      type: UInt64(CL_DEVICE_TYPE_DEFAULT), properties: nil, notifyFptr: nil,
      data: nil)
    #endif
  }()
  
  public init?(
    devices: [CLDevice],
    properties: UnsafeMutablePointer<cl_context_properties>? = nil,
    notifyFptr: (@convention(c) (
      UnsafePointer<Int8>?, UnsafeRawPointer?, Int, UnsafeMutableRawPointer?
    ) -> Void)? = nil,
    data: UnsafeMutableRawPointer? = nil
  ) {
    var error: Int32 = 0
    let numDevices = devices.count
    var deviceIDs: [cl_device_id?] = devices.map(\.deviceID)
    
    let object_ = clCreateContext(
      properties, UInt32(numDevices), &deviceIDs, notifyFptr, data, &error)
    guard CLError.handleCode(error), let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  public init?(
    device: CLDevice,
    properties: UnsafeMutablePointer<cl_context_properties>? = nil,
    notifyFptr: (@convention(c) (
      UnsafePointer<Int8>?, UnsafeRawPointer?, Int, UnsafeMutableRawPointer?
    ) -> Void)? = nil,
    data: UnsafeMutableRawPointer? = nil
  ) {
    var error: Int32 = 0
    var deviceID: cl_device_id? = device.deviceID
    
    let object_ = clCreateContext(
      properties, 1, &deviceID, notifyFptr, data, &error)
    guard CLError.handleCode(error), let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  public init?(
    type: cl_device_type, // Convert this to an Int32 argument.
    properties: UnsafeMutablePointer<cl_context_properties>? = nil,
    notifyFptr: (@convention(c) (
      UnsafePointer<Int8>?, UnsafeRawPointer?, Int, UnsafeMutableRawPointer?
    ) -> Void)? = nil,
    data: UnsafeMutableRawPointer? = nil
  ) {
    // requires CLPlatform.getDevices()
    fatalError()
  }
  
  public var referenceCount: UInt32? {
    getInfo_Int(name: CL_CONTEXT_REFERENCE_COUNT) {
      clGetContextInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var devices: [CLDevice]? {
    getInfo_ArrayReferenceCountable(name: CL_CONTEXT_DEVICES) {
      clGetContextInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var properties: [cl_context_properties]? {
    getInfo_Array(name: CL_CONTEXT_PROPERTIES) {
      clGetContextInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var numDevices: UInt32? {
    getInfo_Int(name: CL_CONTEXT_NUM_DEVICES) {
      clGetContextInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
}
