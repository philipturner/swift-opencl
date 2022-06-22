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
  
  // OpenCL 1.2
  
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
  // TODO: Go through man.opencl.org and see what parameters are ignored.
  
  @inline(__always)
  private func getWorkGroupInfo(device: CLDevice) -> GetInfoClosure {
    // `kernel` instead of `wrapper.object` to prevent exceeding 80 spaces.
    { clGetKernelWorkGroupInfo(kernel, device.deviceID, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public func workGroupSize(device: CLDevice) -> Int? {
    getInfo_Int(CL_KERNEL_WORK_GROUP_SIZE, getWorkGroupInfo(device: device))
  }
  
  public func compileWorkGroupSize(device: CLDevice) -> CLSize? {
    let name = CL_KERNEL_COMPILE_WORK_GROUP_SIZE
    return getInfo_CLSize(name, getWorkGroupInfo(device: device))
  }
  
  public func localMemSize(device: CLDevice) -> UInt64? {
    getInfo_Int(CL_KERNEL_LOCAL_MEM_SIZE, getWorkGroupInfo(device: device))
  }
  
  // OpenCL 1.1
  
  public func preferredWorkGroupSizeMultiple(device: CLDevice) -> Int? {
    let name = CL_KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE
    return getInfo_Int(name, getWorkGroupInfo(device: device))
  }
  
  public func privateMemSize(device: CLDevice) -> UInt64? {
    getInfo_Int(CL_KERNEL_PRIVATE_MEM_SIZE, getWorkGroupInfo(device: device))
  }
  
  // OpenCL 1.2
  
  public func globalWorkSize(device: CLDevice) -> CLSize? {
    getInfo_CLSize(CL_KERNEL_GLOBAL_WORK_SIZE, getWorkGroupInfo(device: device))
  }
}

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.1.")
extension CLKernel {
  private func getSubGroupInfo(
    device: CLDevice,
    range: CLRange
  ) -> GetInfoClosure {
    { name, valueSize, value, returnValue in
      // `withUnsafeBytes` uses a raw pointer instead of a pointer to `Int`,
      // meaning `bufferPointer.count` equals the memory block's size in bytes.
      return range.withUnsafeBytes { bufferPointer -> Int32 in
        #if !canImport(Darwin)
        clGetKernelSubGroupInfo(
          wrapper.object, device.deviceID, name, bufferPointer.count,
          bufferPointer.baseAddress, valueSize, value, returnValue)
        #else
        fatalError("macOS does not support OpenCL 2.1.")
        #endif
      }
    }
  }
  
  // OpenCL 2.1
  
  public func maxSubGroupSize(device: CLDevice, range: CLRange) -> Int? {
    let CL_KERNEL_MAX_SUB_GROUP_SIZE_FOR_NDRANGE: Int32 = 0x2033
    let getInfo = getSubGroupInfo(device: device, range: range)
    return getInfo_Int(CL_KERNEL_MAX_SUB_GROUP_SIZE_FOR_NDRANGE, getInfo)
  }
  
  public func subGroupCount(device: CLDevice, range: CLRange) -> Int? {
    let CL_KERNEL_SUB_GROUP_COUNT_FOR_NDRANGE: Int32 = 0x2034
    let getInfo = getSubGroupInfo(device: device, range: range)
    return getInfo_Int(CL_KERNEL_SUB_GROUP_COUNT_FOR_NDRANGE, getInfo)
  }
  
  public func localSize(device: CLDevice, subGroupCount: Int) -> CLSize? {
    let CL_KERNEL_LOCAL_SIZE_FOR_SUB_GROUP_COUNT: Int32 = 0x11B8
    let range = CLRange(width: subGroupCount)
    let getInfo = getSubGroupInfo(device: device, range: range)
    return getInfo_CLSize(CL_KERNEL_LOCAL_SIZE_FOR_SUB_GROUP_COUNT, getInfo)
  }
  
  public func maxNumSubGroups(device: CLDevice) -> Int? {
    let CL_KERNEL_MAX_NUM_SUB_GROUPS: Int32 = 0x11B9
    let getInfo = getSubGroupInfo(device: device, range: .zero)
    return getInfo_Int(CL_KERNEL_MAX_NUM_SUB_GROUPS, getInfo)
  }
  
  public func compileNumSubGroups(device: CLDevice) -> Int? {
    let CL_KERNEL_COMPILE_NUM_SUB_GROUPS: Int32 = 0x11BA
    let getInfo = getSubGroupInfo(device: device, range: .zero)
    return getInfo_Int(CL_KERNEL_COMPILE_NUM_SUB_GROUPS, getInfo)
  }
}
