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

extension CLVersion {
  @usableFromInline
  init?(clPlatformID: cl_platform_id) {
    var required = 0
    var error = clGetPlatformInfo(
      clPlatformID, UInt32(CL_PLATFORM_VERSION), 0, nil, &required)
    guard CLError.setCode(error),
          required > 7 else {
      return nil
    }
    
    major = 0
    minor = 0
    withUnsafeTemporaryAllocation(
      byteCount: required, alignment: MemoryLayout<Int8>.alignment
    ) { bufferPointer in
      let versionInfo = bufferPointer.getInfoBound(to: Int8.self)
      error = clGetPlatformInfo(
        clPlatformID, UInt32(CL_PLATFORM_VERSION), required, versionInfo, nil)
      
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
  
  @inlinable @inline(__always)
  public init?(platform: CLPlatform) {
    self.init(clPlatformID: platform.clPlatformID)
  }
  
  @usableFromInline
  init?(clDeviceID: cl_device_id) {
    var clPlatformID: cl_platform_id?
    let error = clGetDeviceInfo(
      clDeviceID, UInt32(CL_DEVICE_PLATFORM),
      MemoryLayout.stride(ofValue: clPlatformID), &clPlatformID, nil)
    guard CLError.setCode(error),
          let clPlatformID = clPlatformID else {
      return nil
    }
    self.init(clPlatformID: clPlatformID)
  }
  
  @inlinable @inline(__always)
  public init?(device: CLDevice) {
    self.init(clDeviceID: device.clDeviceID)
  }
  
  @usableFromInline
  init?(clContext: cl_context) {
    var required = 0
    var error = clGetContextInfo(
      clContext, UInt32(CL_CONTEXT_DEVICES), 0, nil, &required)
    guard CLError.setCode(error) else {
      return nil
    }
    guard required > 0 else {
      CLError.setCode(CLErrorCode.deviceNotFound.rawValue)
      return nil
    }
    
    var clDeviceID: cl_device_id?
    withUnsafeTemporaryAllocation(
      byteCount: required, alignment: MemoryLayout<cl_device_id?>.alignment
    ) { bufferPointer in
      let devices = bufferPointer.getInfoBound(to: cl_device_id?.self)
      error = clGetContextInfo(
        clContext, UInt32(CL_CONTEXT_DEVICES), required, devices, nil)
      clDeviceID = devices[0]
    }
    guard CLError.setCode(error),
          let clDeviceID = clDeviceID else {
      return nil
    }
    self.init(clDeviceID: clDeviceID)
  }
  
  @inlinable @inline(__always)
  public init?(context: CLContext) {
    self.init(clContext: context.clContext)
  }
}

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
