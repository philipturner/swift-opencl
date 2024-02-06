import XCTest
import OpenCL

// Reproduction of a subset of the official Cxx tests:
// https://github.com/KhronosGroup/OpenCL-CLHPP/blob/main/tests/test_openclhpp.cpp
final class CxxTests: XCTestCase {
  func testCommandQueue() throws {
    guard let platform = CLPlatform.default,
          let device = platform.devices(type: .gpu)?.first,
          let context = CLContext(device: device) else {
      fatalError("Could not create resources.")
    }
    
    let commandQueue = CLCommandQueue(context: context, device: device)!
    XCTAssertEqual(commandQueue.context!.clContext, context.clContext)
    XCTAssertEqual(commandQueue.device!.clDeviceID, device.clDeviceID)
    
    var propertiesCombinations: [CLCommandQueueProperties] = []
    propertiesCombinations.append([])
    propertiesCombinations.append([.profilingEnable])
    
    for combination in propertiesCombinations {
      guard let commandQueue = CLCommandQueue(
        context: context, device: device, properties: combination) else {
        XCTFail(
          "Could not create command queue with properties: \(combination).")
        continue
      }
      XCTAssertEqual(commandQueue.context!.clContext, context.clContext)
      XCTAssertEqual(commandQueue.device!.clDeviceID, device.clDeviceID)
    }
  }
  
  func testBufferConstructor() throws {
    guard let platform = CLPlatform.default,
          let device = platform.devices(type: .gpu)?.first,
          let context = CLContext(device: device) else {
      fatalError("Could not create resources.")
    }
    
    var host = [Int32](repeating: .zero, count: 1024)
    var buffer = CLBuffer(
      context: context, flags: [.readWrite], size: 1024 * 4)
    XCTAssertNotNil(buffer)
    
    buffer = CLBuffer(
      context: context, flags: [.readWrite, .useHostPointer],
      size: 1024 * 4, hostPointer: &host)
    XCTAssertNotNil(buffer)
  }
  
  func testKernelArgument() throws {
    let source = """
    kernel void testKernel(local bool* argument0,
                           global uchar8* argument1,
                           uint3 argument2,
                           uint argument3) {
      argument0[0] = argument1[0][0];
      argument0[50] = argument1[0][0];
      
      uint constant5 = 5;
      uint constant1 = 1;
      if (argument2[0] + argument2[1] + argument2[2] > argument3) {
        uint address = min(constant5, argument3);
        argument1[1][1] = argument0[address];
      } else {
        uint address = min(constant5, argument3 - constant1);
        argument1[1][1] = argument0[address];
      }
    }
    """
    
    guard let context = CLContext.default,
          let device = CLDevice.default,
          let program = CLProgram(context: context, source: source) else {
      fatalError("Could not create program.")
    }
    do {
      try program.build(device: device)
    } catch {
      fatalError(
        "Could not build program: \(program.buildLog(device: device) ?? "n/a")")
    }
    guard let kernels = program.createKernels(), kernels.count == 1 else {
      fatalError("Could not create kernels.")
    }
    
    let kernel = kernels[0]
    var scalarArg: UInt32 = 0xcafebabe
    var vectorArg: SIMD3<UInt32> = [0x12345678, 0x23456789, 0x87654321]
    try! kernel.setArgument(&scalarArg, index: 3, size: 4)
    try! kernel.setArgument(&vectorArg, index: 2, size: 16)
    
    let buffer = CLBuffer(context: context, flags: .readWrite, size: 32)
    try! kernel.setArgument(buffer, index: 1)
    try! kernel.setArgument(nil, index: 0, size: 123)
    
    let commandQueue = CLCommandQueue(context: context, device: device)!
    try! commandQueue.enqueueKernel(kernel, globalSize: CLNDRange(width: 1))
    try! commandQueue.finish()
  }
  
  func testBufferCopy() throws {
    // Copy from host memory by mapping the buffer into a host pointer. We'll
    // unmap like the test specifies, although in practice there's no reason to
    // unmap.
    guard let context = CLContext.default,
          let device = CLDevice.default,
          let queue = CLCommandQueue(context: context, device: device) else {
      fatalError("Could not create resources.")
    }
    
    let flags: CLMemoryFlags = [.readWrite, .allocateHostPointer]
    let buffer = CLBuffer(context: context, flags: flags, size: 1024 * 4)
    guard let buffer else {
      fatalError("Could not create buffer.")
    }
    var host: [Int32] = []
    for i in 0..<1024 {
      host.append(Int32(i))
    }
    
    let pointer = try! queue.enqueueMap(
      buffer, flags: [.read, .write], offset: 0, size: 1024 * 4)
    let casted = pointer.assumingMemoryBound(to: Int32.self)
    casted.initialize(from: host, count: 1024)
    try! queue.enqueueUnmap(buffer, pointer)
    
    var someHostMemory = [Int32](repeating: .zero, count: 1024)
    try! queue.enqueueRead(buffer, offset: 0, size: 1024 * 4, &someHostMemory)
    XCTAssertEqual(host, someHostMemory)
  }
  
