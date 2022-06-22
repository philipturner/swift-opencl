//
//  Defines.swift
//  
//
//  Created by Philip Turner on 6/22/22.
//

import COpenCL

#if canImport(Darwin)
public typealias cl_device_svm_capabilities = cl_bitfield
public typealias cl_version = cl_uint
#endif
