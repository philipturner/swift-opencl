# SwiftOpenCL

> Note: This is a work in progress. Do not use it for any project except contributing to the development of this repository.

A native Swift API for OpenCL, based on the [C++ bindings](https://github.com/KhronosGroup/OpenCL-CLHPP). SwiftOpenCL runs on Linux, Windows, macOS, and Android, but not iOS\*. It currently assumes you have OpenCL 1.2 on macOS, or OpenCL 3.0 on all other platforms. Eventually, it will automatically detect which OpenCL version you have at runtime, similarly to [PythonKit](https://github.com/pvieito/PythonKit).

> \*On macOS, OpenCL is implemented as a layer on top of Metal. Apple views OpenCL as deprecated, so it prohibits use of OpenCL on iOS. Metal runs faster than OpenCL in some situations (especially ML), similar to CUDA's optimizations on NVIDIA devices. If you can use SwiftOpenCL, learning Metal to run GPGPU algorithms on iOS devices should not be a major hurdle. 
>
> SwiftOpenCL may evolve into a wrapper for Metal, letting cross-platform GPU benchmarks run on iOS. This would enable OpenCL 3.0 functionality, which are eternally stuck on v1.2. The wrapper could also allow half-precision in shaders, which Apple withholds from OpenCL to reduce performance. If SPIR-V cannot translate OpenCL C into MSL, then Apple's [Metal developer tools for Windows](developer.apple.com/metal) may become necessary.

## Naming Conventions

SwiftOpenCL renames the following words in OpenCL macros:
- "Addr" to "Address"
- "Alloc" to "Allocation"
- "Arg" to "Argument"
- "Cacheline" to "CacheLine"
- "Exec" to "Execution"
- "FP" to "FloatingPoint"
- "Mem" to "Memory"
- "Ptr" to "Pointer"

## Tips

`CLError` produces a name collision with Apple’s CoreLocation, but you can just use `CoreLocation.CLError` and `SwiftOpenCL.CLError` explicitly.

