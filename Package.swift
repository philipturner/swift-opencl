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
    .target(
      name: "COpenCL", // This module will eventually be removed.
      dependencies: []),
    .target(
      name: "SwiftOpenCL", // This module will eventually be renamed to OpenCL.
      dependencies: ["COpenCL"]),
    .testTarget(
      name: "SwiftOpenCLTests",
      dependencies: ["SwiftOpenCL"]),
  ]
)
