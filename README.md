# SwiftOpenCL

A native Swift API for OpenCL, which works on every platform. This is similar to the [C++ bindings](https://github.com/KhronosGroup/OpenCL-CLHPP).

> Note: This is by far a work in progress. Do not use it for any project except contributing to the development of this repository.

> Warning: There may be a name collision with CLError in Apple’s CoreLocation, but you can just use CoreLocation.CLError and SwiftOpenCL.CLError explicitly. This is cross-platform, so we shouldn’t change our namespace from `CL` to `OCL` just because of an Apple library.
