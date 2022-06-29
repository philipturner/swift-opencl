//
//  CLProgram+Info.swift
//  
//
//  Created by Philip Turner on 6/21/22.
//

import COpenCL
import struct Foundation.Data

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
    getInfo_CLReferenceCountable(CL_PROGRAM_CONTEXT, getInfo)
  }
  
  public var numDevices: UInt32? {
    getInfo_Int(CL_PROGRAM_NUM_DEVICES, getInfo)
  }
  
  public var devices: [CLDevice]? {
    getInfo_ArrayOfCLReferenceCountable(CL_PROGRAM_DEVICES, getInfo)
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
    
    return withUnsafeTemporaryAllocation(
      of: UnsafeMutablePointer<Int8>.self, capacity: numBinaries
    ) { bufferPointer in
      let binariesPointers = bufferPointer.baseAddress.unsafelyUnwrapped
      for i in 0..<numBinaries {
        let size = sizes[i]
        let binaryPointer: UnsafeMutablePointer<Int8> = .allocate(
          capacity: size)
        output.append(
          Data(bytesNoCopy: binaryPointer, count: size, deallocator: .free))
        binariesPointers[i] = binaryPointer
      }
      let err = clGetProgramInfo(
        wrapper.object, UInt32(CL_PROGRAM_BINARIES),
        numBinaries * MemoryLayout<UnsafeMutablePointer<Int8>>.stride,
        binariesPointers, nil)
      guard CLError.setCode(err, "__GET_PROGRAM_INFO_ERR") else {
        return nil
      }
      return output
    }
  }
  
  // OpenCL 1.2
  
  public var numKernels: Int? {
    getInfo_Int(CL_PROGRAM_NUM_KERNELS, getInfo)
  }
  
  // Parses the string returned by OpenCL and creates an array of kernels.
  public var kernelNames: [String]? {
    if let combined = getInfo_String(CL_PROGRAM_KERNEL_NAMES, getInfo) {
      // Separated by semicolons.
      let substrings = combined.split(
        separator: ";", omittingEmptySubsequences: false)
      return substrings.map(String.init)
    } else {
      return nil
    }
  }
  
  // OpenCL 2.1
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.1.")
  public var il: Data? {
    let name: Int32 = 0x1169
    #if !canImport(Darwin)
    assert(CL_PROGRAM_IL == name)
    #endif
    return getInfo_Data(name, getInfo)
  }
  
  // OpenCL 2.2
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.2.")
  public var scopeGlobalConstructorsPresent: Bool? {
    let name: Int32 = 0x116A
    #if !canImport(Darwin)
    assert(CL_PROGRAM_SCOPE_GLOBAL_CTORS_PRESENT == name)
    #endif
    return getInfo_Bool(name, getInfo)
  }
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.2.")
  public var scopeGlobalDestructorsPresent: Bool? {
    let name: Int32 = 0x116B
    #if !canImport(Darwin)
    assert(CL_PROGRAM_SCOPE_GLOBAL_DTORS_PRESENT == name)
    #endif
    return getInfo_Bool(name, getInfo)
  }
}

extension CLProgram {
  @inline(__always)
  private func getBuildInfo(device: CLDevice) -> GetInfoClosure {
    { clGetProgramBuildInfo(wrapper.object, device.clDeviceID, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public func buildStatus(device: CLDevice) -> CLBuildStatus? {
    getInfo_CLMacro(CL_PROGRAM_BUILD_STATUS, getBuildInfo(device: device))
  }
  
  public func buildOptions(device: CLDevice) -> String? {
    getInfo_String(CL_PROGRAM_BUILD_OPTIONS, getBuildInfo(device: device))
  }
  
  public func buildLog(device: CLDevice) -> String? {
    getInfo_String(CL_PROGRAM_BUILD_LOG, getBuildInfo(device: device))
  }
  
  internal func buildLogHasNoErrors() -> Bool {
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
  
  // OpenCL 1.2
  
  public func binaryType(device: CLDevice) -> CLProgramBinaryType? {
    getInfo_CLMacro(CL_PROGRAM_BINARY_TYPE, getBuildInfo(device: device))
  }
  
  // OpenCL 2.0
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public func globalVariableTotalSize(device: CLDevice) -> Int? {
    let name: Int32 = 0x1185
    #if !canImport(Darwin)
    assert(CL_PROGRAM_BUILD_GLOBAL_VARIABLE_TOTAL_SIZE == name)
    #endif
    return getInfo_Int(name, getBuildInfo(device: device))
  }
}
