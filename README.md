# SwiftOpenCL

> Note: This is a work in progress. Do not use it for any project except contributing to the development of this repository.

A native Swift API for OpenCL, based on the [C++ bindings](https://github.com/KhronosGroup/OpenCL-CLHPP). SwiftOpenCL runs on Linux, Windows, macOS, and Android, but not iOS\*. It currently assumes you have OpenCL 1.2 on macOS, or OpenCL 3.0 on all other platforms. Eventually, it will automatically detect which OpenCL version you have at runtime, similarly to [PythonKit](https://github.com/pvieito/PythonKit).

> \*On macOS, OpenCL is implemented as a layer on top of Metal. Apple views OpenCL as deprecated, so it prohibits use of OpenCL on iOS. Metal runs faster than OpenCL in some situations (especially ML), similarly to how CUDA is optimized for NVIDIA devices. If you can use SwiftOpenCL, learning Metal to run GPGPU algorithms on iOS should not be a major hurdle.
>
> SwiftOpenCL could evolve into a wrapper for Metal, letting cross-platform GPU benchmarks run on iOS. This would enable OpenCL 3.0 functionality on Apple devices, which are eternally stuck on v1.2. The wrapper could also allow half-precision in shaders, which Apple withholds from OpenCL to reduce performance. SPIR-V should translate OpenCL C into MSL, but Apple's [Metal developer tools for Windows](developer.apple.com/metal) will help if that does not work.

## Naming Conventions

SwiftOpenCL renames the following words in OpenCL macros:
- "Addr" to "Address"
- "Alloc" to "Allocation"
- "Arg" to "Argument"
- "Bitfield" to "BitField"
- "Cacheline" to "CacheLine"
- "Exec" to "Execution"
- "FP" to "FloatingPoint"
- "Mem" to "Memory"
- "Ptr" to "Pointer"
- "Rect" to "Rectangle"
- "Spec" to "SpecializationConstant"

## Tips

Most properties of OpenCL types take a non-negligible time to retrieve, making multiple function calls under the hood. When possible, access them once and reuse the returned value. This rule of thumb may also apply when using Metal.

```swift
// ❌
func inList(device: CLDevice, names: [String]) -> Bool {
  // Fetches the device name on potentially every iteration through `names`.
  names.contains(where: { $0 == device.name! })
}

// ✅
func inList(device: CLDevice, names: [String]) -> Bool {
  let deviceName = device.name!
  return names.contains(where: { $0 == deviceName })
}
```

`CLError` produces a name collision with Apple’s CoreLocation framework. You can work around it by stating `CoreLocation.CLError` and `SwiftOpenCL.CLError` explicitly.
