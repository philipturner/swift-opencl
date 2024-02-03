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
    
  }
}
