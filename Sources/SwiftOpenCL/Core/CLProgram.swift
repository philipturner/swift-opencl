//
//  CLProgram.swift
//  
//
//  Created by Philip Turner on 6/21/22.
//

import COpenCL
import struct Foundation.Data

public struct CLProgram: CLReferenceCountable {
  @usableFromInline
  var wrapper: CLReferenceWrapper<Self>
  
  @_transparent
  public var clProgram: cl_program { wrapper.object }
  
  @inline(__always) // Force-inline this internally, but not externally.
  public init?(_ clProgram: cl_program, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(clProgram, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  @usableFromInline
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainProgram(object)
  }
  
  @usableFromInline
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseProgram(object)
  }
  
  // Removing the C++ bindings option for building the program while
  // initializing. This feature was only available in some constructors, and was
  // deactivated in 2013. In 2015, Khronos added the automatic selection of
  // "-cl-std=CL2.0" to this niche build pathway, but not to explicit
  // `Program::build` members. On devices that don't support OpenCL 2.0, the
  // OpenCL C compiler would fail as described in the OpenCL 3.0 specification.
  // This build pathway will not be part of SwiftOpenCL because it's opaque to
  // the developer and could cause an unintentional bug.
  //
  // If you're concerned about the overhead of separating initialization and
  // building into two function calls, you can just call the underlying C
  // functions manually.
  //
  // I am also keeping the option to build with one source instead of an array
  // of sources. This creates multiple ways of accomplishing the same thing, but
  // has some benefits. For example, the developer could pass a string literal
  // into `source:`. Most importantly, this feature is in the C++ bindings.
  // Unless there is a compelling reason, the API should not change when
  // translating from C++ to Swift.
  public init?(context: CLContext, source: String) {
    var error: Int32 = CL_SUCCESS
    var object_: cl_program?
    source.utf8CString.withUnsafeBufferPointer { bufferPointer in
      var string = bufferPointer.baseAddress
      var length = bufferPointer.count
      object_ = clCreateProgramWithSource(
        context.clContext, 1, &string, &length, &error)
    }
    guard CLError.setCode(error, "__CREATE_PROGRAM_WITH_SOURCE_ERR"),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  public init?(source: String) {
    guard let context = CLContext.defaultContext else {
      return nil
    }
    self.init(context: context, source: source)
  }
  
  public init?(context: CLContext, sources: [String]) {
    var error: Int32 = CL_SUCCESS
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
      context.clContext, UInt32(n), &strings, &lengths, &error)
    guard CLError.setCode(error, "__CREATE_PROGRAM_WITH_SOURCE_ERR"),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  public init?(sources: [String]) {
    guard let context = CLContext.defaultContext else {
      return nil
    }
    self.init(context: context, sources: sources)
  }
  
  @usableFromInline
  internal init?(
    context: CLContext,
    devices: [CLDevice],
    binaries: [Data],
    binaryStatus: inout [Int32]?,
    usingBinaryStatus: Bool
  ) {
    var error: Int32 = CL_SUCCESS
    let numDevices = devices.count
    if binaries.count != devices.count {
      CLError.setCode(CL_INVALID_VALUE, "__CREATE_PROGRAM_WITH_BINARY_ERR")
      return nil
    }
    
    var lengths: [Int] = []
    lengths.reserveCapacity(numDevices)
    var images: [UnsafePointer<UInt8>?] = []
    images.reserveCapacity(numDevices)
    var clDeviceIDs: [cl_device_id?] = []
    clDeviceIDs.reserveCapacity(numDevices)
    
    for i in 0..<numDevices {
      let binary = binaries[i]
      binary.withUnsafeBytes { bufferPointer in
        lengths.append(bufferPointer.count)
        images.append(
          bufferPointer.baseAddress.unsafelyUnwrapped
            .assumingMemoryBound(to: UInt8.self))
      }
      clDeviceIDs.append(devices[i].clDeviceID)
    }
    
    var object_: cl_program?
    if usingBinaryStatus {
      binaryStatus = Array(repeating: 0, count: numDevices)
      object_ = clCreateProgramWithBinary(context.clContext, UInt32(numDevices), clDeviceIDs, lengths, &images, &binaryStatus!, &error)
    } else {
      object_ = clCreateProgramWithBinary(context.clContext, UInt32(numDevices), clDeviceIDs, lengths, &images, nil, &error)
    }
    
    guard CLError.setCode(error, "__CREATE_PROGRAM_WITH_BINARY_ERR"),
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
    var error: Int32 = CL_SUCCESS
    let clDeviceIDs: [cl_device_id?] = devices.map(\.clDeviceID)
    let object_ = clCreateProgramWithBuiltInKernels(
      context.clContext, UInt32(devices.count), clDeviceIDs, kernelNames,
      &error)
    
    let message = "__CREATE_PROGRAM_WITH_BUILT_IN_KERNELS_ERR"
    guard CLError.setCode(error, message),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
}

extension CLProgram {
  private func throwBuildCode(_ code: Int32, _ message: String) throws {
    guard CLError.setCode(code, message),
          buildLogHasNoErrors() else {
      throw CLError.latest!
    }
  }
  
  public mutating func build(
    devices: [CLDevice],
    options: UnsafePointer<Int8>? = nil,
    data: UnsafeMutableRawPointer? = nil,
    notifyFptr: (@convention(c) (
      cl_program?, UnsafeMutableRawPointer?
    ) -> Void)? = nil
  ) throws {
    let clDeviceIDs: [cl_device_id?] = devices.map(\.clDeviceID)
    let buildError = clBuildProgram(
      wrapper.object, UInt32(devices.count), clDeviceIDs, options, notifyFptr,
      data)
    try throwBuildCode(buildError, "__BUILD_PROGRAM_ERR")
  }
  
  public mutating func build(
    device: CLDevice,
    options: UnsafePointer<Int8>? = nil,
    data: UnsafeMutableRawPointer? = nil,
    notifyFptr: (@convention(c) (
      cl_program?, UnsafeMutableRawPointer?
    ) -> Void)? = nil
  ) throws {
    var clDeviceID = Optional(device.clDeviceID)
    let buildError = clBuildProgram(
      wrapper.object, 1, &clDeviceID, options, notifyFptr, data)
    try throwBuildCode(buildError, "__BUILD_PROGRAM_ERR")
  }
  
  public mutating func build(
    options: UnsafePointer<Int8>? = nil,
    data: UnsafeMutableRawPointer? = nil,
    notifyFptr: (@convention(c) (
      cl_program?, UnsafeMutableRawPointer?
    ) -> Void)? = nil
  ) throws {
    let buildError = clBuildProgram(
      wrapper.object, 0, nil, options, notifyFptr, data)
    try throwBuildCode(buildError, "__BUILD_PROGRAM_ERR")
  }
  
  public mutating func compile(
    options: UnsafePointer<Int8>? = nil,
    data: UnsafeMutableRawPointer? = nil,
    notifyFptr: (@convention(c) (
      cl_program?, UnsafeMutableRawPointer?
    ) -> Void)? = nil
  ) throws {
    let buildError = clCompileProgram(
      wrapper.object, 0, nil, options, 0, nil, nil, notifyFptr, data)
    try throwBuildCode(buildError, "__COMPILE_PROGRAM_ERR")
  }
  
  public func createKernels() -> [CLKernel]? {
    var numKernels: UInt32 = 0
    var err = clCreateKernelsInProgram(wrapper.object, 0, nil, &numKernels)
    guard CLError.setCode(err, "__CREATE_KERNELS_IN_PROGRAM_ERR") else {
      return nil
    }
    
    return withUnsafeTemporaryAllocation(
      of: cl_kernel?.self, capacity: Int(numKernels)
    ) { bufferPointer in
      let value = bufferPointer.baseAddress.unsafelyUnwrapped
      err = clCreateKernelsInProgram(wrapper.object, numKernels, value, nil)
      guard CLError.setCode(err, "__CREATE_KERNELS_IN_PROGRAM_ERR") else {
        return nil
      }
      
      var kernels: [CLKernel] = []
      kernels.reserveCapacity(Int(numKernels))
      for i in 0..<Int(numKernels) {
        // We do not need to retain because this kernel is being created by the
        // runtime. For why `CLKernel.init` is force-unwrapped, see the comment
        // in `CLPlatform.availablePlatforms`.
        let kernel = CLKernel(value[i]!, retain: false)!
        kernels.append(kernel)
      }
      return kernels
    }
  }
  
  #if !canImport(Darwin)
  public mutating func setSpecializationConstant(
    _ value: UnsafePointer<Bool>, index: UInt32
  ) throws {
    var ucValue = value.pointee ? UInt8.max : 0
    let error = clSetProgramSpecializationConstant(
      wrapper.object, index, MemoryLayout.stride(ofValue: ucValue), &ucValue)
    try CLError.throwCode(error, "__SET_PROGRAM_SPECIALIZATION_CONSTANT_ERR")
  }
  
  public mutating func setSpecializationConstant<T>(
    _ value: UnsafePointer<T>, index: UInt32
  ) throws {
    let error = clSetProgramSpecializationConstant(
      wrapper.object, index, MemoryLayout<T>.stride, value)
    try CLError.throwCode(error, "__SET_PROGRAM_SPECIALIZATION_CONSTANT_ERR")
  }
  
  public mutating func setSpecializationConstant(
    _ value: UnsafeRawPointer, size: Int, index: UInt32
  ) throws {
    let error = clSetProgramSpecializationConstant(
      wrapper.object, index, size, value)
    try CLError.throwCode(error, "__SET_PROGRAM_SPECIALIZATION_CONSTANT_ERR")
  }
  #endif
  
  public static func link(
    _ input1: CLProgram,
    _ input2: CLProgram,
    options: UnsafePointer<Int8>? = nil,
    data: UnsafeMutableRawPointer? = nil,
    notifyFptr: (@convention(c) (
      cl_program?, UnsafeMutableRawPointer?
    ) -> Void)? = nil
  ) -> CLProgram? {
    var error: Int32 = CL_SUCCESS
    guard let ctx = input1.context else {
      CLError.latest!.message = "__LINK_PROGRAM_ERR"
      return nil
    }
    
    let prog: cl_program? = withUnsafeTemporaryAllocation(
      of: cl_program?.self, capacity: 2
    ) { clPrograms in
      clPrograms[0] = input1.clProgram
      clPrograms[1] = input2.clProgram
      return clLinkProgram(
        ctx.clContext, 0, nil, options, 2, clPrograms.baseAddress, notifyFptr,
        data, &error)
    }
    guard CLError.setCode(error, "__COMPILE_PROGRAM_ERR"),
          let prog = prog else {
      return nil
    }
    return CLProgram(prog)
  }
  
  public static func link(
    _ inputPrograms: [CLProgram],
    options: UnsafePointer<Int8>? = nil,
    data: UnsafeMutableRawPointer? = nil,
    notifyFptr: (@convention(c) (
      cl_program?, UnsafeMutableRawPointer?
    ) -> Void)? = nil
  ) -> CLProgram? {
    var error: Int32 = CL_SUCCESS
    let clPrograms: [cl_program?] = inputPrograms.map(\.clProgram)
    var clContext: cl_context?
    if inputPrograms.count > 0 {
      guard let ctx = inputPrograms[0].context else {
        CLError.latest!.message = "__LINK_PROGRAM_ERR"
        return nil
      }
      clContext = ctx.clContext
    }
    
    let prog = clLinkProgram(
      clContext, 0, nil, options, UInt32(inputPrograms.count), clPrograms,
      notifyFptr, data, &error)
    guard CLError.setCode(error, "__COMPILE_PROGRAM_ERR"),
          let prog = prog else {
      return nil
    }
    return CLProgram(prog)
  }
}
