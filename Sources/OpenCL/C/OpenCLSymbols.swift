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

//@inline(__always)
//fileprivate func load<T>(name: StaticString, type: T.Ty

public let clGetPlatformIDs: cl_api_clGetPlatformIDs =
OpenCLLibrary.loadSymbol(name: "clGetPlatformIDs") ?? { _, _, _ in
  fatalError()
}

public let clGetPlatformInfo: cl_api_clGetPlatformInfo =
OpenCLLibrary.loadSymbol(name: "clGetPlatformInfo") ?? { _, _, _, _, _ in
  fatalError()
}

public let clGetDeviceIDs: cl_api_clGetDeviceIDs =
OpenCLLibrary.loadSymbol(name: "clGetDeviceIDs") ?? { _, _, _, _, _ in
  fatalError()
}

public let clGetDeviceInfo: cl_api_clGetDeviceInfo =
OpenCLLibrary.loadSymbol(name: "clGetDeviceInfo") ?? { _, _, _, _, _ in
  fatalError()
}

//public let clGetDeviceInfo: cl_api_clGetDeviceInfo =
//OpenCLLibrary.loadSymbol(name: "clGetDeviceInfo") ?? { _, _, _, _, _ in
//  fatalError()
//}
