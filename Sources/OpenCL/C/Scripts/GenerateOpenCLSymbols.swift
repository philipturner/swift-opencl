//
//  GenerateOpenCLSymbols.swift
//  
//
//  Created by Philip Turner on 7/2/22.
//

import Foundation

// This script helps with generating the bindings in "OpenCLSymbols.swift".
// Copy the ICD dispatch table from "cl_icd.h" into "table". Then, run `swift
// GenerateOpenCLSymbols.swift` on the file and copy the terminal
// output. Resolve the compiler errors involving incorrect numbers of closure
// arguments. Fix each function ending in "KHR" so that the non-"KHR" version
// overrides it.
//
// Watch out for functions like `clGetExtensionFunctionAddressForPlatform`.
// These split onto two lines, and the script can't recognize them. Modify the
// functions so they appear on one line, like the rest.

func createCode(line inputLine: String) -> String? {
  var line = inputLine
  if line.hasPrefix("//") {
    line.removeFirst(2)
  }
  
  if line.hasPrefix("typedef") || line.hasPrefix("}") {
    return nil
  }
  guard line.contains(where: { $0 != " " }) else {
    return nil
  }
  while line.hasPrefix(" ") {
    line.removeFirst(1)
  }
  while line.hasSuffix(" ") {
    line.removeLast(1)
  }
  
  if line.hasPrefix("/* ") && line.hasSuffix(" */"){
    // A comment.
    line.removeFirst(3)
    line.removeLast(3)
    return """
      
      // \(line)
      
      """
  } else if line.hasPrefix("cl_api_") && line.hasSuffix(";") {
    // A function declaration.
    line.removeFirst("cl_api_".count)
    line.removeLast(1)
    let spaceIndex = line.firstIndex(of: " ")!
    let symbolIndex = line.index(after: spaceIndex)
    let symbol = String(line[symbolIndex...])
    
    var argumentLabels: String
    let fiveLabels = "_, _, _, _, _"
    if symbol.hasSuffix("Info") {
      // Five parameters.
      argumentLabels = fiveLabels
    } else if symbol.hasPrefix("clRetain") || symbol.hasPrefix("clRelease") {
      // One parameter.
      argumentLabels = "_"
    } else if symbol.hasPrefix("clEnqueue") {
      // Usually 12 or less parameters.
      argumentLabels = "\(fiveLabels), \(fiveLabels), _, _"
    } else {
      // Usually 6 or less parameters.
      argumentLabels = "\(fiveLabels), _"
    }
    
    return """
      
      public let \(symbol): cl_api_\(symbol) =
      load(name: "\(symbol)") ?? { \(argumentLabels) in
        fatalError()
      }
      
      """
  } else {
    fatalError("""
      Line '\(inputLine)' not recognized. It was stripped down to '\(line)'.
      """)
  }
}

func printOutput(_ table: String) {
  let lines = table.split(separator: "\n")

  var output = ""
  for line in lines {
    if let code = createCode(line: String(line)) {
      output += code
    }
  }
  print(output)
}

