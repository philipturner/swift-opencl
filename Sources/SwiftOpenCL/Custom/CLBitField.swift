//
//  CLBitField.swift
//  
//
//  Created by Philip Turner on 6/22/22.
//

import COpenCL

protocol CLMacro: RawRepresentable where RawValue: BinaryInteger {}
extension CLMacro {
  init(_ macro: Int32) {
    self.init(rawValue: RawValue(macro))!
  }
}

protocol CLBitField: CLMacro, OptionSet {}
extension CLBitField {
  init(_ macro: Int32) {
    self.init(rawValue: RawValue(macro))
  }
}

public struct CLDeviceType: CLBitField {
  public let rawValue: cl_device_type
  public init(rawValue: cl_device_type) {
    self.rawValue = rawValue
  }
  
  public static let `default` = Self(CL_DEVICE_TYPE_DEFAULT)
  public static let cpu = Self(CL_DEVICE_TYPE_CPU)
  public static let gpu = Self(CL_DEVICE_TYPE_GPU)
  public static let accelerator = Self(CL_DEVICE_TYPE_ACCELERATOR)
  public static let custom = Self(CL_DEVICE_TYPE_CUSTOM)
  
  // This type's raw value (0xFFFFFFFF) fills all bits, encompassing all
  // possible device types. Do not treat it like a unique device type.
  //
  // Because the `CL_DEVICE_TYPE_ALL` is larger than `Int32.max`, Swift imports
  // it as `UInt32`. This prevents me from initializing it like other device
  // types. The explicit cast to `Self` shows that the alternative initializer
  // cannot return `nil`.
  public static let all = Self(rawValue: RawValue(CL_DEVICE_TYPE_ALL)) as Self
}

public struct CLDeviceFloatingPointConfig: CLBitField {
  public let rawValue: cl_device_fp_config
  public init(rawValue: cl_device_fp_config) {
    self.rawValue = rawValue
  }
  
  public static let denorm = Self(CL_FP_DENORM)
  public static let infNaN = Self(CL_FP_INF_NAN)
  public static let roundToNearest = Self(CL_FP_ROUND_TO_NEAREST)
  public static let roundToZero = Self(CL_FP_ROUND_TO_ZERO)
  public static let roundToInf = Self(CL_FP_ROUND_TO_INF)
  public static let fma = Self(CL_FP_FMA)
  public static let softFloat = Self(CL_FP_SOFT_FLOAT)
  public static let correctlyRoundedDivideSqrt = Self(
    CL_FP_CORRECTLY_ROUNDED_DIVIDE_SQRT)
}

public struct CLDeviceMemoryCacheType: CLBitField {
  public let rawValue: cl_device_mem_cache_type
  public init(rawValue: cl_device_mem_cache_type) {
    self.rawValue = rawValue
  }
  
  public static let none = Self(CL_NONE)
  public static let readOnlyCache = Self(CL_READ_ONLY_CACHE)
  public static let readWriteCache = Self(CL_READ_WRITE_CACHE)
}

public struct CLDeviceLocalMemoryType: CLMacro {
  public let rawValue: cl_device_local_mem_type
  public init(rawValue: cl_device_local_mem_type) {
    self.rawValue = rawValue
  }
  
  public static let local = Self(CL_LOCAL)
  public static let global = Self(CL_GLOBAL)
}

public struct CLDeviceExecutionCapabilities: CLBitField {
  public let rawValue: cl_device_exec_capabilities
  public init(rawValue: cl_device_exec_capabilities) {
    self.rawValue = rawValue
  }
  
  public static let kernel = Self(CL_EXEC_KERNEL)
  public static let nativeKernel = Self(CL_EXEC_NATIVE_KERNEL)
}

public struct CLCommandQueueProperties: CLBitField {
  public let rawValue: cl_command_queue_properties
  public init(rawValue: cl_command_queue_properties) {
    self.rawValue = rawValue
  }
  
