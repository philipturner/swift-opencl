//
//  CLVersion.swift
//  
//
//  Created by Philip Turner on 4/26/22.
//

import COpenCL

// Merge this into `cl_version`.
public struct CLVersion {
  public var major: Int
  public var minor: Int
  public var patch: Int?
  
//  public init(major: Int, minor: Int, )
}

// Change these to initializers of `CLVersion`.

func getVersion(info versionInfo: UnsafePointer<Int8>) -> (major: Int, minor: Int) {
  var highVersion = 0
  var lowVersion = 0
  var index = 7
  while versionInfo[index] != Character(".").asciiValue! {
    highVersion *= 10
    highVersion += Character(.init(versionInfo[index])).wholeNumberValue!
    index += 1
  }
  index += 1
  while versionInfo[index] != Character(" ").asciiValue! &&
        versionInfo[index] != Character("\0").asciiValue! {
    lowVersion *= 10
    lowVersion += Character(.init(versionInfo[index])).wholeNumberValue!
    index += 1
  }
  return (highVersion, lowVersion)
}

func getVersion(platform: OpaquePointer) -> (major: Int, minor: Int) {
  var size = 0
  clGetPlatformInfo(platform, UInt32(CL_PLATFORM_VERSION), 0, nil, &size)
  
  let versionInfo: UnsafeMutablePointer<Int8> = .allocate(capacity: size)
  defer { versionInfo.deallocate() }
  clGetPlatformInfo(platform, UInt32(CL_PLATFORM_VERSION), size, versionInfo,
    &size)
  return getVersion(info: versionInfo)
}

func getVersion(device: OpaquePointer) -> (major: Int, minor: Int) {
  var platform: OpaquePointer?
  clGetDeviceInfo(device, UInt32(CL_DEVICE_PLATFORM), Int.bitWidth, &platform,
    nil)
  return getVersion(platform: platform!)
}

func getVersion(context: OpaquePointer) -> (major: Int, minor: Int) {
  // The platform cannot be queried directly, so we first have to grab a device
  // and obtain its context
  var size = 0
  clGetContextInfo(context, UInt32(CL_CONTEXT_DEVICES), 0, nil, &size)
  if (size == 0) {
    return (0, 0)
  }
  
  let devices: UnsafeMutablePointer<OpaquePointer> = .allocate(
    capacity: size / Int.bitWidth)
  defer { devices.deallocate() }
  clGetContextInfo(context, UInt32(CL_CONTEXT_DEVICES), size, devices, nil)
  return getVersion(device: devices[0])
}
