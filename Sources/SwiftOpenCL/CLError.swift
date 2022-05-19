//
//  File.swift
//
//
//  Created by Philip Turner on 5/16/22.
//

import Foundation
import COpenCL

public struct CLError: LocalizedError {
  public var code: Int32
  public var message: String?
  
  public init(code: Int32, message: String?) {
    self.code = code
    self.message = message
  }
  
  public static var latest: CLError? = nil
  
  @discardableResult
  static func handleCode(_ code: Int32, _ message: String? = nil) -> Bool {
    if code != CL_SUCCESS {
      latest = CLError(code: code, message: message)
      return false
    } else {
      return true
    }
  }
}
