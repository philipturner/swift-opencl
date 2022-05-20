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

  public init?(context: cl_context, retain: Bool = false) {
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
  
  static var defaultContext: CLContext? = {
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
//      default_ = Context(
//        CL_DEVICE_TYPE_DEFAULT,
//        properties,
//        NULL,
//        NULL,
//        &default_error_);
      return nil
    }
    #else
//    default_ = Context(
//      CL_DEVICE_TYPE_DEFAULT,
//      properties,
//      NULL,
//      NULL,
//      &default_error_);
    return nil
    #endif
  }()
  
  public init?(
    devices: [CLDevice],
    properties: UnsafeMutablePointer<cl_context_properties>? = nil,
    notifyFptr: ((
      UnsafePointer<Int8>, UnsafeRawPointer, Int, UnsafeMutableRawPointer) -> Void)? = nil,
    data: UnsafeMutableRawPointer? = nil,
    err: UnsafeMutablePointer<Int32>? = nil
  ) {
    fatalError()
  }
}
