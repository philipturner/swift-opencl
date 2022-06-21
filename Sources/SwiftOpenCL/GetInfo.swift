//
//  GetInfo.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import Foundation
import COpenCL

/*
/*
//! \brief Wrapper for clGetPlatformInfo().
template <typename T>
cl_int getInfo(cl_platform_info name, T* param) const
{
    return detail::errHandler(
        detail::getInfo(&::clGetPlatformInfo, object_, name, param),
        __GET_PLATFORM_INFO_ERR);
}

//! \brief Wrapper for clGetPlatformInfo() that returns by value.
template <cl_platform_info name> typename
detail::param_traits<detail::cl_platform_info, name>::param_type
getInfo(cl_int* err = NULL) const
{
    typename detail::param_traits<
        detail::cl_platform_info, name>::param_type param;
    cl_int result = getInfo(name, &param);
    if (err != NULL) {
        *err = result;
    }
    return param;
}
*/

//struct GetInfoFunctor0<Func, Arg0> {
//  var f_: Func
//  let arg0_: Arg0
//
//  func callAsFunction(
//    _ param: UInt32, _ size: Int, _ value: UnsafeMutableRawPointer,
//    _ size_ret: UnsafeMutablePointer<Int>
//  ) -> Int32 {
//    f_(arg0_, param, size, value, size_ret)
//  }
//}

func getInfo<Func, Arg0, T>(
  _ f: Func, _ arg0: Arg0, _ name: Int32, _ param: UnsafeMutablePointer<T>
) -> Int32 {
  let f0 = GetInfoFunctor0(f_: f, arg0_: arg0)
  return getInfoHelper(f0, name, param, 0);
}

// f = clGetPlatformInfo
// arg0 = cl_platform_id object_
// name = cl_platform_info name
// param = detail::cl_platform_info
// size_ret = 0

// arg0 is absorbed into the Functor
// GetInfoFunctor0.callAsFunction<T>(
//   param=name
//   size=sizeof(T),
//   value=&T,
//   size_ret=NULL
// )

// This is a reference-counted type, even though the retain() function is a
// no-op.

template<typename Func, typename T>
inline cl_int getInfoHelper(Func f, cl_uint name, T* param, int, typename T::cl_type = 0)
{
    typename T::cl_type value;
    cl_int err = f(name, sizeof(value), &value, NULL);
    if (err != CL_SUCCESS) {
        return err;
    }
    *param = value;
    if (value != NULL)
    {
        err = param->retain();
        if (err != CL_SUCCESS) {
            return err;
        }
    }
    return CL_SUCCESS;
}


func getInfo<Arg0, T>(
  _ f: GetInfoFunctor0<Arg0>, _ name: UInt32, param: UnsafeMutablePointer<T>,
  ??? = 0
) -> Int32 {
  var value: T.cl_type
  let err Int32 = f(name, MemoryLayout.stride(ofValue: value), &value, nil)
  if err != CL_SUCCESS {
    return err
  }
  param.pointee = value
  if value != nil {
    err = param.pointee.retain()
    if err != CL_SUCCESS {
      return err
    }
  }
  return CL_SUCCESS
}

// f(token, param_name, T)
struct token;
template<>
struct param_traits<detail:: token, param_name>
{
  enum { value = param_name };
  typedef T param_type;
}

F(cl_platform_info, CL_PLATFORM_PROFILE, string) \
struct cl_platform_info
template<>
struct param_traits<detail::cl_platform_info, CL_PLATFORM_PROFILE>
{
  enum { value = CL_PLATFORM_PROFILE }
  typedef string param_type
}


