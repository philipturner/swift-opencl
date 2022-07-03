//
//  CLPipe.swift
//  
//
//  Created by Philip Turner on 6/29/22.
//

import COpenCL

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
  
  public init?(
    context: CLContext,
    packetSize: UInt32,
    maxPackets: UInt32
  ) {
    var error: Int32 = CL_SUCCESS
    let flags: CLMemoryFlags = [.readWrite, .hostNoAccess]
    let object_ = clCreatePipe(
      context.clContext, flags.rawValue, packetSize, maxPackets, nil, &error)
    guard CLError.setCode(error, "__CREATE_PIPE_ERR"),
          let object_ = object_,
          let memory = CLMemory(object_) else {
      return nil
    }
    self.init(_unsafeMemory: memory)
  }
}

extension CLPipe {
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetPipeInfo(memory.clMemory, $0, $1, $2, $3) }
  }
  
  // OpenCL 2.0
  
  public var packetSize: UInt32? {
    getInfo_Int(CL_PIPE_PACKET_SIZE, getInfo)
  }
  
  public var maxPackets: UInt32? {
    getInfo_Int(CL_PIPE_MAX_PACKETS, getInfo)
  }
  
  // OpenCL 3.0
  
  public var properties: [CLPipeProperty]? {
    getInfo_ArrayOfCLProperty(CL_PIPE_PROPERTIES, getInfo)
  }
}
