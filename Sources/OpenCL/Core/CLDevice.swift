//
//  CLDevice.swift
//  
//
//  Created by Philip Turner on 4/26/22.
//

import COpenCL

public struct CLDevice: CLReferenceCountable {
  @usableFromInline
  var wrapper: CLReferenceWrapper<Self>
  
  @_transparent
  public var clDeviceID: cl_device_id { wrapper.object }
  
  // Will only retain if the OpenCL version is at least 1.2.
  public init?(_ clDeviceID: cl_device_id, retain: Bool = false) {
    var shouldRetain = false
    if retain {
      guard let version = CLVersion(clDeviceID: clDeviceID) else {
        return nil
      }
      if version >= .init(major: 1, minor: 2) {
        shouldRetain = true
      }
    }
    let wrapper = CLReferenceWrapper<Self>(clDeviceID, shouldRetain)
    guard let wrapper = wrapper else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  @usableFromInline @inline(__always)
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainDevice(object)
  }
  
  @usableFromInline @inline(__always)
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseDevice(object)
  }
  
  public static var `default`: CLDevice? = {
    guard let context = CLContext.default else {
      return nil
    }
    
    // Manually fetches the devices instead of querying `context.devices`. This
    // skips creating unused object wrappers, each of which invokes
    // `swift_retain` and `clRetainDevice` once. It also skips creating an array
    // that would be quickly discarded.
    //
    // This is similar to what happens inside `CLVersion.init?(clContext:)`. I
    // could share code between the two functions, but choose not to.
    var required = 0
    var error = clGetContextInfo(
      context.clContext, UInt32(CL_CONTEXT_DEVICES), 0, nil, &required)
    guard CLError.setCode(error) else {
      return nil
    }
    guard required > 0 else {
      CLError.setCode(CLErrorCode.deviceNotFound.rawValue)
      return nil
    }
    
    return withUnsafeTemporaryAllocation(
      byteCount: required, alignment: MemoryLayout<cl_device_id?>.alignment
    ) { bufferPointer in
      let value = bufferPointer.getInfoBound(to: cl_device_id?.self)
      error = clGetContextInfo(
        context.clContext, UInt32(CL_CONTEXT_DEVICES), required, value, nil)
      guard CLError.setCode(error),
            let clDeviceID = value[0] else {
        return nil
      }
      
      return CLDevice(clDeviceID, retain: true)
    }
  }()
  
  public var currentHostTimer: UInt64? {
    var hostTimestamp: UInt64 = 0
    let error = clGetHostTimer(wrapper.object, &hostTimestamp)
    guard CLError.setCode(error, "__GET_HOST_TIMER_ERR") else {
      return nil
    }
    return hostTimestamp
  }
  
  public var currentDeviceAndHostTimer: (UInt64, UInt64)? {
    var deviceTimestamp: UInt64 = 0
    var hostTimestamp: UInt64 = 0
    let error = clGetDeviceAndHostTimer(
      wrapper.object, &deviceTimestamp, &hostTimestamp)
    guard CLError.setCode(error, "__GET_DEVICE_AND_HOST_TIMER_ERR") else {
      return nil
    }
    return (deviceTimestamp, hostTimestamp)
  }
  
  // This differs from the C++ bindings, which use the argument label
  // `properties`. Only one property can pass in according to the OpenCL 3.0
  // specification (not explicitly stated, but implied). This code is tailored
  // for that constraint.
  //
  // Instead of naming the argument label `property`, I chose the more
  // descriptive label `partitionType`. This creates an API similar to
  // `CLPlatform.devices(type:)`. No other functions in swift-opencl use an API
  // like `CLPlatform.devices(property:)`, so a label similar to `type` may
  // create a uniform naming convention.
  public func subDevices(
    partitionType: CLDevicePartitionProperty
  ) -> [CLDevice]? {
    CLDevicePartitionProperty.withUnsafeTemporaryAllocation(
      property: partitionType
    ) { bufferPointer in
      let property = bufferPointer.baseAddress.unsafelyUnwrapped
      var numDevices: UInt32 = 0
      var error = clCreateSubDevices(
        wrapper.object, property, 0, nil, &numDevices)
      guard CLError.setCode(error, "__CREATE_SUB_DEVICES_ERR") else {
        return nil
      }
      let elements = Int(numDevices)
      
      return withUnsafeTemporaryAllocation(
        of: cl_device_id?.self, capacity: elements
      ) { bufferPointer in
        let ids = bufferPointer.baseAddress.unsafelyUnwrapped
        error = clCreateSubDevices(
          wrapper.object, property, numDevices, ids, nil)
        guard CLError.setCode(error, "__CREATE_SUB_DEVICES_ERR") else {
          return nil
        }
        
        var output: [CLDevice] = []
        output.reserveCapacity(elements)
        for i in 0..<elements {
          // We do not need to retain because this device is being created by
          // the runtime. For why `CLDevice.init` is force-unwrapped, see the
          // comment in `CLPlatform.availablePlatforms`.
          let device = CLDevice(ids[i]!, retain: false)!
          output.append(device)
        }
        return output
      }
    }
  }
}
