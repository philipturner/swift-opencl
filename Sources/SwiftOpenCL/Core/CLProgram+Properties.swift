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
    var output: [Data] = []
    output.reserveCapacity(sizes.count)
    let binariesPointers: UnsafeMutablePointer<UnsafeMutablePointer<Int8>> =
      .allocate(capacity: sizes.count)
    
    for i in 0..<sizes.count {
      let size = sizes[i]
      
    }
    
    return nil
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
  
}

extension CLProgram {
  
  //  private var getBuildInfo: GetInfoClosure {
  //    2
  //  }
  
}
