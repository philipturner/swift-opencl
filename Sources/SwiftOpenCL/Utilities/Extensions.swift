//
//  Extensions.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

extension UnsafeMutableRawBufferPointer {
  // Makes converting temporarily allocated pointers easier in `getInfo_XXX` and
  // related functions.
  @inline(__always)
  func getInfoRebound<T>(to: T.Type) -> UnsafeMutablePointer<T> {
    baseAddress.unsafelyUnwrapped.assumingMemoryBound(to: T.self)
  }
}
