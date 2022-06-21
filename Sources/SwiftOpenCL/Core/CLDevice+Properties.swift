//
//  CLDevice+Properties.swift
//  
//
//  Created by Philip Turner on 5/20/22.
//

import COpenCL

extension CLDevice {
  
  @inline(__always)
  private var callGetInfo: GetInfoClosure {
    { clGetDeviceInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var type: cl_device_type? {
    getInfo_Int(CL_DEVICE_TYPE, callGetInfo)
  }
  
  public var vendorID: UInt32? {
    getInfo_Int(CL_DEVICE_VENDOR_ID, callGetInfo)
  }
  
  public var maxComputeUnits: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_COMPUTE_UNITS, callGetInfo)
  }
  
  public var maxWorkItemDimensions: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS, callGetInfo)
  }
  
  public var maxWorkGroupSize: Int? {
    getInfo_Int(CL_DEVICE_MAX_WORK_GROUP_SIZE, callGetInfo)
  }
  
  public var maxWorkItemSizes: [Int]? {
    getInfo_Array(CL_DEVICE_MAX_WORK_ITEM_SIZES, callGetInfo)
  }
  
  public var preferredVectorWidthChar: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR, callGetInfo)
  }
  
  public var preferredVectorWidthShort: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT, callGetInfo)
  }
  
  public var preferredVectorWidthInt: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT, callGetInfo)
  }
  
  public var preferredVectorWidthLong: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG, callGetInfo)
  }
  
  public var preferredVectorWidthFloat: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT, callGetInfo)
  }
  
  public var preferredVectorWidthDouble: UInt32? {
    getInfo_Int(CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE, callGetInfo)
  }
  
  public var maxClockFrequency: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_CLOCK_FREQUENCY, callGetInfo)
  }
  
  public var maxAddressBits: UInt32? {
    getInfo_Int(CL_DEVICE_ADDRESS_BITS, callGetInfo)
  }
  
  public var maxReadImageArgs: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_READ_IMAGE_ARGS, callGetInfo)
  }
  
  public var maxWriteImageArgs: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_WRITE_IMAGE_ARGS, callGetInfo)
  }
  
  public var maxMemAllocSize: UInt64? {
    getInfo_Int(CL_DEVICE_MAX_MEM_ALLOC_SIZE, callGetInfo)
  }
  
  public var image2DMaxWidth: Int? {
    getInfo_Int(CL_DEVICE_IMAGE2D_MAX_WIDTH, callGetInfo)
  }
  
  public var image2DMaxHeight: Int? {
    getInfo_Int(CL_DEVICE_IMAGE2D_MAX_HEIGHT, callGetInfo)
  }
  
  public var image3DMaxWidth: Int? {
    getInfo_Int(CL_DEVICE_IMAGE3D_MAX_WIDTH, callGetInfo)
  }
  
  public var image3DMaxHeight: Int? {
    getInfo_Int(CL_DEVICE_IMAGE3D_MAX_HEIGHT, callGetInfo)
  }
  
  public var image3DMaxDepth: Int? {
    getInfo_Int(CL_DEVICE_IMAGE3D_MAX_DEPTH, callGetInfo)
  }
  
  public var imageSupport: Bool? {
    getInfo_Bool(CL_DEVICE_IMAGE_SUPPORT, callGetInfo)
  }
  
  public var maxParameterSize: Int? {
    getInfo_Int(CL_DEVICE_MAX_PARAMETER_SIZE, callGetInfo)
  }
  
  public var maxSamplers: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_SAMPLERS, callGetInfo)
  }
  
  public var memBaseAddrAlign: UInt32? {
    getInfo_Int(CL_DEVICE_MEM_BASE_ADDR_ALIGN, callGetInfo)
  }
  
  public var minDataTypeAlignSize: UInt32? {
    getInfo_Int(CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE, callGetInfo)
  }
  
  public var singleFPConfig: cl_device_fp_config? {
    getInfo_Int(CL_DEVICE_SINGLE_FP_CONFIG, callGetInfo)
  }
  
  public var doubleFPConfig: cl_device_fp_config? {
    getInfo_Int(CL_DEVICE_DOUBLE_FP_CONFIG, callGetInfo)
  }
  
  public var halfFPConfig: cl_device_fp_config? {
    getInfo_Int(CL_DEVICE_HALF_FP_CONFIG, callGetInfo)
  }
  
  public var globalMemCacheType: cl_device_mem_cache_type? {
    getInfo_Int(CL_DEVICE_GLOBAL_MEM_CACHE_TYPE, callGetInfo)
  }
  
  public var globalMemCachelineSize: UInt32? {
    getInfo_Int(CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE, callGetInfo)
  }
  
  public var globalMemCacheSize: UInt64? {
    getInfo_Int(CL_DEVICE_GLOBAL_MEM_CACHE_SIZE, callGetInfo)
  }
  
  public var globalMemSize: UInt64? {
    getInfo_Int(CL_DEVICE_GLOBAL_MEM_SIZE, callGetInfo)
  }
  
  public var maxConstantBufferSize: UInt64? {
    getInfo_Int(CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE, callGetInfo)
  }
  
  public var maxConstantArgs: UInt32? {
    getInfo_Int(CL_DEVICE_MAX_CONSTANT_ARGS, callGetInfo)
  }
  
  public var localMemType: cl_device_local_mem_type? {
    getInfo_Int(CL_DEVICE_LOCAL_MEM_TYPE, callGetInfo)
  }
  
  public var localMemSize: UInt64? {
    getInfo_Int(CL_DEVICE_LOCAL_MEM_SIZE, callGetInfo)
  }
  
  public var errorCorrectionSupport: Bool? {
    getInfo_Bool(CL_DEVICE_ERROR_CORRECTION_SUPPORT, callGetInfo)
  }
  
  public var profilingTimerResolution: Int? {
    getInfo_Int(CL_DEVICE_PROFILING_TIMER_RESOLUTION, callGetInfo)
  }
  
  public var endianLittle: Bool? {
    getInfo_Bool(CL_DEVICE_ENDIAN_LITTLE, callGetInfo)
  }
  
  public var available: Bool? {
    getInfo_Bool(CL_DEVICE_AVAILABLE, callGetInfo)
  }
  
  public var executionCapabilities: cl_device_exec_capabilities? {
    getInfo_Int(CL_DEVICE_EXECUTION_CAPABILITIES, callGetInfo)
  }
  
  public var platform: CLPlatform? {
    getInfo_ReferenceCountable(CL_DEVICE_PLATFORM, callGetInfo)
  }
  
  public var name: String? {
    getInfo_String(CL_DEVICE_NAME, callGetInfo)
  }
  
  public var vendor: String? {
    getInfo_String(CL_DEVICE_VENDOR, callGetInfo)
  }
  
  // Add to DocC documentation: The C macro "CL_DRIVER_VERSION" does not include
  // the word "DEVICE"
  public var driverVersion: String? {
    getInfo_String(CL_DRIVER_VERSION, callGetInfo)
  }
  
  public var profile: String? {
    getInfo_String(CL_DEVICE_PROFILE, callGetInfo)
  }
  
  public var version: String? {
    getInfo_String(CL_DEVICE_VERSION, callGetInfo)
  }
  
  public var extensions: String? {
    getInfo_String(CL_DEVICE_EXTENSIONS, callGetInfo)
  }
  
  // OpenCL 1.1
  
  public var nativeVectorWidthChar: UInt32? {
    getInfo_Int(CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR, callGetInfo)
  }
  
  public var openclCVersion: String? {
    getInfo_String(CL_DEVICE_OPENCL_C_VERSION, callGetInfo)
  }
}
