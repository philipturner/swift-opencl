import XCTest
import OpenCL

// Reproduction of the tutorial at this link:
// https://github.com/ULHPC/tutorials/blob/devel/gpu/opencl/code/exercise3.cpp
final class CxxTutorialTests: XCTestCase {
  func testSimpleAdd() throws {
    // MARK: - Locate Device
    
    let allPlatforms = CLPlatform.all
    guard let allPlatforms, allPlatforms.count > 0 else {
      fatalError("Could not retrieve platforms.")
    }
    
    let defaultPlatform = allPlatforms[0]
    guard let platformName = defaultPlatform.name else {
      fatalError("Could not retrieve platform name.")
    }
    #if os(macOS)
    XCTAssertEqual(platformName, "Apple")
    #endif
    
    let allDevices = defaultPlatform.devices(type: .all)
    guard let allDevices, allDevices.count > 0 else {
      fatalError("Could not retrieve devices.")
    }
    
    let defaultDevice = allDevices[0]
    guard defaultDevice.name != nil else {
      fatalError("Could not retrieve device name.")
    }
    
    // MARK: - Create Resources
    
    let context = CLContext(device: defaultDevice)
    let contextWithProperties = CLContext(
      device: defaultDevice,
      properties: [CLContextProperty.platform(defaultPlatform)])
    guard let context,
          let contextWithProperties,
          let numDevices = context.numDevices,
          numDevices > 0,
          contextWithProperties.numDevices == context.numDevices else {
      fatalError("Could not create context.")
    }
    
    let listSize: Int = 10
    let A_d = CLBuffer(context: context, flags: .readOnly, size: listSize * 4)
    let B_d = CLBuffer(context: context, flags: .readOnly, size: listSize * 4)
    let C_d = CLBuffer(context: context, flags: .readOnly, size: listSize * 4)
    let D_d = CLBuffer(context: context, flags: .writeOnly, size: listSize * 4)
    guard let A_d, let B_d, let C_d, let D_d else {
      fatalError("Could not create buffers.")
    }
    XCTAssertEqual(A_d.memory.size, 40)
    XCTAssertEqual(D_d.memory.size, 40)
    
    let A_h: [Int32] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    let B_h: [Int32] = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    let C_h: [Int32] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    let queue = CLCommandQueue(context: context, device: defaultDevice)
    guard let queue else {
      fatalError("Could not create queue.")
    }
    
    try! queue.enqueueWrite(A_d, offset: 0, size: listSize * 4, A_h)
    try! queue.enqueueWrite(B_d, offset: 0, size: listSize * 4, B_h)
    try! queue.enqueueWrite(C_d, offset: 0, size: listSize * 4, C_h)
    
    // MARK: - Compile Sources
    
    var sources: [String] = []
    sources.append("""
    kernel void simple_add(
      global const int* A,
      global const int* B,
      global int* C,
      global int* D
    ) {
      D[get_global_id(0)] =
      A[get_global_id(0)] +
      B[get_global_id(0)] +
      C[get_global_id(0)];
    }
    """)
    sources.append("""
    kernel void other_add(
      global const int* A,
      global const int* B,
      global int* C,
      global int* D
    ) {
      D[get_global_id(0)] =
      A[get_global_id(0)] +
      B[get_global_id(0)] -
      2 * C[get_global_id(0)];
    }
    """)
    
    guard let program = CLProgram(context: context, sources: sources) else {
      fatalError("Could not create program.")
    }
    try! program.build(device: defaultDevice)
    XCTAssertEqual(program.numKernels, 2)
    guard let kernelNames = program.kernelNames else {
      fatalError("Could not retrieve kernel names.")
    }
    XCTAssert(kernelNames.contains("simple_add"))
    XCTAssert(kernelNames.contains("other_add"))
    
    guard let kernels = program.createKernels() else {
      fatalError("Could not create kernels.")
    }
    XCTAssertEqual(kernels.count, 2)
    let simpleAdd = kernels.first(where: { $0.functionName == "simple_add" })
    let otherAdd = kernels.first(where: { $0.functionName == "other_add" })
    guard let simpleAdd, let otherAdd else {
      fatalError("Could not retrieve kernels.")
    }
    
    // MARK: - Encode Commands
    
    try! simpleAdd.setArgument(A_d, index: 0)
    try! simpleAdd.setArgument(B_d, index: 1)
    try! simpleAdd.setArgument(C_d, index: 2)
    try! simpleAdd.setArgument(D_d, index: 3)
    try! queue.enqueueKernel(simpleAdd, globalSize: CLNDRange(width: listSize))
    try! queue.finish()
    
    var D_h = [Int32](repeating: .zero, count: listSize)
    try! queue.enqueueRead(D_d, offset: 0, size: listSize * 4, &D_h)
    XCTAssertEqual(D_h, [11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
    
    try! otherAdd.setArgument(A_d, index: 0)
    try! otherAdd.setArgument(B_d, index: 1)
    try! otherAdd.setArgument(C_d, index: 2)
    try! otherAdd.setArgument(D_d, index: 3)
    try! queue.enqueueKernel(otherAdd, globalSize: CLNDRange(width: listSize))
    try! queue.finish()
    
    var otherD_h = [Int32](repeating: .zero, count: listSize)
    try! queue.enqueueRead(D_d, offset: 0, size: listSize * 4, &otherD_h)
    XCTAssertEqual(otherD_h, [8, 6, 4, 2, 0, -2, -4, -6, -8, -10])
  }
}
