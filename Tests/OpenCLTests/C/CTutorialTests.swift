import XCTest
import OpenCL

// Reproduce the tutorial at this link:
// https://www.eriksmistad.no/getting-started-with-opencl-and-gpu-computing
final class CTutorialTests: XCTestCase {
  func testVectorAddition() throws {
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
    ret = clGetDeviceIDs(
      platformID, UInt64(CL_DEVICE_TYPE_DEFAULT), 1, &deviceID, &retNumDevices)
    
    
  }
}
