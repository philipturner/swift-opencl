//
//  CLErrorCode.swift
//  
//
//  Created by Philip Turner on 6/24/22.
//

import COpenCL

public enum CLErrorCode: Int32 {
  case success = 0
  case deviceNotFound = -1
  case deviceNotAvailable = -2
  case compilerNotAvailable = -3
}
