import XCTest
@testable import OpenCL

// Lets tests fail gracefully when the library can't load. Otherwise, it would
// crash because of a `try!` statement in "OpenCLLibrary.swift".
func testPrecondition(function: String = #function) -> Bool {
  do {
    try OpenCLLibrary.loadLibrary()
  } catch {
    print("""
      Warning: Skipping test `\(function)` because the OpenCL library did not \
      load.
      """)
    return false
  }
  return true
}

// Tests the dynamic symbol loader.
final class OpenCLLibraryTests: XCTestCase {
  func testGetPlatforms() throws {
    guard testPrecondition() else { return }
    
    var numPlatforms: UInt32 = 0
    var error = clGetPlatformIDs(0, nil, &numPlatforms)
    XCTAssertEqual(error, CL_SUCCESS)
    XCTAssertGreaterThan(numPlatforms, 0)
    
    var ids = [cl_platform_id?](repeating: nil, count: Int(numPlatforms))
    error = clGetPlatformIDs(numPlatforms, &ids, nil)
    XCTAssertEqual(error, CL_SUCCESS)
    XCTAssertFalse(ids.contains(nil))
  }
  
  func testLibraryLoading() throws {
    // Test whether the library loads automatically.
    OpenCLLibrary.unitTestClear()
    try OpenCLLibrary.loadLibrary()
    
    do {
      let environmentLibrary = OpenCLLibrary.unitTestGetEnvironment(.library)
      OpenCLLibrary.unitTestUsingDefaultLibraryHandle = false
      defer {
        OpenCLLibrary.unitTestSetEnvironment(.library, environmentLibrary)
        OpenCLLibrary.unitTestUsingDefaultLibraryHandle = true
      }
      
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
      XCTAssertThrowsError(try OpenCLLibrary.loadLibrary())
    }
    
    do {
      let environmentVersion = OpenCLLibrary.unitTestGetEnvironment(.version)
      defer {
        OpenCLLibrary.unitTestSetEnvironment(.version, environmentVersion)
      }
      
      // Do version testing on macOS, where the version is always 1.2.
      #if canImport(Darwin)
      OpenCLLibrary.unitTestClear()
      try OpenCLLibrary.loadLibrary()
      XCTAssertEqual(OpenCLLibrary.version, CLVersion(major: 1, minor: 2))
      
      // Specify the OpenCL version before loading.
      OpenCLLibrary.unitTestClear()
      OpenCLLibrary.setVersion(1, 2)
      try OpenCLLibrary.loadLibrary()
      
      // Specify an incorrect OpenCL version before loading.
      OpenCLLibrary.unitTestClear()
      OpenCLLibrary.setVersion(3, 0)
      XCTAssertThrowsError(try OpenCLLibrary.loadLibrary())
      #endif
    }
    
    // Ensure that cleanup succeeds.
    OpenCLLibrary.unitTestUsingDefaultLibraryHandle = true
    OpenCLLibrary.unitTestClear()
    try OpenCLLibrary.loadLibrary()
  }
}