F(cl_platform_info, CL_PLATFORM_VERSION, string) \
F(cl_platform_info, CL_PLATFORM_NAME, string) \
F(cl_platform_info, CL_PLATFORM_VENDOR, string) \
F(cl_platform_info, CL_PLATFORM_EXTENSIONS, string) \
F(cl_platform_info, CL_PLATFORM_HOST_TIMER_RESOLUTION, cl_ulong) \
F(cl_platform_info, CL_PLATFORM_NUMERIC_VERSION_KHR, cl_version_khr) \
F(cl_platform_info, CL_PLATFORM_EXTENSIONS_WITH_VERSION_KHR, cl::vector<cl_name_version_khr>) \
F(cl_platform_info, CL_PLATFORM_NUMERIC_VERSION, cl_version) \
F(cl_platform_info, CL_PLATFORM_EXTENSIONS_WITH_VERSION, cl::vector<cl_name_version>) \
\

template <cl_platform_info name> typename
detail::param_traits<detail::cl_platform_info, name>::param_type

param_traits<cl_platform_info, CL_PLATFORM_VERSION>::string
param_traits<cl_platform_info, CL_PLATFORM_NAME>::string
param_traits<cl_platform_info, CL_PLATFORM_VENDOR>::string
param_traits<cl_platform_info, CL_PLATFORM_EXTENSIONS>::string
param_traits<cl_platform_info, CL_PLATFORM_HOST_TIMER_RESOLUTION>::cl_ulong
param_traits<cl_platform_info, CL_PLATFORM_NUMERIC_VERSION_KHR>::cl_version_khr
param_traits<cl_platform_info, CL_PLATFORM_EXTENSIONS_WITH_VERSION_KHR>::l::vector<cl_name_version_khr>
param_traits<cl_platform_info, CL_PLATFORM_NUMERIC_VERSION>::cl_version
param_traits<cl_platform_info, CL_PLATFORM_EXTENSIONS_WITH_VERSION>::ccl::vector<cl_name_version>

string getInfo<CL_PLATFORM_VERSION>
string getInfo<CL_PLATFORM_NAME>
string getInfo<CL_PLATFORM_VENDOR>
string getInfo<CL_PLATFORM_EXTENSIONS>
cl_ulong getInfo<CL_PLATFORM_HOST_TIMER_RESOLUTION>
cl_version_khr getInfo<CL_PLATFORM_NUMERIC_VERSION_KHR>
cl::vector<cl_name_version_khr> getInfo<CL_PLATFORM_EXTENSIONS_WITH_VERSION_KHR>
cl_version getInfo<CL_PLATFORM_NUMERIC_VERSION>
cl::vector<cl_name_version> getInfo<CL_PLATFORM_EXTENSIONS_WITH_VERSION>

// For CL_PLATFORM_VERSION:
//
// name = Int32 = CL_PLATFORM_VERSION (macro)
// object_ = cl_platform_id = Arg0
// param = T = param_traits<cl_platform_info, CL_PLATFORM_VERSION>::string
//
// detail::getInfo(&::clGetPlatformInfo, object_, name, param),
// getInfo({ clGetPlatformInfo, object_ }, name, param)
// getInfoHelper({ clGetPlatformInfo, object_ }, name, param, 0)
//
// getInfo(clGetPlatformInfo, object_, CL_PLATFORM_VERSION, inout String)
// getInfoHelper({ clGetPlatformInfo, object_ }, CL_PLATFORM_VERSION, inout String, type object)


// Specialized GetInfoHelper for string params
template <typename Func>
inline cl_int getInfoHelper(Func f, cl_uint name, string* param, long)
{
    size_type required;
    cl_int err = f(name, 0, NULL, &required);
    if (err != CL_SUCCESS) {
        return err;
    }

    // std::string has a constant data member
    // a char vector does not
    if (required > 0) {
        vector<char> value(required);
        err = f(name, required, value.data(), NULL);
        if (err != CL_SUCCESS) {
            return err;
        }
        if (param) {
            param->assign(begin(value), prev(end(value)));
        }
    }
    else if (param) {
        param->assign("");
    }
    return CL_SUCCESS;
}
*/



typealias GetInfoClosure = (
  UInt32, Int, UnsafeMutableRawPointer?, UnsafeMutablePointer<Int>?) -> Int32

