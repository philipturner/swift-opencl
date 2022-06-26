//
//  CLProperties.swift
//  
//
//  Created by Philip Turner on 6/26/22.
//

import COpenCL

protocol CLProperties {
  associatedtype Key: CLMacro
  init(key: Key.RawValue, value: Key.RawValue)
}

@available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
public enum CLMemoryProperties: CLProperties {
  struct Key: CLMacro {
    let rawValue: cl_mem_properties
    init(rawValue: cl_mem_properties) {
      self.rawValue = rawValue
    }
    
    // From the OpenCL 3.0 specification:
    // "OpenCL 3.0 does not define any optional properties for buffers."
    // "OpenCL 3.0 does not define any optional properties for images."
  }
  
  init(key: Key.RawValue, value: Key.RawValue) {
    fatalError("`CLMemoryProperties` does not have any cases.")
  }
}

// This enum is not defined in "cl.h", but multiple macros act like one
// according to the OpenCL 3.0 specification. The enum cases are all properties
// listed in the table under `clCreateCommandQueueWithProperties`.
//
// This also conflicts with `cl_queue_properties_APPLE`. `cl_queue_properties`
// has a different `RawValue` than the Apple counterpart, and calls into a
// different function (`clCreateCommandQueueWithPropertiesAPPLE`). I may change
// the implementation of `CLQueueProperties` to support Apple's extension.
//
// The Apple version of creating a command queue with properties does not allow
// setting `CL_QUEUE_SIZE`. Instead, Apple supports two new properties:
// - CL_COMMAND_QUEUE_PRIORITY_APPLE
// - CL_COMMAND_QUEUE_NUM_COMPUTE_UNITS_APPLE
@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public enum CLQueueProperties: CLProperties {
  case properties(CLCommandQueueProperties)
  case size(UInt32)
  
  struct Key: CLMacro {
    let rawValue: cl_queue_properties
    init(rawValue: cl_queue_properties) {
      self.rawValue = rawValue
    }
    
    static let properties = Self(CL_QUEUE_PROPERTIES)
    static let size = Self(0x1094)
  }
  
  init(key: Key.RawValue, value: Key.RawValue) {
    switch key {
    case Key.properties.rawValue:
      self = .properties(CLCommandQueueProperties(rawValue: value))
    case Key.size.rawValue:
      self = .size(UInt32(value))
    default:
      fatalError("Encountered unexpected key \(key) with value \(value).")
    }
  }
}
