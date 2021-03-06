//
//  CLError.swift
//
//
//  Created by Philip Turner on 5/16/22.
//

import COpenCL
import protocol Foundation.LocalizedError

// TODO: Make a custom error description, store the underlying code in `Storage`
// along with the enumeration or just make the computed property return the
// enumeration.
//
// TODO: Change this from `LocalizedError` to `CustomStringConvertible`, like in
// PythonKit.
//
// Ideas:
// - Grab both the Swift and C function where the error originated. This
//   eliminates the need for looking at the line where the error occurred,
//   because there's often a 1:1 mapping of Swift to C functions.
public struct CLError: LocalizedError {
  // Use reference counted storage to improve memory safety if SwiftOpenCL ever
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
    if let desc = CLError.latest?.errorDescription {
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
  
  // TODO: add #file and #line to allow reconstruction of the stack trace
  // Pass #file and #line into getInfo_XXX as well.
  // Decide whether to make this public after reforming the error mechanism.
  @usableFromInline @inline(__always)
  @discardableResult
  static func setCode(
    _ code: Int32, _ message: @autoclosure () -> String? = Optional(nil)
  ) -> Bool {
    if _slowPath(code != CL_SUCCESS) {
      setLatest(code: code, message: message)
      return false
    } else {
      return true
    }
  }
  
  // Decide whether to make this public after reforming the error mechanism.
  @inline(__always)
  static func throwCode(
    _ code: Int32, _ message: @autoclosure () -> String? = Optional(nil)
  ) throws {
    if _slowPath(code != CL_SUCCESS) {
      setLatest(code: code, message: message)
      throw latest!
    }
  }
  
  // TODO: more advanced functionality that holds a stack of errors, ways to
  // flush them, stack traces, etc.
}
