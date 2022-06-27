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
  public var clContext: cl_context { wrapper.object }
  
  @inline(__always) // Force-inline this internally, but not externally.
  public init?(_ clContext: cl_context, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(clContext, retain) else {
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
    // There is no documentation about why the C++ bindings don't set the
    // platform on macOS. So I am setting it, then seeing if it breaks.
    var error: Int32 = CL_SUCCESS
    guard let p = CLPlatform.defaultPlatform else {
      return nil
    }
    let defaultPlatformID = p.clPlatformID
    
    var object_: cl_context?
    object_ = CLContextProperties.withUnsafeTemporaryAllocation(properties: [
      .platform: cl_context_properties(bitPattern: defaultPlatformID)
    ]) { properties in
      clCreateContextFromType(
        properties.baseAddress, CLDeviceType.`default`.rawValue, nil, nil,
        &error)
    }
    guard CLError.setCode(error),
          let object_ = object_ else {
      return nil
    }
    return CLContext(object_)
  }()
  
  public init?(
    devices: [CLDevice],
    properties: [CLContextProperties]? = nil,
    notify: CLContextCallback.FunctionPointer? = nil
  ) {
    var error: Int32 = CL_SUCCESS
    let numDevices = devices.count
    let clDeviceIDs: [cl_device_id?] = devices.map(\.clDeviceID)
    
    let callback = CLContextCallback(notify)
    var object_: cl_context?
    object_ = CLContextProperties.withUnsafeTemporaryAllocation(
      properties: properties
    ) { properties in
      clCreateContext(
        properties.baseAddress, UInt32(numDevices), clDeviceIDs,
        callback.callback, callback.passRetained(), &error)
    }
    guard CLError.setCode(error),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  public init?(
    device: CLDevice,
    properties: [CLContextProperties]? = nil,
    notify: CLContextCallback.FunctionPointer? = nil
  ) {
    var error: Int32 = CL_SUCCESS
    var clDeviceID: cl_device_id? = device.clDeviceID
    
    let callback = CLContextCallback(notify)
    let object_: cl_context?
    object_ = CLContextProperties.withUnsafeTemporaryAllocation(
      properties: properties
    ) { properties in
      clCreateContext(
        properties.baseAddress, 1, &clDeviceID, callback.callback,
        callback.passRetained(), &error)
    }
    guard CLError.setCode(error),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  public init?(
    type: CLDeviceType,
    properties: [CLContextProperties]? = nil,
    notify: CLContextCallback.FunctionPointer? = nil
  ) {
    // There is no documentation about why the C++ bindings don't set the
    // platform on macOS. So I am setting it, then seeing if it breaks.
    var error: Int32 = CL_SUCCESS
    
    // Redefine the local variable `properties`.
    let inputProperties = properties
    var properties = inputProperties ?? [CLContextProperties](
      unsafeUninitializedCapacity: 1, initializingWith: { _, _ in })
    
    // Get a valid platform ID as we cannot send in a blank one.
    if !properties.contains(where: {
      if case .platform = $0 {
        return true
      }
      return false
    }) {
      
      var selectedPlatform: CLPlatform?
      guard let availablePlatforms = CLPlatform.availablePlatforms else {
        return nil
      }
      for platform in availablePlatforms {
        guard let numDevices = platform.numDevices(type: type) else {
          return nil
        }
        if numDevices > 0 {
          selectedPlatform = platform
          break
        }
      }
      guard let selectedPlatform = selectedPlatform else {
        CLError.setCode(CL_DEVICE_NOT_FOUND, "__CREATE_CONTEXT_FROM_TYPE_ERR")
        return nil
      }
      properties.append(.platform(selectedPlatform))
    }
    
    let callback = CLContextCallback(notify)
    var object_: cl_context?
    object_ = CLContextProperties.withUnsafeTemporaryAllocation(
      properties: properties
    ) { properties in
      clCreateContextFromType(
        properties.baseAddress, type.rawValue, callback.callback,
        callback.passRetained(), &error)
    }
    guard CLError.setCode(error, "__CREATE_CONTEXT_FROM_TYPE_ERR"),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
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
    getInfo_ArrayOfCLReferenceCountable(CL_CONTEXT_DEVICES, getInfo)
  }
  
  public var properties: [CLContextProperties]? {
    getInfo_ArrayOfCLProperties(CL_CONTEXT_PROPERTIES, getInfo)
  }
  
  // OpenCL 1.1
  
  public var numDevices: UInt32? {
    getInfo_Int(CL_CONTEXT_NUM_DEVICES, getInfo)
  }
}
