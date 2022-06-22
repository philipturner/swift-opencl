# SwiftOpenCL

> Note: This is a work in progress. Do not use it for any project except contributing to the development of this repository.

A native Swift API for OpenCL, based on the [C++ bindings](https://github.com/KhronosGroup/OpenCL-CLHPP). SwiftOpenCL runs on Linux, Windows, macOS, and Android, but not iOS\*. It currently supports up to OpenCL 1.2, with more functionality planned for the future.

> \*On macOS, OpenCL is implemented as a layer on top of Metal. Apple views OpenCL as deprecated, so it prohibits use of OpenCL on iOS. Metal runs faster than OpenCL in some situations (especially ML), similar to CUDA's optimizations on NVIDIA devices. If you can use SwiftOpenCL, learning Metal to run GPGPU algorithms on iOS devices should not be a major hurdle. 
>
> SwiftOpenCL could become a partial wrapper for Metal in the future, allowing cross-platform GPU benchmarks to run on iOS. This could also enable OpenCL 3.0 functionality on both iOS and macOS. If GPU shaders do not translate from OpenCL to Metal via SPIR-V, Apple's [Metal developer tools for Windows](developer.apple.com/metal) may become necessary.

## Tips

`CLError` produces a name collision with Apple’s CoreLocation, but you can just use `CoreLocation.CLError` and `SwiftOpenCL.CLError` explicitly.