  func testSetDefault() throws {
    let platform = CLPlatform.default
    XCTAssertNotNil(CLPlatform.default)
    CLPlatform.default = nil
    XCTAssertNil(CLPlatform.default)
    CLPlatform.default = platform
    XCTAssertNotNil(CLPlatform.default)
    
    let device = CLDevice.default
    XCTAssertNotNil(CLDevice.default)
    CLDevice.default = nil
    XCTAssertNil(CLDevice.default)
    CLDevice.default = device
    XCTAssertNotNil(CLDevice.default)
    
    let context = CLContext.default
    XCTAssertNotNil(CLContext.default)
    CLContext.default = nil
    XCTAssertNil(CLContext.default)
    CLContext.default = context
    XCTAssertNotNil(CLContext.default)
    
    let queue = CLCommandQueue.default
    XCTAssertNotNil(CLCommandQueue.default)
    CLCommandQueue.default = nil
    XCTAssertNil(CLCommandQueue.default)
    CLCommandQueue.default = queue
    XCTAssertNotNil(CLCommandQueue.default)
  }
  
  func testBuiltInKernels() throws {
    guard let device = CLDevice.default else {
      fatalError("Could not create device.")
    }
    
    // The GPU should not be an FPGA.
    XCTAssertEqual(device.builtInKernels, [])
  }
  
  func testProgramBinary() throws {
    let source = """
    float functionA(float x);
    float functionB(float x);
    
    // evaluates C = 2 * A + B^2
    kernel void bufferFilter(global float *bufferA,
                             global float *bufferB,
                             global float *bufferC) {
      float valueA = bufferA[0];
      float valueB = bufferB[0];
      valueA = functionA(valueA);
      valueB = functionB(valueB);
      bufferC[0] = valueA + valueB;
    }
    
    kernel void unusedFunction() {
    
    }
    
    float functionA(float x) {
      return x + x;
    }
    
    float functionB(float x) {
      return x * x;
    }
    """
    
    // Create the original program.
    guard let context = CLContext.default,
          let device = CLDevice.default,
          let program = CLProgram(context: context, source: source) else {
      fatalError("Could not create context.")
    }
    do {
      try program.build(devices: context.devices!)
    } catch {
      fatalError(
        "Could not build program: \(program.buildLog(device: device) ?? "n/a")")
    }
    XCTAssertEqual(
      program.kernelNames?.sorted(), 
      ["bufferFilter", "unusedFunction"])
    
    // Extract the binary.
    guard let binaries = program.binaries,
          let devices = program.devices else {
      fatalError("Could not create binary.")
    }
    XCTAssertGreaterThan(devices.count, 0)
    XCTAssertLessThan(devices.count, 1_000)
    XCTAssertEqual(binaries.count, devices.count)
    
    // Inspect the binary sizes.
    let binarySizes = program.binarySizes!
    XCTAssertEqual(context.devices!.count, program.devices!.count)
    XCTAssertEqual(binarySizes.count, devices.count)
    XCTAssert(binarySizes.allSatisfy { $0 > 0 })
    
    // Create another program with the binary.
    for usingBinaryStatus in [true, false] {
      var loadedProgram: CLProgram?
      if usingBinaryStatus {
        loadedProgram = CLProgram(
          context: context, devices:
            program.devices!, binaries:
            program.binaries!)
      } else {
        var binaryStatus: [Int32] = []
        loadedProgram = CLProgram(
          context: context, 
          devices: program.devices!,
          binaries: program.binaries!,
          binaryStatus: &binaryStatus)
        let expected = Array(
          repeating: CLErrorCode.success.rawValue, count: binaries.count)
        XCTAssertEqual(binaryStatus, expected)
      }
      
      guard let loadedProgram else {
        XCTFail("Could not create program for 'usingBinaryStatus = \(usingBinaryStatus)'.")
        continue
      }
      do {
        try loadedProgram.build()
      } catch {
        for (deviceID, device) in program.devices!.enumerated() {
          var message: String
          if let log = loadedProgram.buildLog(device: device) {
            message = "Encountered build error. Build log: \(log)"
          } else {
            message = "No build log available."
          }
          print("Device \(deviceID): \(message)")
        }
        continue
      }
      XCTAssertEqual(loadedProgram.numKernels, 2)
      XCTAssertEqual(
        loadedProgram.kernelNames?.sorted(),
        ["bufferFilter", "unusedFunction"])
      
      // Create resources for a GPU command.
      let kernelIndex = loadedProgram.kernelNames!
        .firstIndex(of: "bufferFilter")!
      let kernel = loadedProgram.createKernels()![kernelIndex]
      let flags: CLMemoryFlags = [.readWrite, .allocateHostPointer]
      let bufferA = CLBuffer(context: context, flags: flags, size: 4)!
      let bufferB = CLBuffer(context: context, flags: flags, size: 4)!
      let bufferC = CLBuffer(context: context, flags: flags, size: 4)!
      let queue = CLCommandQueue.default!
      
      let buffers = [bufferA, bufferB, bufferC]
      var pointers: [UnsafeMutablePointer<Float>] = []
      for buffer in buffers {
        let pointer = try! queue
          .enqueueMap(buffer, flags: [.read, .write], offset: 0, size: 4)
          .assumingMemoryBound(to: Float.self)
        pointers.append(pointer)
      }
      
      // Encode the arguments for a GPU command.
      try! kernel.setArgument(bufferA, index: 0)
      pointers[0].pointee = 6
      pointers[1].pointee = 7
      pointers[2].pointee = -2
      try! kernel.setArgument(bufferB, index: 1)
      try! kernel.setArgument(bufferC, index: 2)
      
      // Issue a GPU command.
      try! queue.enqueueKernel(kernel, globalSize: CLNDRange(width: 1))
      try! queue.finish()
      XCTAssertEqual(2 * 6 + 7 * 7, pointers[2].pointee)
    }
  }
  
