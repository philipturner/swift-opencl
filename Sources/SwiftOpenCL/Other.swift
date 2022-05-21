//
//  Other.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL

func callOnce(
  _ flag: inout Bool, _ function: @autoclosure () throws -> Void
) rethrows {
  if !flag {
    try function()
    flag = true
  }
}
