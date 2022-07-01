// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftOpenCL",
  products: [
    .library(
      name: "OpenCL",
      targets: ["OpenCL"])
  ],
  dependencies: [

  ],
  targets: [
    // This module defines function signatures. It's too tedious to do so
    // manually in Swift. I just copied the headers at this link:
    // https://github.com/KhronosGroup/OpenCL-Headers
    //
    // COpenCL does not link any libraries, letting me bypass the restriction
    // on overriding system module names. I can freely use `OpenCL` in Swift
    // code while referring to SwiftOpenCL, rather than the Objective-C module
    // that Apple created.
    .target(
      name: "COpenCL",
      dependencies: []),
    
    // Where the magic happens.
    .target(
      name: "OpenCL",
      dependencies: ["COpenCL"],
      exclude: [
//        "Core",
//        "Custom",
//        "Utilities"
      ]),
    
    // The tests compile if I exclude all the Swift code that links to COpenCL
    // symbols in the module above. But I have to deactivate the tests until all
    // OpenCL symbols are converted to the dynamically loaded kind.
//    .testTarget(
//      name: "OpenCLTests",
//      dependencies: ["OpenCL"])
  ]
)
