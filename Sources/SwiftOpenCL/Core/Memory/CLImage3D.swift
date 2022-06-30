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
}
