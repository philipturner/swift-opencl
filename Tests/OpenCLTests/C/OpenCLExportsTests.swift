import XCTest
import OpenCL

// Test that the C typedefs are exported from the header, but the C functions
// are exported from "OpenCLSymbols.swift". Must reference every possible
// C function because if one is incorrectly linked, the Swift compiler won't
// tell you.
final class OpenCLExportsTests: XCTestCase {
  func testSymbolLinking() throws {
    _ = clGetPlatformIDs
  }
}
