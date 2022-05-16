//
//  File.swift
//
//
//  Created by Philip Turner on 5/16/22.
//

import Foundation
import COpenCL

struct CLError: LocalizedError {
  var code: Int32
  var message: String?
  var errorDescription: String? { message }
  
  static func handleCode(_ code: Int32, _ message: String? = nil) throws {
    if code != CL_SUCCESS {
      throw CLError(code: code, message: message)
    }
  }
}
