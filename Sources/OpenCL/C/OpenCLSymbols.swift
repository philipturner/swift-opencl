//
//  OpenCLSymbols.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

// To extract the type, use typedefs like
// `cl_api_clCreateCommandQueueWithProperties` from "cl_icd.h". To silence
// deprecation warnings in that header, I commented out the ICD dispatch table.
// Even importing the type of a deprecated function induces a warning, so I
// have to manually specify deprecated symbols in "OpenCLDeprecated.swift".
//
// If a symbol can't load, it is replaced with a dummy symbol that reports an
// error to `CLError` and returns a custom error code.
