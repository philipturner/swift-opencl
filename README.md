# SwiftOpenCL

A native Swift API for OpenCL, which works on every platform. This is similar to the [C++ bindings](https://github.com/KhronosGroup/OpenCL-CLHPP).

> Note: This is a work in progress.

> Warning: There is a name collision with CLError in Apple’s CoreLocation, but you can just use CoreLocation.CLError and SwiftOpenCL.CLError explicitly. This is cross-platform and not Apple-centric so we shouldn’t change our namespace just because of an Apple library.
