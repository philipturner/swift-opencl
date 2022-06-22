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
  public static let allocHostPtr = Self(CL_MEM_USE_HOST_PTR)
//  public static let useHostPtr = Self(CL_MEM_USE_HOST_PTR)
}

public extension CLMemFlags {
  @inlinable public func yo() {
    _ = Self(rawValue: (2 as Any as! RawValue)) as any OptionSet
  }
}
