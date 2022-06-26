//
//  CLUserEvent.swift
//  
//
//  Created by Philip Turner on 6/26/22.
//

import COpenCL

public struct CLUserEvent {
  public var clEvent: CLEvent
  
  /// `CLUserEvent` is a subset of `CLEvent`. The first parameter is unsafe
  /// because it cannot be checked internally to ensure it is a user event.
  @_transparent
  public init(unsafeCLEvent clEvent: CLEvent) {
    self.clEvent = clEvent
  }
  
  public init?(context: CLContext) {
    var error: Int32 = CL_SUCCESS
    let object_ = clCreateUserEvent(context.context, &error)
    guard CLError.setCode(error, "__CREATE_USER_EVENT_ERR"),
          let object_ = object_,
          let clEvent = CLEvent(object_) else {
      return nil
    }
    self.clEvent = clEvent
  }
  
  public mutating func setStatus(_ status: Int32) throws {
    let error = clSetUserEventStatus(clEvent.event, status)
    try CLError.throwCode(error, "__SET_USER_EVENT_STATUS_ERR")
  }
}
