// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-opencl",
  products: [
    .library(
      name: "CL",
      targets: ["CL"]),
  ],
  dependencies: [

  ],
  targets: [
    .target(
      name: "COpenCL",
      dependencies: []),
    .target(
      name: "CL",
      dependencies: ["COpenCL"]),
    .testTarget(
      name: "CLTests",
      dependencies: ["CL"]),
  ]
)
