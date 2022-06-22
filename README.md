# SwiftOpenCL

> Note: This is by far a work in progress. Do not use it for any project except contributing to the development of this repository.

A native Swift API for OpenCL, which works on every platform. This is similar to the [C++ bindings](https://github.com/KhronosGroup/OpenCL-CLHPP). To start off, I will only add support for OpenCL 1.2, the version that runs on macOS.

There may be a name collision with `CLError` in Apple’s CoreLocation, but you can just use `CoreLocation.CLError` and `SwiftOpenCL.CLError` explicitly. This is cross-platform, so we shouldn’t change our namespace from "CL" to "OCL" just because of an Apple library.

You must manually check `CLError.latest` after every function call if you want to enable error propagation. If every OpenCL function was marked with `throws`, `try!` would lose its semantic meaning and litter your code. As a more ergonomic alternative, `CLError.crashOnError` makes functions crash automatically. You can disable it and manually check `CLError.latest` instead. For properties, initializers, and (most) functions with return values, errors instead propagate via optionals.
