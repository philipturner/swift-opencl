//
//  SwiftOpenCL.swift
//
//
//  Created by Philip Turner on 4/25/22.
//

import COpenCL

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
    print(platform_id)
    print(ret_num_platforms)
    print(device_id)
    print(ret_num_devices)
    
    var driverVersion: UnsafeMutablePointer<CChar> = .allocate(capacity: 1000)
    var param_value_size_ret: Int = 0
    ret = clGetDeviceInfo(device_id, cl_device_info(CL_DEVICE_EXTENSIONS), 1000, driverVersion, &param_value_size_ret);
    print(ret)
    print(driverVersion)
    
    let hello: UnsafeMutablePointer<CChar> = driverVersion
    print(hello)
    print(hello[0])
    print(String(cString: hello))
//    print(driverVersion!)
//    print(driverVersion![0])
//    print(String(cString: driverVersion!));
  }
}