// Force-inline this.
func getInfo_Bool(_ name: Int32, _ callGetInfo: GetInfoClosure) -> Bool? {
  var output = false
  let err = callGetInfo(UInt32(name), MemoryLayout<Bool>.stride, &output, nil)
  guard CLError.handleCode(err) else {
    return nil
  }
  return output
}

// Force-inline this.
func getInfo_Int<T: BinaryInteger>(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> T? {
  var output: T = 0
  let err = getInfo(UInt32(name), MemoryLayout<T>.stride, &output, nil)
  guard CLError.handleCode(err) else {
    return nil
  }
  return output
}

func getInfo_ReferenceCountable<T: CLReferenceCountable>(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> T? {
  var value: OpaquePointer? = nil
  let err = getInfo(
    UInt32(name), MemoryLayout<OpaquePointer>.stride, &value, nil)
  guard CLError.handleCode(err) else {
    return nil
  }
  
  guard let value = value else {
    fatalError("This should never happen.")
  }
  return T(value, retain: true)
}

func getInfo_ProgramBinaries2(
  _ f: GetInfoFunctor,
  _ name: UInt32,
  _ param: [[UInt8]]?
) -> Int32 {
  if name != CL_PROGRAM_BINARIES {
    return CL_INVALID_VALUE
  }
    if let param = param {
    let numBinaries = param.count
    let binariesPointers = [UnsafeMutablePointer<UInt8>](
      unsafeUninitializedCapacity: numBinaries, initializingWith: {
        buffer, initializedCount in
        initializedCount = numBinaries
        for i in 0..<numBinaries {
          // Is this safe?
          let ptr = param[i].withUnsafeBufferPointer {
            $0.baseAddress!
          }
          buffer[i] = UnsafeMutablePointer(mutating: ptr)
        }
      })
    defer {
      binariesPointers.forEach { $0.deallocate() }
    }
    
    let ptr = binariesPointers.withUnsafeBufferPointer {
      $0.baseAddress!
    }
    let err = f(
      name, numBinaries * MemoryLayout<UInt8>.stride,
      UnsafeMutablePointer(mutating: ptr), nil)
    if err != CL_SUCCESS {
      return err
    }
  }
  
  return CL_SUCCESS
}

func getInfo_Array<T>(_ name: Int32, _ getInfo: GetInfoClosure) -> [T]? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.handleCode(err) else {
    return nil
  }
  let elements = required / MemoryLayout<T>.stride
  
  let localData = [T](
    unsafeUninitializedCapacity: elements,
    initializingWith: { buffer, initializedCount in
      initializedCount = elements
      err = getInfo(UInt32(name), required, buffer.baseAddress, nil)
    })
  guard CLError.handleCode(err) else {
    return nil
  }
  return localData
}

func getInfo_ArrayOfReferenceCountable<T: CLReferenceCountable>(
  _ name: Int32, _ getInfo: GetInfoClosure
) -> [T]? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.handleCode(err) else {
    return nil
  }
  let elements = required / MemoryLayout<OpaquePointer>.stride
  
  let value: UnsafeMutablePointer<OpaquePointer> = .allocate(capacity: elements)
  defer { value.deallocate() }
  err = getInfo(UInt32(name), required, value, nil)
  guard CLError.handleCode(err) else {
    return nil
  }
  
  var shouldReturnEarly = false
  let output = [T](
    unsafeUninitializedCapacity: elements,
    initializingWith: { buffer, initializedCount in
      for i in 0..<elements {
        guard let element = T(value[i], retain: true) else {
          shouldReturnEarly = true
          initializedCount = i
          return
        }
        buffer[i] = element
      }
      initializedCount = elements
    })
  if shouldReturnEarly {
    return nil
  } else {
    return output
  }
}

