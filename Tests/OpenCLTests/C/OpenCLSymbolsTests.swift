import XCTest
@testable import OpenCL

final class OpenCLSymbolsTests: XCTestCase {
  // Load every symbol defined in the ICD dispatch table.
  func testSymbolLinking() throws {
    guard testPrecondition() else { return }
    
    // OpenCL 1.0
    _ = clGetPlatformIDs
    _ = clGetPlatformInfo
    _ = clGetDeviceIDs
    _ = clGetDeviceInfo
    _ = clCreateContext
    _ = clCreateContextFromType
    _ = clRetainContext
    _ = clReleaseContext
    _ = clGetContextInfo
    _ = clCreateCommandQueue
    _ = clRetainCommandQueue
    _ = clReleaseCommandQueue
    _ = clGetCommandQueueInfo
    _ = clSetCommandQueueProperty
    _ = clCreateBuffer
    _ = clCreateImage2D
    _ = clCreateImage3D
    _ = clRetainMemObject
    _ = clReleaseMemObject
    _ = clGetSupportedImageFormats
    _ = clGetMemObjectInfo
    _ = clGetImageInfo
    _ = clCreateSampler
    _ = clRetainSampler
    _ = clReleaseSampler
    _ = clGetSamplerInfo
    _ = clCreateProgramWithSource
    _ = clCreateProgramWithBinary
    _ = clRetainProgram
    _ = clReleaseProgram
    _ = clBuildProgram
    _ = clUnloadCompiler
    _ = clGetProgramInfo
    _ = clGetProgramBuildInfo
    _ = clCreateKernel
    _ = clCreateKernelsInProgram
    _ = clRetainKernel
    _ = clReleaseKernel
    _ = clSetKernelArg
    _ = clGetKernelInfo
    _ = clGetKernelWorkGroupInfo
    _ = clWaitForEvents
    _ = clGetEventInfo
    _ = clRetainEvent
    _ = clReleaseEvent
    _ = clGetEventProfilingInfo
    _ = clFlush
    _ = clFinish
    _ = clEnqueueReadBuffer
    _ = clEnqueueWriteBuffer
    _ = clEnqueueCopyBuffer
    _ = clEnqueueReadImage
    _ = clEnqueueWriteImage
    _ = clEnqueueCopyImage
    _ = clEnqueueCopyImageToBuffer
    _ = clEnqueueCopyBufferToImage
    _ = clEnqueueMapBuffer
    _ = clEnqueueMapImage
    _ = clEnqueueUnmapMemObject
    _ = clEnqueueNDRangeKernel
    _ = clEnqueueTask
    _ = clEnqueueNativeKernel
    _ = clEnqueueMarker
    _ = clEnqueueWaitForEvents
    _ = clEnqueueBarrier
    _ = clGetExtensionFunctionAddress
    _ = clCreateFromGLBuffer
    _ = clCreateFromGLTexture2D
    _ = clCreateFromGLTexture3D
    _ = clCreateFromGLRenderbuffer
    _ = clGetGLObjectInfo
    _ = clGetGLTextureInfo
    _ = clEnqueueAcquireGLObjects
    _ = clEnqueueReleaseGLObjects
    _ = clGetGLContextInfoKHR
    
    // cl_khr_d3d10_sharing
    // n/a
    
    // OpenCL 1.1
    _ = clSetEventCallback
    _ = clCreateSubBuffer
    _ = clSetMemObjectDestructorCallback
    _ = clCreateUserEvent
    _ = clSetUserEventStatus
    _ = clEnqueueReadBufferRect
    _ = clEnqueueWriteBufferRect
    _ = clEnqueueCopyBufferRect
    
    // cl_ext_device_fission
    _ = _clCreateSubDevicesEXT
    _ = _clRetainDeviceEXT
    _ = _clReleaseDeviceEXT
    
    // cl_khr_gl_event
    _ = clCreateEventFromGLsyncKHR
    
    // OpenCL 1.2
    _ = clCreateSubDevices
    _ = clRetainDevice
    _ = clReleaseDevice
    _ = clCreateImage
    _ = clCreateProgramWithBuiltInKernels
    _ = clCompileProgram
    _ = clLinkProgram
    _ = clUnloadPlatformCompiler
    _ = clGetKernelArgInfo
    _ = clEnqueueFillBuffer
    _ = clEnqueueFillImage
    _ = clEnqueueMigrateMemObjects
    _ = clEnqueueMarkerWithWaitList
    _ = clEnqueueBarrierWithWaitList
    _ = clGetExtensionFunctionAddressForPlatform
    _ = clCreateFromGLTexture
    
    // cl_khr_d3d11_sharing
    // n/a
    
    // cl_khr_dx9_media_sharing
    // n/a
    
    // cl_khr_egl_image
    _ = clCreateFromEGLImageKHR
    _ = clEnqueueAcquireEGLObjectsKHR
    _ = clEnqueueReleaseEGLObjectsKHR
    
    // cl_khr_egl_event
    _ = clCreateEventFromEGLSyncKHR
    
    // OpenCL 2.0
    _ = clCreateCommandQueueWithProperties
    _ = clCreatePipe
    _ = clGetPipeInfo
    _ = clSVMAlloc
    _ = clSVMFree
    _ = clEnqueueSVMFree
    _ = clEnqueueSVMMemcpy
    _ = clEnqueueSVMMemFill
    _ = clEnqueueSVMMap
    _ = clEnqueueSVMUnmap
    _ = clCreateSamplerWithProperties
    _ = clSetKernelArgSVMPointer
    _ = clSetKernelExecInfo
    
    // cl_khr_sub_groups
    _ = _clGetKernelSubGroupInfoKHR
    
    // OpenCL 2.1
    _ = clCloneKernel
    _ = clCreateProgramWithIL
    _ = clEnqueueSVMMigrateMem
    _ = clGetDeviceAndHostTimer
    _ = clGetHostTimer
    _ = clGetKernelSubGroupInfo
    _ = clSetDefaultDeviceCommandQueue
    
    // OpenCL 2.2
    _ = clSetProgramReleaseCallback
    _ = clSetProgramSpecializationConstant
    
    // OpenCL 3.0
    _ = clCreateBufferWithProperties
    _ = clCreateImageWithProperties
    _ = clSetContextDestructorCallback
  }
}
