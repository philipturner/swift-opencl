//
//  Info.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL

typealias GetInfoClosure = (
  /*param_name=*/UInt32,
  /*param_value_size=*/Int,
  /*param_value=*/UnsafeMutableRawPointer?,
  /*param_value_size_ret=*/UnsafeMutablePointer<Int>?) -> Int32

@inline(__always)
func getInfo_Bool(_ name: Int32, _ getInfo: GetInfoClosure) -> Bool? {
  // cl_bool is a typealias of `UInt32`, which is 4 bytes.
  var output: cl_bool = 0
  let err = getInfo(UInt32(name), MemoryLayout<cl_bool>.stride, &output, nil)
  guard CLError.setCode(err) else {
    return nil
  }
  return output != 0
}

@inline(__always)
func getInfo_Int<T: BinaryInteger>(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> T? {
  var output: T = 0
  let err = getInfo(UInt32(name), MemoryLayout<T>.stride, &output, nil)
  guard CLError.setCode(err) else {
    return nil
  }
  return output
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

func getInfo_CLReferenceCountable<T: CLReferenceCountable>(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> T? {
  var value: OpaquePointer? = nil
  let err = getInfo(
    UInt32(name), MemoryLayout<OpaquePointer>.stride, &value, nil)
  guard CLError.setCode(err),
        let value = value else {
    return nil
  }
  return T(value, retain: true)
}

func getInfo_Array<T>(_ name: Int32, _ getInfo: GetInfoClosure) -> [T]? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(err) else {
    return nil
  }
  let elements = required / MemoryLayout<T>.stride
  
  let localData = [T](
    unsafeUninitializedCapacity: elements,
    initializingWith: { buffer, initializedCount in
      initializedCount = elements
      err = getInfo(UInt32(name), required, buffer.baseAddress, nil)
    })
  guard CLError.setCode(err) else {
    return nil
  }
  return localData
}

// The OpenCL 3.0 specification says each name string is null-terminated, with a
// maximum of 63 characters.
@available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
func getInfo_ArrayOfCLNameVersion(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> [CLNameVersion]? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(err) else {
    return nil
  }
  let elementStride = MemoryLayout<cl_version>.stride + 64
  let elements = required / elementStride
  precondition(required % elementStride == 0,
    "`required` was not a multiple of \(elementStride).")
  
  return withUnsafeTemporaryAllocation(
    byteCount: required, alignment: MemoryLayout<cl_version>.stride
  ) { bufferPointer in
    var value = bufferPointer.baseAddress.unsafelyUnwrapped.assumingMemoryBound(
      to: Int8.self)
    err = getInfo(UInt32(name), required, value, nil)
    guard CLError.setCode(err) else {
      return nil
    }
    
    var output: [CLNameVersion] = []
    output.reserveCapacity(elements)
    for _ in 0..<elements {
      defer {
        value += elementStride
      }
      let rawVersion = UnsafeRawPointer(value).assumingMemoryBound(
        to: cl_version.self).pointee
      let version = CLVersion(version: rawVersion)
      let name = String(cString: value + MemoryLayout<cl_version>.stride)
      output.append(CLNameVersion(version: version, name: name))
    }
    return output
  }
}

func getInfo_String(_ name: Int32, _ getInfo: GetInfoClosure) -> String? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(err) else {
    return nil
  }
  
  if required > 0 {
    var value: UnsafeMutableRawPointer = .allocate(
      byteCount: required, alignment: 1)
    err = getInfo(UInt32(name), required, &value, nil)
    guard CLError.setCode(err) else {
      value.deallocate()
      return nil
    }
    return String(
      bytesNoCopy: value, length: required, encoding: .utf8,
      freeWhenDone: true)!
  } else {
    return ""
  }
}

func getInfo_CLSize(_ name: Int32, _ getInfo: GetInfoClosure) -> CLSize? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(err) else {
    return nil
  }
  let elements = required / MemoryLayout<Int>.stride
  
  var output = CLSize.zero
  withUnsafeTemporaryAllocation(
    of: Int.self, capacity: elements
  ) { bufferPointer in
    let pointer = bufferPointer.baseAddress.unsafelyUnwrapped
    err = getInfo(UInt32(name), required, pointer, nil)
    for i in 0..<min(elements, 3) {
      output[i] = pointer[i]
    }
  }
  guard CLError.setCode(err) else {
    return nil
  }
  return output
}

func getInfo_ArrayOfCLReferenceCountable<T: CLReferenceCountable>(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> [T]? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(err) else {
    return nil
  }
  let elements = required / MemoryLayout<OpaquePointer>.stride
  
  return withUnsafeTemporaryAllocation(
    of: OpaquePointer.self, capacity: elements
  ) { bufferPointer in
    let value = bufferPointer.baseAddress.unsafelyUnwrapped
    err = getInfo(UInt32(name), required, value, nil)
    guard CLError.setCode(err) else {
      return nil
    }
    
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
