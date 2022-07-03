//
//  CLProperty.swift
//  
//
//  Created by Philip Turner on 6/26/22.
//

import COpenCL

protocol CLProperty {
  associatedtype Key: CLMacro
  
  init(key: Key.RawValue, value: Key.RawValue)
  
  func serialized() -> (Key.RawValue, Key.RawValue)
}

extension CLProperty {
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
  
  @discardableResult
  static func withUnsafeTemporaryAllocation<T>(
    properties: [Self]?,
    _ body: (UnsafeMutableBufferPointer<Key.RawValue>) throws -> T
  ) rethrows -> T {
    var capacity = 1
    if let count = properties?.count {
      capacity += count * 2
    }
    return try Swift.withUnsafeTemporaryAllocation(
      of: Key.RawValue.self, capacity: capacity
    ) { bufferPointer in
      if let properties = properties {
        for i in 0..<properties.count {
          let keyIndex = i * 2
          let (key, value) = properties[i].serialized()
          bufferPointer[keyIndex] = key
          bufferPointer[keyIndex + 1] = value
        }
        bufferPointer[properties.count * 2] = 0
      } else {
        bufferPointer[0] = 0
      }
      return try body(bufferPointer)
    }
  }
}

// MARK: - Property Types

public enum CLContextProperty: CLProperty {
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
      self = .interopUserSync(clBool == CL_TRUE)
    default:
      fatalError("Encountered unexpected key \(key) with value \(value).")
    }
  }
  
  func serialized() -> (Key.RawValue, Key.RawValue) {
    switch self {
    case .platform(let platform):
      return (Key.platform.rawValue, .init(bitPattern: platform.clPlatformID))
    case .interopUserSync(let interopUserSync):
      return (Key.interopUserSync.rawValue, interopUserSync ? 1 : 0)
    }
  }
}

@available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
public enum CLMemoryProperty: CLProperty {
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
    fatalError("`CLMemoryProperty` does not have any cases.")
  }
  
  func serialized() -> (Key.RawValue, Key.RawValue) {
    fatalError("`CLMemoryProperty` does not have any cases.")
  }
}

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public enum CLPipeProperty: CLProperty {
  struct Key: CLMacro {
    let rawValue: cl_pipe_properties
    init(rawValue: cl_pipe_properties) {
      self.rawValue = rawValue
    }
    
    // From the OpenCL 3.0 specification:
    // "Currently, in all OpenCL versions, properties must be NULL."
  }
  
  init(key: Key.RawValue, value: Key.RawValue) {
    fatalError("`CLPipeProperty` does not have any cases.")
  }
  
  func serialized() -> (Key.RawValue, Key.RawValue) {
    fatalError("`CLPipeProperty` does not have any cases.")
  }
}

// This enum is not defined in "cl.h", but multiple macros act like one
// according to the OpenCL 3.0 specification. The enum cases are all properties
// listed in the table under `clCreateCommandQueueWithProperties`.
public enum CLQueueProperty: CLProperty {
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
  
  func serialized() -> (Key.RawValue, Key.RawValue) {
    switch self {
    case .properties(let properties):
      return (Key.properties.rawValue, .init(properties.rawValue))
    case .size(let size):
      return (Key.size.rawValue, .init(size))
    }
  }
}

// As with `CLQueueProperties`, this enum is not explicitly defined in "cl.h".
// It takes some keys from `cl_sampler_info`, just like `CLQueueProperties`
// takes keys from `cl_command_queue_info`.
@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public enum CLSamplerProperty: CLProperty {
  case normalizedCoords(Bool)
  case addressingMode(CLAddressingMode)
  case filterMode(CLFilterMode)
  
  struct Key: CLMacro {
    let rawValue: cl_sampler_properties
    init(rawValue: cl_sampler_properties) {
      self.rawValue = rawValue
    }
    
    static let normalizedCoords = Self(CL_SAMPLER_NORMALIZED_COORDS)
    static let addressingMode = Self(CL_SAMPLER_ADDRESSING_MODE)
    static let filterMode = Self(CL_SAMPLER_FILTER_MODE)
  }
  
  init(key: Key.RawValue, value: Key.RawValue) {
    switch key {
    case Key.normalizedCoords.rawValue:
      let clBool: UInt32 = cl_bool(value)
      self = .normalizedCoords(clBool == CL_TRUE)
    case Key.addressingMode.rawValue:
      let rawValue: UInt32 = cl_addressing_mode(value)
      self = .addressingMode(CLAddressingMode(rawValue: rawValue)!)
    case Key.filterMode.rawValue:
      let rawValue: UInt32 = cl_filter_mode(value)
      self = .filterMode(CLFilterMode(rawValue: rawValue)!)
    default:
      fatalError("Encountered unexpected key \(key) with value \(value).")
    }
  }
  
  func serialized() -> (Key.RawValue, Key.RawValue) {
    switch self {
    case .normalizedCoords(let normalizedCoords):
      return (Key.normalizedCoords.rawValue, normalizedCoords ? 1 : 0)
    case .addressingMode(let addressingMode):
      return (Key.addressingMode.rawValue, .init(addressingMode.rawValue))
    case .filterMode(let filterMode):
      return (Key.filterMode.rawValue, .init(filterMode.rawValue))
    }
  }
}

