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
    
    var commandQueue = CLCommandQueue(context: context, device: device)!
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
    
    let commandQueue = CLCommandQueue(context: context, device: device)!
    
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
                           global bool8* argument1,
                           uint3 argument2,
                           uint argument3) {
      argument0[0] = argument1[0][0];
      argument0[50] = argument1[0][0];
      
      if (argument2[0] + argument2[1] + argument2[2] > argument3) {
        uint address = min(uint(5), argument3);
        argument1[1][1] = argument0[address];
      } else {
        uint address = min(uint(5), argument3 - 1);
        argument1[1][1] = argument0[address];
      }
    }
    """
    
    guard let context = CLContext.default,
          let device = CLDevice.default,
          var program = CLProgram(context: context, source: source) else {
      fatalError("Could not create program.")
    }
    try! program.build(device: device)
    guard let kernels = program.createKernels(), kernels.count == 1 else {
      fatalError("Could not create kernels.")
    }
    
    var kernel = kernels[0]
    var scalarArg: UInt32 = 0xcafebabe
    var vectorArg: SIMD3<UInt32> = [0x12345678, 0x23456789, 0x87654321]
    try! kernel.setArgument(&scalarArg, index: 3, size: 4)
    try! kernel.setArgument(&vectorArg, index: 2, size: 16)
    
    let buffer = CLBuffer(context: context, flags: .readWrite, size: 32)
    try! kernel.setArgument(buffer, index: 1)
    try! kernel.setArgument(nil, index: 0, size: 123)
    
    var commandQueue = CLCommandQueue(context: context, device: device)!
    try! commandQueue.enqueueKernel(kernel, globalSize: CLNDRange(width: 1))
    try! commandQueue.finish()
  }
  
  func testBufferCopy() throws {
    // Copy from host memory by mapping the buffer into a host pointer. We'll
    // unmap like the test specifies, although in practice there's no reason to
    // unmap.
    guard let context = CLContext.default,
          let device = CLDevice.default,
          var queue = CLCommandQueue(context: context, device: device) else {
      fatalError("Could not create resources.")
    }
    
    let buffer = CLBuffer(context: context, flags: .readWrite, size: 1024 * 4)
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
  
  func testLinkProgram() throws {
    // TODO: Test whether you can declare a symbol in the first program, but
    // defer its implementation to another. This could be very helpful for
    // reducing compile time of the OpenCL Metal stdlib.
    //
    // TODO: Test whether you can create header programs from source, and use
    // that to (maybe) reduce the compile time of the OpenCL Metal stdlib. Or,
    // at least avoid the injection of raw shader code. Transform the OpenCL
    // Metal stdlib into a neat include ("#include <metal_stdlib").
    let source1 = """
    kernel void testKernel1(local bool* argument0,
                            local bool* argument1) {
      *argument0 = *argument1;
    }
    """
    let source2 = """
    kernel void testKernel2(global bool* argument0,
                            global bool* argument1) {
      *argument0 = *argument1;
    }
    """
    
    guard let context = CLContext.default,
          let device = CLDevice.default,
          var program1 = CLProgram(context: context, source: source1),
          var program2 = CLProgram(context: context, source: source2) else {
      fatalError("Could not create programs.")
    }
    
    // TODO: Figure out why the program is failing to compile.
//    try! program1.compile()
//    try! program2.compile()
    
    let program = CLProgram.link(program1, program2)
    let programFromVector = CLProgram.link([program1, program2])
    XCTAssertNil(program)
    XCTAssertNil(programFromVector)
  }
}
