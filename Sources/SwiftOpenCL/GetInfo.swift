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
    _ param: Int32, _ size: Int, _ value: UnsafeMutableRawPointer,
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
