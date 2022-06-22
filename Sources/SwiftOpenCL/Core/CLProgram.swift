//
//  CLProgram.swift
//  
//
//  Created by Philip Turner on 6/21/22.
//

import COpenCL
import Foundation

public struct CLProgram: CLReferenceCountable {
  var wrapper: CLReferenceWrapper<Self>
  public var program: cl_program { wrapper.object }
  
  public init?(_ program: cl_program, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(program, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainProgram(object)
  }

  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseProgram(object)
  }
  
  public init?(source: String, build: Bool = false) {
    guard let context = CLContext.defaultContext else {
      return nil
    }
    self.init(context: context, source: source, build: build)
  }
  
  public init?(context: CLContext, source: String, build: Bool = false) {
    var error: Int32 = 0
    var object_: cl_program?
    source.utf8CString.withUnsafeBufferPointer { bufferPointer in
      var string = bufferPointer.baseAddress
      var length = bufferPointer.count
      object_ = clCreateProgramWithSource(
        context.context, UInt32(1), &string, &length, &error)
    }
    guard CLError.handleCode(error, "__CREATE_PROGRAM_WITH_SOURCE_ERR"),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
    
    if build {
      error = clBuildProgram(object_, 0, nil, "-cl-std=CL2.0", nil, nil)
      guard CLError.handleCode(error, "__BUILD_PROGRAM_ERR"),
            buildLogHasNoErrors() else {
        return nil
      }
    }
  }
  
  public init?(sources: [String]) {
    guard let context = CLContext.defaultContext else {
      return nil
    }
    self.init(context: context, sources: sources)
  }
  