func getInfo_String(_ name: Int32, _ getInfo: GetInfoClosure) -> String? {
  var required = 0
  var err = getInfo(UInt32(name), 0, nil, &required)
  guard CLError.handleCode(err) else {
    return nil
  }
  
  if required > 0 {
    var value = malloc(required)!
    err = getInfo(UInt32(name), required, &value, nil)
    guard CLError.handleCode(err) else {
      free(value)
      return nil
    }
    return String(
      bytesNoCopy: value, length: required, encoding: .utf8,
      freeWhenDone: true)!
  } else {
    return ""
  }
}




protocol GetInfoFunctor {
  func callAsFunction(
    _ param: UInt32, _ size: Int, _ value: UnsafeMutableRawPointer?,
    _ size_ret: UnsafeMutablePointer<Int>?
  ) -> Int32
}

struct GetInfoFunctor0: GetInfoFunctor {
  var f_: @convention(c) (
    OpaquePointer?, UInt32, Int, UnsafeMutableRawPointer?,
    UnsafeMutablePointer<Int>?) -> Int32
  var arg0_: OpaquePointer?
  
  func callAsFunction(
    _ param: UInt32, _ size: Int, _ value: UnsafeMutableRawPointer?,
    _ size_ret: UnsafeMutablePointer<Int>?
  ) -> Int32 {
    return f_(arg0_, param, size, value, size_ret)
  }
}

struct GetInfoFunctor1<Arg0, Arg1>: GetInfoFunctor {
  var f_: @convention(c) (
    OpaquePointer?, OpaquePointer?, UInt32, Int,
    UnsafeMutableRawPointer?, UnsafeMutablePointer<Int>?) -> Int32
  var arg0_: OpaquePointer?
  var arg1_: OpaquePointer?
  
  func callAsFunction(
    _ param: UInt32, _ size: Int, _ value: UnsafeMutableRawPointer?,
    _ size_ret: UnsafeMutablePointer<Int>?
  ) -> Int32 {
    return f_(arg0_, arg1_, param, size, value, size_ret)
  }
}

// Specialized for getInfo<CL_PROGRAM_BINARIES>
// Assumes that the output vector was correctly resized on the way in
func getInfoHelper(
  _ f: GetInfoFunctor,
  _ name: UInt32,
  _ param: [[UInt8]]?
) -> Int32 {
  if name != CL_PROGRAM_BINARIES {
    return CL_INVALID_VALUE
  }
    if let param = param {
    let numBinaries = param.count
    let binariesPointers = [UnsafeMutablePointer<UInt8>](
      unsafeUninitializedCapacity: numBinaries, initializingWith: {
        buffer, initializedCount in
        initializedCount = numBinaries
        for i in 0..<numBinaries {
          // Is this safe?
          let ptr = param[i].withUnsafeBufferPointer {
            $0.baseAddress!
          }
          buffer[i] = UnsafeMutablePointer(mutating: ptr)
        }
      })
    defer {
      binariesPointers.forEach { $0.deallocate() }
    }
    
    let ptr = binariesPointers.withUnsafeBufferPointer {
      $0.baseAddress!
    }
    let err = f(
      name, numBinaries * MemoryLayout<UInt8>.stride,
      UnsafeMutablePointer(mutating: ptr), nil)
    if err != CL_SUCCESS {
      return err
    }
  }
  
  return CL_SUCCESS
}

// Specialized getInfoHelper for vector params
func getInfoHelper<T>(
  _ f: GetInfoFunctor,
  _ name: UInt32,
  _ param: inout [T]
) -> Int32 {
  var required: Int = 0
  var err = f(name, 0, nil, &required)
  if err != CL_SUCCESS {
    return err
  }
  let elements = required / MemoryLayout<T>.stride
  
  let localData = Array<T>(
    unsafeUninitializedCapacity: elements,
    initializingWith: { buffer, initializedCount in
      initializedCount = elements
      err = f(name, required, buffer.baseAddress!, nil)
    })
  if err != CL_SUCCESS {
    return err
  }
  param = localData
  
  return CL_SUCCESS
}

