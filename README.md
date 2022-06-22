# SwiftOpenCL

> Note: This is a work in progress. Do not use it for any project except contributing to the development of this repository.

A native Swift API for OpenCL, which works on every platform. This is similar to the [C++ bindings](https://github.com/KhronosGroup/OpenCL-CLHPP). To start off, I will only add support for OpenCL 1.2, the version that runs on macOS.

## Tips

`CLError` produces a name collision with Apple’s CoreLocation, but you can just use `CoreLocation.CLError` and `SwiftOpenCL.CLError` explicitly.
