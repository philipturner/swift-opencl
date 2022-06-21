//
//  CLProgram+Properties.swift
//  
//
//  Created by Philip Turner on 6/21/22.
//

import COpenCL
import Foundation

extension CLProgram {
  
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetProgramInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var referenceCount: UInt32? {
    getInfo_Int(CL_PROGRAM_REFERENCE_COUNT, getInfo)
  }
  
  public var context: CLContext? {
    getInfo_ReferenceCountable(CL_PROGRAM_CONTEXT, getInfo)
  }
  
  public var numDevices: UInt32? {
    getInfo_Int(CL_PROGRAM_NUM_DEVICES, getInfo)
  }
  
  public var devices: [CLDevice]? {
    getInfo_ArrayOfReferenceCountable(CL_PROGRAM_DEVICES, getInfo)
  }
  
  public var source: String? {
    getInfo_String(CL_PROGRAM_SOURCE, getInfo)
  }
  
  public var binarySizes: [Int]? {
    getInfo_Array(CL_PROGRAM_BINARY_SIZES, getInfo)
  }
  
  public var binaries: [Data]? {
    guard let sizes = binarySizes else {
      return nil
    }
    let numBinaries = sizes.count
    var output: [Data] = []
    output.reserveCapacity(numBinaries)
    let binariesPointers: UnsafeMutablePointer<UnsafeMutablePointer<Int8>> =
      .allocate(capacity: numBinaries)
    defer { binariesPointers.deallocate() }
    
    for i in 0..<numBinaries {
      let size = sizes[i]
      let binaryPointer: UnsafeMutablePointer<Int8> = .allocate(capacity: size)
      output.append(
        Data(bytesNoCopy: binaryPointer, count: size, deallocator: .free))
      binariesPointers[i] = binaryPointer
    }
    let err = clGetProgramInfo(
      wrapper.object, UInt32(CL_PROGRAM_BINARIES),
      numBinaries * MemoryLayout<UnsafeMutablePointer<Int8>>.stride,
      binariesPointers, nil)
    guard CLError.handleCode(err, "__GET_PROGRAM_INFO_ERR") else {
      return nil
    }
    return output
  }
  
  // OpenCL 1.2
  
  public var numKernels: Int? {
    getInfo_Int(CL_PROGRAM_NUM_KERNELS, getInfo)
  }
  
  public var kernelNames: String? {
    getInfo_String(CL_PROGRAM_KERNEL_NAMES, getInfo)
  }
  
}

extension CLProgram {
  
  @inline(__always)
  fileprivate func getBuildInfo(device: CLDevice) -> GetInfoClosure {
    { clGetProgramBuildInfo(wrapper.object, device.deviceID, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public func buildStatus(device: CLDevice) -> cl_build_status? {
    getInfo_Int(CL_PROGRAM_BUILD_STATUS, getBuildInfo(device: device))
  }
  
  public func buildOptions(device: CLDevice) -> String? {
    getInfo_String(CL_PROGRAM_BUILD_OPTIONS, getBuildInfo(device: device))
  }
  
  public func buildLog(device: CLDevice) -> String? {
    getInfo_String(CL_PROGRAM_BUILD_LOG, getBuildInfo(device: device))
  }
  
  // OpenCL 1.2
  
  public func binaryType(device: CLDevice) -> cl_program_binary_type? {
    getInfo_Int(CL_PROGRAM_BINARY_TYPE, getBuildInfo(device: device))
  }
  
  func buildLogHasError() -> Bool {
    guard let devices = devices else {
      return false
    }
    for device in devices {
      if buildLog(device: device) == nil {
        return false
      }
    }
    return true
  }
  
}
