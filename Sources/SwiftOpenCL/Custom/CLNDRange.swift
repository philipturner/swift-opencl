//
//  CLNDRange.swift
//  
//
//  Created by Philip Turner on 6/22/22.
//

import COpenCL

// This may change to a dedicated struct.
public typealias CLSize = SIMD3<Int>

public struct CLNDRange {
  @usableFromInline
  var storage: SIMD4<Int>
  
  @usableFromInline
  @_transparent
  internal init() {
    storage = SIMD4(0, 0, 0, 0)
  }
  
  /// Initialized with zero dimensions.
  @_transparent
  public static var zero: Self { .init() }
  
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
  
  public subscript(index: Int) -> Int {
    @_transparent get { storage[index] }
    @_transparent set { storage[index] = newValue }
  }
  
  @inlinable
  public mutating func withUnsafeMutableBytes<R>(
    _ body: (UnsafeMutableRawBufferPointer) throws -> R
  ) rethrows -> R {
    var copy = self
    let output = try withUnsafeMutablePointer(to: &copy) { pointer -> R in
      let buffer = UnsafeMutableRawBufferPointer(
        start: UnsafeMutableRawPointer(pointer),
        count: dimensions)
      return try body(buffer)
    }
    self = copy
    return output
  }
  
  @inlinable
  public func withUnsafeBytes<R>(
    _ body: (UnsafeRawBufferPointer) throws -> R
  ) rethrows -> R {
    return try withUnsafePointer(to: self) { pointer in
      let buffer = UnsafeRawBufferPointer(
        start: UnsafeRawPointer(pointer),
        count: dimensions)
      return try body(buffer)
    }
  }
  
  @inlinable
  public mutating func withUnsafeMutableBufferPointer<R>(
    _ body: (inout UnsafeMutableBufferPointer<Int>) throws -> R
  ) rethrows -> R {
    var copy = self
    let output = try withUnsafeMutablePointer(to: &copy) { pointer -> R in
      let baseAddress = UnsafeMutableRawPointer(mutating: pointer)
      var buffer = UnsafeMutableBufferPointer<Int>(
        start: baseAddress.assumingMemoryBound(to: Int.self),
        count: dimensions)
      return try body(&buffer)
    }
    self = copy
    return output
  }
  
  @inlinable
  public func withUnsafeBufferPointer<R>(
    _ body: (UnsafeBufferPointer<Int>) throws -> R
  ) rethrows -> R {
    return try withUnsafePointer(to: self) { pointer in
      let buffer = UnsafeBufferPointer<Int>(
        start: UnsafeRawPointer(pointer).assumingMemoryBound(to: Int.self),
        count: dimensions)
      return try body(buffer)
    }
  }
}
