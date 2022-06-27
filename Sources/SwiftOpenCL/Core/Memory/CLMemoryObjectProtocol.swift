//
//  CLMemoryObjectProtocol.swift
//  
//
//  Created by Philip Turner on 6/24/22.
//

import COpenCL

// Do not make this protocol public. Its relation to `CLMemoryObject` differs
// from the relation between `NSObject` and `NSObjectProtocol`, or the relation
// between `Tensor` and `TensorProtocol`.
@usableFromInline
protocol CLMemoryObjectProtocol {
  
}
