//
//  CLDevice+Properties.swift
//  
//
//  Created by Philip Turner on 5/20/22.
//

import COpenCL

extension CLDevice {
  
  // OpenCL 1.0
  
  public var type: cl_device_type? {
    getInfo_Int(name: CL_DEVICE_TYPE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var vendorID: UInt32? {
    getInfo_Int(name: CL_DEVICE_VENDOR_ID) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxComputeUnits: UInt32? {
    getInfo_Int(name: CL_DEVICE_MAX_COMPUTE_UNITS) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxWorkItemDimensions: UInt32? {
    getInfo_Int(name: CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxWorkGroupSize: Int? {
    getInfo_Int(name: CL_DEVICE_MAX_WORK_GROUP_SIZE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxWorkItemSizes: [Int]? {
    getInfo_Array(name: CL_DEVICE_MAX_WORK_ITEM_SIZES) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var preferredVectorWidthChar: UInt32? {
    getInfo_Int(name: CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var preferredVectorWidthShort: UInt32? {
    getInfo_Int(name: CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var preferredVectorWidthInt: UInt32? {
    getInfo_Int(name: CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var preferredVectorWidthLong: UInt32? {
    getInfo_Int(name: CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var preferredVectorWidthFloat: UInt32? {
    getInfo_Int(name: CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var preferredVectorWidthDouble: UInt32? {
    getInfo_Int(name: CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxClockFrequency: UInt32? {
    getInfo_Int(name: CL_DEVICE_MAX_CLOCK_FREQUENCY) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxAddressBits: UInt32? {
    getInfo_Int(name: CL_DEVICE_ADDRESS_BITS) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxReadImageArgs: UInt32? {
    getInfo_Int(name: CL_DEVICE_MAX_READ_IMAGE_ARGS) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxWriteImageArgs: UInt32? {
    getInfo_Int(name: CL_DEVICE_MAX_WRITE_IMAGE_ARGS) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxMemAllocSize: UInt64? {
    getInfo_Int(name: CL_DEVICE_MAX_MEM_ALLOC_SIZE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var image2DMaxWidth: Int? {
    getInfo_Int(name: CL_DEVICE_IMAGE2D_MAX_WIDTH) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var image2DMaxHeight: Int? {
    getInfo_Int(name: CL_DEVICE_IMAGE2D_MAX_HEIGHT) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var image3DMaxWidth: Int? {
    getInfo_Int(name: CL_DEVICE_IMAGE3D_MAX_WIDTH) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var image3DMaxHeight: Int? {
    getInfo_Int(name: CL_DEVICE_IMAGE3D_MAX_HEIGHT) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var image3DMaxDepth: Int? {
    getInfo_Int(name: CL_DEVICE_IMAGE3D_MAX_DEPTH) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var imageSupport: Bool? {
    getInfo_Bool(name: CL_DEVICE_IMAGE_SUPPORT) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxParameterSize: Int? {
    getInfo_Int(name: CL_DEVICE_MAX_PARAMETER_SIZE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxSamplers: UInt32? {
    getInfo_Int(name: CL_DEVICE_MAX_SAMPLERS) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var memBaseAddrAlign: UInt32? {
    getInfo_Int(name: CL_DEVICE_MEM_BASE_ADDR_ALIGN) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var minDataTypeAlignSize: UInt32? {
    getInfo_Int(name: CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var singleFPConfig: cl_device_fp_config? {
    getInfo_Int(name: CL_DEVICE_SINGLE_FP_CONFIG) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var doubleFPConfig: cl_device_fp_config? {
    getInfo_Int(name: CL_DEVICE_DOUBLE_FP_CONFIG) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var halfFPConfig: cl_device_fp_config? {
    getInfo_Int(name: CL_DEVICE_HALF_FP_CONFIG) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var globalMemCacheType: cl_device_mem_cache_type? {
    getInfo_Int(name: CL_DEVICE_GLOBAL_MEM_CACHE_TYPE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var globalMemCachelineSize: UInt32? {
    getInfo_Int(name: CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var globalMemCacheSize: UInt64? {
    getInfo_Int(name: CL_DEVICE_GLOBAL_MEM_CACHE_SIZE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var globalMemSize: UInt64? {
    getInfo_Int(name: CL_DEVICE_GLOBAL_MEM_SIZE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxConstantBufferSize: UInt64? {
    getInfo_Int(name: CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var maxConstantArgs: UInt32? {
    getInfo_Int(name: CL_DEVICE_MAX_CONSTANT_ARGS) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var localMemType: cl_device_local_mem_type? {
    getInfo_Int(name: CL_DEVICE_LOCAL_MEM_TYPE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var localMemSize: UInt64? {
    getInfo_Int(name: CL_DEVICE_LOCAL_MEM_SIZE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var errorCorrectionSupport: Bool? {
    getInfo_Bool(name: CL_DEVICE_ERROR_CORRECTION_SUPPORT) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var profilingTimerResolution: Int? {
    getInfo_Int(name: CL_DEVICE_PROFILING_TIMER_RESOLUTION) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var endianLittle: Bool? {
    getInfo_Bool(name: CL_DEVICE_ENDIAN_LITTLE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var available: Bool? {
    getInfo_Bool(name: CL_DEVICE_AVAILABLE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var executionCapabilities: cl_device_exec_capabilities? {
    getInfo_Int(name: CL_DEVICE_EXECUTION_CAPABILITIES) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var platform: CLPlatform? {
    getInfo_ReferenceCountable(name: CL_DEVICE_PLATFORM) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var name: String? {
    getInfo_String(name: CL_DEVICE_NAME) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var vendor: String? {
    getInfo_String(name: CL_DEVICE_VENDOR) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  // Add to DocC documentation: The C macro "CL_DRIVER_VERSION" does not include
  // the word "DEVICE"
  public var driverVersion: String? {
    getInfo_String(name: CL_DRIVER_VERSION) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var profile: String? {
    getInfo_String(name: CL_DEVICE_PROFILE) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var version: String? {
    getInfo_String(name: CL_DEVICE_VERSION) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  public var extensions: String? {
    getInfo_String(name: CL_DEVICE_EXTENSIONS) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
  
  // OpenCL 1.1
  
  public var openclCVersion: String? {
    getInfo_String(name: CL_DEVICE_OPENCL_C_VERSION) {
      clGetDeviceInfo(wrapper.object, $0, $1, $2, $3)
    }
  }
}
