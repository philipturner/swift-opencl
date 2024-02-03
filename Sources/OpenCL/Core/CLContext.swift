//
//  CLContext.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL
import struct Foundation.Data

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
  
  @usableFromInline @inline(__always)
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainContext(object)
  }
  
  @usableFromInline @inline(__always)
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseContext(object)
  }
  
  public static var `default`: CLContext? = {
    // There is no documentation about why the C++ bindings don't set the
    // platform on macOS. So I am setting it, then seeing if it breaks.
    var error: Int32 = CL_SUCCESS
    guard let p = CLPlatform.default else {
      return nil
    }
    let defaultPlatformID = p.clPlatformID
    
    var object_: cl_context?
    CLContextProperty.withUnsafeTemporaryAllocation(properties: [
      .platform: cl_context_properties(bitPattern: defaultPlatformID)
    ]) { properties in
      object_ = clCreateContextFromType(
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
    properties: [CLContextProperty]? = nil,
    notify: ((
      _ errorInfo: String,
      _ privateInfo: Data) -> Void)? = nil
  ) {
    var error: Int32 = CL_SUCCESS
    var object_: cl_context?
    withUnsafeTemporaryAllocation(
      of: cl_device_id?.self, capacity: devices.count
    ) { bufferPointer in
      let clDeviceIDs = bufferPointer.baseAddress.unsafelyUnwrapped
      CLContextProperty.withUnsafeTemporaryAllocation(
        properties: properties
      ) { properties in
        let callback = CLContextCallback(notify)
        object_ = clCreateContext(
          properties.baseAddress, UInt32(devices.count), clDeviceIDs,
          callback.callback, callback.passRetained(), &error)
      }
    }
    guard CLError.setCode(error),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  public init?(
    device: CLDevice,
    properties: [CLContextProperty]? = nil,
    notify: ((
      _ errorInfo: String,
      _ privateInfo: Data) -> Void)? = nil
  ) {
    var error: Int32 = CL_SUCCESS
    var clDeviceID: cl_device_id? = device.clDeviceID
    
    var object_: cl_context?
    CLContextProperty.withUnsafeTemporaryAllocation(
      properties: properties
    ) { properties in
      let callback = CLContextCallback(notify)
      object_ = clCreateContext(
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
    properties: [CLContextProperty]? = nil,
    notify: ((
      _ errorInfo: String,
      _ privateInfo: Data) -> Void)? = nil
  ) {
    // There is no documentation about why the C++ bindings don't set the
    // platform on macOS. So I am setting it, then seeing if it breaks.
    var error: Int32 = CL_SUCCESS
    
    // Redefine the local variable `properties`.
    let inputProperties = properties
    var properties = inputProperties ?? [CLContextProperty](
      unsafeUninitializedCapacity: 1, initializingWith: { _, _ in })
    
    // Get a valid platform ID as we cannot send in a blank one.
    if !properties.contains(where: {
      // Returns true is a platform is in the list.
      if case .platform = $0 {
        return true
      }
      return false
    }) {
      var selectedPlatform: CLPlatform?
      guard let availablePlatforms = CLPlatform.all else {
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
    
    var object_: cl_context?
    CLContextProperty.withUnsafeTemporaryAllocation(
      properties: properties
    ) { properties in
      let callback = CLContextCallback(notify)
      object_ = clCreateContextFromType(
        properties.baseAddress, type.rawValue, callback.callback,
        callback.passRetained(), &error)
    }
    guard CLError.setCode(error, "__CREATE_CONTEXT_FROM_TYPE_ERR"),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  public func supportedImageFormats(
    flags: CLMemoryFlags, type: CLMemoryObjectType
  ) -> [CLImageFormat]? {
    var numEntries: UInt32 = 0
    var error = clGetSupportedImageFormats(
      wrapper.object, flags.rawValue, type.rawValue, 0, nil, &numEntries)
    guard CLError.setCode(error, "__GET_SUPPORTED_IMAGE_FORMATS_ERR") else {
      return nil
    }
    if numEntries == 0 {
      return []
    }
    let elements = Int(numEntries)
    
    let output = Array<CLImageFormat>(
      unsafeUninitializedCapacity: elements
    ) { bufferPointer, initializedCount in
      let rebound = UnsafeMutableRawBufferPointer(bufferPointer)
        .getInfoBound(to: cl_image_format.self)
      error = clGetSupportedImageFormats(
        wrapper.object, flags.rawValue, type.rawValue, numEntries, rebound, nil)
      initializedCount = elements
    }
    guard CLError.setCode(error, "__GET_SUPPORTED_IMAGE_FORMATS_ERR") else {
      return nil
    }
    return output
  }
  
  // This function is not in the C++ bindings. Perhaps because the `cl_context`
  // is no longer valid at this point. Unless there's a reason not to, I will
  // add `clSetContextDestructorCallback` to the bindings.
  //
  // Look at `CLEvent.setCallback` for why `notify` has no argument label.
  public func setDestructorCallback(
    _ notify: @escaping (_ context: CLContext) -> Void
  ) throws {
    let callback = CLContextDestructorCallback(notify)
    let error = clSetContextDestructorCallback(
      wrapper.object, callback.callback, callback.passRetained())
    try CLError.throwCode(error)
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
  
  public var properties: [CLContextProperty]? {
    getInfo_ArrayOfCLProperty(CL_CONTEXT_PROPERTIES, getInfo)
  }
  
  // OpenCL 1.1
  
  public var numDevices: UInt32? {
    getInfo_Int(CL_CONTEXT_NUM_DEVICES, getInfo)
  }
}