/* Specialization for reference-counted types. This depends on the
 * existence of Wrapper<T>::cl_type, and none of the other types having the
 * cl_type member. Note that simplify specifying the parameter as Wrapper<T>
 * does not work, because when using a derived type (e.g. Context) the generic
 * template will provide a better match.
 */
// TODO

// Specialized GetInfoHelper for string params
func getInfoHelper(
  _ f: GetInfoFunctor,
  _ name: UInt32,
  _ param: inout String?
) -> Int32 {
  var required = 0
  var err = f(name, 0, nil, &required)
  if err != CL_SUCCESS {
    return err
  }
  
  if required > 0 {
    var value = malloc(required)!
    err = f(name, required, &value, nil)
    if err != CL_SUCCESS {
      free(value)
      return err
    }
    param = String(
      bytesNoCopy: value, length: required, encoding: .utf8,
      freeWhenDone: true)!
  } else {
    param = ""
  }
  return CL_SUCCESS
}

// Specialized GetInfoHelper for clsize_t params
func getInfoHelper(
  _ f: GetInfoFunctor,
  _ name: UInt32,
  _ param: inout [Int]?,
  _ N: Int
) -> Int32 {
  var required = 0
  var err = f(name, 0, nil, &required)
  if err != CL_SUCCESS {
    return err
  }
  
  var elements = required / MemoryLayout<Int>.stride
  let value = UnsafeMutablePointer<Int>.allocate(capacity: elements)
  defer { value.deallocate() }
  err = f(name, required, value, nil)
  if err != CL_SUCCESS {
    return err
  }
  
  if elements > N {
    elements = N
  }
  param = .init(
    unsafeUninitializedCapacity: elements,
    initializingWith: { buffer, initializedCount in
      initializedCount = elements
      for i in 0..<elements {
        buffer[i] = value[i]
      }
    })
  return CL_SUCCESS
}

// For CL objects
func getInfoHelper(
  _ f: GetInfoFunctor,
  _ name: UInt32,
  _ param: inout OpaquePointer?
) -> Int32 {
  var value: OpaquePointer? = nil
  let err = f(name, MemoryLayout.stride(ofValue: value), &value, nil)
  if err != CL_SUCCESS {
    return err
  }
  
  param = value
  if value != nil {
    /* err = param->retain(); */
    if err != CL_SUCCESS {
      return err
    }
  }
  return CL_SUCCESS
}




/*
// Convenience functions

template <typename Func, typename T>
inline cl_int
getInfo(Func f, cl_uint name, T* param)
{
    return getInfoHelper(f, name, param, 0);
}

template <typename Func, typename Arg0>
struct GetInfoFunctor0
{
    Func f_; const Arg0& arg0_;
    cl_int operator ()(
        cl_uint param, size_type size, void* value, size_type* size_ret)
    { return f_(arg0_, param, size, value, size_ret); }
};

template <typename Func, typename Arg0, typename Arg1>
struct GetInfoFunctor1
{
    Func f_; const Arg0& arg0_; const Arg1& arg1_;
    cl_int operator ()(
        cl_uint param, size_type size, void* value, size_type* size_ret)
    { return f_(arg0_, arg1_, param, size, value, size_ret); }
};

template <typename Func, typename Arg0, typename T>
inline cl_int
getInfo(Func f, const Arg0& arg0, cl_uint name, T* param)
{
    GetInfoFunctor0<Func, Arg0> f0 = { f, arg0 };
    return getInfoHelper(f0, name, param, 0);
}

template <typename Func, typename Arg0, typename Arg1, typename T>
inline cl_int
getInfo(Func f, const Arg0& arg0, const Arg1& arg1, cl_uint name, T* param)
{
    GetInfoFunctor1<Func, Arg0, Arg1> f0 = { f, arg0, arg1 };
    return getInfoHelper(f0, name, param, 0);
}
*/
