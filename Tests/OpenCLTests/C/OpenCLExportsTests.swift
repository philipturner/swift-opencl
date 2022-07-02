import XCTest
import OpenCL

// OpenCL should export COpenCL.
//
// Test that the C typedefs are exported from the header, but the C functions
// are exported from "OpenCLSymbols.swift". Each C function declaration in the
// headers is commented out to prevent you from doing something like
// `COpenCL.clGetPlatformIDs`. That would cause a compiler error because those
// C symbols are not linked.
final class OpenCLExportsTests: XCTestCase {
  func testTypealiasExports() throws {
    guard testPrecondition() else { return }
    
    _ = cl_platform_id.self
    _ = cl_device_id.self
    _ = cl_platform_id.self
    _ = cl_platform_id.self
    _ = cl_platform_id.self
    _ = cl_platform_id.self
    _ = cl_platform_id.self
    _ = cl_platform_id.self
    _ = cl_platform_id.self
    
    // Also test keypaths
  }
}