  func testBuildLog() throws {
    // Ensure the OpenCL compiler fails on an invalid program and reports the
    // failure to the log. Afterward, the compiler should successfully compile
    // a valid program.
    guard let context = CLContext.default,
          let device = CLDevice.default else {
      fatalError("Could not create context and device.")
    }
    
    let invalidSource = """
    kernel void invalidFunction(global float *bufferA,
                                global float *bufferB) {
      bufferE[0] = bufferA[0];
    }
    """
    let validSource = """
    kernel void validFunction(global float *bufferA,
                              global float *bufferB) {
      bufferB[0] = bufferA[0];
    }
    """
    
    let invalidProgram = CLProgram(context: context, source: invalidSource)
    let validProgram = CLProgram(context: context, source: validSource)
    guard let invalidProgram,
          let validProgram else {
      fatalError("Could not create programs.")
    }
    
    // The Swift compiler confuses 'CLBuildStatus.none' with 'Optional.none',
    // so we explicitly unwrap the optional.
    XCTAssertEqual(invalidProgram.buildStatus(device: device)!, .none)
    XCTAssertThrowsError(try invalidProgram.build())
    XCTAssertEqual(invalidProgram.buildOptions(device: device), "")
    XCTAssertEqual(invalidProgram.buildStatus(device: device), .error)
    
    let invalidLog = invalidProgram.buildLog(device: device)!
    XCTAssert(invalidLog.contains("bufferE"))
    
    XCTAssertEqual(validProgram.buildStatus(device: device)!, .none)
    XCTAssertNoThrow(try validProgram.build())
    XCTAssertEqual(validProgram.buildOptions(device: device), "")
    XCTAssertEqual(validProgram.buildStatus(device: device), .success)
    
    let validLog = validProgram.buildLog(device: device)!
    XCTAssert(!validLog.contains(where: { $0.isLetter }))
  }
  
  func testVersion() throws {
    guard let platform = CLPlatform.default,
          let platformVersion = platform.version,
          let device = CLDevice.default,
          let deviceVersion = device.version,
          let openclCVersion = device.openclCVersion else {
      fatalError("Could not create versions.")
    }
    let versions = [platformVersion, deviceVersion, openclCVersion]
    
    for version in versions {
      var openclLocation: String.Index?
    outer:
      for i in version.indices {
        guard version[i] == "O" else {
          continue
        }
        let opencl = "OpenCL"
        
        var versionIterator = i
        var openclIterator = opencl.indices.first!
        for _ in 0..<6 {
          let versionLetter = version[versionIterator]
          let openclLetter = opencl[openclIterator]
          guard versionLetter == openclLetter else {
            continue outer
          }
          versionIterator = version.index(after: versionIterator)
          openclIterator = opencl.index(after: openclIterator)
        }
        openclLocation = i
        break
      }
      guard let openclLocation else {
        fatalError("Could not locate OpenCL in version string.")
      }
      
      var cursor = openclLocation
      XCTAssertEqual(version[cursor], "O")
      for _ in 0..<6 {
        cursor = version.index(after: cursor)
      }
      XCTAssertEqual(version[cursor], " ")
      
      // Skip the "C" character, if it exists.
      cursor = version.index(after: cursor)
      if version[cursor] == "C" {
        cursor = version.index(after: cursor)
        cursor = version.index(after: cursor)
      }
      
      // Locate the major version.
      let major = version[cursor].asciiValue! - Character("0").asciiValue!
      
      // Locate the minor version.
      cursor = version.index(after: cursor)
      XCTAssertEqual(version[cursor], ".")
      cursor = version.index(after: cursor)
      let minor = version[cursor].asciiValue! - Character("0").asciiValue!
      
      let clVersion = CLVersion(major: UInt32(major), minor: UInt32(minor))
      let minimumVersion = CLVersion(major: 1, minor: 2)
      XCTAssertGreaterThanOrEqual(clVersion, minimumVersion)
      
      let maximumVersion = CLVersion(major: 10, minor: 10, patch: 10)
      XCTAssertLessThan(clVersion, maximumVersion)
    }
  }
  
  func testDevice() throws {
    guard let device = CLDevice.default else {
      fatalError("Could not retrieve device.")
    }
    
    XCTAssertNotNil(device.vendorID)
    XCTAssertNotNil(device.vendor)
    XCTAssertNotNil(device.name)
  }
}
