//
//  CLDevice+Properties.swift
//  
//
//  Created by Philip Turner on 5/20/22.
//

import COpenCL

extension CLDevice {
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetDeviceInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var type: CLDeviceType? {
    getInfo_CLMacro(CL_DEVICE_TYPE, getInfo)
  }
  
  public var vendorID: UInt32? {
    getInfo_Int(CL_DEVICE_VENDOR_ID, getInfo)
  }
  
  public var maxComputeUnits: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_COMPUTE_UNITS, getInfo)
  }
  
  public var maxWorkItemDimensions: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS, getInfo)
  }
  
  public var maxWorkGroupSize: Int? {
    getInfo_Int(CL_DEVICE_MAX_WORK_GROUP_SIZE, getInfo)
  }
  
  public var maxWorkItemSizes: [Int]? {
    getInfo_Array(CL_DEVICE_MAX_WORK_ITEM_SIZES, getInfo)
  }
  
  public var preferredVectorWidthChar: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR, getInfo)
  }
  
  public var preferredVectorWidthShort: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT, getInfo)
  }
  
  public var preferredVectorWidthInt: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT, getInfo)
  }
  
  public var preferredVectorWidthLong: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG, getInfo)
  }
  
  public var preferredVectorWidthFloat: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT, getInfo)
  }
  
  public var preferredVectorWidthDouble: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE, getInfo)
  }
  
  public var maxClockFrequency: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_CLOCK_FREQUENCY, getInfo)
  }
  
  public var maxAddressBits: UInt32? {
    getInfo_Int(CL_DEVICE_ADDRESS_BITS, getInfo)
  }
  
  public var maxReadImageArguments: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_READ_IMAGE_ARGS, getInfo)
  }
  
  public var maxWriteImageArguments: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_WRITE_IMAGE_ARGS, getInfo)
  }
  
  public var maxMemoryAllocationSize: UInt64? {
    getInfo_Int(CL_DEVICE_MAX_MEM_ALLOC_SIZE, getInfo)
  }
  
  public var image2DMaxWidth: Int? {
    getInfo_Int(CL_DEVICE_IMAGE2D_MAX_WIDTH, getInfo)
  }
  
  public var image2DMaxHeight: Int? {
    getInfo_Int(CL_DEVICE_IMAGE2D_MAX_HEIGHT, getInfo)
  }
  
  public var image3DMaxWidth: Int? {
    getInfo_Int(CL_DEVICE_IMAGE3D_MAX_WIDTH, getInfo)
  }
  
  public var image3DMaxHeight: Int? {
    getInfo_Int(CL_DEVICE_IMAGE3D_MAX_HEIGHT, getInfo)
  }
  
  public var image3DMaxDepth: Int? {
    getInfo_Int(CL_DEVICE_IMAGE3D_MAX_DEPTH, getInfo)
  }
  
  public var imageSupport: Bool? {
    getInfo_Bool(CL_DEVICE_IMAGE_SUPPORT, getInfo)
  }
  
  public var maxParameterSize: Int? {
    getInfo_Int(CL_DEVICE_MAX_PARAMETER_SIZE, getInfo)
  }
  
  public var maxSamplers: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_SAMPLERS, getInfo)
  }
  
  public var memoryBaseAddressAlign: UInt32? {
    getInfo_Int(CL_DEVICE_MEM_BASE_ADDR_ALIGN, getInfo)
  }
  
  public var minDataTypeAlignSize: UInt32? {
    getInfo_Int(CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE, getInfo)
  }
  
  public var singleFloatingPointConfig: CLDeviceFloatingPointConfig? {
    getInfo_CLMacro(CL_DEVICE_SINGLE_FP_CONFIG, getInfo)
  }
  
  public var doubleFloatingPointConfig: CLDeviceFloatingPointConfig? {
    getInfo_CLMacro(CL_DEVICE_DOUBLE_FP_CONFIG, getInfo)
  }
  
  public var halfFloatingPointConfig: CLDeviceFloatingPointConfig? {
    getInfo_CLMacro(CL_DEVICE_HALF_FP_CONFIG, getInfo)
  }
  
  public var globalMemoryCacheType: CLDeviceMemoryCacheType? {
    getInfo_CLMacro(CL_DEVICE_GLOBAL_MEM_CACHE_TYPE, getInfo)
  }
  
  public var globalMemoryCacheLineSize: UInt32? {
    getInfo_Int(CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE, getInfo)
  }
  
  public var globalMemoryCacheSize: UInt64? {
    getInfo_Int(CL_DEVICE_GLOBAL_MEM_CACHE_SIZE, getInfo)
  }
  
  public var globalMemorySize: UInt64? {
    getInfo_Int(CL_DEVICE_GLOBAL_MEM_SIZE, getInfo)
  }
  
  public var maxConstantBufferSize: UInt64? {
    getInfo_Int(CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE, getInfo)
  }
  
  public var maxConstantArguments: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_CONSTANT_ARGS, getInfo)
  }
  
  public var localMemoryType: CLDeviceLocalMemoryType? {
    getInfo_CLMacro(CL_DEVICE_LOCAL_MEM_TYPE, getInfo)
  }
  
  public var localMemorySize: UInt64? {
    getInfo_Int(CL_DEVICE_LOCAL_MEM_SIZE, getInfo)
  }
  
  public var errorCorrectionSupport: Bool? {
    getInfo_Bool(CL_DEVICE_ERROR_CORRECTION_SUPPORT, getInfo)
  }
  
  public var profilingTimerResolution: Int? {
    getInfo_Int(CL_DEVICE_PROFILING_TIMER_RESOLUTION, getInfo)
  }
  
  public var endianLittle: Bool? {
    getInfo_Bool(CL_DEVICE_ENDIAN_LITTLE, getInfo)
  }
  
  public var available: Bool? {
    getInfo_Bool(CL_DEVICE_AVAILABLE, getInfo)
  }
  
  public var executionCapabilities: CLDeviceExecutionCapabilities? {
    getInfo_CLMacro(CL_DEVICE_EXECUTION_CAPABILITIES, getInfo)
  }
  
  public var platform: CLPlatform? {
    getInfo_CLReferenceCountable(CL_DEVICE_PLATFORM, getInfo)
  }
  
  public var name: String? {
    getInfo_String(CL_DEVICE_NAME, getInfo)
  }
  
  public var vendor: String? {
    getInfo_String(CL_DEVICE_VENDOR, getInfo)
  }
  
  // The C macro `CL_DRIVER_VERSION` does not include the word "DEVICE".
  public var driverVersion: String? {
    getInfo_String(CL_DRIVER_VERSION, getInfo)
  }
  
  public var profile: String? {
    getInfo_String(CL_DEVICE_PROFILE, getInfo)
  }
  
  public var version: String? {
    getInfo_String(CL_DEVICE_VERSION, getInfo)
  }
  
  public var extensions: String? {
    getInfo_String(CL_DEVICE_EXTENSIONS, getInfo)
  }
  
  // OpenCL 1.1
  
  public var preferredVectorWidthHalf: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF, getInfo)
  }
  
  public var nativeVectorWidthChar: UInt32? {
    getInfo_Int(CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR, getInfo)
  }
  
  public var nativeVectorWidthShort: UInt32? {
    getInfo_Int(CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT, getInfo)
  }
  
  public var nativeVectorWidthInt: UInt32? {
    getInfo_Int(CL_DEVICE_NATIVE_VECTOR_WIDTH_INT, getInfo)
  }
  
  public var nativeVectorWidthLong: UInt32? {
    getInfo_Int(CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG, getInfo)
  }
  
  public var nativeVectorWidthFloat: UInt32? {
    getInfo_Int(CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT, getInfo)
  }
  
  public var nativeVectorWidthDouble: UInt32? {
    getInfo_Int(CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE, getInfo)
  }
  
  public var nativeVectorWidthHalf: UInt32? {
    getInfo_Int(CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF, getInfo)
  }
  
  public var openclCVersion: String? {
    getInfo_String(CL_DEVICE_OPENCL_C_VERSION, getInfo)
  }
  
  // OpenCL 1.2
  
  public var linkerAvailable: Bool? {
    getInfo_Bool(CL_DEVICE_LINKER_AVAILABLE, getInfo)
  }
  
  public var imageMaxBufferSize: Int? {
    getInfo_Int(CL_DEVICE_IMAGE_MAX_BUFFER_SIZE, getInfo)
  }
  
  public var imageMaxArraySize: Int? {
    getInfo_Int(CL_DEVICE_IMAGE_MAX_ARRAY_SIZE, getInfo)
  }
  
  public var parentDevice: CLDevice? {
    getInfo_CLReferenceCountable(CL_DEVICE_PARENT_DEVICE, getInfo)
  }
  
  public var partitionMaxSubDevices: UInt32? {
    getInfo_Int(CL_DEVICE_PARTITION_MAX_SUB_DEVICES, getInfo)
  }
  
  public var partitionProperties: [CLDevicePartitionProperty]? {
    getInfo_Array(CL_DEVICE_PARTITION_PROPERTIES, getInfo)
  }
  
  public var partitionType: [CLDevicePartitionProperty]? {
    getInfo_Array(CL_DEVICE_PARTITION_TYPE, getInfo)
  }
  
  public var referenceCount: UInt32? {
    getInfo_Int(CL_DEVICE_REFERENCE_COUNT, getInfo)
  }
  
  public var preferredInteropUserSync: Bool? {
    getInfo_Bool(CL_DEVICE_PREFERRED_INTEROP_USER_SYNC, getInfo)
  }
  
  public var partitionAffinityDomain: CLDeviceAffinityDomain? {
    getInfo_CLMacro(CL_DEVICE_PARTITION_AFFINITY_DOMAIN, getInfo)
  }
  
  public var builtInKernels: String? {
    getInfo_String(CL_DEVICE_BUILT_IN_KERNELS, getInfo)
  }
  
  public var printfBufferSize: Int? {
    getInfo_Int(CL_DEVICE_PRINTF_BUFFER_SIZE, getInfo)
  }
}

