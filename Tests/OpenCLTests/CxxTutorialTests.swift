import XCTest
import OpenCL

// Reproduction of the tutorial at this link:
// https://ulhpc-tutorials.readthedocs.io/en/latest/gpu/opencl/
final class CxxTutorialTests: XCTestCase {
  func testSimpleAdd() throws {
    // MARK: - Locating Device
    
    let allPlatforms = CLPlatform.all
    guard let allPlatforms, allPlatforms.count > 0 else {
      XCTFail("Could not retrieve platforms.")
      return
    }
    
    let defaultPlatform = allPlatforms[0]
    guard let platformName = defaultPlatform.name else {
      XCTFail("Could not retrieve platform name.")
      return
    }
    #if os(macOS)
    XCTAssertEqual(platformName, "Apple")
    #endif
    
    let allDevices = defaultPlatform.devices(type: .all)
    guard let allDevices, allDevices.count > 0 else {
      XCTFail("Could not retrieve devices.")
      return
    }
    
    let defaultDevice = allDevices[0]
    guard defaultDevice.name != nil else {
      XCTFail("Could not retrieve device name.")
      return
    }
    
    // MARK: - Creating Resources
    
    // TODO: Figure out why this is failing.
    let context = CLContext(device: defaultDevice) { errorInfo, _ in
      print("error info:", errorInfo)
    }
    print(context)
    print(CLError.latest?.localizedDescription)
    print(context?.numDevices)
    
    print(CLContext.default)
  }
}
