//
//  CLImage3D.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

public struct CLImage3D: CLImageProtocol {
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
    guard type == .image3D else {
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
    depth: Int,
    rowPitch: Int = 0,
    slicePitch: Int = 0,
    hostPointer: UnsafeMutableRawPointer? = nil
  ) {
    var error: Int32 = CL_SUCCESS
    var descriptor = CLImageDescriptor(type: .image3D)
    descriptor.width = width
    descriptor.height = height
    descriptor.depth = depth
    descriptor.rowPitch = rowPitch
    descriptor.slicePitch = slicePitch
    var object_ = Self.getCLMem(
      context: context, properties: properties, flags: flags, format: format,
      descriptor: &descriptor, hostPointer: hostPointer, error: &error)
    
    if error == CLErrorCode.symbolNotFound.rawValue {
      var formatCopy = unsafeBitCast(format, to: cl_image_format.self)
      object_ = clCreateImage3D(
        context.clContext, flags.rawValue, &formatCopy, width, height, depth,
        rowPitch, slicePitch, hostPointer, &error)
    }
    guard CLError.setCode(error),
          let object_ = object_,
          let memory = CLMemory(object_) else {
      return nil
    }
    self.init(_unsafeMemory: memory)
  }
}
