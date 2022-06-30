//
//  CLImage.swift
//  
//
//  Created by Philip Turner on 6/29/22.
//

import COpenCL

public struct CLImage: CLMemoryProtocol {
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
    guard type.isImage else {
      CLError.setCode(CLErrorCode.invalidMemoryObject.rawValue)
      return nil
    }
    self.init(_unsafeMemory: memory)

  }
}

// Serves no purpose besides organization, ensuring all sub-types conform.
protocol CLImageProtocol: CLMemoryProtocol {
  var image: CLImage { get }
  init?(image: CLImage)
}

public struct CLImageFormat {
  public var channelOrder: CLChannelOrder
  public var channelType: CLChannelType
  
  public init(channelOrder: CLChannelOrder, channelType: CLChannelType) {
    self.channelOrder = channelOrder
    self.channelType = channelType
  }
}

extension CLImage {
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetImageInfo(memory.clMemory, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var format: CLImageFormat? {
    if let rawValue: UInt64 = getInfo_Int(CL_IMAGE_FORMAT, getInfo) {
      let vector = unsafeBitCast(rawValue, to: SIMD2<UInt32>.self)
      guard let channelOrder = CLChannelOrder(rawValue: vector[0]),
            let channelType = CLChannelType(rawValue: vector[1]) else {
        CLError.setCode(CLErrorCode.imageFormatNotSupported.rawValue)
        return nil
      }
      return CLImageFormat(channelOrder: channelOrder, channelType: channelType)
    } else {
      return nil
    }
  }
  
  public var elementSize: Int? {
    getInfo_Int(CL_IMAGE_ELEMENT_SIZE, getInfo)
  }
  
  public var rowPitch: Int? {
    getInfo_Int(CL_IMAGE_ROW_PITCH, getInfo)
  }
  
  public var slicePitch: Int? {
    getInfo_Int(CL_IMAGE_SLICE_PITCH, getInfo)
  }
  
  public var width: Int? {
    getInfo_Int(CL_IMAGE_WIDTH, getInfo)
  }
  
  public var height: Int? {
    getInfo_Int(CL_IMAGE_HEIGHT, getInfo)
  }
  
  public var depth: Int? {
    getInfo_Int(CL_IMAGE_DEPTH, getInfo)
  }
  
  // OpenCL 1.2
  
  public var arraySize: Int? {
    getInfo_Int(CL_IMAGE_ARRAY_SIZE, getInfo)
  }
  
  public var numMipLevels: UInt32? {
    getInfo_Int(CL_IMAGE_NUM_MIP_LEVELS, getInfo)
  }
  
  public var numSamples: UInt32? {
    getInfo_Int(CL_IMAGE_NUM_SAMPLES, getInfo)
  }
}
