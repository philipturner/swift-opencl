//
//  CLCallback.swift
//  
//
//  Created by Philip Turner on 6/26/22.
//

import COpenCL

protocol CLCallback: AnyObject {
  associatedtype FunctionPointer
  var functionPointer: FunctionPointer? { get }
  init(_ functionPointer: FunctionPointer?)
  
  // Must not be an optional type.
  associatedtype CallbackFunctionPointer
  static var unwrappedCallback: CallbackFunctionPointer { get }
}
extension CLCallback {
  @inline(__always)
  func passRetained() -> UnsafeMutableRawPointer {
    Unmanaged.passRetained(self).toOpaque()
  }
  @inline(__always)
  var callback: CallbackFunctionPointer? {
    if functionPointer != nil {
      return Self.unwrappedCallback
    } else {
      return nil
    }
  }
}

final class CLContextCallback: CLCallback {
  typealias FunctionPointer = (
    _ errinfo: UnsafePointer<Int8>?,
    _ private_info: UnsafeRawPointer?,
    _ cb: Int) -> Void
  var functionPointer: FunctionPointer?
  init(_ functionPointer: FunctionPointer?) {
    self.functionPointer = functionPointer
  }
  
  static let unwrappedCallback: (@convention(c) (
    _ errinfo: UnsafePointer<Int8>?,
    _ private_info: UnsafeRawPointer?,
    _ cb: Int,
    _ user_info: UnsafeMutableRawPointer?
  ) -> Void) = {
    let reconstructedObject = Unmanaged<CLContextCallback>
      .fromOpaque($3!).takeRetainedValue()
    reconstructedObject.functionPointer!($0, $1, $2)
  }
}

final class CLEventCallback: CLCallback {
  typealias FunctionPointer = (
    _ event: cl_event?,
    _ event_command_status: Int32?) -> Void
  var functionPointer: FunctionPointer?
  init(_ functionPointer: FunctionPointer?) {
    self.functionPointer = functionPointer
  }
  
  static let unwrappedCallback: @convention(c) (
    _ event: cl_event?,
    _ event_command_status: Int32,
    _ user_info: UnsafeMutableRawPointer?
  ) -> Void = {
    let reconstructedObject = Unmanaged<CLEventCallback>
      .fromOpaque($2!).takeRetainedValue()
    reconstructedObject.functionPointer!($0, $1)
  }
}

final class CLProgramCallback: CLCallback {
  typealias FunctionPointer = (
    _ program: cl_program?) -> Void
  var functionPointer: FunctionPointer?
  init(_ functionPointer: FunctionPointer?) {
    self.functionPointer = functionPointer
  }
  
  static let unwrappedCallback: @convention(c) (
    _ program: cl_program?,
    _ user_info: UnsafeMutableRawPointer?
  ) -> Void = {
    let reconstructedObject = Unmanaged<CLProgramCallback>
      .fromOpaque($1!).takeRetainedValue()
    reconstructedObject.functionPointer!($0)
  }
}
