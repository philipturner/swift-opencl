//
//  CLEvent.swift
//  
//
//  Created by Philip Turner on 6/21/22.
//

import COpenCL

public struct CLEvent: CLReferenceCountable {
  var wrapper: CLReferenceWrapper<Self>
  public var event: cl_event { wrapper.object }
  
  public init?(_ event: cl_event, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(event, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainContext(object)
  }
  
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseContext(object)
  }
  
  
  
}

extension CLEvent {
  
  @inline(__always)
  private var getInfo_Event: GetInfoClosure {
    { clGetEventInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
//  public var commandQueue: CLCommandQueue? {
//    getInfo_ReferenceCountable(CL_EVENT_COMMAND_QUEUE, callGetEventInfo)
//  }
  
  public var commandType: cl_command_type? {
    getInfo_Int(CL_EVENT_COMMAND_TYPE, getInfo_Event)
  }
  
  public var referenceCount: UInt32? {
    getInfo_Int(CL_EVENT_REFERENCE_COUNT, getInfo_Event)
  }
  
  public var commandExecutionStatus: Int32? {
    getInfo_Int(CL_EVENT_COMMAND_EXECUTION_STATUS, getInfo_Event)
  }
  
  // OpenCL 1.1
  
  public var context: CLContext? {
    getInfo_ReferenceCountable(CL_EVENT_CONTEXT, getInfo_Event)
  }
  
}

extension CLEvent {
  
  @inline(__always)
  private var getInfo_Profiling: GetInfoClosure {
    { clGetEventProfilingInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var commandQueued: UInt64? {
    getInfo_Int(CL_PROFILING_COMMAND_QUEUED, getInfo_Profiling)
  }
  
  public var commandSubmit: UInt64? {
    getInfo_Int(CL_PROFILING_COMMAND_SUBMIT, getInfo_Profiling)
  }
  
  public var commandStart: UInt64? {
    getInfo_Int(CL_PROFILING_COMMAND_START, getInfo_Profiling)
  }
  
  public var commandEnd: UInt64? {
    getInfo_Int(CL_PROFILING_COMMAND_END, getInfo_Profiling)
  }
  
}
