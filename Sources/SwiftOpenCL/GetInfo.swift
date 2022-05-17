//
//  GetInfo.swift
//  
//
//  Created by Philip Turner on 5/16/22.
//

import Foundation
import COpenCL

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

struct GetInfoFunctor0<Func, Arg0> {
  var f_: Func
  let arg0_: Arg0
  
  func callAsFunction(
    _ param: UInt32, _ size: Int, _ value: UnsafeMutableRawPointer,
    _ size_ret: UnsafeMutablePointer<Int>
  ) -> Int32 {
    f_(arg0_, param, size, value, size_ret)
  }
}

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
