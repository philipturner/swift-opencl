//
//  OpenCLSymbols.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

// To extract the type, this file uses typedefs like
// `cl_api_clCreateCommandQueueWithProperties` from "cl_icd.h". The ICD dispatch
// table is commented out to silence deprecation warnings in that header. Even
// importing the type of a deprecated function induces a warning, so I have to
// manually specify deprecated symbols in "OpenCLDeprecated.swift". Each
// deprecated symbol has a comment in this file, showing where it would be
// located sans the warning.
//
// Some symbols were introduced as an extension in one version, then an official
// function in the next version. One example is `clGetKernelSubGroupInfo`. For
// these, I try loading a fallback like `clGetKernelSubGroupInfoKHR`. If a
// symbol still can't load, it is replaced with a dummy symbol that reports an
// error to `CLError` and returns a custom error code.

@inline(__always)
fileprivate func load<T>(name: StaticString) -> T? {
  OpenCLLibrary.loadSymbol(name: name)
}

@inline(__always)
fileprivate func objectCreationError<T>(
  name: String,
  error: UnsafeMutablePointer<Int32>?
) -> T? {
  CLError.setCode(CLErrorCode.symbolNotFound.rawValue, name)
  error?.pointee = CLError.latest!.code
  return nil
}

// OpenCL 1.0

public let clGetPlatformIDs: cl_api_clGetPlatformIDs =
load(name: "clGetPlatformIDs") ?? { _, _, _ in
  fatalError()
}

public let clGetPlatformInfo: cl_api_clGetPlatformInfo =
load(name: "clGetPlatformInfo") ?? { _, _, _, _, _ in
  fatalError()
}

public let clGetDeviceIDs: cl_api_clGetDeviceIDs =
load(name: "clGetDeviceIDs") ?? { _, _, _, _, _ in
  fatalError()
}

public let clGetDeviceInfo: cl_api_clGetDeviceInfo =
load(name: "clGetDeviceInfo") ?? { _, _, _, _, _ in
  fatalError()
}

public let clCreateContext: cl_api_clCreateContext =
load(name: "clCreateContext") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clCreateContextFromType: cl_api_clCreateContextFromType =
load(name: "clCreateContextFromType") ?? { _, _, _, _, _ in
  fatalError()
}

public let clRetainContext: cl_api_clRetainContext =
load(name: "clRetainContext") ?? { _ in
  fatalError()
}

public let clReleaseContext: cl_api_clReleaseContext =
load(name: "clReleaseContext") ?? { _ in
  fatalError()
}

public let clGetContextInfo: cl_api_clGetContextInfo =
load(name: "clGetContextInfo") ?? { _, _, _, _, _ in
  fatalError()
}

public let clCreateCommandQueue: cl_api_clCreateCommandQueue =
load(name: "clCreateCommandQueue") ?? { _, _, _, _ in
  fatalError()
}

public let clRetainCommandQueue: cl_api_clRetainCommandQueue =
load(name: "clRetainCommandQueue") ?? { _ in
  fatalError()
}

public let clReleaseCommandQueue: cl_api_clReleaseCommandQueue =
load(name: "clReleaseCommandQueue") ?? { _ in
  fatalError()
}

public let clGetCommandQueueInfo: cl_api_clGetCommandQueueInfo =
load(name: "clGetCommandQueueInfo") ?? { _, _, _, _, _ in
  fatalError()
}

// Deprecated: clSetCommandQueueProperty

public let clCreateBuffer: cl_api_clCreateBuffer =
load(name: "clCreateBuffer") ?? { _, _, _, _, _ in
  fatalError()
}

// Deprecated: clCreateImage2D

// Deprecated: clCreateImage3D

public let clRetainMemObject: cl_api_clRetainMemObject =
load(name: "clRetainMemObject") ?? { _ in
  fatalError()
}

public let clReleaseMemObject: cl_api_clReleaseMemObject =
load(name: "clReleaseMemObject") ?? { _ in
  fatalError()
}

