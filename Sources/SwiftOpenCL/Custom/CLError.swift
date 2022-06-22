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
  init(code: Int32, message: String?) {
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
  
  // TODO: add #file and #line to allow reconstruction of the stack trace
  // Pass #file and #line into getInfo_XXX as well.
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
}
