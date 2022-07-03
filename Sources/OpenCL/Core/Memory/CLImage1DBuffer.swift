//
//  CLImage1DBuffer.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

public struct CLImage1DBuffer: CLImageProtocol {
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
    guard type == .image1DBuffer else {
      CLError.setCode(CLErrorCode.invalidMemoryObject.rawValue)
      return nil
    }
    self.init(_unsafeMemory: memory)
  }
  
  // `flags` defaults to 0 because it should be inherited from `sourceBuffer`.
  // Rearranging the order of arguments to match `CLImage2D`. `sourceBuffer`
  // appears after `format`, while in the C++ bindings it appears after `width`.
  public init?(
    context: CLContext,
    properties: [CLMemoryProperty]? = nil,
    flags: CLMemoryFlags = [],
    format: CLImageFormat,
    sourceBuffer: CLBuffer,
    width: Int
  ) {
    var descriptor = CLImageDescriptor(type: .image1DBuffer)
    descriptor.width = width
    descriptor.clMemory = sourceBuffer.memory.clMemory
    self.init(
      context: context, properties: properties, flags: flags, format: format,
      descriptor: &descriptor, hostPointer: nil)
  }
}
