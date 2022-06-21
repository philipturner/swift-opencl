//
//  CLProgram.swift
//  
//
//  Created by Philip Turner on 6/21/22.
//

import COpenCL

public struct CLProgram: CLReferenceCountable {
  var wrapper: CLReferenceWrapper<Self>
  public var program: cl_program { wrapper.object }
  
  public init?(_ program: cl_program, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(program, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainProgram(object)
  }

  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseProgram(object)
  }
  
  public init?(source: String, build: Bool = false) {
    guard let context = CLContext.defaultContext else {
      return nil
    }
    self.init(context: context, source: source, build: build)
  }
  
  public init?(context: CLContext, source: String, build: Bool = false) {
//    var error: Int32 = 0
    return nil
  }
  
}

extension CLProgram {
  
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetProgramInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
}

// Too complex to implement at the moment.

extension CLProgram {
  
  @inline(__always)
  private func getBuildInfoClosure(device: CLDevice) -> GetInfoClosure {
    { clGetProgramBuildInfo(wrapper.object, device.deviceID, $0, $1, $2, $3) }
  }
  
  
  
//  private var getBuildInfo: GetInfoClosure {
//    2
//  }

}
