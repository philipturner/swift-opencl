//
//  CLContext.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL

public struct CLContext: CLReferenceCountable {
  @usableFromInline
  var wrapper: CLReferenceWrapper<Self>
  
  @_transparent
  public var context: cl_context { wrapper.object }

  // Force-inline this internally, but not externally.
  public init?(_ context: cl_context, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(context, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }

  @usableFromInline
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainContext(object)
  }

  @usableFromInline
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
      properties[0] = cl_context_properties(CL_CONTEXT_PLATFORM)
      properties[1] = cl_context_properties(bitPattern: defaultPlatform)
      properties[2] = 0
      return CLContext(
        type: UInt64(CL_DEVICE_TYPE_DEFAULT),
        properties: properties.baseAddress, data: nil, notifyFptr: nil)
    }
    #else
    return CLContext(
      type: UInt64(CL_DEVICE_TYPE_DEFAULT), properties: nil, data: nil,
      notifyFptr: nil)
    #endif
  }()
  
  // Convert to a more Swift-friendly function, which uses `CLContextProperties`
  // instead of `cl_context_properties`. Also, change `notifyFptr` to
  // `callback`.
  public init?(
    devices: [CLDevice],
    properties: UnsafePointer<cl_context_properties>? = nil,
    data: UnsafeMutableRawPointer? = nil,
    notifyFptr: (@convention(c) (
      UnsafePointer<Int8>?, UnsafeRawPointer?, Int, UnsafeMutableRawPointer?
    ) -> Void)? = nil
  ) {
    var error: Int32 = CL_SUCCESS
    let numDevices = devices.count
    let deviceIDs: [cl_device_id?] = devices.map(\.deviceID)
    
    let object_ = clCreateContext(
      properties, UInt32(numDevices), deviceIDs, notifyFptr, data, &error)
    guard CLError.setCode(error), let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  public init?(
    device: CLDevice,
    properties: UnsafePointer<cl_context_properties>? = nil,
    data: UnsafeMutableRawPointer? = nil,
    notifyFptr: (@convention(c) (
      UnsafePointer<Int8>?, UnsafeRawPointer?, Int, UnsafeMutableRawPointer?
    ) -> Void)? = nil
  ) {
    var error: Int32 = CL_SUCCESS
    var deviceID: cl_device_id? = device.deviceID
    
    let object_ = clCreateContext(
      properties, 1, &deviceID, notifyFptr, data, &error)
    guard CLError.setCode(error), let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  public init?(
    type: cl_device_type, // Convert this to an Int32 argument.
    properties: UnsafePointer<cl_context_properties>? = nil,
    data: UnsafeMutableRawPointer? = nil,
    notifyFptr: (@convention(c) (
      UnsafePointer<Int8>?, UnsafeRawPointer?, Int, UnsafeMutableRawPointer?
    ) -> Void)? = nil
  ) {
    // requires CLPlatform.getDevices()
    fatalError()
  }
}

extension CLContext {
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetContextInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var referenceCount: UInt32? {
    getInfo_Int(CL_CONTEXT_REFERENCE_COUNT, getInfo)
  }
  
  public var devices: [CLDevice]? {
    getInfo_ArrayOfReferenceCountable(CL_CONTEXT_DEVICES, getInfo)
  }
  
  public var properties: [CLContextProperties]? {
    getInfo_Array(CL_CONTEXT_PROPERTIES, getInfo)
  }
  
  // OpenCL 1.1
  
  public var numDevices: UInt32? {
    getInfo_Int(CL_CONTEXT_NUM_DEVICES, getInfo)
  }
}
