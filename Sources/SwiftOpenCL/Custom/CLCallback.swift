//
//  CLCallback.swift
//  
//
//  Created by Philip Turner on 6/26/22.
//

import COpenCL
import struct Foundation.Data

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
    _ errorInfo: String,
    _ privateInfo: Data) -> Void
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
    // The OpenCL 3.0 specification does not explicitly ensure that `errinfo`
    // and `private_info` are never null.
    var errorInfo: String
    if let errinfo = $0 {
      errorInfo = String(cString: errinfo)
    } else {
      errorInfo = ""
    }
    var privateInfo: Data
    if let private_info = $1 {
      privateInfo = Data(bytes: private_info, count: $2)
    } else {
      privateInfo = Data()
    }
    let userInfo = $3
    
    let reconstructedObject = Unmanaged<CLContextCallback>
      .fromOpaque(userInfo!).takeRetainedValue()
    reconstructedObject.functionPointer!(errorInfo, privateInfo)
  }
}

final class CLContextDestructorCallback: CLCallback {
  typealias FunctionPointer = (
    _ context: CLContext) -> Void
  var functionPointer: FunctionPointer?
  init(_ functionPointer: FunctionPointer?) {
    self.functionPointer = functionPointer
  }
  
  static let unwrappedCallback: @convention(c) (
    _ context: cl_context?,
    _ user_info: UnsafeMutableRawPointer?
  ) -> Void = {
    let context = CLContext($0!)!
    let userInfo = $1
    
    let reconstructedObject = Unmanaged<CLContextDestructorCallback>
      .fromOpaque(userInfo!).takeRetainedValue()
    reconstructedObject.functionPointer!(context)
  }
}

final class CLEventCallback: CLCallback {
  typealias FunctionPointer = (
    _ event: CLEvent,
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
    let event = CLEvent($0!)!
    let eventCommandStatus = CLCommandExecutionStatus(rawValue: $1)
    let userInfo = $2
    
    let reconstructedObject = Unmanaged<CLEventCallback>
      .fromOpaque(userInfo!).takeRetainedValue()
    reconstructedObject.functionPointer!(event, eventCommandStatus)
  }
}

final class CLMemoryObjectDestructorCallback: CLCallback {
  typealias FunctionPointer = (
    _ memoryObject: CLMemoryObject) -> Void
  var functionPointer: FunctionPointer?
  init(_ functionPointer: FunctionPointer?) {
    self.functionPointer = functionPointer
  }
  
  static let unwrappedCallback: @convention(c) (
    _ memobj: cl_mem?,
    _ user_info: UnsafeMutableRawPointer?
  ) -> Void = {
    let memoryObject = CLMemoryObject($0!)!
    let userInfo = $1
    
    let reconstructedObject = Unmanaged<CLMemoryObjectDestructorCallback>
      .fromOpaque(userInfo!).takeRetainedValue()
    reconstructedObject.functionPointer!(memoryObject)
  }
}

final class CLProgramCallback: CLCallback {
  typealias FunctionPointer = (
    _ program: CLProgram) -> Void
  var functionPointer: FunctionPointer?
  init(_ functionPointer: FunctionPointer?) {
    self.functionPointer = functionPointer
  }
  
  static let unwrappedCallback: @convention(c) (
    _ program: cl_program?,
    _ user_info: UnsafeMutableRawPointer?
  ) -> Void = {
    let program = CLProgram($0!)!
    let userInfo = $1
    
    let reconstructedObject = Unmanaged<CLProgramCallback>
      .fromOpaque(userInfo!).takeRetainedValue()
    reconstructedObject.functionPointer!(program)
  }
}
