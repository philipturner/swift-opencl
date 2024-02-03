//
//  CLError.swift
//
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL
import protocol Foundation.LocalizedError

public struct CLError: Error, CustomStringConvertible {
  // Use reference counted storage to improve memory safety if swift-opencl ever
  // writes to `CLError.latest` from two threads simultaneously.
  private class Storage {
    var code: Int32
    var message: String?
    
    init(code: Int32, message: String?) {
      self.code = code
      self.message = message
     }
  }
  
  private var storage: Storage
  
  public init(code: Int32, message: String?) {
    storage = Storage(code: code, message: message)
  }
  
  public var code: Int32 {
    get { storage.code }
    set { storage.code = newValue }
  }
  public var message: String? {
    get { storage.message }
    set { storage.message = newValue }
  }
  public var description: String {
    "OpenCL error code \(code): \(message ?? "n/a")"
  }
  public var localizedDescription: String {
    description
  }
  
  // MARK: - Static Members
  
  public static var latest: CLError? = nil
  
  /// Call this after a guard statement that checks whether an OpenCL object is
  /// nil.
  ///
  /// ```swift
  /// guard let name = device.name else {
  ///   CLError.fatalError()
  /// }
  /// ```
  public static func fatalError(
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    line: UInt = #line
  ) -> Never {
    var expandedMessage = "OpenCL error: \(message())"
    // Should this be `.localizedDescription` instead?
    if let desc = CLError.latest?.description {
      expandedMessage += "\n\(desc)"
    } else {
      expandedMessage += "\nNo OpenCL errors present."
    }
    Swift.fatalError(expandedMessage, file: file, line: line)
  }
  
  @inline(never)
  private static func setLatest(code: Int32, message: () -> String?) {
    latest = CLError(code: code, message: message())
  }
  
  @usableFromInline @inline(__always)
  @discardableResult
  static func setCode(
    _ code: Int32, _ message: @autoclosure () -> String? = Optional(nil)
  ) -> Bool {
    if code != CL_SUCCESS {
      setLatest(code: code, message: message)
      return false
    } else {
      return true
    }
  }
  
  @inline(__always)
  static func throwCode(
    _ code: Int32, _ message: @autoclosure () -> String? = Optional(nil)
  ) throws {
    if code != CL_SUCCESS {
      setLatest(code: code, message: message)
      throw latest!
    }
  }
}
