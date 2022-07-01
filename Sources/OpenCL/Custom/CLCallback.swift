//
//  CLCallback.swift
//  
//
//  Created by Philip Turner on 6/26/22.
//

import COpenCL
import struct Foundation.Data

class CLCallbackStorage<T> {
  var functionPointer: T
  init(_ functionPointer: T) {
    self.functionPointer = functionPointer
  }
}

protocol CLCallback {
  associatedtype FunctionPointer
  associatedtype CallbackFunctionPointer
  static var unwrappedCallback: CallbackFunctionPointer { get }
  
  typealias Storage = CLCallbackStorage<FunctionPointer>
  var storage: Storage? { get }
  init(storage: Storage?)
}

extension CLCallback {
  @inline(__always)
  init(_ functionPointer: FunctionPointer?) {
    if _slowPath(functionPointer != nil) {
      self.init(storage: Storage(functionPointer!))
    } else {
      self.init(storage: nil)
    }
  }
  
  @inline(__always)
  func passRetained() -> UnsafeMutableRawPointer? {
    if let storage = storage {
      return Unmanaged.passRetained(storage).toOpaque()
    } else {
      return nil
    }
  }
  
  @inline(__always)
  var callback: CallbackFunctionPointer? {
    if storage != nil {
      return Self.unwrappedCallback
    } else {
      return nil
    }
  }
  
  @inline(__always)
  fileprivate static func extractClosure(
    _ userInfo: UnsafeMutableRawPointer?
  ) -> FunctionPointer {
    let object = Unmanaged<Storage>.fromOpaque(userInfo!).takeRetainedValue()
    return object.functionPointer
  }
}

struct CLContextCallback: CLCallback {
  typealias FunctionPointer = (
    _ errorInfo: String,
    _ privateInfo: Data) -> Void
  var storage: Storage?
  
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
    extractClosure(userInfo)(errorInfo, privateInfo)
  }
}

struct CLContextDestructorCallback: CLCallback {
  typealias FunctionPointer = (
    _ context: CLContext) -> Void
  var storage: Storage?
  
  static let unwrappedCallback: @convention(c) (
    _ context: cl_context?,
    _ user_info: UnsafeMutableRawPointer?
  ) -> Void = {
    let context = CLContext($0!)!
    let userInfo = $1
    extractClosure(userInfo)(context)
  }
}

struct CLEventCallback: CLCallback {
  typealias FunctionPointer = (
    _ event: CLEvent,
    _ eventCommandStatus: CLCommandExecutionStatus) -> Void
  var storage: Storage?
  
  static let unwrappedCallback: @convention(c) (
    _ event: cl_event?,
    _ event_command_status: Int32,
    _ user_info: UnsafeMutableRawPointer?
  ) -> Void = {
    let event = CLEvent($0!)!
    let eventCommandStatus = CLCommandExecutionStatus(rawValue: $1)!
    let userInfo = $2
    extractClosure(userInfo)(event, eventCommandStatus)
  }
}

struct CLMemoryDestructorCallback: CLCallback {
  typealias FunctionPointer = (
    _ memory: CLMemory) -> Void
  var storage: Storage?
  
  static let unwrappedCallback: @convention(c) (
    _ mem: cl_mem?,
    _ user_info: UnsafeMutableRawPointer?
  ) -> Void = {
    let memory = CLMemory($0!)!
    let userInfo = $1
    extractClosure(userInfo)(memory)
  }
}

struct CLProgramCallback: CLCallback {
  typealias FunctionPointer = (
    _ program: CLProgram) -> Void
  var storage: Storage?
  
  static let unwrappedCallback: @convention(c) (
    _ program: cl_program?,
    _ user_info: UnsafeMutableRawPointer?
  ) -> Void = {
    let program = CLProgram($0!)!
    let userInfo = $1
    extractClosure(userInfo)(program)
  }
}
