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
    var error: Int32 = 0
    var object_: cl_program?
    source.utf8CString.withUnsafeBufferPointer { bufferPointer in
      var string = bufferPointer.baseAddress
      var length = bufferPointer.count
      object_ = clCreateProgramWithSource(
        context.context, UInt32(1), &string, &length, &error)
    }
    guard CLError.handleCode(error, "__CREATE_PROGRAM_WITH_SOURCE_ERR"),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
    
    if build {
      error = clBuildProgram(object_, 0, nil, "-cl-std=CL2.0", nil, nil)
      guard CLError.handleCode(error, "__BUILD_PROGRAM_ERR"),
            !buildLogHasError() else {
        return nil
      }
    }
  }
  
  public init?(sources: [String]) {
    guard let context = CLContext.defaultContext else {
      return nil
    }
    self.init(context: context, sources: sources)
  }
  
  public init?(context: CLContext, sources: [String]) {
    var error: Int32 = 0
    let n = sources.count
    var lengths: [Int] = []
    lengths.reserveCapacity(n)
    var strings: [UnsafePointer<Int8>?] = []
    strings.reserveCapacity(n)
    
    for source in sources {
      lengths.append(source.utf8.count)
      source.withCString {
        strings.append($0)
      }
    }
    let object_ = clCreateProgramWithSource(
      context.context, UInt32(n), &strings, &lengths, &error)
    guard CLError.handleCode(error, "__CREATE_PROGRAM_WITH_SOURCE_ERR"),
          let object_ = object_ else {
      return nil
    }
    self.init(object_)
  }
  
}
