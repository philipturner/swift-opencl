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

// Minor change to the closure parameters: combining `private_info` and `cb`
// into an `UnsafeRawBufferPointer`. Did not convert `errinfo` to `String` or
// `private_info` to `Data` for performance reasons. Automatically converting
// these to higher-level Swift types might harm developer ergonomics. If the
// user wanted to access the original function inputs with minimal overhead, it
// would be extremely difficult to do so manually.
//
// I am still debating whether to convert these to higher-level Swift types.
// Until there is a compelling reason for a change, the Swift bindings will
// retain the same public API as the C++ bindings.
final class CLContextCallback: CLCallback {
  typealias FunctionPointer = (
    _ errorInfo: UnsafePointer<Int8>?,
    _ privateInfo: UnsafeRawBufferPointer) -> Void
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
    let errorInfo = $0
    let privateInfo = UnsafeRawBufferPointer(start: $1, count: $2)
    let userInfo = $3
    
    let reconstructedObject = Unmanaged<CLContextCallback>
      .fromOpaque(userInfo!).takeRetainedValue()
    reconstructedObject.functionPointer!(errorInfo, privateInfo)
  }
}

final class CLEventCallback: CLCallback {
  typealias FunctionPointer = (
    _ event: cl_event?,
    _ eventCommandStatus: CLCommandExecutionStatus) -> Void
  var functionPointer: FunctionPointer?
  init(_ functionPointer: FunctionPointer?) {
    self.functionPointer = functionPointer
  }
  
  static let unwrappedCallback: @convention(c) (
    _ event: cl_event?,
    _ event_command_status: Int32,
    _ user_info: UnsafeMutableRawPointer?
  ) -> Void = {
    let event = $0
    let eventCommandStatus = CLCommandExecutionStatus(rawValue: $1)
    let userInfo = $2
    
    let reconstructedObject = Unmanaged<CLEventCallback>
      .fromOpaque(userInfo!).takeRetainedValue()
    reconstructedObject.functionPointer!(event, eventCommandStatus)
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
    let program = $0
    let userInfo = $1
    
    let reconstructedObject = Unmanaged<CLProgramCallback>
      .fromOpaque(userInfo!).takeRetainedValue()
    reconstructedObject.functionPointer!(program)
  }
}