// MARK: - Custom Property Types

// One of the associated values is an array, which cannot be represented by an
// integral type. Therefore, this cannot conform to `CLProperties`. It never
// appears in an array of other properties, so
// `Self.withUnsafeTemporaryAllocation(properties:)` should be reimplemented.
public enum CLDevicePartitionProperty {
  case equally(UInt32)
  case byCounts([UInt32])
  case byAffinityDomain(CLDeviceAffinityDomain)
  
  typealias Key = CLDevicePartitionPropertyKey
  
  // The implementation can return "no value" for a `CLDevicePartitionProperty`
  // without creating an error. To prevent possibly two meanings of `nil` (one
  // being error, the other being nothing), the function calling this
  // initializer should be creating a special kind of error to describe this
  // case.
  init?(buffer: UnsafePointer<Key.RawValue>) {
    let key = buffer[0]
    if key == 0 {
      return nil
    }
    switch Key(rawValue: key) {
    case nil:
      fatalError("Invalid raw value for `cl_device_partition_property`.")
    case .equally:
      self = .equally(UInt32(buffer[1]))
    case .byCounts:
      let countsBuffer = buffer.advanced(by: 1)
      var numCounts: Int = 0
      while true {
        let value = buffer[numCounts]
        if value == 0 {
          break
        }
        numCounts += 1
      }
      
      var counts: [UInt32] = []
      counts.reserveCapacity(numCounts)
      for i in 0..<numCounts {
        counts.append(UInt32(countsBuffer[i]))
      }
      self = .byCounts(counts)
    case .byAffinityDomain:
      let rawValue = cl_device_affinity_domain(buffer[1])
      self = .byAffinityDomain(CLDeviceAffinityDomain(rawValue: rawValue))
    }
  }
}

// The device partition property equivalent of `CLProperty.Key`.
//
// Unlike other property types, `CLDevicePartitionProperty`'s key must be
// public. This lets it match the semantics of `CL_DEVICE_PARTITION_PROPERTIES`
// by returning a list of supported keys. To make `Key` easy to enumerate over,
// it is an `enum` instead of a `struct`.
//
// Showing `CLDevicePartitionProperty.Key` in the public API would appear wildly
// different than every other type exposed by OpenCL. None of the exposed
// properties sourced from `getInfoHelper` return nested types. To solve this
// problem, I made the key a top level type. Its name is now one continuous
// word: `CLDevicePartitionPropertyKey`.
public enum CLDevicePartitionPropertyKey:
  cl_device_partition_property, CLMacro
{
  case equally = 0x1086
  case byCounts = 0x1087
  case byAffinityDomain = 0x1088
}

extension CLDevicePartitionProperty {
  // Should automatically inline because the function is only referenced once.
  @discardableResult
  static func withUnsafeTemporaryAllocation<T>(
    property: Self,
    _ body: (UnsafeMutableBufferPointer<Key.RawValue>) throws -> T
  ) rethrows -> T {
    var capacity: Int
    switch property {
    case .equally:
      capacity = 3
    case .byCounts(let counts):
      capacity = 1 + counts.count + 1
    case .byAffinityDomain:
      capacity = 3
    }
    
    typealias RawValue = Key.RawValue
    return try Swift.withUnsafeTemporaryAllocation(
      of: RawValue.self, capacity: capacity
    ) { bufferPointer in
      let buffer = bufferPointer.baseAddress.unsafelyUnwrapped
      switch property {
      case .equally(let n):
        buffer[0] = CLDevicePartitionPropertyKey.equally.rawValue
        buffer[1] = RawValue(n)
        buffer[2] = 0
      case .byCounts(let counts):
        buffer[0] = CLDevicePartitionPropertyKey.byCounts.rawValue
        let countsBuffer = buffer.advanced(by: 1)
        for i in 0..<counts.count {
          countsBuffer[i] = RawValue(counts[i])
        }
        countsBuffer[counts.count] = 0
      case .byAffinityDomain(let affinityDomain):
        buffer[0] = CLDevicePartitionPropertyKey.byAffinityDomain.rawValue
        buffer[1] = RawValue(affinityDomain.rawValue)
        buffer[2] = 0
      }
      
      return try body(bufferPointer)
    }
  }
}