public let clGetSupportedImageFormats: cl_api_clGetSupportedImageFormats =
load(name: "clGetSupportedImageFormats") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clGetMemObjectInfo: cl_api_clGetMemObjectInfo =
load(name: "clGetMemObjectInfo") ?? { _, _, _, _, _ in
  fatalError()
}

public let clGetImageInfo: cl_api_clGetImageInfo =
load(name: "clGetImageInfo") ?? { _, _, _, _, _ in
  fatalError()
}

public let clCreateSampler: cl_api_clCreateSampler =
load(name: "clCreateSampler") ?? { _, _, _, _, _ in
  fatalError()
}

public let clRetainSampler: cl_api_clRetainSampler =
load(name: "clRetainSampler") ?? { _ in
  fatalError()
}

public let clReleaseSampler: cl_api_clReleaseSampler =
load(name: "clReleaseSampler") ?? { _ in
  fatalError()
}

public let clGetSamplerInfo: cl_api_clGetSamplerInfo =
load(name: "clGetSamplerInfo") ?? { _, _, _, _, _ in
  fatalError()
}

public let clCreateProgramWithSource: cl_api_clCreateProgramWithSource =
load(name: "clCreateProgramWithSource") ?? { _, _, _, _, _ in
  fatalError()
}

public let clCreateProgramWithBinary: cl_api_clCreateProgramWithBinary =
load(name: "clCreateProgramWithBinary") ?? { _, _, _, _, _, _, _ in
  fatalError()
}

public let clRetainProgram: cl_api_clRetainProgram =
load(name: "clRetainProgram") ?? { _ in
  fatalError()
}

public let clReleaseProgram: cl_api_clReleaseProgram =
load(name: "clReleaseProgram") ?? { _ in
  fatalError()
}

public let clBuildProgram: cl_api_clBuildProgram =
load(name: "clBuildProgram") ?? { _, _, _, _, _, _ in
  fatalError()
}

// Deprecated: clUnloadCompiler

public let clGetProgramInfo: cl_api_clGetProgramInfo =
load(name: "clGetProgramInfo") ?? { _, _, _, _, _ in
  fatalError()
}

public let clGetProgramBuildInfo: cl_api_clGetProgramBuildInfo =
load(name: "clGetProgramBuildInfo") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clCreateKernel: cl_api_clCreateKernel =
load(name: "clCreateKernel") ?? { _, _, _ in
  fatalError()
}

public let clCreateKernelsInProgram: cl_api_clCreateKernelsInProgram =
load(name: "clCreateKernelsInProgram") ?? { _, _, _, _ in
  fatalError()
}

public let clRetainKernel: cl_api_clRetainKernel =
load(name: "clRetainKernel") ?? { _ in
  fatalError()
}

public let clReleaseKernel: cl_api_clReleaseKernel =
load(name: "clReleaseKernel") ?? { _ in
  fatalError()
}

public let clSetKernelArg: cl_api_clSetKernelArg =
load(name: "clSetKernelArg") ?? { _, _, _, _ in
  fatalError()
}

public let clGetKernelInfo: cl_api_clGetKernelInfo =
load(name: "clGetKernelInfo") ?? { _, _, _, _, _ in
  fatalError()
}

public let clGetKernelWorkGroupInfo: cl_api_clGetKernelWorkGroupInfo =
load(name: "clGetKernelWorkGroupInfo") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clWaitForEvents: cl_api_clWaitForEvents =
load(name: "clWaitForEvents") ?? { _, _ in
  fatalError()
}

public let clGetEventInfo: cl_api_clGetEventInfo =
load(name: "clGetEventInfo") ?? { _, _, _, _, _ in
  fatalError()
}

public let clRetainEvent: cl_api_clRetainEvent =
load(name: "clRetainEvent") ?? { _ in
  fatalError()
}

public let clReleaseEvent: cl_api_clReleaseEvent =
load(name: "clReleaseEvent") ?? { _ in
  fatalError()
}

