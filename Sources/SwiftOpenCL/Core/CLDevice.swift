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
  public var deviceID: cl_device_id { wrapper.object }
  
  // Will only retain if OpenCL version is at least 1.2.
  public init?(_ deviceID: cl_device_id, retain: Bool = false) {
    var shouldRetain = false
    if retain {
      let version = getVersion(device: deviceID)
      // Needs OpenCL 1.2 or higher.
      if version.major > 1 || version.minor >= 2 {
        shouldRetain = true
      }
    }
    guard let wrapper = CLReferenceWrapper<Self>(deviceID, shouldRetain) else {
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
  
  // to make `defaultDevice`, I need to first create CLContext.
}
