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
    do {
      try program.build(device: device)
    } catch let error {
      print(error.localizedDescription)
    }
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
    do {
      try commandQueue.enqueueKernel(kernel, globalSize: CLNDRange(width: 1))
    } catch let error {
      print(error.localizedDescription)
    }
    try! commandQueue.finish()
  }
}
