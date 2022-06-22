//
//  CLKernel+Properties.swift
//  
//
//  Created by Philip Turner on 6/22/22.
//

import COpenCL

extension CLKernel {
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetKernelInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var functionName: String? {
    getInfo_String(CL_KERNEL_FUNCTION_NAME, getInfo)
  }
  
  public var numArgs: UInt32? {
    getInfo_Int(CL_KERNEL_NUM_ARGS, getInfo)
  }
  
  public var referenceCount: UInt32? {
    getInfo_Int(CL_KERNEL_REFERENCE_COUNT, getInfo)
  }
  
  public var context: CLContext? {
    getInfo_ReferenceCountable(CL_KERNEL_CONTEXT, getInfo)
  }
  
  public var program: CLProgram? {
    getInfo_ReferenceCountable(CL_KERNEL_PROGRAM, getInfo)
  }
  
  // OpenCL 1.2
  
  public var attributes: String? {
    getInfo_String(CL_KERNEL_ATTRIBUTES, getInfo)
  }
}

extension CLKernel {
  @inline(__always)
  private func getArgInfo(index: UInt32) -> GetInfoClosure {
    { clGetKernelArgInfo(wrapper.object, index, $0, $1, $2, $3) }
  }
  
  public func addressQualifier(
    argumentIndex index: UInt32
  ) -> cl_kernel_arg_address_qualifier? {
    getInfo_Int(CL_KERNEL_ARG_ADDRESS_QUALIFIER, getArgInfo(index: index))
  }
  
  public func accessQualifier(
    argumentIndex index: UInt32
  ) -> cl_kernel_arg_access_qualifier? {
    getInfo_Int(CL_KERNEL_ARG_ACCESS_QUALIFIER, getArgInfo(index: index))
  }
  
  public func typeName(
    argumentIndex index: UInt32
  ) -> String? {
    getInfo_String(CL_KERNEL_ARG_TYPE_NAME, getArgInfo(index: index))
  }
  
  public func name(
    argumentIndex index: UInt32
  ) -> String? {
    getInfo_String(CL_KERNEL_ARG_NAME, getArgInfo(index: index))
  }
  
  public func typeQualifier(
    argumentIndex index: UInt32
  ) -> cl_kernel_arg_type_qualifier? {
    getInfo_Int(CL_KERNEL_ARG_TYPE_QUALIFIER, getArgInfo(index: index))
  }
}

extension CLKernel {
  @inline(__always)
  private func getWorkGroupInfo(device: CLDevice) -> GetInfoClosure {
    // `kernel` instead of `wrapper.object` to prevent exceeding 80 spaces.
    { clGetKernelWorkGroupInfo(kernel, device.deviceID, $0, $1, $2, $3) }
  }
  
  public func workGroupSize(device: CLDevice) -> Int? {
    getInfo_Int(CL_KERNEL_WORK_GROUP_SIZE, getWorkGroupInfo(device: device))
  }
}
