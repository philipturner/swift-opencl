//
//  CLVersion.swift
//  
//
//  Created by Philip Turner on 4/26/22.
//

import COpenCL

public struct CLVersion: Comparable {
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
  
  @inlinable
  public static func < (lhs: CLVersion, rhs: CLVersion) -> Bool {
    if lhs.major != rhs.major {
      return lhs.major < rhs.major
    }
    if lhs.minor != rhs.minor {
      return lhs.minor < rhs.minor
    }
    
    // Not having a patch is considered being "0" of the patch. If one side has
    // a patch and another doesn't, the versions will already be counted as not
    // equal. So determine a convention for comparing them.
    let lhsPatch = lhs.patch ?? 0
    let rhsPatch = rhs.patch ?? 0
    return lhsPatch < rhsPatch
  }
}

public struct CLNameVersion {
  public var version: CLVersion
  public var name: String
  
  @_transparent
  public init(version: CLVersion, name: String) {
    self.version = version
    self.name = name
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
    var error = clGetContextInfo(
      context, UInt32(CL_CONTEXT_DEVICES), 0, nil, &size)
    guard CLError.setCode(error),
          size > 0 else {
      return nil
    }
    let numDevices = size / MemoryLayout<cl_device_id?>.stride
    
    var deviceID: cl_device_id?
    withUnsafeTemporaryAllocation(
      of: cl_device_id?.self, capacity: numDevices
    ) { bufferPointer in
      let devices = bufferPointer.baseAddress.unsafelyUnwrapped
      error = clGetContextInfo(
        context, UInt32(CL_CONTEXT_DEVICES), size, devices, nil)
      deviceID = devices[0]
    }
    guard CLError.setCode(error),
          let deviceID = deviceID else {
      return nil
    }
    self.init(deviceID: deviceID)
  }
}

@available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
extension CLVersion {
  @usableFromInline static let majorBits = 10
  @usableFromInline static let minorBits = 10
  @usableFromInline static let patchBits = 12
  
  @usableFromInline static let majorMask: UInt32 = 1 << majorBits - 1
  @usableFromInline static let minorMask: UInt32 = 1 << minorBits - 1
  @usableFromInline static let patchMask: UInt32 = 1 << patchBits - 1
  
  @inlinable
  init(version: cl_version) {
    major = version
    minor = version
    var patch = version
    
    // Vectorize the bitwise AND.
    major &= Self.majorMask << (Self.minorBits + Self.patchBits)
    minor &= Self.minorMask << Self.patchBits
    patch &= Self.patchMask
    
    major >>= Self.minorBits + Self.patchBits
    minor >>= Self.patchBits
    self.patch = patch
  }
  
  @inlinable
  var version: cl_version {
    // Unwrapping of `patch` could induce a 1-cycle overhead, so waiting to
    // vectorize until later.
    var majorMask = major << (Self.minorBits + Self.patchBits)
    var minorMask = minor << Self.patchBits
    var patchMask = patch ?? 0
    
    // Vectorize the bitwise AND.
    majorMask &= Self.majorMask << (Self.minorBits + Self.patchBits)
    minorMask &= Self.minorMask << Self.patchBits
    patchMask &= Self.patchMask
    return majorMask | minorMask | patchMask
  }
}
