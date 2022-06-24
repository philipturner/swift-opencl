//
//  CLVersion.swift
//  
//
//  Created by Philip Turner on 4/26/22.
//

import COpenCL

public struct CLVersion {
  // Using `UInt32` instead of `Int` to halve CPU register usage. Also, it's a
  // standard type to represent things across the OpenCL API. `cl_version` is
  // even a typealias of `UInt32`.
  public var major: UInt32
  public var minor: UInt32
  public var patch: UInt32?
  
  @_transparent
  public init(major: UInt32, minor: UInt32, patch: UInt32? = nil) {
    self.major = major
    self.minor = minor
    self.patch = patch
  }
}

// I wish I could pass the Swift wrapper types into the functions, but that is
// not possible inside the initializer of one of those wrappers (e.g.
// `CLDevice.init`). Also, the extension after this processes the raw
// `cl_version` integer. This at least creates a theme of initializing
// `CLVersion` with raw C-side stuff.
//
// An alternative is creating two sets of initializers - one for the Swift
// wrapper and one for the C type. That option creates ambiguity in
// `.init(context:)`, but most importantly, nearly identical ways to accomplish
// the same thing. That goes against the design principles of Swift.
extension CLVersion {
  public init?(platformID: cl_platform_id) {
    var size = 0
    var error = clGetPlatformInfo(
      platformID, UInt32(CL_PLATFORM_VERSION), 0, nil, &size)
    guard CLError.setCode(error),
          size > 7 else {
      return nil
    }
    
    major = 0
    minor = 0
    withUnsafeTemporaryAllocation(
      of: Int8.self, capacity: size
    ) { bufferPointer in
      let versionInfo = bufferPointer.baseAddress.unsafelyUnwrapped
      error = clGetPlatformInfo(
        platformID, UInt32(CL_PLATFORM_VERSION), size, versionInfo, nil)
      
      // In these loops, each integer operation likely adds 1 cycle of overhead
      // because Swift guards against overflows, unless you prefix the ops with
      // "&". Memory accesses, integer multiplies, and the encapsulating
      // function call could dwarf this 1-cycle overhead. Also, it's better to
      // preserve the debugging advantages of overflow checking.
      var index = 7
      while versionInfo[index] != 0x2E /* Unicode for '.' */ {
        major *= 10
        major += UInt32(versionInfo[index] - 0x30) /* Unicode for '0' */
        index += 1
      }
      index += 1
      while versionInfo[index] != 0x20 /* Unicode for ' ' */ &&
            versionInfo[index] != 0x00 /* Unicode for '\0' */ {
        minor *= 10
        minor += UInt32(versionInfo[index] - 0x30) /* Unicode for '0' */
        index += 1
      }
    }
    guard CLError.setCode(error) else {
      return nil
    }
  }
  
  public init?(deviceID: cl_device_id) {
    var platformID: cl_platform_id?
    let error = clGetDeviceInfo(
      deviceID, UInt32(CL_DEVICE_PLATFORM),
      MemoryLayout.stride(ofValue: platformID), &platformID, nil)
    guard CLError.setCode(error),
          let platformID = platformID else {
      return nil
    }
    self.init(platformID: platformID)
  }
  
  /// Initialize with the raw C pointer to the context.
  // The argument label may be ambiguous because it could imply that you pass a
  // `CLContext`. However, I am following the naming convention established in
  // the two functions above.
  public init?(context: cl_context) {
    var size = 0
    fatalError()
  }
}

extension CLVersion {
  // init(rawCLVersion: cl_version)
  // var rawCLVersion: cl_version
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

func getVersion(info versionInfo: UnsafePointer<Int8>) -> (major: Int, minor: Int) {
  // In these loops, each integer operation likely adds 1 cycle of overhead
  // because Swift guards against overflows, unless you prefix the ops with "&".
  // Memory accesses, integer multiplies, and the encapsulating function call
  // could dwarf this 1-cycle overhead. Also, it's better to preserve the
  // debugging advantages of overflow checking.
  var highVersion = 0
  var lowVersion = 0
  var index = 7
  while versionInfo[index] != 0x2E /* Unicode for '.' */ {
    highVersion *= 10
    highVersion += Int(versionInfo[index] - 0x30) /* Unicode for '0' */
    index += 1
  }
  index += 1
  while versionInfo[index] != 0x20 /* Unicode for ' ' */ &&
        versionInfo[index] != 0x00 /* Unicode for '\0' */ {
    lowVersion *= 10
    lowVersion += Int(versionInfo[index] - 0x30) /* Unicode for '0' */
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
