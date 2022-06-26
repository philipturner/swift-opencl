//
//  CLDeviceCommandQueue.swift
//  
//
//  Created by Philip Turner on 6/26/22.
//

import COpenCL

public struct CLDeviceCommandQueue {
  public var clCommandQueue: CLCommandQueue
  
  /// `CLDeviceCommandQueue` is a subset of `CLCommandQueue`. The first
  /// parameter is unsafe because it is not checked internally to ensure it is a
  /// device command queue. You can check it manually by querying
  /// `CLCommandQueue.propertiesArray`.
  public init(unsafeCLCommandQueue clCommandQueue: CLCommandQueue) {
    self.clCommandQueue = clCommandQueue
  }
}
