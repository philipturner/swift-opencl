//
//  Defines.swift
//  
//
//  Created by Philip Turner on 6/22/22.
//

import COpenCL

#if canImport(Darwin)
public typealias cl_command_queue_properties = cl_bitfield
public typealias cl_device_atomic_capabilities = cl_bitfield
public typealias cl_device_device_enqueue_capabilities = cl_bitfield
public typealias cl_device_svm_capabilities = cl_bitfield
public typealias cl_svm_mem_flags = cl_bitfield
public typealias cl_version = cl_uint
#endif