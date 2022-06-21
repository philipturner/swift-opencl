//
//  GetInfo.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL

typealias GetInfoClosure = (
  UInt32, Int, UnsafeMutableRawPointer?, UnsafeMutablePointer<Int>?) -> Int32

// Force-inline this.
func getInfo_Bool(_ name: Int32, _ callGetInfo: GetInfoClosure) -> Bool? {
  var output = false
  let err = callGetInfo(UInt32(name), MemoryLayout<Bool>.stride, &output, nil)
  guard CLError.handleCode(err) else {
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
  guard CLError.handleCode(err) else {
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
  guard CLError.handleCode(err) else {
    return nil
  }
  
  guard let value = value else {
    fatalError("This should never happen.")
  }
  return T(value, retain: true)
}

func getInfo_Array<T>(_ name: Int32, _ getInfo: GetInfoClosure) -> [T]? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.handleCode(err) else {
    return nil
  }
  let elements = required / MemoryLayout<T>.stride
  
  let localData = [T](
    unsafeUninitializedCapacity: elements,
    initializingWith: { buffer, initializedCount in
      initializedCount = elements
      err = getInfo(UInt32(name), required, buffer.baseAddress, nil)
    })
  guard CLError.handleCode(err) else {
    return nil
  }
  return localData
}

func getInfo_ArrayOfReferenceCountable<T: CLReferenceCountable>(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> [T]? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.handleCode(err) else {
    return nil
  }
  let elements = required / MemoryLayout<OpaquePointer>.stride
  
  let value: UnsafeMutablePointer<OpaquePointer> = .allocate(capacity: elements)
  defer { value.deallocate() }
  err = getInfo(UInt32(name), required, value, nil)
  guard CLError.handleCode(err) else {
    return nil
  }
  
  var shouldReturnEarly = false
  let output = [T](
    unsafeUninitializedCapacity: elements,
    initializingWith: { buffer, initializedCount in
      for i in 0..<elements {
        guard let element = T(value[i], retain: true) else {
          shouldReturnEarly = true
          initializedCount = i
          return
        }
        buffer[i] = element
      }
      initializedCount = elements
    })
  if shouldReturnEarly {
    return nil
  } else {
    return output
  }
}

func getInfo_String(_ name: Int32, _ getInfo: GetInfoClosure) -> String? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.handleCode(err) else {
    return nil
  }
  
  if required > 0 {
    var value = malloc(required)!
    err = getInfo(UInt32(name), required, &value, nil)
    guard CLError.handleCode(err) else {
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
