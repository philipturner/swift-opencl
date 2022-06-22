//
//  CLRange.swift
//  
//
//  Created by Philip Turner on 6/22/22.
//

import COpenCL

typealias CLSize = SIMD3<Int>

public struct CLRange {
  @usableFromInline
  var storage: SIMD4<Int>
  
  @_transparent
  public init(width: Int) {
    storage = SIMD4(width, 1, 1, 1)
  }
  
  @_transparent
  public init(width: Int, height: Int) {
    storage = SIMD4(width, height, 1, 2)
  }
  
  @_transparent
  public init(width: Int, height: Int, depth: Int) {
    storage = SIMD4(width, height, depth, 3)
  }
  
  @_transparent
  public var dimensions: Int { storage.w }
  
  subscript(index: Int) -> Int {
    @_transparent
    get {
      storage[index]
    }
    @_transparent
    set {
      storage[index] = newValue
    }
  }
  
  // overloads to withUnsafePointer and withUnsafeBytes
}
