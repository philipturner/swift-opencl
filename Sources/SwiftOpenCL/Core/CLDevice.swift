//
//  CLDevice.swift
//  
//
//  Created by Philip Turner on 4/26/22.
//

import COpenCL

public struct CLDevice: CLReferenceCountable {
  var wrapper: CLReferenceWrapper<Self>
  public var deviceID: cl_device_id { wrapper.object }
  
  // Document what OpenCL version supports `retain` in DocC.
  public init?(_ deviceID: cl_device_id, retain: Bool = false) {
    var shouldRetain = false
    if retain {
      let version = getVersion(device: deviceID)
      // Needs OpenCL 1.2 or higher.
      if version.0 > 1 || version.1 >= 2 {
        shouldRetain = true
      }
    }
    guard let wrapper = CLReferenceWrapper<Self>(deviceID, shouldRetain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainDevice(object)
  }
  
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseDevice(object)
  }
  
  // to make `defaultDevice`, I need to first create CLContext.
  
  public var type: cl_device_type? {
    getInfo_Int(name: CL_DEVICE_TYPE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var vendorID: UInt32? {
    getInfo_Int(name: CL_DEVICE_VENDOR_ID) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxComputeUnits: UInt32? {
    getInfo_Int(name: CL_DEVICE_MAX_COMPUTE_UNITS) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
}
