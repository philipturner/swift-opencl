//
//  CLImage1DArray.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

public struct CLImage1DArray: CLImageProtocol {
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
    guard type == .image1DArray else {
      CLError.setCode(CLErrorCode.invalidMemoryObject.rawValue)
      return nil
    }
    self.init(_unsafeMemory: memory)
  }
  
  // Added a default value of `0` for `rowPitch` and added a new argument
  // `slicePitch` with a default value of `0`. The OpenCL 3.0 specification says
  // an image descriptor's slice pitch has a meaning for:
  // - 1D image arrays
  // - 2D image arrays
  // - 3D images
  public init?(
    context: CLContext,
    properties: [CLMemoryProperty]? = nil,
    flags: CLMemoryFlags,
    format: CLImageFormat,
    arraySize: Int,
    width: Int,
    rowPitch: Int = 0,
    slicePitch: Int = 0,
    hostPointer: UnsafeMutableRawPointer? = nil
  ) {
    var descriptor = CLImageDescriptor(type: .image1DArray)
    descriptor.width = width
    descriptor.arraySize = arraySize
    descriptor.rowPitch = rowPitch
    descriptor.slicePitch = slicePitch
    self.init(
      context: context, properties: properties, flags: flags, format: format,
      descriptor: &descriptor, hostPointer: hostPointer)
  }
}
