//
//  CLSampler.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

public struct CLSampler: CLReferenceCountable {
  @usableFromInline
  var wrapper: CLReferenceWrapper<Self>
  
  @_transparent
  public var clSampler: cl_sampler { wrapper.object }
  
  @inline(__always) // Force-inline this internally, but not externally.
  public init?(_ clSampler: cl_sampler, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(clSampler, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  @usableFromInline
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainSampler(object)
  }
  
  @usableFromInline
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseSampler(object)
  }
  
  public init?(
    context: CLContext,
    normalizedCoords: Bool,
    addressingMode: CLAddressingMode,
    filterMode: CLFilterMode
  ) {
    var error: Int32 = 0
    var object_: cl_sampler?
    #if !canImport(Darwin)
    CLSamplerProperty.withUnsafeTemporaryAllocation(properties: [
      .normalizedCoords: cl_sampler_properties(normalizedCoords ? 1 : 0),
      .addressingMode: cl_sampler_properties(addressingMode.rawValue),
      .filterMode: cl_sampler_properties(filterMode.rawValue)
    ]) { samplerProperties in
      object_ = clCreateSamplerWithProperties(
        context.clContext, samplerProperties.baseAddress, &error)
    }
    let message = "__CREATE_SAMPLER_WITH_PROPERTIES_ERR"
    #else
    object_ = clCreateSampler(
      context.clContext, normalizedCoords ? 1 : 0, addressingMode.rawValue,
      filterMode.rawValue, &error)
    let message = "__CREATE_SAMPLER_ERR"
    #endif
    guard CLError.setCode(error, message),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
}

extension CLSampler {
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetSamplerInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var referenceCount: UInt32? {
    getInfo_Int(CL_SAMPLER_REFERENCE_COUNT, getInfo)
  }
  
  public var context: CLContext? {
    getInfo_CLReferenceCountable(CL_SAMPLER_CONTEXT, getInfo)
  }
  
  public var normalizedCoords: Bool? {
    getInfo_Bool(CL_SAMPLER_NORMALIZED_COORDS, getInfo)
  }
  
  public var addressingMode: CLAddressingMode? {
    getInfo_CLMacro(CL_SAMPLER_ADDRESSING_MODE, getInfo)
  }
  
  public var filterMode: CLFilterMode? {
    getInfo_CLMacro(CL_SAMPLER_FILTER_MODE, getInfo)
  }
  
  // OpenCL 3.0
  
  @available(macOS, unavailable, message: "macOS does not support OpenCL 3.0.")
  public var properties: [CLSamplerProperty]? {
    let name: Int32 = 0x1158
    #if !canImport(Darwin)
    assert(CL_SAMPLER_PROPERTIES == name)
    #endif
    return getInfo_ArrayOfCLProperty(name, getInfo)
  }
}
