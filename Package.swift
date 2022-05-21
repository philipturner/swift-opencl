// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "OpenCL",
  platforms: [
    .macOS(.v10_10),
  ],
  products: [
    .library(
      name: "OpenCL",
      targets: ["SwiftOpenCL"]),
  ],
  dependencies: [

  ],
  targets: [
    .target(
      name: "COpenCL",
      dependencies: []),
    .target(
      name: "SwiftOpenCL",
      dependencies: ["COpenCL"],
      path: "Sources/OpenCL"),
    .testTarget(
      name: "SwiftOpenCLTests",
      dependencies: ["SwiftOpenCL"]),
  ]
)
