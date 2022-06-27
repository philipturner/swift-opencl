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
extension CLProperties {
  @inline(__always)
  @discardableResult
  static func withUnsafeTemporaryAllocation<T>(
    properties: KeyValuePairs<Key, Key.RawValue>,
    _ body: (UnsafeMutableBufferPointer<Key.RawValue>) throws -> T
  ) rethrows -> T {
    return try Swift.withUnsafeTemporaryAllocation(
      of: Key.RawValue.self, capacity: properties.count * 2 + 1
    ) { bufferPointer in
      for i in 0..<properties.count {
        let keyIndex = i * 2
        let property = properties[i]
        bufferPointer[keyIndex] = property.key.rawValue
        bufferPointer[keyIndex + 1] = property.value
      }
      bufferPointer[properties.count * 2] = 0
      return try body(bufferPointer)
    }
  }
}

public enum CLContextProperties: CLProperties {
  case platform(CLPlatform)
  case interopUserSync(Bool)
  
  struct Key: CLMacro {
    let rawValue: cl_context_properties
    init(rawValue: cl_context_properties) {
      self.rawValue = rawValue
    }
    
    static let platform = Self(CL_CONTEXT_PLATFORM)
    static let interopUserSync = Self(CL_CONTEXT_INTEROP_USER_SYNC)
  }
  
  init(key: Key.RawValue, value: Key.RawValue) {
    switch key {
    case Key.platform.rawValue:
      let clPlatformID = cl_platform_id(bitPattern: value)!
      self = .platform(CLPlatform(clPlatformID)!)
    case Key.interopUserSync.rawValue:
      let clBool: UInt32 = cl_bool(value)
      self = .interopUserSync(clBool != 0)
    default:
      fatalError("Encountered unexpected key \(key) with value \(value).")
    }
  }
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
