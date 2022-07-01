// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftOpenCL",
  products: [
    .library(
      name: "SwiftOpenCL",
      targets: ["SwiftOpenCL"])
  ],
  dependencies: [

  ],
  targets: [
    // This module will be repurposed to define function signatures. It's too
    // tedious to do so manually in Swift. I will just modify "cl.h" from the
    // Khronos website.
    .target(
      name: "COpenCL",
      dependencies: []),
    // This module will eventually be renamed to OpenCL.
    .target(
      name: "SwiftOpenCL",
      dependencies: ["COpenCL"]),
    .testTarget(
      name: "SwiftOpenCLTests",
      dependencies: ["SwiftOpenCL"]),
  ]
)
