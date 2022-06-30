//
//  CLPipe.swift
//  
//
//  Created by Philip Turner on 6/29/22.
//

import COpenCL

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public struct CLPipe: CLMemoryProtocol {
  public let memory: CLMemory
  
  @_transparent
  public init(_unsafeMemory memory: CLMemory) {
    self.memory = memory
  }
  
  @inlinable
  public init?(memory: CLMemory) {
    guard let type = memory.type else {
      return nil
    }
    guard type == .pipe else {
      CLError.setCode(CLErrorCode.invalidMemoryObject.rawValue)
      return nil
    }
    self.init(_unsafeMemory: memory)
  }
  
  public init?(context: CLContext, packetSize: UInt32, maxPackets: UInt32) {
    var error: Int32 = CL_SUCCESS
    let flags: CLMemoryFlags = [.readWrite, .hostNoAccess]
    
    var object_: cl_mem?
    #if !canImport(Darwin)
    object_ = clCreatePipe(
      context.clContext, flags.rawValue, packetSize, maxPackets, nil, &error)
    #endif
    guard CLError.setCode(error, "__CREATE_PIPE_ERR"),
          let object_ = object_,
          let memory = CLMemory(object_) else {
      return nil
    }
    self.init(_unsafeMemory: memory)
  }
}

// OpenCL 2.0

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
extension CLPipe {
  @inline(__always)
  private var getInfo: GetInfoClosure {
    #if !canImport(Darwin)
    { clGetPipeInfo(memory.clMemory, $0, $1, $2, $3) }
    #else
    // Allow this to compile on macOS.
    fatalError("macOS does not support OpenCL 2.0.")
    #endif
  }
  
  public var packetSize: UInt32? {
    let name: Int32 = 0x1120
    #if !canImport(Darwin)
    assert(CL_PIPE_PACKET_SIZE == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var maxPackets: UInt32? {
    let name: Int32 = 0x1121
    #if !canImport(Darwin)
    assert(CL_PIPE_MAX_PACKETS == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
}

// OpenCL 3.0

@available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
extension CLPipe {
  public var properties: [CLPipeProperty]? {
    let name: Int32 = 0x1122
    #if !canImport(Darwin)
    assert(CL_PIPE_PROPERTIES == name)
    #endif
    return getInfo_ArrayOfCLProperty(name, getInfo)
  }
}
