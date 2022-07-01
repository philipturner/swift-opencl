//
//  OpenCLSymbols.swift
//  
//
//  Created by Philip Turner on 6/30/22.
//

import COpenCL

// If a symbol can't load, replace it with a dummy symbol that reports an error
// to `CLError` and returns a custom error code.
//
// How to extract the type:
/// ```
/// fileprivate func returnInstance<T>(of type: T) -> T {
///   return 2 as Any as! T
/// }
///
/// let x = returnInstance(of: COpenCL.clUnloadCompiler)
/// ```
