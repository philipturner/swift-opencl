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
  // If you're concerned about the CPU-side overhead of separating
  // initialization and building into two function calls, you can just call the
  // underlying C functions manually.
  //
  // I am also keeping the option to build with one source instead of an array
  // of sources. This creates multiple ways of accomplishing the same thing, but
  // has some benefits. For example, it eliminates the CPU-side overhead of
  // dynamically allocating array memory. Most importantly, this feature is in
  // the C++ bindings. Unless there is a compelling reason, the API should not
  // change when translating from C++ to Swift.
  public init?(context: CLContext, source: String) {
    var error: Int32 = CL_SUCCESS
    
    // This will copy the source's contents before passing it into the C
    // function. There is no alternative approach that's easy to implement.
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
  
  @inlinable
  public init?(source: String) {
    guard let context = CLContext.defaultContext else {
      return nil
    }
    self.init(context: context, source: source)
  }
  
  public init?(context: CLContext, sources: [String]) {
    var error: Int32 = CL_SUCCESS
    let n = sources.count
    
    // Instead of creating one large allocation and dividing it in two, I create
    // separate allocations for `strings` and `lengths`. This doubles the
    // chance that it will allocate on the stack instead of the heap.
    //
    // Violating the practice of indenting code after entering a new scope. This
    // bypasses the "pyramid of doom", which would make the code difficult to
    // read.
    var object_: cl_kernel?
    withUnsafeTemporaryAllocation(
      of: Int.self, capacity: n
    ) { bufferPointer in
      let lengths = bufferPointer.baseAddress.unsafelyUnwrapped
      
    withUnsafeTemporaryAllocation(
      of: UnsafePointer<Int8>?.self, capacity: n
    ) { bufferPointer in
      let strings = bufferPointer.baseAddress.unsafelyUnwrapped
      
      // Copying these strings is the only way to pass them into the C function.
      // This creates several function calls to `malloc`, and `free`.
      // `withUnsafeTemporaryAllocation` may eliminate 4 function calls on top
      // of that, but only as a one-time performance improvement. If `sources`
      // is very large, the overhead of copying strings could dwarf the
      // performance gains from temporary buffers. If `sources` is very small,
      // temporary buffers should measurably impact performance.
      for i in 0..<sources.count {
        let source = sources[i]
        let count = source.utf8.count
        source.withCString {
          let cString: UnsafeMutablePointer<Int8> = .allocate(capacity: count)
          
          // Should not create a function call into `memcpy` because it lowers
          // to `Builtin.copyArray`.
          cString.initialize(from: $0, count: count)
          strings[i] = UnsafePointer(cString)
        }
        lengths[i] = count
      }
      defer {
        for i in 0..<sources.count {
          strings[i]?.deallocate()
        }
      }
      
      object_ = clCreateProgramWithSource(
        context.clContext, UInt32(n), strings, lengths, &error)
    }
    }
    
    guard CLError.setCode(error, "__CREATE_PROGRAM_WITH_SOURCE_ERR"),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  @inlinable
  public init?(sources: [String]) {
    guard let context = CLContext.defaultContext else {
      return nil
    }
    self.init(context: context, sources: sources)
  }
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.1.")
  public init?(context: CLContext, il: Data) {
    var error: Int32 = CL_SUCCESS
    var object_: cl_context?
    il.withUnsafeBytes { bufferPointer in
      let il = bufferPointer.baseAddress.unsafelyUnwrapped
      let count = bufferPointer.count
      #if !canImport(Darwin)
      object_ = clCreateProgramWithIL(context.clContext, il, count, &error)
      #endif
    }
    guard CLError.setCode(error, "__CREATE_PROGRAM_WITH_IL_ERR"),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.1.")
  @inlinable
  public init?(il: Data) {
    guard let context = CLContext.defaultContext else {
      return nil
    }
    self.init(context: context, il: il)
  }
  
  // Unlike `init?(context:sources:)`, this function can get away with not
  // copying the contents of `binaries`. Apple's documentation warns to never
  // use the `Data`'s pointer outside the closure's scope, but I'm fine as long
  // as the `Data` is never mutated or deallocated. As a precaution, I ensured
  // that `binaries` does not deallocate until the relevant code has finished.
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
    guard binaries.count == devices.count else {
      CLError.setCode(CL_INVALID_VALUE, "__CREATE_PROGRAM_WITH_BINARY_ERR")
      return nil
    }
    
    var object_: cl_program?
    withExtendedLifetime(binaries) {
    
    withUnsafeTemporaryAllocation(
      of: Int.self, capacity: numDevices
    ) { bufferPointer in
      let lengths = bufferPointer.baseAddress.unsafelyUnwrapped
      
    withUnsafeTemporaryAllocation(
      of: UnsafePointer<UInt8>?.self, capacity: numDevices
    ) { bufferPointer in
      let images = bufferPointer.baseAddress.unsafelyUnwrapped
      
    withUnsafeTemporaryAllocation(
      of: cl_device_id?.self, capacity: numDevices
    ) { bufferPointer in
      let clDeviceIDs = bufferPointer.baseAddress.unsafelyUnwrapped
      for i in 0..<numDevices {
        binaries[i].withUnsafeBytes {
          lengths[i] = $0.count
          images[i] = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
        }
        clDeviceIDs[i] = devices[i].clDeviceID
      }
      
      if usingBinaryStatus {
        binaryStatus = Array(repeating: 0, count: numDevices)
        object_ = clCreateProgramWithBinary(
          context.clContext, UInt32(numDevices), clDeviceIDs, lengths, images,
          &binaryStatus!, &error)
      } else {
        object_ = clCreateProgramWithBinary(
          context.clContext, UInt32(numDevices), clDeviceIDs, lengths, images,
          nil, &error)
      }
    }
    }
    }
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
  
  // Differs from the C++ bindings, which make you combine `kernelNames` into
  // one string.
  public init?(context: CLContext, devices: [CLDevice], kernelNames: [String]) {
    var error: Int32 = CL_SUCCESS
    var object_: cl_program?
    withUnsafeTemporaryAllocation(
      of: cl_device_id?.self, capacity: devices.count
    ) { bufferPointer in
      let clDeviceIDs = bufferPointer.baseAddress.unsafelyUnwrapped
      for i in 0..<devices.count {
        clDeviceIDs[i] = devices[i].clDeviceID
      }
      
      // +1 for every semicolon in between kernels, +1 for the null terminator.
      var cStringLength = max(1, kernelNames.count)
      cStringLength += kernelNames.reduce(0) { $0 + $1.count }
      withUnsafeTemporaryAllocation(
        of: Int8.self, capacity: cStringLength
      ) { bufferPointer in
        var byteStream = bufferPointer.baseAddress.unsafelyUnwrapped
        for kernelName in kernelNames {
          let count = kernelName.utf8.count
          kernelName.withCString {
            // Should not create a function call into `memcpy` because it lowers
            // to `Builtin.copyArray`.
            byteStream.initialize(from: $0, count: count)
          }
          byteStream[count] = 0x3B /* Unicode for ';' */
          byteStream += count + 1
        }
        
        // Add a null terminator, potentially overwriting a semicolon added in
        // the last loop iteration above.
        let kernelNames = bufferPointer.baseAddress.unsafelyUnwrapped
        kernelNames[cStringLength - 1] = 0
        object_ = clCreateProgramWithBuiltInKernels(
          context.clContext, UInt32(devices.count), clDeviceIDs, kernelNames,
          &error)
      }
    }
    
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
  
  // Change `notify` to a single-line type declaration.
  public mutating func build(
    devices: [CLDevice],
    options: String? = nil,
    notify: ((CLProgram) -> Void)? = nil
  ) throws {
    try withUnsafeTemporaryAllocation(
      of: cl_device_id?.self, capacity: devices.count
    ) { bufferPointer in
      let clDeviceIDs = bufferPointer.baseAddress.unsafelyUnwrapped
      for i in 0..<devices.count {
        clDeviceIDs[i] = devices[i].clDeviceID
      }
      
      let callback = CLProgramCallback(notify)
      let buildError = clBuildProgram(
        wrapper.object, UInt32(devices.count), clDeviceIDs, options,
        callback.callback, callback.passRetained())
      try throwBuildCode(buildError, "__BUILD_PROGRAM_ERR")
    }
  }
  
  public mutating func build(
    device: CLDevice,
    options: String? = nil,
    notify: ((CLProgram) -> Void)? = nil
  ) throws {
    var clDeviceID: cl_device_id? = device.clDeviceID
    let callback = CLProgramCallback(notify)
    let buildError = clBuildProgram(
      wrapper.object, 1, &clDeviceID, options, callback.callback,
      callback.passRetained())
    try throwBuildCode(buildError, "__BUILD_PROGRAM_ERR")
  }
  
  public mutating func build(
    options: String? = nil,
    notify: ((CLProgram) -> Void)? = nil
  ) throws {
    let callback = CLProgramCallback(notify)
    let buildError = clBuildProgram(
      wrapper.object, 0, nil, options, callback.callback,
      callback.passRetained())
    try throwBuildCode(buildError, "__BUILD_PROGRAM_ERR")
  }
  
  public mutating func compile(
    options: String? = nil,
    notify: ((CLProgram) -> Void)? = nil
  ) throws {
    let callback = CLProgramCallback(notify)
    let buildError = clCompileProgram(
      wrapper.object, 0, nil, options, 0, nil, nil, callback.callback,
      callback.passRetained())
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
    _ value: Bool, index: UInt32
  ) throws {
    var ucValue = value ? UInt8.max : 0
    let error = clSetProgramSpecializationConstant(
      wrapper.object, index, MemoryLayout.stride(ofValue: ucValue), &ucValue)
    try CLError.throwCode(error, "__SET_PROGRAM_SPECIALIZATION_CONSTANT_ERR")
  }
  
  public mutating func setSpecializationConstant<T>(
    _ value: T, index: UInt32
  ) throws {
    var valueCopy = value
    let error = clSetProgramSpecializationConstant(
      wrapper.object, index, MemoryLayout<T>.stride, valueCopy)
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
  
//  public static func link(
//    _ input1: CLProgram,
//    _ input2: CLProgram,
//    options: String? = nil,
//    notify: ((CLProgram) -> Void)? = nil
//  ) -> CLProgram? {
//    var error: Int32 = CL_SUCCESS
//    guard let ctx = input1.context else {
//      CLError.latest!.message = "__LINK_PROGRAM_ERR"
//      return nil
//    }
//
//    let prog: cl_program? = withUnsafeTemporaryAllocation(
//      of: cl_program?.self, capacity: 2
//    ) { clPrograms in
//      clPrograms[0] = input1.clProgram
//      clPrograms[1] = input2.clProgram
//      return clLinkProgram(
//        ctx.clContext, 0, nil, options, 2, clPrograms.baseAddress, notifyFptr,
//        data, &error)
//    }
//    guard CLError.setCode(error, "__COMPILE_PROGRAM_ERR"),
//          let prog = prog else {
//      return nil
//    }
//    return CLProgram(prog)
//  }
  
  public static func link(
    _ inputPrograms: [CLProgram],
    options: String? = nil,
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
