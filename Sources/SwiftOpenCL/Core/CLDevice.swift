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
  
  // Will only retain if OpenCL version is at least 1.2.
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
  
  @usableFromInline
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainDevice(object)
  }
  
  @usableFromInline
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseDevice(object)
  }
  
  public static var defaultDevice: CLDevice? = {
    guard let context = CLContext.defaultContext,
          let device = context.firstDevice else {
      return nil
    }
    return device
  }()
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.1.")
  var currentHostTimer: UInt64? {
    var hostTimestamp: UInt64 = 0
    #if !canImport(Darwin)
    let err = clGetHostTimer(wrapper.object, &hostTimestamp)
    guard CLError.setCode(err, "__GET_HOST_TIMER_ERR") else {
      return nil
    }
    #endif
    return hostTimestamp
  }
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.1.")
  var currentDeviceAndHostTimer: (UInt64, UInt64)? {
    var deviceTimestamp: UInt64 = 0
    var hostTimestamp: UInt64 = 0
    #if !canImport(Darwin)
    let err = clGetDeviceAndHostTimer(
      wrapper.object, &deviceTimestamp, &hostTimestamp)
    guard CLError.setCode(err, "__GET_DEVICE_AND_HOST_TIMER_ERR") else {
      return nil
    }
    #endif
    return (deviceTimestamp, hostTimestamp)
  }
}
