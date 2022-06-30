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
    flags: CLMemoryFlags,
    format: CLImageFormat,
    width: Int,
    height: Int,
    rowPitch: Int = 0,
    hostPointer: UnsafeMutableRawPointer? = nil
  ) {
    var error: Int32 = CL_SUCCESS
    var useCreateImage = false
    if let version = CLVersion(clContext: context.clContext) {
      useCreateImage = version >= .init(major: 1, minor: 2)
    }
    
    var object_: cl_mem?
    if useCreateImage {
      var descriptor = CLImageDescriptor(type: .image2D)
      descriptor.width = width
      descriptor.height = height
      descriptor.rowPitch = rowPitch
      
      var formatCopy = unsafeBitCast(format, to: cl_image_format.self)
      var descriptorCopy = unsafeBitCast(descriptor, to: cl_image_desc.self)
      object_ = clCreateImage(
        context.clContext, flags.rawValue, &formatCopy, &descriptorCopy,
        hostPointer, &error)
    } else {
      var formatCopy = unsafeBitCast(format, to: cl_image_format.self)
      // Not able to import this in Swift because it was deprecated so long ago.
      // This should be possible once I dynamically load OpenCL symbols.
      #if !canImport(Darwin)
      object_ = clCreateImage2D(
        context.clContext, flags.rawValue, &formatCopy, width, height, rowPitch,
        hostPointer, &error)
      #endif
    }
    
    guard CLError.setCode(error),
          let object_ = object_,
          let memory = CLMemory(object_) else {
      return nil
    }
    self.init(_unsafeMemory: memory)
  }
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public init?(
    context: CLContext,
    format: CLImageFormat,
    sourceBuffer: CLBuffer,
    width: Int,
    height: Int,
    rowPitch: Int = 0
  ) {
    fatalError()
  }
  
  // Renaming the argument label `order` to `channelOrder`.
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public init?(
    context: CLContext,
    order: CLChannelOrder,
    sourceImage: CLImage
  ) {
    fatalError()
  }
}
