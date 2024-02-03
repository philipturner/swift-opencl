//
//  CLCommandQueue+Enqueue.swift
//  
//
//  Created by Philip Turner on 6/21/22.
//

import COpenCL

// For now, the API will not expose any means to use OpenCL events. The target
// use case should not require them. It is effectively using the default
// argument of null event arrays, and you can't override the default value.
// Here is what such an API would look like:
//
//  @discardableResult
//  private func _enqueueWrite(
//    _ buffer: CLBuffer,
//    blocking: Bool,
//    offset: Int,
//    size: Int,
//    _ pointer: UnsafeRawPointer,
//    eventWaitList: [CLEvent]?,
//    returnEvent: Bool
//  ) throws -> CLEvent? {
//    // Create a utility function that shares this boilerplate among every
//    // 'enqueue' function.
//    var eventCapacity = 0
//    if let eventWaitList {
//      eventCapacity += eventWaitList.count
//    }
//    if returnEvent {
//      eventCapacity += 1
//    }
//
//    return try withUnsafeTemporaryAllocation(
//      of: cl_event?.self, capacity: eventCapacity
//    ) { eventBuffer in
//      var eventWaitListPointer: UnsafeMutablePointer<cl_event?>?
//      var eventPointer: UnsafeMutablePointer<cl_event?>?
//      if let eventWaitList {
//        for i in eventWaitList.indices {
//          eventBuffer[i] = eventWaitList[i].event
//        }
//        eventWaitListPointer = eventBuffer.baseAddress
//      }
//      if returnEvent {
//        eventPointer = eventBuffer.baseAddress! + eventCapacity - 1
//      }
//
//      let error = clEnqueueWriteBuffer(
//        wrapper.object, buffer.memory.clMemory,
//        cl_bool(blocking ? CL_TRUE : CL_FALSE), offset, size, pointer,
//        cl_uint(eventWaitList?.count ?? 0), eventWaitListPointer,
//        eventPointer)
//      guard CLError.setCode(error, "__ENQUEUE_WRITE_BUFFER_ERR") else {
//        throw CLError.latest!
//      }
//
//      if returnEvent {
//        guard let clEvent = eventPointer!.pointee else {
//          fatalError("clEvent was nil.")
//        }
//        return CLEvent(clEvent)
//      } else {
//        return nil
//      }
//    }
//  }
//
//  public func enqueueWrite(
//    _ buffer: CLBuffer,
//    blocking: Bool = true,
//    offset: Int,
//    size: Int,
//    _ pointer: UnsafeRawPointer,
//    eventWaitList: [CLEvent]? = nil
//  ) throws {
//    try _enqueueWrite(
//      buffer, blocking: blocking, offset: offset, size: size, pointer,
//      eventWaitList: eventWaitList, returnEvent: false)
//  }
//
//  public func enqueueWrite(
//    _ buffer: CLBuffer,
//    blocking: Bool = true,
//    offset: Int,
//    size: Int,
//    _ pointer: UnsafeRawPointer,
//    eventWaitList: [CLEvent]? = nil,
//    event: inout CLEvent?
//  ) throws {
//    event = try _enqueueWrite(
//      buffer, blocking: blocking, offset: offset, size: size, pointer,
//      eventWaitList: eventWaitList, returnEvent: true)
//  }

extension CLCommandQueue {
  public func enqueueMap(
    _ buffer: CLBuffer,
    blocking: Bool = true,
    flags: CLMapFlags,
    offset: Int,
    size: Int
  ) throws -> UnsafeMutableRawPointer {
    var error: Int32 = .zero
    let pointer = clEnqueueMapBuffer(
      wrapper.object, buffer.memory.clMemory, blocking ? 1 : 0, flags.rawValue,
      offset, size, 0, nil, nil, &error)
    guard CLError.setCode(error, "__ENQUEUE_MAP_BUFFER_ERR") else {
      throw CLError.latest!
    }
    return pointer!
  }
  
  public func enqueueRead(
    _ buffer: CLBuffer,
    blocking: Bool = true,
    offset: Int,
    size: Int,
    _ pointer: UnsafeMutableRawPointer
  ) throws {
    let error = clEnqueueReadBuffer(
      wrapper.object, buffer.memory.clMemory, blocking ? 1 : 0,
      offset, size, pointer, 0, nil, nil)
    guard CLError.setCode(error, "__ENQUEUE_READ_BUFFER_ERR") else {
      throw CLError.latest!
    }
  }
  
  public func enqueueUnmap(
    _ buffer: CLBuffer,
    _ pointer: UnsafeMutableRawPointer
  ) throws {
    let error = clEnqueueUnmapMemObject(
      wrapper.object, buffer.memory.clMemory, pointer, 0, nil, nil)
    guard CLError.setCode(error, "__ENQUEUE_UNMAP_BUFFER_ERR") else {
      throw CLError.latest!
    }
  }
  
  public func enqueueWrite(
    _ buffer: CLBuffer,
    blocking: Bool = true,
    offset: Int,
    size: Int,
    _ pointer: UnsafeRawPointer
  ) throws {
    let error = clEnqueueWriteBuffer(
      wrapper.object, buffer.memory.clMemory, blocking ? 1 : 0,
      offset, size, pointer, 0, nil, nil)
    guard CLError.setCode(error, "__ENQUEUE_WRITE_BUFFER_ERR") else {
      throw CLError.latest!
    }
  }
  
  public func enqueueKernel(
    _ kernel: CLKernel,
    globalOffset: CLNDRange? = nil,
    globalSize: CLNDRange,
    localSize: CLNDRange? = nil
  ) throws {
    try withUnsafeTemporaryAllocation(
      of: SIMD4<Int>.self, capacity: 3
    ) { vectors in
      let opaque = OpaquePointer(vectors.baseAddress!)
      let casted = UnsafePointer<Int>(opaque)
      if let globalOffset {
        vectors[0] = globalOffset.storage
      }
      vectors[1] = globalSize.storage
      if let localSize {
        vectors[2] = localSize.storage
      }
      
      let error = clEnqueueNDRangeKernel(
        wrapper.object, kernel.clKernel, cl_uint(globalSize.dimensions),
        globalOffset == nil ? nil : casted + 0,
        casted + 4,
        localSize == nil ? nil : casted + 8,
        0, nil, nil)
      guard CLError.setCode(error, "__ENQUEUE_NDRANGE_KERNEL_ERR") else {
        throw CLError.latest!
      }
    }
  }
}
