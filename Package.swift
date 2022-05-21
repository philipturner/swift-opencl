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
      name: "COpenCL",
      dependencies: []),
    .target(
      name: "SwiftOpenCL",
      dependencies: ["COpenCL"]),
    .testTarget(
      name: "SwiftOpenCLTests",
      dependencies: ["SwiftOpenCL"]),
  ]
)
