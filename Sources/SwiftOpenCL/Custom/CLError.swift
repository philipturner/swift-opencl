//
//  CLError.swift
//
//
//  Created by Philip Turner on 5/16/22.
//

import Foundation
import COpenCL

public struct CLError: LocalizedError {
  // Use reference counted storage to improve memory safety if SwiftOpenCL ever
  // writes to `CLError.latest` from two threads simultaneously.
  private class Storage {
    var code: Int32
    var message: String?
    
    init(code: Int32, message: String?) {
      self.code = code
      self.message = message
     }
  }
  
  private var storage: Storage
  
  @inline(never)
  public init(code: Int32, message: String?) {
    storage = Storage(code: code, message: message)
  }
  
  var code: Int32 {
    get { storage.code }
    set { storage.code = newValue }
  }
  var message: String? {
    get { storage.message }
    set { storage.message = newValue }
  }
  
  // MARK: - Static Members
  
  public static var latest: CLError? = nil
  
//  // You must manually check `CLError.latest` after every function call if you want to enable error propagation. If every OpenCL function was marked with `throws`, `try!` would lose its semantic meaning and litter your code. As a more ergonomic alternative, `CLError.crashOnError` makes functions crash automatically. You can disable it and manually check `CLError.latest` instead. For properties, initializers, and (most) functions with return values, errors instead propagate via optionals.
//
//  // An alternative to both making every single function `throws` and forcing
//  // the user to fetch `CLError.latest` after every function is called.
//  public static var crashOnError: Bool = true
  
  // TODO: add #file and #line to allow reconstruction of the stack trace
  @inline(__always)
  @discardableResult
  static func setCode(_ code: Int32, _ message: String? = nil) -> Bool {
    if code != CL_SUCCESS {
      latest = CLError(code: code, message: message)
      return false
    } else {
      return true
    }
  }
  
  @inline(__always)
  static func throwCode(_ code: Int32, _ message: String? = nil) throws {
    if code != CL_SUCCESS {
      latest = CLError(code: code, message: message)
      throw latest!
    }
  }
  
//  @inlinable @inline(__always)
//  public static func crashIfErrorExists() {
//    if crashOnError && CLError.latest != nil {
//      crash()
//    }
//  }
//
//  @usableFromInline
//  internal static func crash() -> Never {
//    let error = CLError.latest!
//    fatalError("""
//      Automatically crashing on `CLError`: \(error.localizedDescription)
//      To disable automatic crashing, turn off `CLError.crashOnError`.
//      """)
//  }
}
