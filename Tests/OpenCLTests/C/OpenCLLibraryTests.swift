import XCTest
@testable import OpenCL

// Tests the dynamic symbol loader.
final class OpenCLLibraryTests: XCTestCase {
  func testLibraryLoading() throws {
    OpenCLLibrary.unitTestClear()
    try OpenCLLibrary.loadLibrary()
    
    do {
      OpenCLLibrary.unitTestUsingDefaultLibraryHandle = false
      defer { OpenCLLibrary.unitTestUsingDefaultLibraryHandle = true }
      
      // Test universal default library locations.
      #if canImport(Darwin) || os(Windows)
      OpenCLLibrary.unitTestClear()
      #if canImport(Darwin)
      OpenCLLibrary.useLibrary(at:
        "/System/Library/Frameworks/OpenCL.framework/Versions/A/OpenCL")
      #elseif os(Windows)
      OpenCLLibrary.useLibrary(at: "C:\\Windows\\System32\\opencl.dll")
      #endif
      try OpenCLLibrary.loadLibrary()
      #endif
      
      // Test what happens when the library path is invalid.
      OpenCLLibrary.unitTestClear()
      OpenCLLibrary.useLibrary(at: " ")
      XCTAssertNil(try? OpenCLLibrary.loadLibrary())
    }
    
    // Ensure that cleanup succeeds.
    OpenCLLibrary.unitTestClear()
    OpenCLLibrary.useLibrary(at: nil)
    try OpenCLLibrary.loadLibrary()
  }
}
