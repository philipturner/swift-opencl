import XCTest
@testable import OpenCL

// Lets tests fail gracefully when the library can't load. Otherwise, it would
// crash because of a `try!` statement in "OpenCLLibrary.swift".
//
// Usage (violates the convention of one statement per line):
// `guard testPrecondition() else { return }`
func testPrecondition() -> Bool {
  do {
    try OpenCLLibrary.loadLibrary()
  } catch {
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
    
    let environmentLibrary = OpenCLLibrary.unitTestGetEnvironmentLibrary()
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
    OpenCLLibrary.unitTestSetEnvironmentLibrary(environmentLibrary)
    
    // Ensure that cleanup succeeds.
    OpenCLLibrary.unitTestClear()
    try OpenCLLibrary.loadLibrary()
  }
}
