//
//  CLMemoryObject.swift
//  
//
//  Created by Philip Turner on 6/24/22.
//

import COpenCL

// This protocol's name is not finalized. If it becomes
// `CLMemoryObjectProtocol`:
//
// Do not make this protocol public. Its relation to `CLMemoryObject` differs
// from the relation between `NSObject` and `NSObjectProtocol`, and the relation
// between `Tensor` and `TensorProtocol`.
//
// If the name is `CLMemoryObject`, it should still not be public because it's
// internal to SwiftOpenCL and serves no purpose in the public API.
@usableFromInline
protocol CLMemoryObject {
  
}