public let clGetEventProfilingInfo: cl_api_clGetEventProfilingInfo =
load(name: "clGetEventProfilingInfo") ?? { _, _, _, _, _ in
  fatalError()
}

public let clFlush: cl_api_clFlush =
load(name: "clFlush") ?? { _ in
  fatalError()
}

public let clFinish: cl_api_clFinish =
load(name: "clFinish") ?? { _ in
  fatalError()
}

public let clEnqueueReadBuffer: cl_api_clEnqueueReadBuffer =
load(name: "clEnqueueReadBuffer") ?? { _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueWriteBuffer: cl_api_clEnqueueWriteBuffer =
load(name: "clEnqueueWriteBuffer") ?? { _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueCopyBuffer: cl_api_clEnqueueCopyBuffer =
load(name: "clEnqueueCopyBuffer") ?? { _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueReadImage: cl_api_clEnqueueReadImage =
load(name: "clEnqueueReadImage") ?? { _, _, _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueWriteImage: cl_api_clEnqueueWriteImage =
load(name: "clEnqueueWriteImage") ?? { _, _, _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueCopyImage: cl_api_clEnqueueCopyImage =
load(name: "clEnqueueCopyImage") ?? { _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueCopyImageToBuffer: cl_api_clEnqueueCopyImageToBuffer =
load(name: "clEnqueueCopyImageToBuffer") ?? { _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueCopyBufferToImage: cl_api_clEnqueueCopyBufferToImage =
load(name: "clEnqueueCopyBufferToImage") ?? { _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueMapBuffer: cl_api_clEnqueueMapBuffer =
load(name: "clEnqueueMapBuffer") ?? { _, _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueMapImage: cl_api_clEnqueueMapImage =
load(name: "clEnqueueMapImage") ?? { _, _, _, _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueUnmapMemObject: cl_api_clEnqueueUnmapMemObject =
load(name: "clEnqueueUnmapMemObject") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueNDRangeKernel: cl_api_clEnqueueNDRangeKernel =
load(name: "clEnqueueNDRangeKernel") ?? { _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueTask: cl_api_clEnqueueTask =
load(name: "clEnqueueTask") ?? { _, _, _, _, _ in
  fatalError()
}

public let clEnqueueNativeKernel: cl_api_clEnqueueNativeKernel =
load(name: "clEnqueueNativeKernel") ?? { _, _, _, _, _, _, _, _, _, _ in
  fatalError()
}

// Deprecated: clEnqueueMarker

// Deprecated: clEnqueueWaitForEvents

// Deprecated: clEnqueueBarrier

// Deprecated: clGetExtensionFunctionAddress

public let clCreateFromGLBuffer: cl_api_clCreateFromGLBuffer =
load(name: "clCreateFromGLBuffer") ?? { _, _, _, _ in
  fatalError()
}

public let clCreateFromGLTexture2D: cl_api_clCreateFromGLTexture2D =
load(name: "clCreateFromGLTexture2D") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clCreateFromGLTexture3D: cl_api_clCreateFromGLTexture3D =
load(name: "clCreateFromGLTexture3D") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clCreateFromGLRenderbuffer: cl_api_clCreateFromGLRenderbuffer =
load(name: "clCreateFromGLRenderbuffer") ?? { _, _, _, _ in
  fatalError()
}

public let clGetGLObjectInfo: cl_api_clGetGLObjectInfo =
load(name: "clGetGLObjectInfo") ?? { _, _, _ in
  fatalError()
}

public let clGetGLTextureInfo: cl_api_clGetGLTextureInfo =
load(name: "clGetGLTextureInfo") ?? { _, _, _, _, _ in
  fatalError()
}

public let clEnqueueAcquireGLObjects: cl_api_clEnqueueAcquireGLObjects =
load(name: "clEnqueueAcquireGLObjects") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueReleaseGLObjects: cl_api_clEnqueueReleaseGLObjects =
load(name: "clEnqueueReleaseGLObjects") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clGetGLContextInfoKHR: cl_api_clGetGLContextInfoKHR =
load(name: "clGetGLContextInfoKHR") ?? { _, _, _, _, _ in
  fatalError()
}

// cl_khr_d3d10_sharing
// Not part of SwiftOpenCL for now.

// OpenCL 1.1

public let clSetEventCallback: cl_api_clSetEventCallback =
load(name: "clSetEventCallback") ?? { _, _, _, _ in
  fatalError()
}

public let clCreateSubBuffer: cl_api_clCreateSubBuffer =
load(name: "clCreateSubBuffer") ?? { _, _, _, _, _ in
  fatalError()
}

public let clSetMemObjectDestructorCallback:
  cl_api_clSetMemObjectDestructorCallback =
load(name: "clSetMemObjectDestructorCallback") ?? { _, _, _ in
  fatalError()
}

public let clCreateUserEvent: cl_api_clCreateUserEvent =
load(name: "clCreateUserEvent") ?? { _, _ in
  fatalError()
}

public let clSetUserEventStatus: cl_api_clSetUserEventStatus =
load(name: "clSetUserEventStatus") ?? { _, _ in
  fatalError()
}

public let clEnqueueReadBufferRect: cl_api_clEnqueueReadBufferRect =
load(name: "clEnqueueReadBufferRect") ??
{ _, _, _, _, _, _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueWriteBufferRect: cl_api_clEnqueueWriteBufferRect =
load(name: "clEnqueueWriteBufferRect") ??
{ _, _, _, _, _, _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueCopyBufferRect: cl_api_clEnqueueCopyBufferRect =
load(name: "clEnqueueCopyBufferRect") ??
{ _, _, _, _, _, _, _, _, _, _, _, _, _ in
  fatalError()
}

// cl_ext_device_fission

let _clCreateSubDevicesEXT: cl_api_clCreateSubDevicesEXT =
load(name: "clCreateSubDevicesEXT") ?? { _, _, _, _, _ in
  fatalError()
}

let _clRetainDeviceEXT: cl_api_clRetainDeviceEXT =
load(name: "clRetainDeviceEXT") ?? { _ in
  fatalError()
}

let _clReleaseDeviceEXT: cl_api_clReleaseDeviceEXT =
load(name: "clReleaseDeviceEXT") ?? { _ in
  fatalError()
}

@available(*, deprecated, message: "Use 'clCreateSubDevices' instead.")
public let clCreateSubDevicesEXT = _clCreateSubDevicesEXT

@available(*, deprecated, message: "Use 'clRetainDevice' instead.")
public let clRetainDeviceEXT = _clRetainDeviceEXT

@available(*, deprecated, message: "Use 'clReleaseDevice' instead.")
public let clReleaseDeviceEXT = _clReleaseDeviceEXT

// cl_khr_gl_event

public let clCreateEventFromGLsyncKHR: cl_api_clCreateEventFromGLsyncKHR =
load(name: "clCreateEventFromGLsyncKHR") ?? { _, _, _ in
  fatalError()
}

// OpenCL 1.2

public let clCreateSubDevices: cl_api_clCreateSubDevices =
load(name: "clCreateSubDevices") ?? unsafeBitCast(
  _clCreateSubDevicesEXT, to: cl_api_clCreateSubDevices.self)

public let clRetainDevice: cl_api_clRetainDevice =
load(name: "clRetainDevice") ?? _clRetainDeviceEXT

public let clReleaseDevice: cl_api_clReleaseDevice =
load(name: "clReleaseDevice") ?? _clReleaseDeviceEXT

public let clCreateImage: cl_api_clCreateImage =
load(name: "clCreateImage") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clCreateProgramWithBuiltInKernels:
  cl_api_clCreateProgramWithBuiltInKernels =
load(name: "clCreateProgramWithBuiltInKernels") ?? { _, _, _, _, _ in
  fatalError()
}

public let clCompileProgram: cl_api_clCompileProgram =
load(name: "clCompileProgram") ?? { _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clLinkProgram: cl_api_clLinkProgram =
load(name: "clLinkProgram") ?? { _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clUnloadPlatformCompiler: cl_api_clUnloadPlatformCompiler =
load(name: "clUnloadPlatformCompiler") ?? { _ in
  fatalError()
}

public let clGetKernelArgInfo: cl_api_clGetKernelArgInfo =
load(name: "clGetKernelArgInfo") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueFillBuffer: cl_api_clEnqueueFillBuffer =
load(name: "clEnqueueFillBuffer") ?? { _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueFillImage: cl_api_clEnqueueFillImage =
load(name: "clEnqueueFillImage") ?? { _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueMigrateMemObjects: cl_api_clEnqueueMigrateMemObjects =
load(name: "clEnqueueMigrateMemObjects") ?? { _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueMarkerWithWaitList: cl_api_clEnqueueMarkerWithWaitList =
load(name: "clEnqueueMarkerWithWaitList") ?? { _, _, _, _ in
  fatalError()
}

public let clEnqueueBarrierWithWaitList: cl_api_clEnqueueBarrierWithWaitList =
load(name: "clEnqueueBarrierWithWaitList") ?? { _, _, _, _ in
  fatalError()
}

public let clGetExtensionFunctionAddressForPlatform: cl_api_clGetExtensionFunctionAddressForPlatform =
load(name: "clGetExtensionFunctionAddressForPlatform") ?? { _, _ in
  fatalError()
}

public let clCreateFromGLTexture: cl_api_clCreateFromGLTexture =
load(name: "clCreateFromGLTexture") ?? { _, _, _, _, _, _ in
  fatalError()
}

// cl_khr_d3d11_sharing
// Not part of SwiftOpenCL for now.

// cl_khr_dx9_media_sharing
// Not part of SwiftOpenCL for now.

// cl_khr_egl_image

public let clCreateFromEGLImageKHR: cl_api_clCreateFromEGLImageKHR =
load(name: "clCreateFromEGLImageKHR") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueAcquireEGLObjectsKHR: cl_api_clEnqueueAcquireEGLObjectsKHR =
load(name: "clEnqueueAcquireEGLObjectsKHR") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueReleaseEGLObjectsKHR: cl_api_clEnqueueReleaseEGLObjectsKHR =
load(name: "clEnqueueReleaseEGLObjectsKHR") ?? { _, _, _, _, _, _ in
  fatalError()
}

// cl_khr_egl_event

public let clCreateEventFromEGLSyncKHR: cl_api_clCreateEventFromEGLSyncKHR =
load(name: "clCreateEventFromEGLSyncKHR") ?? { _, _, _, _ in
  fatalError()
}

// OpenCL 2.0

public let clCreateCommandQueueWithProperties:
  cl_api_clCreateCommandQueueWithProperties =
load(name: "clCreateCommandQueueWithProperties") ?? { _, _, _, error in
  objectCreationError(name: "clCreateCommandQueueWithProperties", error: error)
}

public let clCreatePipe: cl_api_clCreatePipe =
load(name: "clCreatePipe") ?? { _, _, _, _, _, _ in
  fatalError()
}

public let clGetPipeInfo: cl_api_clGetPipeInfo =
load(name: "clGetPipeInfo") ?? { _, _, _, _, _ in
  fatalError()
}

public let clSVMAlloc: cl_api_clSVMAlloc =
load(name: "clSVMAlloc") ?? { _, _, _, _ in
  fatalError()
}

public let clSVMFree: cl_api_clSVMFree =
load(name: "clSVMFree") ?? { _, _ in
  fatalError()
}

public let clEnqueueSVMFree: cl_api_clEnqueueSVMFree =
load(name: "clEnqueueSVMFree") ?? { _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueSVMMemcpy: cl_api_clEnqueueSVMMemcpy =
load(name: "clEnqueueSVMMemcpy") ?? { _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueSVMMemFill: cl_api_clEnqueueSVMMemFill =
load(name: "clEnqueueSVMMemFill") ?? { _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueSVMMap: cl_api_clEnqueueSVMMap =
load(name: "clEnqueueSVMMap") ?? { _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clEnqueueSVMUnmap: cl_api_clEnqueueSVMUnmap =
load(name: "clEnqueueSVMUnmap") ?? { _, _, _, _, _ in
  fatalError()
}

public let clCreateSamplerWithProperties: cl_api_clCreateSamplerWithProperties =
load(name: "clCreateSamplerWithProperties") ?? { _, _, _ in
  fatalError()
}

public let clSetKernelArgSVMPointer: cl_api_clSetKernelArgSVMPointer =
load(name: "clSetKernelArgSVMPointer") ?? { _, _, _ in
  fatalError()
}

public let clSetKernelExecInfo: cl_api_clSetKernelExecInfo =
load(name: "clSetKernelExecInfo") ?? { _, _, _, _ in
  fatalError()
}

// cl_khr_sub_groups

let _clGetKernelSubGroupInfoKHR: cl_api_clGetKernelSubGroupInfoKHR =
load(name: "clGetKernelSubGroupInfoKHR") ?? { _, _, _, _, _, _, _, _ in
  fatalError()
}

@available(*, deprecated, message: "Use 'clGetKernelSubGroupInfo' instead.")
public let clGetKernelSubGroupInfoKHR = _clGetKernelSubGroupInfoKHR

// OpenCL 2.1

public let clCloneKernel: cl_api_clCloneKernel =
load(name: "clCloneKernel") ?? { _, _ in
  fatalError()
}

public let clCreateProgramWithIL: cl_api_clCreateProgramWithIL =
load(name: "clCreateProgramWithIL") ?? { _, _, _ , _ in
  fatalError()
}

public let clEnqueueSVMMigrateMem: cl_api_clEnqueueSVMMigrateMem =
load(name: "clEnqueueSVMMigrateMem") ?? { _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clGetDeviceAndHostTimer: cl_api_clGetDeviceAndHostTimer =
load(name: "clGetDeviceAndHostTimer") ?? { _, _, _ in
  fatalError()
}

public let clGetHostTimer: cl_api_clGetHostTimer =
load(name: "clGetHostTimer") ?? { _, _ in
  fatalError()
}

public let clGetKernelSubGroupInfo: cl_api_clGetKernelSubGroupInfo =
load(name: "clGetKernelSubGroupInfo") ?? _clGetKernelSubGroupInfoKHR

public let clSetDefaultDeviceCommandQueue:
  cl_api_clSetDefaultDeviceCommandQueue =
load(name: "clSetDefaultDeviceCommandQueue") ?? { _, _, _ in
  fatalError()
}

// OpenCL 2.2

public let clSetProgramReleaseCallback: cl_api_clSetProgramReleaseCallback =
load(name: "clSetProgramReleaseCallback") ?? { _, _, _ in
  fatalError()
}

public let clSetProgramSpecializationConstant:
  cl_api_clSetProgramSpecializationConstant =
load(name: "clSetProgramSpecializationConstant") ?? { _, _, _, _ in
  fatalError()
}

// OpenCL 3.0

public let clCreateBufferWithProperties: cl_api_clCreateBufferWithProperties =
load(name: "clCreateBufferWithProperties") ?? { _, _, _, _, _, error in
  objectCreationError(name: "clCreateBufferWithProperties", error: error)
}

public let clCreateImageWithProperties: cl_api_clCreateImageWithProperties =
load(name: "clCreateImageWithProperties") ?? { _, _, _, _, _, _, _ in
  fatalError()
}

public let clSetContextDestructorCallback:
  cl_api_clSetContextDestructorCallback =
load(name: "clSetContextDestructorCallback") ?? { _, _, _ in
  fatalError()
}
