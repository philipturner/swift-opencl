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
          let devices = context.devices else {
      return nil
    }
    return devices[0]
  }()
}
