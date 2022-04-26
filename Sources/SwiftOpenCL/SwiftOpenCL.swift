//
//  SwiftOpenCL.swift
//
//
//  Created by Philip Turner on 4/25/22.
//

@_implementationOnly import COpenCL

public struct SwiftOpenCL {
  public private(set) var text = "Hello, World!"

  public init() {
    let some_integer = cl_device_type()
    
    var platform_id: cl_platform_id! = nil
    var device_id: cl_device_id! = nil
    var ret_num_devices: cl_uint = 0
    var ret_num_platforms: cl_uint = 0
    var ret = clGetPlatformIDs(1, &platform_id, &ret_num_platforms);
    ret = clGetDeviceIDs(platform_id, cl_device_type(CL_DEVICE_TYPE_DEFAULT), 1,
      &device_id, &ret_num_devices)
    print(ret)
  }
}
