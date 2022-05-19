//
//  CLDevice.swift
//  
//
//  Created by Philip Turner on 4/26/22.
//

import COpenCL

//public class CLDevice {
//  private static var default_initialized: Bool = false
//  private static var default_: CLDevice? = nil
//  private static var default_error_: Int32 = 0
//
//  // line 2143: declare Device::makeDefault
//  // line 3211: implement Device::makeDefault
//  private static func makeDefault() {
//
//  }
//
//  private static func makeDefaultProvided(_ p: CLDevice) {
//    default_ = p
//  }
//}

public struct CLDevice: CLReferenceCountable {
  var wrapper: CLReferenceWrapper<Self>
  public var id: cl_device_id { wrapper.object }
  
  // in initializer, check OpenCL version of the device before retaining
  public init?(id: cl_device_id, retain: Bool = false) {
    var shouldRetain = false
    if retain {
      let version = getVersion(device: id)
      // Needs OpenCL 1.2 or higher
      if version.0 > 1 || version.1 >= 2 {
        shouldRetain = true
      }
    }
    guard let wrapper = CLReferenceWrapper<Self>(id, shouldRetain) else {
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
}
