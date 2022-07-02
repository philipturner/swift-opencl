//
//  OpenCLDeprecated.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

// To silence deprecation warnings, I have to manually specify these functions'
// types. Change to `#if false` to validate that these function signatures are
// correct.
#if true
public typealias cl_api_clSetCommandQueueProperty = @convention(c) (
  cl_command_queue?, cl_command_queue_properties, cl_bool,
  UnsafeMutablePointer<cl_command_queue_properties>?) -> cl_int

public typealias cl_api_clCreateImage2D = @convention(c) (
  cl_context?, cl_mem_flags, UnsafePointer<cl_image_format>?, size_t, size_t,
  size_t, UnsafeMutableRawPointer?, UnsafeMutablePointer<cl_int>?) -> cl_mem?

public typealias cl_api_clCreateImage3D = @convention(c) (
  cl_context?, cl_mem_flags, UnsafePointer<cl_image_format>?, size_t, size_t,
  size_t, size_t, size_t, UnsafeMutableRawPointer?,
  UnsafeMutablePointer<Int32>?) -> cl_mem?

public typealias cl_api_clUnloadCompiler = @convention(c) () -> cl_int

public typealias cl_api_clEnqueueMarker = @convention(c) (
  cl_command_queue?, UnsafeMutablePointer<cl_event?>?) -> cl_int

public typealias cl_api_clEnqueueWaitForEvents = @convention(c) (
  cl_command_queue?, cl_uint, UnsafePointer<cl_event?>?) -> cl_int

public typealias cl_api_clEnqueueBarrier = @convention(c) (
  cl_command_queue?) -> cl_int

public typealias cl_api_clGetExtensionFunctionAddress = @convention(c) (
  UnsafePointer<CChar>?) -> UnsafeMutableRawPointer?
#endif

@inline(__always)
fileprivate func load<T>(name: StaticString) -> T? {
  OpenCLLibrary.loadSymbol(name: name)
}

public let clSetCommandQueueProperty: cl_api_clSetCommandQueueProperty =
load(name: "clSetCommandQueueProperty") ?? { _, _, _, _ in
  fatalError()
}

public let clCreateImage2D: cl_api_clCreateImage2D =
load(name: "clCreateImage2D") ?? { _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clCreateImage3D: cl_api_clCreateImage3D =
load(name: "clCreateImage3D") ?? { _, _, _, _, _, _, _, _, _, _ in
  fatalError()
}

public let clUnloadCompiler: cl_api_clUnloadCompiler =
load(name: "clUnloadCompiler") ?? {
  fatalError()
}

public let clEnqueueMarker: cl_api_clEnqueueMarker =
load(name: "clEnqueueMarker") ?? { _, _ in
  fatalError()
}

public let clEnqueueWaitForEvents: cl_api_clEnqueueWaitForEvents =
load(name: "clEnqueueWaitForEvents") ?? { _, _, _ in
  fatalError()
}

public let clEnqueueBarrier: cl_api_clEnqueueBarrier =
load(name: "clEnqueueBarrier") ?? { _ in
  fatalError()
}

public let clGetExtensionFunctionAddress: cl_api_clGetExtensionFunctionAddress =
load(name: "clGetExtensionFunctionAddress") ?? { _ in
  fatalError()
}
