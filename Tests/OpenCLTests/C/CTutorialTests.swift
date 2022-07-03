import XCTest
import OpenCL

// Reproduction of the tutorial at this link:
// https://www.eriksmistad.no/getting-started-with-opencl-and-gpu-computing
final class CTutorialTests: XCTestCase {
  func testVectorAddition() throws {
    let listSize = 1024
    var arrayA: [Int32] = []
    arrayA.reserveCapacity(listSize)
    var arrayB: [Int32] = []
    arrayB.reserveCapacity(listSize)
    for i in 0..<listSize {
      arrayA.append(Int32(i))
      arrayB.append(Int32(listSize - i))
    }
    
    let sourceStr = """
    __kernel void vector_add(__global const int *A, __global const int *B, \
    __global int *C) {
     
        // Get the index of the current element to be processed
        int i = get_global_id(0);
     
        // Do the operation
        C[i] = A[i] + B[i];
    }
    """
    let sourceSize = sourceStr.count
    
    var platformID: cl_platform_id?
    var deviceID: cl_device_id?
    var retNumDevices: UInt32 = 0
    var retNumPlatforms: UInt32 = 0
    var ret = clGetPlatformIDs(1, &platformID, &retNumPlatforms)
    XCTAssertEqual(ret, 0)
    ret = clGetDeviceIDs(
      platformID, UInt64(CL_DEVICE_TYPE_DEFAULT), 1, &deviceID, &retNumDevices)
    XCTAssertEqual(ret, 0)
    
    let context = clCreateContext(nil, 1, &deviceID, nil, nil, &ret)
    XCTAssertEqual(ret, 0)
    let commandQueue = clCreateCommandQueue(context, deviceID, 0, &ret)
    XCTAssertEqual(ret, 0)
    
    let bufferSize = listSize * MemoryLayout<Int32>.stride
    func makeBuffer() -> cl_mem? {
      let buffer = clCreateBuffer(
        context, UInt64(CL_MEM_READ_ONLY), bufferSize, nil, &ret)
      XCTAssertEqual(ret, 0)
      return buffer
    }
    let bufferA = makeBuffer()
    let bufferB = makeBuffer()
    let bufferC = makeBuffer()
    
    ret = clEnqueueWriteBuffer(
      commandQueue, bufferA, UInt32(CL_TRUE), 0, bufferSize, arrayA, 0, nil,
      nil)
    XCTAssertEqual(ret, 0)
    ret = clEnqueueWriteBuffer(
      commandQueue, bufferB, UInt32(CL_TRUE), 0, bufferSize, arrayB, 0, nil,
      nil)
    XCTAssertEqual(ret, 0)
    
    let program = sourceStr.withCString { cString -> cl_program? in
      var cStringCopy: UnsafePointer<Int8>? = cString
      var sourceSizeCopy = sourceSize
      return clCreateProgramWithSource(
        context, 1, &cStringCopy, &sourceSizeCopy, &ret)
    }
    XCTAssertEqual(ret, 0)
    ret = clBuildProgram(program, 1, &deviceID, nil, nil, nil)
    XCTAssertEqual(ret, 0)
    let kernel = clCreateKernel(program, "vector_add", &ret)
    XCTAssertEqual(ret, 0)
    
    func setArgument(_ buffer: cl_mem?, index: UInt32) {
      var bufferCopy = buffer
      ret = clSetKernelArg(
        kernel, index, MemoryLayout.stride(ofValue: buffer), &bufferCopy)
      XCTAssertEqual(ret, 0)
    }
    setArgument(bufferA, index: 0)
    setArgument(bufferB, index: 1)
    setArgument(bufferC, index: 2)
    
    var globalItemSize = listSize
    var localItemSize = 64
    ret = clEnqueueNDRangeKernel(
      commandQueue, kernel, 1, nil, &globalItemSize, &localItemSize, 0, nil,
      nil)
    XCTAssertEqual(ret, 0)
    
    var arrayC = [Int32](repeating: 0, count: listSize)
    ret = clEnqueueReadBuffer(
      commandQueue, bufferC, UInt32(CL_TRUE), 0, bufferSize, &arrayC, 0, nil,
      nil)
    XCTAssertEqual(ret, 0)
    
    for i in 0..<listSize {
      let elementA = arrayA[i]
      let elementB = arrayB[i]
      let elementC = arrayC[i]
      guard elementA + elementB == elementC else {
        XCTFail("\(elementA) + \(elementB) = \(elementC)")
        break
      }
    }
    
    func check(_ closure: @autoclosure () -> Int32) {
      ret = closure()
      XCTAssertEqual(ret, 0)
    }
    check(clFlush(commandQueue))
    check(clFinish(commandQueue))
    check(clReleaseKernel(kernel))
    check(clReleaseProgram(program))
    check(clReleaseMemObject(bufferA))
    check(clReleaseMemObject(bufferB))
    check(clReleaseMemObject(bufferC))
    check(clReleaseCommandQueue(commandQueue))
    check(clReleaseContext(context))
  }
}
