import XCTest
import OpenCL

// Reproduction of the tutorial at this link:
// https://ulhpc-tutorials.readthedocs.io/en/latest/gpu/opencl
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
    
    let queue = CLCommandQueue(context: context, device: defaultDevice)
    guard let queue else {
      fatalError("Could not create queue.")
    }
    
    
    
    // MARK: - Compile Sources
    
    var sources: [String] = []
    sources.append("""
    void kernel simple_add(
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
    void kernel other_add(
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
    
    guard var program = CLProgram(context: context, sources: sources) else {
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
    
    
    
  }
}
