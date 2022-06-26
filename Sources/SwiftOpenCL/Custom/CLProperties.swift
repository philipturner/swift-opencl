//
//  CLProperties.swift
//  
//
//  Created by Philip Turner on 6/26/22.
//

import COpenCL

// protocol CLProperties { associatedtype Key: CLMacro }

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public typealias cl_queue_properties = cl_properties

@available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
public typealias cl_mem_properties = cl_properties

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
public enum CLQueueProperties {
  case properties(CLCommandQueueProperties)
  case size(UInt32)
  
  // Should this initializer be public?
  internal init(key: cl_queue_properties, value: cl_queue_properties) {
    switch key {
    case cl_queue_properties(CL_QUEUE_PROPERTIES):
      self = .properties(.init(rawValue: value))
    case cl_queue_properties(0x1094): // CL_QUEUE_SIZE
      self = .size(UInt32(value))
    default:
      fatalError("Encountered unexpected key \(key) with value \(value).")
    }
  }
}