  public static let outOfOrderExecutionModeEnable = Self(
    CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE)
  public static let profilingEnable = Self(CL_QUEUE_PROFILING_ENABLE)
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let onDevice = Self(1 << 2)
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let onDeviceDefault = Self(1 << 3)
}

public struct CLDeviceAffinityDomain: CLBitField {
  public let rawValue: cl_device_affinity_domain
  public init(rawValue: cl_device_affinity_domain) {
    self.rawValue = rawValue
  }
  
  public static let numa = Self(CL_DEVICE_AFFINITY_DOMAIN_NUMA)
  public static let l4Cache = Self(CL_DEVICE_AFFINITY_DOMAIN_L4_CACHE)
  public static let l3Cache = Self(CL_DEVICE_AFFINITY_DOMAIN_L3_CACHE)
  public static let l2Cache = Self(CL_DEVICE_AFFINITY_DOMAIN_L2_CACHE)
  public static let l1Cache = Self(CL_DEVICE_AFFINITY_DOMAIN_L1_CACHE)
  public static let nextPartitionable = Self(
    CL_DEVICE_AFFINITY_DOMAIN_NEXT_PARTITIONABLE)
}

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public struct CLDeviceSVMCapabilities: CLBitField {
  public let rawValue: cl_device_svm_capabilities
  public init(rawValue: cl_device_svm_capabilities) {
    self.rawValue = rawValue
  }
  
  public static let coarseGrainBuffer = Self(1 << 0)
  public static let fineGrainBuffer = Self(1 << 1)
  public static let fineGrainSystem = Self(1 << 2)
  public static let atomics = Self(1 << 3)
}

public struct CLMemoryFlags: CLBitField {
  public let rawValue: cl_mem_flags
  public init(rawValue: cl_mem_flags) {
    self.rawValue = rawValue
  }
  
  public static let readWrite = Self(CL_MEM_READ_WRITE)
  public static let writeOnly = Self(CL_MEM_WRITE_ONLY)
  public static let readOnly = Self(CL_MEM_READ_ONLY)
  public static let useHostPointer = Self(CL_MEM_USE_HOST_PTR)
  public static let allocateHostPointer = Self(CL_MEM_ALLOC_HOST_PTR)
  public static let copyHostPointer = Self(CL_MEM_COPY_HOST_PTR)
  public static let hostWriteOnly = Self(CL_MEM_HOST_WRITE_ONLY)
  public static let hostReadOnly = Self(CL_MEM_HOST_READ_ONLY)
  public static let hostNoAccess = Self(CL_MEM_HOST_NO_ACCESS)
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let kernelReadAndWrite = Self(1 << 12)
}

// Not all `cl_mem_flags` from "cl.h" are SVM memory flags. Only flags described
// in the OpenCL 3.0 specification under `clSVMAlloc` are.
@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public struct CLSVMMemoryFlags: CLBitField {
  public let rawValue: cl_svm_mem_flags
  public init(rawValue: cl_svm_mem_flags) {
    self.rawValue = rawValue
  }
  
  public static let readWrite = Self(CL_MEM_READ_WRITE)
  public static let writeOnly = Self(CL_MEM_WRITE_ONLY)
  public static let readOnly = Self(CL_MEM_READ_ONLY)
  public static let fineGrainBuffer = Self(1 << 10)
  public static let atomics = Self(1 << 11)
}

public struct CLMemoryMigrationFlags: CLBitField {
  public let rawValue: cl_mem_migration_flags
  public init(rawValue: cl_mem_migration_flags) {
    self.rawValue = rawValue
  }
  
  public static let host = Self(CL_MIGRATE_MEM_OBJECT_HOST)
  public static let contentUndefined = Self(
    CL_MIGRATE_MEM_OBJECT_CONTENT_UNDEFINED)
}

