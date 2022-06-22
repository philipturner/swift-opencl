//
//  Bitfields.swift
//  
//
//  Created by Philip Turner on 6/22/22.
//

import COpenCL

protocol CLMacro: OptionSet where RawValue: BinaryInteger {}
extension CLMacro {
  init(_ macro: Int32) {
    self.init(rawValue: RawValue(macro))
  }
}

public struct CLDeviceFPConfig: CLMacro {
  public let rawValue: cl_device_fp_config
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let denorm = Self(CL_FP_DENORM)
  public static let infNaN = Self(CL_FP_INF_NAN)
  public static let roundToNearest = Self(CL_FP_ROUND_TO_NEAREST)
  public static let roundToZero = Self(CL_FP_ROUND_TO_ZERO)
  public static let roundToInf = Self(CL_FP_ROUND_TO_INF)
  public static let fma = Self(CL_FP_FMA)
  public static let softFloat = Self(CL_FP_SOFT_FLOAT)
  public static let correctlyRoundedDivideSqrt =
    Self(CL_FP_CORRECTLY_ROUNDED_DIVIDE_SQRT)
}

public struct CLDeviceMemCacheType: CLMacro {
  public let rawValue: cl_device_mem_cache_type
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let none = Self(CL_NONE)
  public static let readOnlyCache = Self(CL_READ_ONLY_CACHE)
  public static let readWriteCache = Self(CL_READ_WRITE_CACHE)
}


public struct CLDeviceLocalMemType: CLMacro {
  public let rawValue: cl_device_local_mem_type
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let local = Self(CL_LOCAL)
  public static let global = Self(CL_GLOBAL)
}

public struct CLDeviceExecCapabilities: CLMacro {
  public let rawValue: cl_device_exec_capabilities
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let kernel = Self(CL_EXEC_KERNEL)
  public static let nativeKernel = Self(CL_EXEC_NATIVE_KERNEL)
}

public struct CLCommandQueueProperties: CLMacro {
  public let rawValue: cl_command_queue_properties
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let outOfOrderExecModeEnable =
    Self(CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE)
  public static let profilingEnable = Self(CL_QUEUE_PROFILING_ENABLE)
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let onDevice = Self(1 << 2)
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let onDeviceDefault = Self(1 << 3)
}

public struct CLContextProperties: CLMacro {
  public let rawValue: cl_context_properties
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let platform = Self(CL_CONTEXT_PLATFORM)
  public static let interopUserSync = Self(CL_CONTEXT_INTEROP_USER_SYNC)
}

public struct CLDevicePartitionProperty: CLMacro {
  public let rawValue: cl_device_partition_property
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let equally = Self(CL_DEVICE_PARTITION_EQUALLY)
  public static let byCounts = Self(CL_DEVICE_PARTITION_BY_COUNTS)
  public static let byCountsListEnd = Self(CL_DEVICE_PARTITION_BY_COUNTS_LIST_END)
  public static let byAffinityDomain = Self(CL_DEVICE_PARTITION_BY_AFFINITY_DOMAIN)
}

public struct CLDeviceAffinityDomain: CLMacro {
  public let rawValue: cl_device_affinity_domain
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let numa = Self(CL_DEVICE_AFFINITY_DOMAIN_NUMA)
  public static let l4Cache = Self(CL_DEVICE_AFFINITY_DOMAIN_L4_CACHE)
  public static let l3Cache = Self(CL_DEVICE_AFFINITY_DOMAIN_L3_CACHE)
  public static let l2Cache = Self(CL_DEVICE_AFFINITY_DOMAIN_L2_CACHE)
  public static let l1Cache = Self(CL_DEVICE_AFFINITY_DOMAIN_L1_CACHE)
  public static let nextPartitionable =
    Self(CL_DEVICE_AFFINITY_DOMAIN_NEXT_PARTITIONABLE)
}

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public struct CLDeviceSVMCapabilities: CLMacro {
  public let rawValue: cl_device_svm_capabilities
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let coarseGrainBuffer = Self(1 << 0)
  public static let fineGrainBuffer = Self(1 << 1)
  public static let fineGrainSystem = Self(1 << 2)
  public static let atomics = Self(1 << 3)
}

