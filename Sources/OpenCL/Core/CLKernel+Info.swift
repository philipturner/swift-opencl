//
//  CLKernel+Info.swift
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
  
  public var numArguments: UInt32? {
    getInfo_Int(CL_KERNEL_NUM_ARGS, getInfo)
  }
  
  public var referenceCount: UInt32? {
    getInfo_Int(CL_KERNEL_REFERENCE_COUNT, getInfo)
  }
  
  public var context: CLContext? {
    getInfo_CLReferenceCountable(CL_KERNEL_CONTEXT, getInfo)
  }
  
  public var program: CLProgram? {
    getInfo_CLReferenceCountable(CL_KERNEL_PROGRAM, getInfo)
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
  ) -> CLKernelArgumentAddressQualifier? {
    getInfo_CLMacro(CL_KERNEL_ARG_ADDRESS_QUALIFIER, getArgInfo(index: index))
  }
  
  public func accessQualifier(
    argumentIndex index: UInt32
  ) -> CLKernelArgumentAccessQualifier? {
    getInfo_CLMacro(CL_KERNEL_ARG_ACCESS_QUALIFIER, getArgInfo(index: index))
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
  ) -> CLKernelArgumentTypeQualifier? {
    getInfo_CLMacro(CL_KERNEL_ARG_TYPE_QUALIFIER, getArgInfo(index: index))
  }
}

extension CLKernel {
  @inline(__always)
  private func getWorkGroupInfo(device: CLDevice) -> GetInfoClosure {
    // `clKernel` instead of `wrapper.object` to prevent exceeding 80 spaces.
    { clGetKernelWorkGroupInfo(clKernel, device.clDeviceID, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public func workGroupSize(device: CLDevice) -> Int? {
    getInfo_Int(CL_KERNEL_WORK_GROUP_SIZE, getWorkGroupInfo(device: device))
  }
  
  public func compileWorkGroupSize(device: CLDevice) -> CLSize? {
    let name = CL_KERNEL_COMPILE_WORK_GROUP_SIZE
    return getInfo_CLSize(name, getWorkGroupInfo(device: device))
  }
  
  public func localMemorySize(device: CLDevice) -> UInt64? {
    getInfo_Int(CL_KERNEL_LOCAL_MEM_SIZE, getWorkGroupInfo(device: device))
  }
  
  // OpenCL 1.1
  
  public func preferredWorkGroupSizeMultiple(device: CLDevice) -> Int? {
    let name = CL_KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE
    return getInfo_Int(name, getWorkGroupInfo(device: device))
  }
  
  public func privateMemorySize(device: CLDevice) -> UInt64? {
    getInfo_Int(CL_KERNEL_PRIVATE_MEM_SIZE, getWorkGroupInfo(device: device))
  }
  
  // OpenCL 1.2
  
  public func globalWorkSize(device: CLDevice) -> CLSize? {
    getInfo_CLSize(CL_KERNEL_GLOBAL_WORK_SIZE, getWorkGroupInfo(device: device))
  }
}

extension CLKernel {
  private func getSubGroupInfo(
    device: CLDevice,
    range: CLNDRange
  ) -> GetInfoClosure {
    { name, valueSize, value, returnValue in
      // `withUnsafeBytes` uses a raw pointer instead of a pointer to `Int`,
      // meaning `bufferPointer.count` equals the memory block's size in bytes.
      return range.withUnsafeBytes { bufferPointer -> Int32 in
        clGetKernelSubGroupInfo(
          wrapper.object, device.clDeviceID, name, bufferPointer.count,
          bufferPointer.baseAddress, valueSize, value, returnValue)
      }
    }
  }
  
  // OpenCL 2.1
  
  public func maxSubGroupSize(device: CLDevice, range: CLNDRange) -> Int? {
    let getInfo = getSubGroupInfo(device: device, range: range)
    return getInfo_Int(CL_KERNEL_MAX_SUB_GROUP_SIZE_FOR_NDRANGE, getInfo)
  }
  
  public func subGroupCount(device: CLDevice, range: CLNDRange) -> Int? {
    let getInfo = getSubGroupInfo(device: device, range: range)
    return getInfo_Int(CL_KERNEL_SUB_GROUP_COUNT_FOR_NDRANGE, getInfo)
  }
  
  public func localSize(device: CLDevice, subGroupCount: Int) -> CLSize? {
    let range = CLNDRange(width: subGroupCount)
    let getInfo = getSubGroupInfo(device: device, range: range)
    return getInfo_CLSize(CL_KERNEL_LOCAL_SIZE_FOR_SUB_GROUP_COUNT, getInfo)
  }
  
  public func maxNumSubGroups(device: CLDevice) -> Int? {
    let getInfo = getSubGroupInfo(device: device, range: .zero)
    return getInfo_Int(CL_KERNEL_MAX_NUM_SUB_GROUPS, getInfo)
  }
  
  public func compileNumSubGroups(device: CLDevice) -> Int? {
    let getInfo = getSubGroupInfo(device: device, range: .zero)
    return getInfo_Int(CL_KERNEL_COMPILE_NUM_SUB_GROUPS, getInfo)
  }
}