public struct CLChannelOrder: CLMacro {
  public let rawValue: cl_channel_order
  public init(rawValue: cl_channel_order) {
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
  // "OpenCL C", other parts of this API translate it to `openclC`. This clearly
  // shows "opencl" came from one word and "C" came from another. The
  // alternative, `openCLC`, looks like something called "CLC" was very open.
  //
  // Even worse, when translating "DirectX 12" to Swift, you could do
  // `directX12` instead of the lowercase `directx12`. Emphasis on the surprise
  // "X!". Imagine the fun Microsoft would have with that in an irreversible,
  // backwards-compatible API. Meanwhile, "Metal 3" becomes the beautiful
  // `metal3` no matter what we do. This favoring of Apple's graphics libraries
  // would sabotage our already finite efforts to make Swift something taken
  // seriously on Windows.
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
  // semantics, if it (or any Apple extension) should be included at all.
//  #if canImport(Darwin)
//  public static let abgr = Self(CL_ABGR_APPLE)
//  #else
//  public static let abgr = Self(CL_ABGR)
//  #endif
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let abgr = Self(0x10C2)
}

public struct CLChannelType: CLMacro {
  public let rawValue: cl_channel_type
  public init(rawValue: cl_channel_type) {
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

public struct CLMemoryObjectType: CLMacro {
  public let rawValue: cl_mem_object_type
  public init(rawValue: cl_mem_object_type) {
    self.rawValue = rawValue
  }
  
  public static let buffer = Self(CL_MEM_OBJECT_BUFFER)
  public static let image2D = Self(CL_MEM_OBJECT_IMAGE2D)
  public static let image3D = Self(CL_MEM_OBJECT_IMAGE3D)
  public static let image2DArray = Self(CL_MEM_OBJECT_IMAGE2D_ARRAY)
  public static let image1D = Self(CL_MEM_OBJECT_IMAGE1D)
  public static let image1DArray = Self(CL_MEM_OBJECT_IMAGE1D_ARRAY)
  public static let image1DBuffer = Self(CL_MEM_OBJECT_IMAGE1D_BUFFER)
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let pipe = Self(0x10F7)
}

public struct CLAddressingMode: CLMacro {
  public let rawValue: cl_addressing_mode
  public init(rawValue: cl_addressing_mode) {
    self.rawValue = rawValue
  }
  
  public static let none = Self(CL_ADDRESS_NONE)
  public static let clampToEdge = Self(CL_ADDRESS_CLAMP_TO_EDGE)
  public static let clamp = Self(CL_ADDRESS_CLAMP)
  public static let `repeat` = Self(CL_ADDRESS_REPEAT)
  public static let mirroredRepeat = Self(CL_ADDRESS_MIRRORED_REPEAT)
}

public struct CLFilterMode: CLMacro {
  public let rawValue: cl_filter_mode
  public init(rawValue: cl_filter_mode) {
    self.rawValue = rawValue
  }
  
  public static let nearest = Self(CL_FILTER_NEAREST)
  public static let linear = Self(CL_FILTER_LINEAR)
}

public struct CLMapFlags: CLBitField {
  public let rawValue: cl_map_flags
  public init(rawValue: cl_map_flags) {
    self.rawValue = rawValue
  }
  
  public static let read = Self(CL_MAP_READ)
  public static let write = Self(CL_MAP_WRITE)
  public static let writeInvalidateRegion = Self(CL_MAP_WRITE_INVALIDATE_REGION)
}

public struct CLProgramBinaryType: CLMacro {
  public let rawValue: cl_program_binary_type
  public init(rawValue: cl_program_binary_type) {
    self.rawValue = rawValue
  }
  
  public static let none = Self(CL_PROGRAM_BINARY_TYPE_NONE)
  public static let compiledProject = Self(
    CL_PROGRAM_BINARY_TYPE_COMPILED_OBJECT)
  public static let library = Self(CL_PROGRAM_BINARY_TYPE_LIBRARY)
  public static let executable = Self(CL_PROGRAM_BINARY_TYPE_EXECUTABLE)
}

public struct CLBuildStatus: CLMacro {
  public let rawValue: cl_build_status
  public init(rawValue: cl_build_status) {
    self.rawValue = rawValue
  }
  
  public static let success = Self(CL_BUILD_SUCCESS)
  public static let none = Self(CL_BUILD_NONE)
  public static let error = Self(CL_BUILD_ERROR)
  public static let inProgress = Self(CL_BUILD_IN_PROGRESS)
}

public struct CLKernelArgumentAddressQualifier: CLMacro {
  public let rawValue: cl_kernel_arg_address_qualifier
  public init(rawValue: cl_kernel_arg_address_qualifier) {
    self.rawValue = rawValue
  }
  
  public static let global = Self(CL_KERNEL_ARG_ADDRESS_GLOBAL)
  public static let local = Self(CL_KERNEL_ARG_ADDRESS_LOCAL)
  public static let constant = Self(CL_KERNEL_ARG_ADDRESS_CONSTANT)
  public static let `private` = Self(CL_KERNEL_ARG_ADDRESS_PRIVATE)
}

public struct CLKernelArgumentAccessQualifier: CLMacro {
  public let rawValue: cl_kernel_arg_access_qualifier
  public init(rawValue: cl_kernel_arg_access_qualifier) {
    self.rawValue = rawValue
  }
  
  public static let readOnly = Self(CL_KERNEL_ARG_ACCESS_READ_ONLY)
  public static let writeOnly = Self(CL_KERNEL_ARG_ACCESS_WRITE_ONLY)
  public static let readWrite = Self(CL_KERNEL_ARG_ACCESS_READ_WRITE)
  public static let none = Self(CL_KERNEL_ARG_ACCESS_NONE)
}

public struct CLKernelArgumentTypeQualifier: CLBitField {
  public let rawValue: cl_kernel_arg_type_qualifier
  public init(rawValue: cl_kernel_arg_type_qualifier) {
    self.rawValue = rawValue
  }
  
  public static let none = Self(CL_KERNEL_ARG_TYPE_NONE)
  public static let const = Self(CL_KERNEL_ARG_TYPE_CONST)
  public static let restrict = Self(CL_KERNEL_ARG_TYPE_RESTRICT)
  public static let volatile = Self(CL_KERNEL_ARG_TYPE_VOLATILE)
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.1.")
  public static let pipe = Self(1 << 3)
}

public struct CLCommandType: CLMacro {
  public let rawValue: cl_command_type
  public init(rawValue: cl_command_type) {
    self.rawValue = rawValue
  }
  
  // Choosing `ndrange` instead of `ndRange` because it's one word, just like
  // "NDArray". Apple does something similar with
  // `MPSGraphTensorData.mpsndarray()`.
  public static let ndrangeKernel = Self(CL_COMMAND_NDRANGE_KERNEL)
  public static let task = Self(CL_COMMAND_TASK)
  public static let nativeKernel = Self(CL_COMMAND_NATIVE_KERNEL)
  public static let readBuffer = Self(CL_COMMAND_READ_BUFFER)
  public static let writeBuffer = Self(CL_COMMAND_WRITE_BUFFER)
  public static let copyBuffer = Self(CL_COMMAND_COPY_BUFFER)
  public static let readImage = Self(CL_COMMAND_READ_IMAGE)
  public static let writeImage = Self(CL_COMMAND_WRITE_IMAGE)
  public static let copyImage = Self(CL_COMMAND_COPY_IMAGE)
  public static let copyImageToBuffer = Self(CL_COMMAND_COPY_IMAGE_TO_BUFFER)
  public static let copyBufferToImage = Self(CL_COMMAND_COPY_BUFFER_TO_IMAGE)
  public static let mapBuffer = Self(CL_COMMAND_MAP_BUFFER)
  public static let mapImage = Self(CL_COMMAND_MAP_IMAGE)
  public static let unmapMemoryObject = Self(CL_COMMAND_UNMAP_MEM_OBJECT)
  public static let marker = Self(CL_COMMAND_MARKER)
  public static let acquireGLObjects = Self(CL_COMMAND_ACQUIRE_GL_OBJECTS)
  public static let releaseGLObjects = Self(CL_COMMAND_RELEASE_GL_OBJECTS)
  public static let readBufferRectangle = Self(CL_COMMAND_READ_BUFFER_RECT)
  public static let writeBufferRectangle = Self(CL_COMMAND_WRITE_BUFFER_RECT)
  public static let copyBufferRectangle = Self(CL_COMMAND_COPY_BUFFER_RECT)
  public static let user = Self(CL_COMMAND_USER)
  public static let barrier = Self(CL_COMMAND_BARRIER)
  public static let migrateMemoryObjects = Self(CL_COMMAND_MIGRATE_MEM_OBJECTS)
  public static let fillBuffer = Self(CL_COMMAND_FILL_BUFFER)
  public static let fillImage = Self(CL_COMMAND_FILL_IMAGE)
  
  // Not expanding `memfill` to `memoryFill` because then I must expand
  // `memcpy` to `memoryCopy`. "memcpy" is a widely known C function, along with
  // "free". I think the SVM is trying to emulate basic C memory manipulation
  // here.
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let svmFree = Self(0x1209)
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let svmMemcpy = Self(0x120A)
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let svmMemfill = Self(0x120B)
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let svmMap = Self(0x120C)
  @available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
  public static let svmUnmap = Self(0x120D)
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
  public static let svmMigrateMemory = Self(0x120E)
}

// No associated C typedef or enumeration in COpenCL. SwiftOpenCL synthesizes
// this new type for developer ergonomics. Should this declaration be `public`
// or `internal`?
public struct CLCommandExecutionStatus: CLMacro {
  public let rawValue: Int32
  public init(rawValue: Int32) {
    self.rawValue = rawValue
  }
  
  public static let complete = Self(CL_COMPLETE)
  public static let running = Self(CL_RUNNING)
  public static let submitted = Self(CL_SUBMITTED)
  public static let queued = Self(CL_QUEUED)
}

public struct CLBufferCreateType: CLMacro {
  public let rawValue: cl_buffer_create_type
  public init(rawValue: cl_buffer_create_type) {
    self.rawValue = rawValue
  }
  
  public static let region = Self(CL_BUFFER_CREATE_TYPE_REGION)
}

@available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
public struct CLDeviceAtomicCapabilities: CLBitField {
  public let rawValue: cl_device_atomic_capabilities
  public init(rawValue: cl_device_atomic_capabilities) {
    self.rawValue = rawValue
  }
  
  // Renaming atomic memory orderings to match their description in the OpenCL
  // 3.0 specification.
  public static let relaxed = Self(1 << 0)
  public static let acquireRelease = Self(1 << 1)
  public static let sequentiallyConsistent = Self(1 << 2)
  public static let scopeWorkItem = Self(1 << 3)
  public static let scopeWorkGroup = Self(1 << 4)
  public static let device = Self(1 << 5)
  public static let allDevices = Self(1 << 6)
}

// Having the word "Device" twice appears wierd, but it's not a typo. It means
// "device-side enqueue capabilities of a device". There are several other
// "capabilities of a device", such as the atomic capabilities defined above.
@available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
public struct CLDeviceDeviceEnqueueCapabilities: CLBitField {
  public let rawValue: cl_device_device_enqueue_capabilities
  public init(rawValue: cl_device_device_enqueue_capabilities) {
    self.rawValue = rawValue
  }
  
  public static let supported = Self(1 << 0)
  public static let replaceableDefault = Self(1 << 1)
}
