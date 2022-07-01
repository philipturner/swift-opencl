//
//  CLImage1D.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

public struct CLImage1D: CLImageProtocol {
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
    guard type == .image1D else {
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
    hostPointer: UnsafeMutableRawPointer? = nil
  ) {
    var descriptor = CLImageDescriptor(type: .image1D)
    descriptor.width = width
    self.init(
      context: context, flags: flags, format: format, descriptor: &descriptor,
      hostPointer: hostPointer)
  }
}
