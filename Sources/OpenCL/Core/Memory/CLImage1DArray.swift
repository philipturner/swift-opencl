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
  
  // Rearranging the order of arguments to match order of stored properties in
  // `CLImageDescriptor`. `arraySize` appears just before `rowPitch` in the
  // descriptor struct.
  public init?(
    context: CLContext,
    flags: CLMemoryFlags,
    format: CLImageFormat,
    width: Int,
    arraySize: Int,
    rowPitch: Int,
    hostPointer: UnsafeMutableRawPointer? = nil
  ) {
    var descriptor = CLImageDescriptor(type: .image1DArray)
    descriptor.width = width
    descriptor.arraySize = arraySize
    descriptor.rowPitch = rowPitch
    self.init(
      context: context, flags: flags, format: format, descriptor: &descriptor,
      hostPointer: hostPointer)
  }
}
