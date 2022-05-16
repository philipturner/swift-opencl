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
  var errorDescription: String?
}

func errHandler(_ code: Int32, _ message: String?) throws {
  if code != CL_SUCCESS {
    throw CLError(code: code, errorDescription: message)
  }
}