// OpenCL 2.0

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
extension CLDevice {
  // `CL_DEVICE_QUEUE_PROPERTIES` is deprecated, but it's the only way to fetch
  // that info on macOS. `CL_DEVICE_QUEUE_ON_HOST_PROPERTIES` has the same raw
  // value as the macro it deprecates. Should I make a property for the
  // deprecated one that's only available on macOS?
  //
  // Solution: Make something that's available on all platforms, but deprecated
  // on everything except macOS.
  public var queueOnHostProperties: CLCommandQueueProperties? {
    let name: Int32 = 0x102A
    #if !canImport(Darwin)
    assert(CL_DEVICE_QUEUE_ON_HOST_PROPERTIES == name)
    #endif
    return getInfo_CLMacro(name, getInfo)
  }
  
  public var queueOnDeviceProperties: CLCommandQueueProperties? {
    let name: Int32 = 0x104E
    #if !canImport(Darwin)
    assert(CL_DEVICE_QUEUE_ON_DEVICE_PROPERTIES == name)
    #endif
    return getInfo_CLMacro(name, getInfo)
  }
  
  public var queueOnDevicePreferredSize: UInt32? {
    let name: Int32 = 0x104F
    #if !canImport(Darwin)
    assert(CL_DEVICE_QUEUE_ON_DEVICE_PREFERRED_SIZE == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var queueOnDeviceMaxSize: UInt32? {
    let name: Int32 = 0x1050
    #if !canImport(Darwin)
    assert(CL_DEVICE_QUEUE_ON_DEVICE_MAX_SIZE == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var maxOnDeviceQueues: UInt32? {
    let name: Int32 = 0x1051
    #if !canImport(Darwin)
    assert(CL_DEVICE_MAX_ON_DEVICE_QUEUES == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var maxOnDeviceEvents: UInt32? {
    let name: Int32 = 0x1052
    #if !canImport(Darwin)
    assert(CL_DEVICE_MAX_ON_DEVICE_EVENTS == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var maxPipeArguments: UInt32? {
    let name: Int32 = 0x1055
    #if !canImport(Darwin)
    assert(CL_DEVICE_MAX_PIPE_ARGS == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var pipeMaxActiveReservations: UInt32? {
    let name: Int32 = 0x1056
    #if !canImport(Darwin)
    assert(CL_DEVICE_PIPE_MAX_ACTIVE_RESERVATIONS == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var pipeMaxPacketSize: UInt32? {
    let name: Int32 = 0x1057
    #if !canImport(Darwin)
    assert(CL_DEVICE_PIPE_MAX_PACKET_SIZE == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var svmCapabilities: CLDeviceSVMCapabilities? {
    let name: Int32 = 0x1053
    #if !canImport(Darwin)
    assert(CL_DEVICE_SVM_CAPABILITIES == name)
    #endif
    return getInfo_CLMacro(name, getInfo)
  }
  
  public var preferredPlatformAtomicAlignment: UInt32? {
    let name: Int32 = 0x1058
    #if !canImport(Darwin)
    assert(CL_DEVICE_PREFERRED_PLATFORM_ATOMIC_ALIGNMENT == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var preferredGlobalAtomicAlignment: UInt32? {
    let name: Int32 = 0x1059
    #if !canImport(Darwin)
    assert(CL_DEVICE_PREFERRED_GLOBAL_ATOMIC_ALIGNMENT == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var preferredLocalAtomicAlignment: UInt32? {
    let name: Int32 = 0x105A
    #if !canImport(Darwin)
    assert(CL_DEVICE_PREFERRED_LOCAL_ATOMIC_ALIGNMENT == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var imagePitchAlignment: UInt32? {
    let name: Int32 = 0x104A
    #if !canImport(Darwin)
    assert(CL_DEVICE_IMAGE_PITCH_ALIGNMENT == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var imageBaseAddressAlignment: UInt32? {
    let name: Int32 = 0x104B
    #if !canImport(Darwin)
    assert(CL_DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var maxReadWriteImageArguments: UInt32? {
    let name: Int32 = 0x104C
    #if !canImport(Darwin)
    assert(CL_DEVICE_MAX_READ_WRITE_IMAGE_ARGS == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var maxGlobalVariableSize: Int? {
    let name: Int32 = 0x104D
    #if !canImport(Darwin)
    assert(CL_DEVICE_MAX_GLOBAL_VARIABLE_SIZE == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var globalVariablePreferredTotalSize: Int? {
    let name: Int32 = 0x1054
    #if !canImport(Darwin)
    assert(CL_DEVICE_GLOBAL_VARIABLE_PREFERRED_TOTAL_SIZE == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
}

// OpenCL 2.1

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.1.")
extension CLDevice {
  public var maxNumSubGroups: UInt32? {
    let name: Int32 = 0x105C
    #if !canImport(Darwin)
    assert(CL_DEVICE_MAX_NUM_SUB_GROUPS == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var ilVersion: String? {
    let name: Int32 = 0x105B
    #if !canImport(Darwin)
    assert(CL_DEVICE_IL_VERSION == name)
    #endif
    return getInfo_String(name, getInfo)
  }
  
  public var subGroupIndependentForwardProgress: Bool? {
    let name: Int32 = 0x105D
    #if !canImport(Darwin)
    assert(CL_DEVICE_SUB_GROUP_INDEPENDENT_FORWARD_PROGRESS == name)
    #endif
    return getInfo_Bool(name, getInfo)
  }
}

// OpenCL 3.0

@available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
extension CLDevice {
  public var numericVersion: CLVersion? {
    let name: Int32 = 0x105E
    #if !canImport(Darwin)
    assert(CL_DEVICE_NUMERIC_VERSION == name)
    #endif
    if let rawVersion: cl_version = getInfo_Int(name, getInfo) {
      return CLVersion(version: rawVersion)
    } else {
      return nil
    }
  }
  
  public var extensionsWithVersion: [CLNameVersion]? {
    let name: Int32 = 0x1060
    #if !canImport(Darwin)
    assert(CL_DEVICE_EXTENSIONS_WITH_VERSION == name)
    #endif
    return getInfo_ArrayOfCLNameVersion(name, getInfo)
  }
  
  public var ilsWithVersion: [CLNameVersion]? {
    let name: Int32 = 0x1061
    #if !canImport(Darwin)
    assert(CL_DEVICE_ILS_WITH_VERSION == name)
    #endif
    return getInfo_ArrayOfCLNameVersion(name, getInfo)
  }
  
  public var builtInKernelsWithVersion: [CLNameVersion]? {
    let name: Int32 = 0x1062
    #if !canImport(Darwin)
    assert(CL_DEVICE_BUILT_IN_KERNELS_WITH_VERSION == name)
    #endif
    return getInfo_ArrayOfCLNameVersion(name, getInfo)
  }
  
  public var atomicMemoryCapabilities: CLDeviceAtomicCapabilities? {
    let name: Int32 = 0x1063
    #if !canImport(Darwin)
    assert(CL_DEVICE_ATOMIC_MEMORY_CAPABILITIES == name)
    #endif
    return getInfo_CLMacro(name, getInfo)
  }
  
  public var atomicFenceCapabilities: CLDeviceAtomicCapabilities? {
    let name: Int32 = 0x1064
    #if !canImport(Darwin)
    assert(CL_DEVICE_ATOMIC_FENCE_CAPABILITIES == name)
    #endif
    return getInfo_CLMacro(name, getInfo)
  }
  
  public var nonUniformWorkGroupSupport: Bool? {
    let name: Int32 = 0x1065
    #if !canImport(Darwin)
    assert(CL_DEVICE_NON_UNIFORM_WORK_GROUP_SUPPORT == name)
    #endif
    return getInfo_Bool(name, getInfo)
  }
  
  public var openclCAllVersions: [CLNameVersion]? {
    let name: Int32 = 0x1066
    #if !canImport(Darwin)
    assert(CL_DEVICE_OPENCL_C_ALL_VERSIONS == name)
    #endif
    return getInfo_ArrayOfCLNameVersion(name, getInfo)
  }
  
  public var preferredWorkGroupSizeMultiple: Int? {
    let name: Int32 = 0x1067
    #if !canImport(Darwin)
    assert(CL_DEVICE_PREFERRED_WORK_GROUP_SIZE_MULTIPLE == name)
    #endif
    return getInfo_Int(name, getInfo)
  }
  
  public var workGroupCollectiveFunctionsSupport: Bool? {
    let name: Int32 = 0x1068
    #if !canImport(Darwin)
    assert(CL_DEVICE_WORK_GROUP_COLLECTIVE_FUNCTIONS_SUPPORT == name)
    #endif
    return getInfo_Bool(name, getInfo)
  }
  
  public var genericAddressSpaceSupport: Bool? {
    let name: Int32 = 0x1069
    #if !canImport(Darwin)
    assert(CL_DEVICE_GENERIC_ADDRESS_SPACE_SUPPORT == name)
    #endif
    return getInfo_Bool(name, getInfo)
  }
  
  public var openclCFeatures: [CLNameVersion]? {
    let name: Int32 = 0x106F
    #if !canImport(Darwin)
    assert(CL_DEVICE_OPENCL_C_FEATURES == name)
    #endif
    return getInfo_ArrayOfCLNameVersion(name, getInfo)
  }
  
  public var deviceEnqueueCapabilities: CLDeviceDeviceEnqueueCapabilities? {
    let name: Int32 = 0x1070
    #if !canImport(Darwin)
    assert(CL_DEVICE_DEVICE_ENQUEUE_CAPABILITIES == name)
    #endif
    return getInfo_CLMacro(name, getInfo)
  }
  
  public var pipeSupport: Bool? {
    let name: Int32 = 0x1071
    #if !canImport(Darwin)
    assert(CL_DEVICE_PIPE_SUPPORT == name)
    #endif
    return getInfo_Bool(name, getInfo)
  }
  
  public var latestConformanceVersionPassed: String? {
    let name: Int32 = 0x1072
    #if !canImport(Darwin)
    assert(CL_DEVICE_LATEST_CONFORMANCE_VERSION_PASSED == name)
    #endif
    return getInfo_String(name, getInfo)
  }
}