  public init?(context: CLContext, sources: [String]) {
    var error: Int32 = 0
    let n = sources.count
    var lengths: [Int] = []
    lengths.reserveCapacity(n)
    var strings: [UnsafePointer<Int8>?] = []
    strings.reserveCapacity(n)
    
    for source in sources {
      lengths.append(source.utf8.count)
      source.withCString {
        strings.append($0)
      }
    }
    let object_ = clCreateProgramWithSource(
      context.context, UInt32(n), &strings, &lengths, &error)
    guard CLError.handleCode(error, "__CREATE_PROGRAM_WITH_SOURCE_ERR"),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  @usableFromInline
  internal init?(
    context: CLContext,
    devices: [CLDevice],
    binaries: [Data],
    binaryStatus: inout [Int32]?,
    usingBinaryStatus: Bool
  ) {
    var error: Int32 = 0
    let numDevices = devices.count
    if binaries.count != devices.count {
      CLError.handleCode(CL_INVALID_VALUE, "__CREATE_PROGRAM_WITH_BINARY_ERR")
      return nil
    }
    
    var lengths: [Int] = []
    lengths.reserveCapacity(numDevices)
    var images: [UnsafePointer<UInt8>?] = []
    images.reserveCapacity(numDevices)
    var deviceIDs: [cl_device_id?] = []
    deviceIDs.reserveCapacity(numDevices)
    
    for i in 0..<numDevices {
      let binary = binaries[i]
      binary.withUnsafeBytes { bufferPointer in
        lengths.append(bufferPointer.count)
        images.append(
          bufferPointer.baseAddress!.assumingMemoryBound(to: UInt8.self))
      }
      deviceIDs.append(devices[i].deviceID)
    }
    
    var object_: cl_program?
    if usingBinaryStatus {
      binaryStatus = Array(repeating: 0, count: numDevices)
      object_ = clCreateProgramWithBinary(context.context, UInt32(numDevices), deviceIDs, lengths, &images, &binaryStatus!, &error)
    } else {
      object_ = clCreateProgramWithBinary(context.context, UInt32(numDevices), deviceIDs, lengths, &images, nil, &error)
    }
    
    guard CLError.handleCode(error, "__CREATE_PROGRAM_WITH_BINARY_ERR"),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  @inlinable @inline(__always)
  public init?(
    context: CLContext,
    devices: [CLDevice],
    binaries: [Data]
  ) {
    var ignoredBinaryStatus: [Int32]?
    self.init(
      context: context, devices: devices, binaries: binaries,
      binaryStatus: &ignoredBinaryStatus, usingBinaryStatus: false)
  }
  
  @inlinable @inline(__always)
  public init?(
    context: CLContext,
    devices: [CLDevice],
    binaries: [Data],
    binaryStatus: inout [Int32]?
  ) {
    self.init(
      context: context, devices: devices, binaries: binaries,
      binaryStatus: &binaryStatus, usingBinaryStatus: true)
  }
  
  public init?(context: CLContext, devices: [CLDevice], kernelNames: String) {
    var error: Int32 = 0
    let deviceIDs: [cl_device_id?] = devices.map(\.deviceID)
    let object_ = clCreateProgramWithBuiltInKernels(
      context.context, UInt32(devices.count), deviceIDs, kernelNames, &error)
    
    let message = "__CREATE_PROGRAM_WITH_BUILT_IN_KERNELS_ERR"
    guard CLError.handleCode(error, message),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
}

extension CLProgram {
  
  private func throwBuildError(_ error: Int32, _ message: String) throws {
    guard CLError.handleCode(error, message),
          buildLogHasNoErrors() else {
      throw CLError.latest!
    }
  }
  
  private static func throwError(_ error: Int32, _ message: String) throws {
    guard CLError.handleCode(error, message) else {
      throw CLError.latest!
    }
  }
  
  public func build(
    devices: [CLDevice],
    options: UnsafePointer<Int8>? = nil,
    notifyFptr: (@convention(c) (
      cl_program?, UnsafeMutableRawPointer?
    ) -> Void)? = nil,
    data: UnsafeMutableRawPointer? = nil
  ) throws {
    let deviceIDs: [cl_device_id?] = devices.map(\.deviceID)
    let buildError = clBuildProgram(
      wrapper.object, UInt32(devices.count), deviceIDs, options, notifyFptr,
      data)
    try throwBuildError(buildError, "__BUILD_PROGRAM_ERR")
  }
  
  public func build(
    device: CLDevice,
    options: UnsafePointer<Int8>? = nil,
    notifyFptr: (@convention(c) (
      cl_program?, UnsafeMutableRawPointer?
    ) -> Void)? = nil,
    data: UnsafeMutableRawPointer? = nil
  ) throws {
    var deviceID = Optional(device.deviceID)
    let buildError = clBuildProgram(
      wrapper.object, 1, &deviceID, options, notifyFptr, data)
    try throwBuildError(buildError, "__BUILD_PROGRAM_ERR")
  }
  
  public func build(
    options: UnsafePointer<Int8>? = nil,
    notifyFptr: (@convention(c) (
      cl_program?, UnsafeMutableRawPointer?
    ) -> Void)? = nil,
    data: UnsafeMutableRawPointer? = nil
  ) throws {
    let buildError = clBuildProgram(
      wrapper.object, 0, nil, options, notifyFptr, data)
    try throwBuildError(buildError, "__BUILD_PROGRAM_ERR")
  }
  
  public func compile(
    options: UnsafePointer<Int8>? = nil,
    notifyFptr: (@convention(c) (
      cl_program?, UnsafeMutableRawPointer?
    ) -> Void)? = nil,
    data: UnsafeMutableRawPointer? = nil
  ) throws {
    let buildError = clCompileProgram(
      wrapper.object, 0, nil, options, 0, nil, nil, notifyFptr, data)
    try throwBuildError(buildError, "__COMPILE_PROGRAM_ERR")
  }
  
  // public func createKernels(...) throws
  
  #if !canImport(Darwin)
  public func setSpecializationConstant<T>(
    _ value: UnsafePointer<T>, index: UInt32
  ) throws {
    let error = clSetProgramSpecializationConstant(
      wrapper.object, index, MemoryLayout<T>.stride, value)
    try throwError(error, "__SET_PROGRAM_SPECIALIZATION_CONSTANT_ERR")
  }
  
  public func setSpecializationConstant(
    _ value: UnsafePointer, size: Int, index: UInt32
  ) throws {
    let error = clSetProgramSpecializationConstant(
      wrapper.object, index, size, value)
    try throwError(error, "__SET_PROGRAM_SPECIALIZATION_CONSTANT_ERR")
  }
  #endif
  
  public func link(
    with input: CLProgram,
    options: UnsafePointer<Int8>? = nil,
    notifyFptr: (@convention(c) (
      cl_program?, UnsafeMutableRawPointer?
    ) -> Void)? = nil,
    data: UnsafeMutableRawPointer? = nil
  ) -> CLProgram? {
    var error: Int32 = 0
    guard let ctx = self.context else {
      CLError.latest!.message = "__LINK_PROGRAM_ERR"
      return nil
    }
    
    let prog = withUnsafeTemporaryAllocation(
      of: cl_program?.self, capacity: 2
    ) { programs in
      programs[0] = self.program
      programs[1] = input.program
      return clLinkProgram(
        ctx.context, 0, nil, options, 2, programs.baseAddress!, notifyFptr,
        data, &error)
    }
    guard CLError.handleCode(error, "__COMPILE_PROGRAM_ERR"),
          let prog = prog else {
      return nil
    }
    return CLProgram(prog)
  }
  
  public static func link(
    programs inputPrograms: [CLProgram],
    options: UnsafePointer<Int8>? = nil,
    notifyFptr: (@convention(c) (
      cl_program?, UnsafeMutableRawPointer?
    ) -> Void)? = nil,
    data: UnsafeMutableRawPointer? = nil
  ) -> CLProgram? {
    var error: Int32 = 0
    let programs: [cl_program?] = inputPrograms.map(\.program)
    var context: cl_context?
    if inputPrograms.count > 0 {
      guard let ctx = inputPrograms[0].context else {
        CLError.latest!.message = "__LINK_PROGRAM_ERR"
        return nil
      }
      context = ctx.context
    }
    
    let prog = clLinkProgram(
      context, 0, nil, options, UInt32(inputPrograms.count), programs,
      notifyFptr, data, &error)
    guard CLError.handleCode(error, "__COMPILE_PROGRAM_ERR"),
          let prog = prog else {
      return nil
    }
    return CLProgram(prog)
  }
  
}
