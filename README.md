# SwiftOpenCL

> Note: This is a work in progress. Do not use it for any project except contributing to the development of this repository.

A native Swift API for OpenCL, based on the [C++ bindings](https://github.com/KhronosGroup/OpenCL-CLHPP). SwiftOpenCL runs on Linux, Windows, macOS, and Android, but not iOS\*. It currently supports up to OpenCL 1.2, with more functionality planned for the future.

\*On macOS, OpenCL is implemented as a layer on top of Metal. Apple views OpenCL as deprecated and discourages use, so it does not provide OpenCL bindings for Metal on iOS. Metal has several platform-specific optimizations not present in OpenCL, similar to CUDA's optimizations on NVIDIA devices. In the future, I may turn SwiftOpenCL into a wrapper for Metal on iOS.

## Tips

`CLError` produces a name collision with Apple’s CoreLocation, but you can just use `CoreLocation.CLError` and `SwiftOpenCL.CLError` explicitly.
