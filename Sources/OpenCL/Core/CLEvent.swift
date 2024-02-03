//
//  CLEvent.swift
//  
//
//  Created by Philip Turner on 6/21/22.
//

import COpenCL

public struct CLEvent: CLReferenceCountable {
  @usableFromInline
  var wrapper: CLReferenceWrapper<Self>
  
  @_transparent
  public var event: cl_event { wrapper.object }
  
  @inline(__always) // Force-inline this internally, but not externally.
  public init?(_ event: cl_event, retain: Bool = false) {
    guard let wrapper = CLReferenceWrapper<Self>(event, retain) else {
      return nil
    }
    self.wrapper = wrapper
  }
  
  @usableFromInline @inline(__always)
  static func retain(_ object: OpaquePointer) -> Int32 {
    clRetainContext(object)
  }
  
  @usableFromInline @inline(__always)
  static func release(_ object: OpaquePointer) -> Int32 {
    clReleaseContext(object)
  }
  
  public func wait() throws {
    var clEvent: cl_event? = wrapper.object
    let error = clWaitForEvents(1, &clEvent)
    try CLError.throwCode(error, "__WAIT_FOR_EVENTS_ERR")
  }
  
  // `notify` does not have an argument label here because it's the object of
  // the verb `set`. `CLProgram.setSpecializationConstant` also follows this
  // naming convention. This differs from functions such as `CLProgram.build`,
  // which use an argument label when `notify` is one of multiple equally
  // important parameters. The parameters `notify` and `type` are rearranged to
  // to emphasize that this function is a setter, but that prohibits passing in
  // a trailing closure. Perhaps Swift 6 will allow a trailing closure:
  // https://github.com/apple/swift-evolution/blob/master/proposals/0286-forward-scan-trailing-closures.md
  public func setCallback(
    _ notify: @escaping (
      _ event: CLEvent,
      _ eventCommandStatus: CLCommandExecutionStatus) -> Void,
    type: CLCommandExecutionStatus
  ) throws {
    let callback = CLEventCallback(notify)
    let error = clSetEventCallback(
      wrapper.object, type.rawValue, callback.callback, callback.passRetained())
    try CLError.throwCode(error, "__SET_EVENT_CALLBACK_ERR")
  }
  
  public static func waitForEvents(_ events: [CLEvent]) throws {
    var error: Int32 = CL_SUCCESS
    let numEvents = events.count
    if numEvents > 0 {
      withUnsafeTemporaryAllocation(
        of: cl_event?.self, capacity: numEvents
      ) { bufferPointer in
        let clEvents = bufferPointer.baseAddress.unsafelyUnwrapped
        error = clWaitForEvents(UInt32(numEvents), clEvents)
      }
    } else {
      error = clWaitForEvents(0, nil)
    }
    try CLError.throwCode(error, "__WAIT_FOR_EVENTS_ERR")
  }
}

public struct CLUserEvent {
  public let event: CLEvent
  
  /// `CLUserEvent` is a subset of `CLEvent`. The first parameter is unsafe
  /// because it cannot be checked internally to ensure it is a user event.
  @_transparent
  public init(_unsafeEvent event: CLEvent) {
    self.event = event
  }
  
  public init?(context: CLContext) {
    var error: Int32 = CL_SUCCESS
    let object_ = clCreateUserEvent(context.clContext, &error)
    guard CLError.setCode(error, "__CREATE_USER_EVENT_ERR"),
          let object_ = object_,
          let event = CLEvent(object_) else {
      return nil
    }
    self.event = event
  }
  
  public func setStatus(_ status: Int32) throws {
    let error = clSetUserEventStatus(event.event, status)
    try CLError.throwCode(error, "__SET_USER_EVENT_STATUS_ERR")
  }
}

extension CLEvent {
  @inline(__always)
  private var getInfo: GetInfoClosure {
    { clGetEventInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var commandQueue: CLCommandQueue? {
    getInfo_CLReferenceCountable(CL_EVENT_COMMAND_QUEUE, getInfo)
  }
  
  public var commandType: CLCommandType? {
    getInfo_CLMacro(CL_EVENT_COMMAND_TYPE, getInfo)
  }
  
  public var referenceCount: UInt32? {
    getInfo_Int(CL_EVENT_REFERENCE_COUNT, getInfo)
  }
  
  public var commandExecutionStatus: Int32? {
    getInfo_Int(CL_EVENT_COMMAND_EXECUTION_STATUS, getInfo)
  }
  
  // OpenCL 1.1
  
  public var context: CLContext? {
    getInfo_CLReferenceCountable(CL_EVENT_CONTEXT, getInfo)
  }
}

extension CLEvent {
  @inline(__always)
  private var getProfilingInfo: GetInfoClosure {
    { clGetEventProfilingInfo(wrapper.object, $0, $1, $2, $3) }
  }
  
  // OpenCL 1.0
  
  public var commandQueued: UInt64? {
    getInfo_Int(CL_PROFILING_COMMAND_QUEUED, getProfilingInfo)
  }
  
  public var commandSubmit: UInt64? {
    getInfo_Int(CL_PROFILING_COMMAND_SUBMIT, getProfilingInfo)
  }
  
  public var commandStart: UInt64? {
    getInfo_Int(CL_PROFILING_COMMAND_START, getProfilingInfo)
  }
  
  public var commandEnd: UInt64? {
    getInfo_Int(CL_PROFILING_COMMAND_END, getProfilingInfo)
  }
}
