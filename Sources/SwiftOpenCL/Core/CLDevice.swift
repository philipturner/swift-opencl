//
//  CLDevice.swift
//  
//
//  Created by Philip Turner on 4/26/22.
//

import COpenCL

public class CLDevice {
  private static var default_initialized: Bool = false
  private static var default_: CLDevice? = nil
  private static var default_error_: Int32 = 0
  
  // line 2143: declare Device::makeDefault
  // line 3211: implement Device::makeDefault
  private static func makeDefault() {
    
  }
  
  private static func makeDefaultProvided(_ p: CLDevice) {
    default_ = p
  }
}
