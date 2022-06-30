//
//  CLImage1DBuffer.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

//public struct CLImage1DBuffer: CLImageProtocol {
//  public let image: CLImage
//
//  @_transparent
//  public init(_unsafeImage image: CLImage) {
//    self.image = image
//  }
//
//  @inlinable
//  public init?(memory: CLMemory) {
//    guard let type = memory.type else {
//      return nil
//    }
//    guard type == .image1DBuffer else {
//      CLError.setCode(CLErrorCode.invalidMemoryObject.rawValue)
//      return nil
//    }
//    self.init(_unsafeMemory: memory)
//  }
//
//  public init(
//    context: CLContext,
//    flags: CLMemoryFlags,
//    format: CLImageFormat,
//    width: Int,
//    height: Int,
//    rowPitch: Int = 0,
//  )
//}
