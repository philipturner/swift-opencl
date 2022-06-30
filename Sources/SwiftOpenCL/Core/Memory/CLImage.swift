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

extension CLImage {
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetImageInfo(memory.clMemory, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var format: CLImageFormat? {
    if let rawValue: UInt64 = getInfo_Int(CL_IMAGE_FORMAT, getInfo) {
      // `CLImageFormat` has a different alignment than `rawValue`, but that
      // should not be an issue because the alignment is smaller (4 < 8).
      return unsafeBitCast(rawValue, to: CLImageFormat.self)
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

// MARK: - CLImageProtocol

public protocol CLImageProtocol: CLMemoryProtocol {
  var image: CLImage { get }
  
  /// Anything conforming to `CLImageProtocol` is a subset of `CLImage`. The
  /// first parameter is unsafe because its type is not checked internally. Use
  /// `init?(image:)` when the type is unknown.
  init(_unsafeImage image: CLImage)
  
//  init?(image: CLImage)
}

extension CLImageProtocol {
  @_transparent
  public var memory: CLMemory { image.memory }
  
  @_transparent
  public init(_unsafeMemory memory: CLMemory) {
    let image = CLImage(_unsafeMemory: memory)
    self.init(_unsafeImage: image)
  }
  
  @inlinable @inline(__always)
  public init?(image: CLImage) {
    self.init(memory: image.memory)
  }
}

// MARK: - Data Structures

// `CLImageFormat` and `CLImageDescriptor` can be safely `unsafeBitCast`ed to
// the C types they replicate.
public struct CLImageFormat {
  public var channelOrder: CLChannelOrder
  public var channelType: CLChannelType
  
  public init(channelOrder: CLChannelOrder, channelType: CLChannelType) {
    self.channelOrder = channelOrder
    self.channelType = channelType
  }
}

// `CLImageDescriptor` doesn't need to be public, so it's okay that the raw
// `clMemory` pointer is part of it.
internal struct CLImageDescriptor {
  var type: CLMemoryObjectType
  var width: Int = 0
  var height: Int = 0
  var depth: Int = 0
  var arraySize: Int = 0
  var rowPitch: Int = 0
  var slicePitch: Int = 0
  var numMipLevels: UInt32 = 0
  var numSamples: UInt32 = 0
  
  // The property `buffer` seems deprecated. I'm not including it because
  // `memory` is more generic.
  var clMemory: cl_mem?
}
