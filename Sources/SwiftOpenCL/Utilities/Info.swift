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

// Force-inline this.
func getInfo_Bool(_ name: Int32, _ callGetInfo: GetInfoClosure) -> Bool? {
  var output = false
  // cl_bool is a typealias of `UInt32`, which is 4 bytes.
  let err = callGetInfo(UInt32(name), MemoryLayout<cl_bool>.stride, &output, nil)
  guard CLError.setCode(err) else {
    return nil
  }
  return output
}

// Force-inline this.
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

func getInfo_ReferenceCountable<T: CLReferenceCountable>(
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

func getInfo_ArrayOfCLNameVersion(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> [(cl_version, String)]? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(err) else {
    return nil
  }
  let elementStride = MemoryLayout<cl_version>.stride + 64
  let elements = required / elementStride
  precondition(required % elementStride == 0,
    "`required` was not a multiple of \(elementStride).")
  
  // Leave one more byte for manually null-terminating.
  let value: UnsafeMutableRawPointer = malloc(required + 1)!
  defer { value.deallocate() }
  err = getInfo(UInt32(name), required, value, nil)
  guard CLError.setCode(err) else {
    return nil
  }
  
  var output: [(cl_version, String)] = []
  output.reserveCapacity(elements)
  var byteStream = value.assumingMemoryBound(to: Int8.self)
  for _ in 0..<elements {
    // Ensure C-style string is null-terminated.
    let overwrittenChar = byteStream[64]
    defer {
      byteStream[64] = overwrittenChar
      byteStream += 64
    }
    byteStream[64] = 0
    
    let version = UnsafeRawPointer(byteStream)
      .assumingMemoryBound(to: cl_version.self).pointee
    let name = String(cString: byteStream + 4 /* cl_version is UInt32 */)
    output.append((version, name))
  }
  return output
}

func getInfo_String(_ name: Int32, _ getInfo: GetInfoClosure) -> String? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(err) else {
    return nil
  }
  
  if required > 0 {
    var value = malloc(required)!
    err = getInfo(UInt32(name), required, &value, nil)
    guard CLError.setCode(err) else {
      free(value)
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

func getInfo_ArrayOfReferenceCountable<T: CLReferenceCountable>(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> [T]? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.setCode(err) else {
    return nil
  }
  let elements = required / MemoryLayout<OpaquePointer>.stride
  
  let value: UnsafeMutablePointer<OpaquePointer> = .allocate(capacity: elements)
  defer { value.deallocate() }
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
