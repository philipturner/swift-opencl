//
//  CLDevice+Info.swift
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
  
  // Parses the string returned by OpenCL and creates an array of extensions.
  public var extensions: [String]? {
    if let combined = getInfo_String(CL_DEVICE_EXTENSIONS, getInfo) {
      // Separated by spaces.
      let substrings = combined.split(
        separator: " ", omittingEmptySubsequences: true)
      return substrings.map(String.init)
    } else {
      return nil
    }
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
  
  public var partitionProperties: [CLDevicePartitionPropertyKey]? {
    getInfo_Array(CL_DEVICE_PARTITION_PROPERTIES, getInfo)
  }
  
  public var partitionType: CLDevicePartitionProperty? {
    var required = 0
    var error = getInfo(UInt32(CL_DEVICE_PARTITION_TYPE), 0, nil, &required)
    guard CLError.setCode(error) else {
      return nil
    }
    guard required > 0 else {
      CLError.setCode(CL_INVALID_PROPERTY)
      return nil
    }
    
    typealias RawValue = CLDevicePartitionProperty.Key.RawValue
    return withUnsafeTemporaryAllocation(
      byteCount: required, alignment: MemoryLayout<RawValue>.alignment
    ) { bufferPointer in
      let value = bufferPointer.getInfoBound(to: RawValue.self)
      error =  getInfo(UInt32(CL_DEVICE_PARTITION_TYPE), required, value, nil)
      guard CLError.setCode(error) else {
        return nil
      }
      
      guard let output = CLDevicePartitionProperty(buffer: value) else {
        CLError.setCode(CL_INVALID_PROPERTY)
        return nil
      }
      return output
    }
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
  
  // Parses the string returned by OpenCL and creates an array of kernels.
  public var builtInKernels: [String]? {
    if let combined = getInfo_String(CL_DEVICE_BUILT_IN_KERNELS, getInfo) {
      // Separated by semicolons.
      let substrings = combined.split(
        separator: ";", omittingEmptySubsequences: true)
      return substrings.map(String.init)
    } else {
      return nil
    }
  }
  
  public var printfBufferSize: Int? {
    getInfo_Int(CL_DEVICE_PRINTF_BUFFER_SIZE, getInfo)
  }
  
  // `CL_DEVICE_QUEUE_PROPERTIES` is deprecated by
  // `CL_DEVICE_QUEUE_ON_HOST_PROPERTIES`, but it's the only way to fetch that
  // info on macOS. Both macros have the same raw value, 0x102A. The new macro
  // was introduced in OpenCL 2.0, but its functionality existed in OpenCL 1.2.
  // Therefore, I exposed this property on macOS with a name that doesn't match
  // its macro.
  public var queueOnHostProperties: CLCommandQueueProperties? {
    getInfo_CLMacro(CL_DEVICE_QUEUE_ON_HOST_PROPERTIES, getInfo)
  }
  
  // OpenCL 2.0
  
  public var queueOnDeviceProperties: CLCommandQueueProperties? {
    getInfo_CLMacro(CL_DEVICE_QUEUE_ON_DEVICE_PROPERTIES, getInfo)
  }
  
  public var queueOnDevicePreferredSize: UInt32? {
    getInfo_Int(CL_DEVICE_QUEUE_ON_DEVICE_PREFERRED_SIZE, getInfo)
  }
  
  public var queueOnDeviceMaxSize: UInt32? {
    getInfo_Int(CL_DEVICE_QUEUE_ON_DEVICE_MAX_SIZE, getInfo)
  }
  
  public var maxOnDeviceQueues: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_ON_DEVICE_QUEUES, getInfo)
  }
  
  public var maxOnDeviceEvents: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_ON_DEVICE_EVENTS, getInfo)
  }
  
  public var maxPipeArguments: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_PIPE_ARGS, getInfo)
  }
  
  public var pipeMaxActiveReservations: UInt32? {
    getInfo_Int(CL_DEVICE_PIPE_MAX_ACTIVE_RESERVATIONS, getInfo)
  }
  
  public var pipeMaxPacketSize: UInt32? {
    getInfo_Int(CL_DEVICE_PIPE_MAX_PACKET_SIZE, getInfo)
  }
  
  public var svmCapabilities: CLDeviceSVMCapabilities? {
    getInfo_CLMacro(CL_DEVICE_SVM_CAPABILITIES, getInfo)
  }
  
  public var preferredPlatformAtomicAlignment: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_PLATFORM_ATOMIC_ALIGNMENT, getInfo)
  }
  
  public var preferredGlobalAtomicAlignment: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_GLOBAL_ATOMIC_ALIGNMENT, getInfo)
  }
  
  public var preferredLocalAtomicAlignment: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_LOCAL_ATOMIC_ALIGNMENT, getInfo)
  }
  
  public var imagePitchAlignment: UInt32? {
    getInfo_Int(CL_DEVICE_IMAGE_PITCH_ALIGNMENT, getInfo)
  }
  
  public var imageBaseAddressAlignment: UInt32? {
    getInfo_Int(CL_DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT, getInfo)
  }
  
  public var maxReadWriteImageArguments: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_READ_WRITE_IMAGE_ARGS, getInfo)
  }
  
  public var maxGlobalVariableSize: Int? {
    getInfo_Int(CL_DEVICE_MAX_GLOBAL_VARIABLE_SIZE, getInfo)
  }
  
  public var globalVariablePreferredTotalSize: Int? {
    getInfo_Int(CL_DEVICE_GLOBAL_VARIABLE_PREFERRED_TOTAL_SIZE, getInfo)
  }
  
  // OpenCL 2.1
  
  public var maxNumSubGroups: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_NUM_SUB_GROUPS, getInfo)
  }
  
  // Parses the string returned by OpenCL and creates an array of IL versions.
  // This property's name differs from the singular `IL_VERSION` in the macro.
  // When it was first introduced, the macro may have indicated just one
  // version. It could be repurposed to mean multiple versions, combining them
  // into one string for backward-compability. Regardless of the history, this
  // property should be plural because it is an array.
  public var ilVersions: [String]? {
    if let combined = getInfo_String(CL_DEVICE_IL_VERSION, getInfo) {
      // Separated by spaces.
      let substrings = combined.split(
        separator: " ", omittingEmptySubsequences: true)
      return substrings.map(String.init)
    } else {
      return nil
    }
  }
  
  public var subGroupIndependentForwardProgress: Bool? {
    getInfo_Bool(CL_DEVICE_SUB_GROUP_INDEPENDENT_FORWARD_PROGRESS, getInfo)
  }
  
  // OpenCL 3.0
  
  public var numericVersion: CLVersion? {
    let name = CL_DEVICE_NUMERIC_VERSION
    if let rawVersion: cl_version = getInfo_Int(name, getInfo) {
      return CLVersion(version: rawVersion)
    } else {
      return nil
    }
  }
  
  public var extensionsWithVersion: [CLNameVersion]? {
    getInfo_ArrayOfCLNameVersion(CL_DEVICE_EXTENSIONS_WITH_VERSION, getInfo)
  }
  
  public var ilsWithVersion: [CLNameVersion]? {
    getInfo_ArrayOfCLNameVersion(CL_DEVICE_ILS_WITH_VERSION, getInfo)
  }
  
  public var builtInKernelsWithVersion: [CLNameVersion]? {
    getInfo_ArrayOfCLNameVersion(CL_DEVICE_BUILT_IN_KERNELS_WITH_VERSION, getInfo)
  }
  
  public var atomicMemoryCapabilities: CLDeviceAtomicCapabilities? {
    getInfo_CLMacro(CL_DEVICE_ATOMIC_MEMORY_CAPABILITIES, getInfo)
  }
  
  public var atomicFenceCapabilities: CLDeviceAtomicCapabilities? {
    getInfo_CLMacro(CL_DEVICE_ATOMIC_FENCE_CAPABILITIES, getInfo)
  }
  
  public var nonUniformWorkGroupSupport: Bool? {
    getInfo_Bool(CL_DEVICE_NON_UNIFORM_WORK_GROUP_SUPPORT, getInfo)
  }
  
  public var openclCAllVersions: [CLNameVersion]? {
    getInfo_ArrayOfCLNameVersion(CL_DEVICE_OPENCL_C_ALL_VERSIONS, getInfo)
  }
  
  public var preferredWorkGroupSizeMultiple: Int? {
    getInfo_Int(CL_DEVICE_PREFERRED_WORK_GROUP_SIZE_MULTIPLE, getInfo)
  }
  
  public var workGroupCollectiveFunctionsSupport: Bool? {
    getInfo_Bool(CL_DEVICE_WORK_GROUP_COLLECTIVE_FUNCTIONS_SUPPORT, getInfo)
  }
  
  public var genericAddressSpaceSupport: Bool? {
    getInfo_Bool(CL_DEVICE_GENERIC_ADDRESS_SPACE_SUPPORT, getInfo)
  }
  
  public var openclCFeatures: [CLNameVersion]? {
    getInfo_ArrayOfCLNameVersion(CL_DEVICE_OPENCL_C_FEATURES, getInfo)
  }
  
  public var deviceEnqueueCapabilities: CLDeviceDeviceEnqueueCapabilities? {
    getInfo_CLMacro(CL_DEVICE_DEVICE_ENQUEUE_CAPABILITIES, getInfo)
  }
  
  public var pipeSupport: Bool? {
    getInfo_Bool(CL_DEVICE_PIPE_SUPPORT, getInfo)
  }
  
  public var latestConformanceVersionPassed: String? {
    getInfo_String(CL_DEVICE_LATEST_CONFORMANCE_VERSION_PASSED, getInfo)
  }
}
