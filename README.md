# Swift Bindings for OpenCL

A native Swift API for OpenCL, based on the [C++ bindings](https://github.com/KhronosGroup/OpenCL-CLHPP). This package runs on macOS, Linux, Windows, and Android. It detects which OpenCL version you have at runtime.

## Naming Conventions

`swift-opencl` renames the following words in OpenCL macros:
- "Addr" to "Address"
- "Alloc" to "Allocation"
- "Arg" to "Argument"
- "Bitfield" to "BitField"
- "Cacheline" to "CacheLine"
- "Ctor" to "Constructor"
- "Dtor" to "Destructor"
- "Exec" to "Execution"
- "FP" to "FloatingPoint"
- "Mem" to "Memory"
- "Memobject" to "MemoryObject"
- "Ptr" to "Pointer"
- "Rect" to "Rectangle"
- "Spec" to "SpecializationConstant"

This package's source code has numerous comments explaining where its API structure and names differ from the C++ bindings. It lacks much documentation otherwise, because the C++ bindings are extensively documented. Just download `opencl.hpp` and search for the C++ counterpart to any Swift type.

## Tips

Most properties of OpenCL types take a non-negligible time to retrieve, making multiple function calls under the hood. When possible, access them once and reuse the returned value.

```swift
import OpenCL

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

`swift-opencl` dynamically loads OpenCL symbols at runtime like [PythonKit](https://github.com/pvieito/PythonKit), so it can import OpenCL on macOS without depending on the Objective-C framework. This means `swift-opencl`'s Swift module can be named `OpenCL`. If you use the module, ensure the system framework named `OpenCL` is not in your dependency chain.

`CLError` produces a name collision with Apple’s CoreLocation framework. You can work around it by stating `CoreLocation.CLError` and `OpenCL.CLError` explicitly.