public struct CLMemFlags: CLMacro {
  public let rawValue: cl_mem_flags
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let readWrite = Self(CL_MEM_READ_WRITE)
  public static let writeOnly = Self(CL_MEM_WRITE_ONLY)
  public static let readOnly = Self(CL_MEM_READ_ONLY)
  public static let useHostPtr = Self(CL_MEM_USE_HOST_PTR)
  public static let allocHostPtr = Self(CL_MEM_ALLOC_HOST_PTR)
  public static let copyHostPtr = Self(CL_MEM_COPY_HOST_PTR)
  public static let hostWriteOnly = Self(CL_MEM_HOST_WRITE_ONLY)
  public static let hostReadOnly = Self(CL_MEM_HOST_READ_ONLY)
  public static let hostNoAccess = Self(CL_MEM_HOST_NO_ACCESS)
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let kernelReadAndWrite = Self(1 << 12)
}

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public struct CLSVMMemFlags: CLMacro {
  public let rawValue: cl_svm_mem_flags
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let readWrite = Self(CL_MEM_READ_WRITE)
  public static let writeOnly = Self(CL_MEM_WRITE_ONLY)
  public static let readOnly = Self(CL_MEM_READ_ONLY)
  public static let useHostPtr = Self(CL_MEM_USE_HOST_PTR)
  public static let allocHostPtr = Self(CL_MEM_ALLOC_HOST_PTR)
  public static let copyHostPtr = Self(CL_MEM_COPY_HOST_PTR)
  public static let hostWriteOnly = Self(CL_MEM_HOST_WRITE_ONLY)
  public static let hostReadOnly = Self(CL_MEM_HOST_READ_ONLY)
  public static let hostNoAccess = Self(CL_MEM_HOST_NO_ACCESS)
  
  public static let fineGrainBuffer = Self(1 << 10)
  public static let atomics = Self(1 << 11)
  public static let kernelReadAndWrite = Self(1 << 12)
}

public struct CLMemMigrationFlags: CLMacro {
  public let rawValue: cl_mem_migration_flags
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let objectHost = Self(CL_MIGRATE_MEM_OBJECT_HOST)
  public static let objectContentUndefined =
    Self(CL_MIGRATE_MEM_OBJECT_CONTENT_UNDEFINED)
}

public struct CLChannelOrder: CLMacro {
  public let rawValue: cl_channel_order
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let r = Self(CL_R)
  public static let a = Self(CL_A)
  public static let rg = Self(CL_RG)
  public static let ra = Self(CL_RA)
  public static let rgb = Self(CL_RGB)
  public static let rgba = Self(CL_RGBA)
  public static let bgra = Self(CL_BGRA)
  public static let argb = Self(CL_ARGB)
  public static let intensity = Self(CL_INTENSITY)
  public static let luminance = Self(CL_LUMINANCE)
  public static let rx = Self(CL_Rx)
  public static let rgx = Self(CL_RGx)
  public static let rgbx = Self(CL_RGBx)
  public static let depth = Self(CL_DEPTH)
  public static let depthStencil = Self(CL_DEPTH_STENCIL)
  
  // Making all characters lowercase. This looks like it violates the naming
  // convention used elsewhere, but it doesn't. `sRGB` is one word, similar to
  // how `ReLU` and `OpenCL` are all one word. It looks wierd to put `reLU` and
  // `openCL`, so it's better to make them `relu` and `opencl`. Regarding
  // "OpenCL C", another part of this API translated it `openclC`. This clearly
  // shows "opencl" came from one word and "C" came from another. The
  // alternative, `openCLC`, looks like something called "CLC" was very open.
  // I'd love to learn about the "CLC" programming language; please show me the
  // docs!
  //
  // Even worse, when translating "DirectX 12" to Swift, you could do
  // `directX12` instead of the lowercase `directx12`. Emphasis on the surprise
  // "X!". Imagine the fun Microsoft would have with that in an irreversible,
  // backwards-compatible API. Meanwhile, "Metal 3" becomes the beautiful
  // `metal3` no matter what we do. This favoring of Apple's graphics libraries
  // would sabotage our already finite efforts to make Swift something taken
  // seriously on Windows. Excellent work!
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let srgb = Self(0x10BF)
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let srgbx = Self(0x10C0)
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let srgba = Self(0x10C1)
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let sbgra = Self(0x10C2)
  
  // Part of OpenCL 2.0, but also part of an extension Apple made to earlier
  // versions. Not including it yet because I haven't decided on the naming
  // semantics.
//  #if canImport(Darwin)
//  public static let abgr = Self(CL_ABGR_APPLE)
//  #else
//  public static let abgr = Self(CL_ABGR)
//  #endif
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let abgr = Self(0x10C2)
}

public struct CLChannelType: CLMacro {
  public let rawValue: cl_channel_order
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let snormInt8 = Self(CL_SNORM_INT8)
  public static let snormInt16 = Self(CL_SNORM_INT16)
  public static let unormInt8 = Self(CL_UNORM_INT8)
  public static let unormInt16 = Self(CL_UNORM_INT16)
  public static let unormShort565 = Self(CL_UNORM_SHORT_565)
  public static let unormShort555 = Self(CL_UNORM_SHORT_555)
  public static let unormInt101010 = Self(CL_UNORM_INT_101010)
  public static let signedInt8 = Self(CL_SIGNED_INT8)
  public static let signedInt16 = Self(CL_SIGNED_INT16)
  public static let signedInt32 = Self(CL_SIGNED_INT32)
  public static let unsignedInt8 = Self(CL_UNSIGNED_INT8)
  public static let unsignedInt16 = Self(CL_UNSIGNED_INT16)
  public static let unsignedInt32 = Self(CL_UNSIGNED_INT32)
  public static let halfFloat = Self(CL_HALF_FLOAT)
  public static let float = Self(CL_FLOAT)
  public static let unormInt24 = Self(CL_UNORM_INT24)
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.1.")
  public static let unormInt1010102 = Self(0x10E0)
}
