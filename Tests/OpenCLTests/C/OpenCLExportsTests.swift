import XCTest
import OpenCL

// Test that the C typedefs are exported from the header, but the C functions
// are exported from "OpenCLSymbols.swift". Each C function declaration in the
// headers is commented out to prevent you from doing something like
// `COpenCL.clGetPlatformIDs`. That would cause a compiler error because those
// C symbols are not linked.
final class OpenCLExportsTests: XCTestCase {
  // Load every symbol defined in the ICD dispatch table.
  func testSymbolLinking() throws {
    _ = clGetPlatformIDs
  }
}
