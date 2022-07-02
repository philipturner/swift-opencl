//
//  OpenCLDeprecated.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

// To silence deprecation warnings, I have to manually write out these
// functions' types.

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
