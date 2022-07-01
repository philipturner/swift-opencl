//
//  Defines.swift
//  
//
//  Created by Philip Turner on 6/22/22.
//

import COpenCL

#if canImport(Darwin)
@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public typealias cl_properties = cl_ulong

// Bit Fields

@available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
public typealias cl_device_atomic_capabilities = cl_bitfield

@available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
public typealias cl_device_device_enqueue_capabilities = cl_bitfield

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public typealias cl_device_svm_capabilities = cl_bitfield

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public typealias cl_svm_mem_flags = cl_bitfield

@available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
public typealias cl_version = cl_uint

// Properties

@available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
public typealias cl_mem_properties = cl_properties

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public typealias cl_pipe_properties = intptr_t

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public typealias cl_queue_properties = cl_properties

@available(macOS, unavailable, message: "macOS does not support OpenCL 2.0.")
public typealias cl_sampler_properties = cl_properties
#endif
