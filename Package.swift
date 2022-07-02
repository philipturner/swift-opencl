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
    // This module defines function signatures in C because doing so manually in
    // Swift would be too tedious. I copied and edited the headers at this link:
    // https://github.com/KhronosGroup/OpenCL-Headers
    //
    // COpenCL does not link any libraries, letting me bypass the restriction
    // on overriding system module names. I can freely use `OpenCL` in Swift
    // code while referring to SwiftOpenCL, rather than the Objective-C module
    // that Apple created.
    //
    // Rather than specify a target OpenCL version, I silenced the warning
    // message in "cl_version.h".
    .target(
      name: "COpenCL",
      dependencies: []),
    
    // Where the magic happens.
    .target(
      name: "OpenCL",
      dependencies: ["COpenCL"],
      exclude: [
//        "C",
        "Core",
        "Custom",
        "Utilities",
        
        // Scripts
        "C/GenerateOpenCLSymbols.swift"
      ]),
    
    // The tests compile if I exclude all the Swift code that links to COpenCL
    // symbols in the module above. Otherwise, I must deactivate the tests until
    // all OpenCL symbols can be loaded at runtime.
    .testTarget(
      name: "OpenCLTests",
      dependencies: ["OpenCL"])
  ]
)