// It's fine if the table is commented out with "//"-style comments.
printOutput("""
//typedef struct _cl_icd_dispatch {
//  /* OpenCL 1.0 */
//  cl_api_clGetPlatformIDs clGetPlatformIDs;
//  cl_api_clGetPlatformInfo clGetPlatformInfo;
//  cl_api_clGetDeviceIDs clGetDeviceIDs;
//  cl_api_clGetDeviceInfo clGetDeviceInfo;
//  cl_api_clCreateContext clCreateContext;
//  cl_api_clCreateContextFromType clCreateContextFromType;
//  cl_api_clRetainContext clRetainContext;
//  cl_api_clReleaseContext clReleaseContext;
//  cl_api_clGetContextInfo clGetContextInfo;
//  cl_api_clCreateCommandQueue clCreateCommandQueue;
//  cl_api_clRetainCommandQueue clRetainCommandQueue;
//  cl_api_clReleaseCommandQueue clReleaseCommandQueue;
//  cl_api_clGetCommandQueueInfo clGetCommandQueueInfo;
//  cl_api_clSetCommandQueueProperty clSetCommandQueueProperty;
//  cl_api_clCreateBuffer clCreateBuffer;
//  cl_api_clCreateImage2D clCreateImage2D;
//  cl_api_clCreateImage3D clCreateImage3D;
//  cl_api_clRetainMemObject clRetainMemObject;
//  cl_api_clReleaseMemObject clReleaseMemObject;
//  cl_api_clGetSupportedImageFormats clGetSupportedImageFormats;
//  cl_api_clGetMemObjectInfo clGetMemObjectInfo;
//  cl_api_clGetImageInfo clGetImageInfo;
//  cl_api_clCreateSampler clCreateSampler;
//  cl_api_clRetainSampler clRetainSampler;
//  cl_api_clReleaseSampler clReleaseSampler;
//  cl_api_clGetSamplerInfo clGetSamplerInfo;
//  cl_api_clCreateProgramWithSource clCreateProgramWithSource;
//  cl_api_clCreateProgramWithBinary clCreateProgramWithBinary;
//  cl_api_clRetainProgram clRetainProgram;
//  cl_api_clReleaseProgram clReleaseProgram;
//  cl_api_clBuildProgram clBuildProgram;
//  cl_api_clUnloadCompiler clUnloadCompiler;
//  cl_api_clGetProgramInfo clGetProgramInfo;
//  cl_api_clGetProgramBuildInfo clGetProgramBuildInfo;
//  cl_api_clCreateKernel clCreateKernel;
//  cl_api_clCreateKernelsInProgram clCreateKernelsInProgram;
//  cl_api_clRetainKernel clRetainKernel;
//  cl_api_clReleaseKernel clReleaseKernel;
//  cl_api_clSetKernelArg clSetKernelArg;
//  cl_api_clGetKernelInfo clGetKernelInfo;
//  cl_api_clGetKernelWorkGroupInfo clGetKernelWorkGroupInfo;
//  cl_api_clWaitForEvents clWaitForEvents;
//  cl_api_clGetEventInfo clGetEventInfo;
//  cl_api_clRetainEvent clRetainEvent;
//  cl_api_clReleaseEvent clReleaseEvent;
//  cl_api_clGetEventProfilingInfo clGetEventProfilingInfo;
//  cl_api_clFlush clFlush;
//  cl_api_clFinish clFinish;
//  cl_api_clEnqueueReadBuffer clEnqueueReadBuffer;
//  cl_api_clEnqueueWriteBuffer clEnqueueWriteBuffer;
//  cl_api_clEnqueueCopyBuffer clEnqueueCopyBuffer;
//  cl_api_clEnqueueReadImage clEnqueueReadImage;
//  cl_api_clEnqueueWriteImage clEnqueueWriteImage;
//  cl_api_clEnqueueCopyImage clEnqueueCopyImage;
//  cl_api_clEnqueueCopyImageToBuffer clEnqueueCopyImageToBuffer;
//  cl_api_clEnqueueCopyBufferToImage clEnqueueCopyBufferToImage;
//  cl_api_clEnqueueMapBuffer clEnqueueMapBuffer;
//  cl_api_clEnqueueMapImage clEnqueueMapImage;
//  cl_api_clEnqueueUnmapMemObject clEnqueueUnmapMemObject;
//  cl_api_clEnqueueNDRangeKernel clEnqueueNDRangeKernel;
//  cl_api_clEnqueueTask clEnqueueTask;
//  cl_api_clEnqueueNativeKernel clEnqueueNativeKernel;
//  cl_api_clEnqueueMarker clEnqueueMarker;
//  cl_api_clEnqueueWaitForEvents clEnqueueWaitForEvents;
//  cl_api_clEnqueueBarrier clEnqueueBarrier;
//  cl_api_clGetExtensionFunctionAddress clGetExtensionFunctionAddress;
//  cl_api_clCreateFromGLBuffer clCreateFromGLBuffer;
//  cl_api_clCreateFromGLTexture2D clCreateFromGLTexture2D;
//  cl_api_clCreateFromGLTexture3D clCreateFromGLTexture3D;
//  cl_api_clCreateFromGLRenderbuffer clCreateFromGLRenderbuffer;
//  cl_api_clGetGLObjectInfo clGetGLObjectInfo;
//  cl_api_clGetGLTextureInfo clGetGLTextureInfo;
//  cl_api_clEnqueueAcquireGLObjects clEnqueueAcquireGLObjects;
//  cl_api_clEnqueueReleaseGLObjects clEnqueueReleaseGLObjects;
//  cl_api_clGetGLContextInfoKHR clGetGLContextInfoKHR;
//
//  /* cl_khr_d3d10_sharing */
//  cl_api_clGetDeviceIDsFromD3D10KHR clGetDeviceIDsFromD3D10KHR;
//  cl_api_clCreateFromD3D10BufferKHR clCreateFromD3D10BufferKHR;
//  cl_api_clCreateFromD3D10Texture2DKHR clCreateFromD3D10Texture2DKHR;
//  cl_api_clCreateFromD3D10Texture3DKHR clCreateFromD3D10Texture3DKHR;
//  cl_api_clEnqueueAcquireD3D10ObjectsKHR clEnqueueAcquireD3D10ObjectsKHR;
//  cl_api_clEnqueueReleaseD3D10ObjectsKHR clEnqueueReleaseD3D10ObjectsKHR;
//
//  /* OpenCL 1.1 */
//  cl_api_clSetEventCallback clSetEventCallback;
//  cl_api_clCreateSubBuffer clCreateSubBuffer;
//  cl_api_clSetMemObjectDestructorCallback clSetMemObjectDestructorCallback;
//  cl_api_clCreateUserEvent clCreateUserEvent;
//  cl_api_clSetUserEventStatus clSetUserEventStatus;
//  cl_api_clEnqueueReadBufferRect clEnqueueReadBufferRect;
//  cl_api_clEnqueueWriteBufferRect clEnqueueWriteBufferRect;
//  cl_api_clEnqueueCopyBufferRect clEnqueueCopyBufferRect;
//
//  /* cl_ext_device_fission */
//  cl_api_clCreateSubDevicesEXT clCreateSubDevicesEXT;
//  cl_api_clRetainDeviceEXT clRetainDeviceEXT;
//  cl_api_clReleaseDeviceEXT clReleaseDeviceEXT;
//
//  /* cl_khr_gl_event */
//  cl_api_clCreateEventFromGLsyncKHR clCreateEventFromGLsyncKHR;
//
//  /* OpenCL 1.2 */
//  cl_api_clCreateSubDevices clCreateSubDevices;
//  cl_api_clRetainDevice clRetainDevice;
//  cl_api_clReleaseDevice clReleaseDevice;
//  cl_api_clCreateImage clCreateImage;
//  cl_api_clCreateProgramWithBuiltInKernels clCreateProgramWithBuiltInKernels;
//  cl_api_clCompileProgram clCompileProgram;
//  cl_api_clLinkProgram clLinkProgram;
//  cl_api_clUnloadPlatformCompiler clUnloadPlatformCompiler;
//  cl_api_clGetKernelArgInfo clGetKernelArgInfo;
//  cl_api_clEnqueueFillBuffer clEnqueueFillBuffer;
//  cl_api_clEnqueueFillImage clEnqueueFillImage;
//  cl_api_clEnqueueMigrateMemObjects clEnqueueMigrateMemObjects;
//  cl_api_clEnqueueMarkerWithWaitList clEnqueueMarkerWithWaitList;
//  cl_api_clEnqueueBarrierWithWaitList clEnqueueBarrierWithWaitList;
//  cl_api_clGetExtensionFunctionAddressForPlatform clGetExtensionFunctionAddressForPlatform;
//  cl_api_clCreateFromGLTexture clCreateFromGLTexture;
//
//  /* cl_khr_d3d11_sharing */
//  cl_api_clGetDeviceIDsFromD3D11KHR clGetDeviceIDsFromD3D11KHR;
//  cl_api_clCreateFromD3D11BufferKHR clCreateFromD3D11BufferKHR;
//  cl_api_clCreateFromD3D11Texture2DKHR clCreateFromD3D11Texture2DKHR;
//  cl_api_clCreateFromD3D11Texture3DKHR clCreateFromD3D11Texture3DKHR;
//  cl_api_clCreateFromDX9MediaSurfaceKHR clCreateFromDX9MediaSurfaceKHR;
//  cl_api_clEnqueueAcquireD3D11ObjectsKHR clEnqueueAcquireD3D11ObjectsKHR;
//  cl_api_clEnqueueReleaseD3D11ObjectsKHR clEnqueueReleaseD3D11ObjectsKHR;
//
//  /* cl_khr_dx9_media_sharing */
//  cl_api_clGetDeviceIDsFromDX9MediaAdapterKHR clGetDeviceIDsFromDX9MediaAdapterKHR;
//  cl_api_clEnqueueAcquireDX9MediaSurfacesKHR clEnqueueAcquireDX9MediaSurfacesKHR;
//  cl_api_clEnqueueReleaseDX9MediaSurfacesKHR clEnqueueReleaseDX9MediaSurfacesKHR;
//
//  /* cl_khr_egl_image */
//  cl_api_clCreateFromEGLImageKHR clCreateFromEGLImageKHR;
//  cl_api_clEnqueueAcquireEGLObjectsKHR clEnqueueAcquireEGLObjectsKHR;
//  cl_api_clEnqueueReleaseEGLObjectsKHR clEnqueueReleaseEGLObjectsKHR;
//
//  /* cl_khr_egl_event */
//  cl_api_clCreateEventFromEGLSyncKHR clCreateEventFromEGLSyncKHR;
//
//  /* OpenCL 2.0 */
//  cl_api_clCreateCommandQueueWithProperties clCreateCommandQueueWithProperties;
//  cl_api_clCreatePipe clCreatePipe;
//  cl_api_clGetPipeInfo clGetPipeInfo;
//  cl_api_clSVMAlloc clSVMAlloc;
//  cl_api_clSVMFree clSVMFree;
//  cl_api_clEnqueueSVMFree clEnqueueSVMFree;
//  cl_api_clEnqueueSVMMemcpy clEnqueueSVMMemcpy;
//  cl_api_clEnqueueSVMMemFill clEnqueueSVMMemFill;
//  cl_api_clEnqueueSVMMap clEnqueueSVMMap;
//  cl_api_clEnqueueSVMUnmap clEnqueueSVMUnmap;
//  cl_api_clCreateSamplerWithProperties clCreateSamplerWithProperties;
//  cl_api_clSetKernelArgSVMPointer clSetKernelArgSVMPointer;
//  cl_api_clSetKernelExecInfo clSetKernelExecInfo;
//
//  /* cl_khr_sub_groups */
//  cl_api_clGetKernelSubGroupInfoKHR clGetKernelSubGroupInfoKHR;
//
//  /* OpenCL 2.1 */
//  cl_api_clCloneKernel clCloneKernel;
//  cl_api_clCreateProgramWithIL clCreateProgramWithIL;
//  cl_api_clEnqueueSVMMigrateMem clEnqueueSVMMigrateMem;
//  cl_api_clGetDeviceAndHostTimer clGetDeviceAndHostTimer;
//  cl_api_clGetHostTimer clGetHostTimer;
//  cl_api_clGetKernelSubGroupInfo clGetKernelSubGroupInfo;
//  cl_api_clSetDefaultDeviceCommandQueue clSetDefaultDeviceCommandQueue;
//
//  /* OpenCL 2.2 */
//  cl_api_clSetProgramReleaseCallback clSetProgramReleaseCallback;
//  cl_api_clSetProgramSpecializationConstant clSetProgramSpecializationConstant;
//
//  /* OpenCL 3.0 */
//  cl_api_clCreateBufferWithProperties clCreateBufferWithProperties;
//  cl_api_clCreateImageWithProperties clCreateImageWithProperties;
//  cl_api_clSetContextDestructorCallback clSetContextDestructorCallback;
//
//} cl_icd_dispatch;
""")


