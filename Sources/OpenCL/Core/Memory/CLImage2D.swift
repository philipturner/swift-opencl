//
//  CLImage2D.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

public struct CLImage2D: CLImageProtocol {
  public let image: CLImage
  
  @_transparent
  public init(_unsafeImage image: CLImage) {
    self.image = image
  }
  
  @inlinable
  public init?(memory: CLMemory) {
    guard let type = memory.type else {
      return nil
    }
    guard type == .image2D else {
      CLError.setCode(CLErrorCode.invalidMemoryObject.rawValue)
      return nil
    }
    self.init(_unsafeMemory: memory)
  }
  
  public init?(
    context: CLContext,
    properties: [CLMemoryProperty]? = nil,
    flags: CLMemoryFlags,
    format: CLImageFormat,
    width: Int,
    height: Int,
    rowPitch: Int = 0,
    hostPointer: UnsafeMutableRawPointer? = nil
  ) {
    var error: Int32 = CL_SUCCESS
    var descriptor = CLImageDescriptor(type: .image2D)
    descriptor.width = width
    descriptor.height = height
    descriptor.rowPitch = rowPitch
    var object_ = Self.getCLMem(
      context: context, properties: properties, flags: flags, format: format,
      descriptor: &descriptor, hostPointer: hostPointer, error: &error)
    
    if error == CLErrorCode.symbolNotFound.rawValue {
      var formatCopy = unsafeBitCast(format, to: cl_image_format.self)
      object_ = clCreateImage2D(
        context.clContext, flags.rawValue, &formatCopy, width, height, rowPitch,
        hostPointer, &error)
    }
    guard CLError.setCode(error),
          let object_ = object_,
          let memory = CLMemory(object_) else {
      return nil
    }
    self.init(_unsafeMemory: memory)
  }
  
  // `flags` defaults to 0 because it should be inherited from `sourceBuffer`.
  public init?(
    context: CLContext,
    properties: [CLMemoryProperty]? = nil,
    flags: CLMemoryFlags = [],
    format: CLImageFormat,
    sourceBuffer: CLBuffer,
    width: Int,
    height: Int,
    rowPitch: Int = 0
  ) {
    var descriptor = CLImageDescriptor(type: .image2D)
    descriptor.width = width
    descriptor.height = height
    descriptor.rowPitch = rowPitch
    descriptor.clMemory = sourceBuffer.memory.clMemory
    self.init(
      context: context, properties: properties, flags: flags, format: format,
      descriptor: &descriptor, hostPointer: nil)
  }
  
  // `flags` defaults to 0 because it should be inherited from `sourceImage`.
  // Renaming the argument label `order` to `channelOrder`.
  public init?(
    context: CLContext,
    properties: [CLMemoryProperty]? = nil,
    flags: CLMemoryFlags = [],
    channelOrder: CLChannelOrder,
    sourceImage: CLImage
  ) {
    guard let sourceWidth = sourceImage.width,
          let sourceHeight = sourceImage.height,
          let sourceRowPitch = sourceImage.rowPitch,
          let sourceNumMipLevels = sourceImage.numMipLevels,
          let sourceNumSamples = sourceImage.numSamples,
          var format = sourceImage.format else {
      return nil
    }
    format.channelOrder = channelOrder
    
    var descriptor = CLImageDescriptor(type: .image2D)
    descriptor.width = sourceWidth
    descriptor.height = sourceHeight
    descriptor.rowPitch = sourceRowPitch
    descriptor.numMipLevels = sourceNumMipLevels
    descriptor.numSamples = sourceNumSamples
    descriptor.clMemory = sourceImage.memory.clMemory
    self.init(
      context: context, properties: properties, flags: flags, format: format,
      descriptor: &descriptor, hostPointer: nil)
  }
}
