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
// manually specify deprecated symbols in "OpenCLDeprecated.swift".
//
// If a symbol can't load, it is replaced with a dummy symbol that reports an
// error to `CLError` and returns a custom error code.
//
// Violating the code style convention of indenting the second line of a
// statement. If the rule was followed, this would be too difficult to read.

public let clGetPlatformIDs: cl_api_clGetPlatformIDs =
OpenCLLibrary.loadSymbol(name: "clGetPlatformIDs") ?? { _, _, _ in
  fatalError()
}
