//
//  Info.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL
import struct Foundation.Data

typealias GetInfoClosure = (
  _ param_name: UInt32,
  _ param_value_size: Int,
  _ param_value: UnsafeMutableRawPointer?,
  _ param_value_size_ret: UnsafeMutablePointer<Int>?) -> Int32

// MARK: - Single Value Accessors

@inline(__always)
func getInfo_Bool(_ name: Int32, _ getInfo: GetInfoClosure) -> Bool? {
  // cl_bool is a typealias of `UInt32`, which is 4 bytes.
  var output: cl_bool = 0
  let error = getInfo(
    UInt32(name), MemoryLayout.stride(ofValue: output), &output, nil)
  guard CLError.setCode(error) else {
    return nil
  }
  return output == CL_TRUE
}

@inline(__always)
func getInfo_CLMacro<T: CLMacro>(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> T? {
  let rawValue: T.RawValue? = getInfo_Int(name, getInfo)
  guard let rawValue = rawValue else {
    return nil
  }
  return T(rawValue: rawValue)
}

// Do not force-inline because `T.init` might be large and already inlined.
func getInfo_CLReferenceCountable<T: CLReferenceCountable>(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> T? {
  var value: OpaquePointer? = nil
  let error = getInfo(
    UInt32(name), MemoryLayout.stride(ofValue: value), &value, nil)
  guard CLError.setCode(error),
        let value = value else {
    return nil
  }
  return T(value, retain: true)
}

func getInfo_CLSize(_ name: Int32, _ getInfo: GetInfoClosure) -> CLSize? {
  var required = 0
  var error = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(error) else {
    return nil
  }
  
  return withUnsafeTemporaryAllocation(
    byteCount: required, alignment: MemoryLayout<Int>.alignment
  ) { bufferPointer in
    let value = bufferPointer.getInfoBound(to: Int.self)
    error = getInfo(UInt32(name), required, value, nil)
    guard CLError.setCode(error) else {
      return nil
    }
    
    var output = CLSize.zero
    let elements = required / MemoryLayout<Int>.stride
    for i in 0..<min(elements, 3) {
      output[i] = value[i]
    }
    return output
  }
}

// Shares a lot of duplicated code with `getInfo_String`, but no way to
// practically share code between the two functions.
func getInfo_Data(_ name: Int32, _ getInfo: GetInfoClosure) -> Data? {
  var required = 0
  var error = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(error) else {
    return nil
  }
  
  if required > 0 {
    var value: UnsafeMutableRawPointer = .allocate(
      byteCount: required, alignment: MemoryLayout<UInt8>.alignment)
    error = getInfo(UInt32(name), required, &value, nil)
    guard CLError.setCode(error) else {
      value.deallocate()
      return nil
    }
    return Data(bytesNoCopy: value, count: required, deallocator: .free)
  } else {
    return Data()
  }
}

@inline(__always)
func getInfo_Int<T: FixedWidthInteger>(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> T? {
  var output: T = 0
  let error = getInfo(
    UInt32(name), MemoryLayout.stride(ofValue: output), &output, nil)
  guard CLError.setCode(error) else {
    return nil
  }
  return output
}

func getInfo_String(_ name: Int32, _ getInfo: GetInfoClosure) -> String? {
  var required = 0
  var error = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(error) else {
    return nil
  }
  
  if required > 0 {
    let value = UnsafeMutablePointer<UInt8>.allocate(capacity: required)
    error = getInfo(UInt32(name), required, value, nil)
    guard CLError.setCode(error) else {
      value.deallocate()
      return nil
    }
    if value[required - 1] == 0 {
      required -= 1
    }
    return String(
      bytesNoCopy: value, length: required, encoding: .utf8,
      freeWhenDone: true)!
  } else {
    return ""
  }
}

// MARK: - Array Accessors

func getInfo_Array<T>(_ name: Int32, _ getInfo: GetInfoClosure) -> [T]? {
  var required = 0
  var error = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(error) else {
    return nil
  }
  let elements = required / MemoryLayout<T>.stride
  
  let output = Array<T>(
    unsafeUninitializedCapacity: elements
  ) { bufferPointer, initializedCount in
    error = getInfo(UInt32(name), required, bufferPointer.baseAddress, nil)
    initializedCount = elements
  }
  guard CLError.setCode(error) else {
    return nil
  }
  return output
}

// The OpenCL 3.0 specification says each name string is null-terminated, with a
// maximum of 63 characters.
func getInfo_ArrayOfCLNameVersion(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> [CLNameVersion]? {
  var required = 0
  var error = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(error) else {
    return nil
  }
  
  return withUnsafeTemporaryAllocation(
    byteCount: required, alignment: MemoryLayout<cl_version>.alignment
  ) { bufferPointer in
    var value = bufferPointer.getInfoBound(to: Int8.self)
    error = getInfo(UInt32(name), required, value, nil)
    guard CLError.setCode(error) else {
      return nil
    }
    
    let elementStride = MemoryLayout<cl_version>.stride + 64
    let elements = required / elementStride
    var output: [CLNameVersion] = []
    output.reserveCapacity(elements)
    for _ in 0..<elements {
      defer {
        value += elementStride
      }
      let rawVersion = UnsafeRawPointer(value)
        .assumingMemoryBound(to: cl_version.self).pointee
      let version = CLVersion(version: rawVersion)
      let name = String(cString: value + MemoryLayout<cl_version>.stride)
      output.append(CLNameVersion(version: version, name: name))
    }
    return output
  }
}

func getInfo_ArrayOfCLProperty<T: CLProperty>(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> [T]? {
  var required = 0
  var error = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(error) else {
    return nil
  }
  
  typealias RawValue = T.Key.RawValue
  return withUnsafeTemporaryAllocation(
    byteCount: required, alignment: MemoryLayout<RawValue>.alignment
  ) { bufferPointer in
    let value = bufferPointer.getInfoBound(to: RawValue.self)
    error = getInfo(UInt32(name), required, value, nil)
    guard CLError.setCode(error) else {
      return nil
    }
    
    // The array is a series of key-value pairs ending with 0, so the count
    // should be odd.
    let elements = required / MemoryLayout<RawValue>.stride
    precondition(elements & 1 != 0, """
      Attempted to create an array of `CLProperties`, but its count was even.
      """)
    let numProperties = elements >> 1 // (array.count - 1) / 2
    var output: [T] = []
    output.reserveCapacity(numProperties)
    
    for i in 0..<numProperties {
      let keyIndex = i * 2
      let key = value[keyIndex]
      let value_ = value[keyIndex + 1]
      output.append(T(key: key, value: value_))
    }
    return output
  }
}

func getInfo_ArrayOfCLReferenceCountable<T: CLReferenceCountable>(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> [T]? {
  var required = 0
  var error = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(error) else {
    return nil
  }
  
  return withUnsafeTemporaryAllocation(
    byteCount: required, alignment: MemoryLayout<OpaquePointer>.alignment
  ) { bufferPointer in
    let value = bufferPointer.getInfoBound(to: OpaquePointer.self)
    error = getInfo(UInt32(name), required, value, nil)
    guard CLError.setCode(error) else {
      return nil
    }
    
    let elements = required / MemoryLayout<OpaquePointer>.stride
    var output: [T] = []
    output.reserveCapacity(elements)
    for i in 0..<elements {
      guard let element = T(value[i], retain: true) else {
        return nil
      }
      output.append(element)
    }
    return output
  }
}
