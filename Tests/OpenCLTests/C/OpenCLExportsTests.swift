import XCTest
import OpenCL

// OpenCL should export COpenCL.
//
// Test that the C typedefs are exported from the header, but the C functions
// are exported from "OpenCLSymbols.swift". Each C function declaration in the
// headers is commented out to prevent you from doing something like
// `COpenCL.clGetPlatformIDs`. That would cause a compiler error because those
// C symbols are not linked.
final class OpenCLExportsTests: XCTestCase {
  func testTypealiasExports() throws {
    guard testPrecondition() else { return }
    
    _ = cl_platform_id.self
    _ = cl_device_id.self
    _ = cl_context.self
    _ = cl_command_queue.self
    _ = cl_mem.self
    _ = cl_program.self
    _ = cl_kernel.self
    _ = cl_event.self
    _ = cl_sampler.self
    
    _ = cl_bool.self
    _ = cl_bitfield.self
    _ = cl_properties.self
    _ = cl_device_type.self
    _ = cl_platform_info.self
    _ = cl_device_info.self
    _ = cl_device_fp_config.self
    _ = cl_device_mem_cache_type.self
    _ = cl_device_local_mem_type.self
    _ = cl_device_exec_capabilities.self
    _ = cl_device_svm_capabilities.self
    _ = cl_command_queue_properties.self
    _ = cl_device_partition_property.self
    _ = cl_device_affinity_domain.self
    
    _ = cl_context_properties.self
    _ = cl_context_info.self
    _ = cl_queue_properties.self
    _ = cl_command_queue_info.self
    _ = cl_channel_order.self
    _ = cl_channel_type.self
    _ = cl_mem_flags.self
    _ = cl_svm_mem_flags.self
    _ = cl_mem_object_type.self
    _ = cl_mem_info.self
    _ = cl_mem_migration_flags.self
    _ = cl_image_info.self
    _ = cl_buffer_create_type.self
    _ = cl_addressing_mode.self
    _ = cl_filter_mode.self
    _ = cl_sampler_info.self
    _ = cl_pipe_properties.self
    _ = cl_pipe_info.self
    _ = cl_program_info.self
    _ = cl_program_build_info.self
    _ = cl_program_binary_type.self
    _ = cl_build_status.self
    _ = cl_kernel_info.self
    _ = cl_kernel_arg_info.self
    _ = cl_kernel_arg_address_qualifier.self
    _ = cl_kernel_arg_access_qualifier.self
    _ = cl_kernel_arg_type_qualifier.self
    _ = cl_kernel_work_group_info.self
    _ = cl_kernel_sub_group_info.self
    _ = cl_event_info.self
    _ = cl_command_type.self
    _ = cl_profiling_info.self
    _ = cl_sampler_properties.self
    _ = cl_kernel_exec_info.self
    _ = cl_device_atomic_capabilities.self
    _ = cl_device_device_enqueue_capabilities.self
    _ = cl_khronos_vendor_id.self
    _ = cl_mem_properties.self
    _ = cl_version.self
    
    _ = cl_image_format.self
    _ = \cl_image_format.image_channel_order
    _ = \cl_image_format.image_channel_data_type
    
    _ = _cl_image_desc.self
    _ = \_cl_image_desc.image_type
    _ = \_cl_image_desc.image_width
    _ = \_cl_image_desc.image_height
    _ = \_cl_image_desc.image_depth
    _ = \_cl_image_desc.image_array_size
    _ = \_cl_image_desc.image_row_pitch
    _ = \_cl_image_desc.image_slice_pitch
    _ = \_cl_image_desc.num_mip_levels
    _ = \_cl_image_desc.num_samples
    _ = \_cl_image_desc.buffer
    _ = \_cl_image_desc.mem_object
    
    _ = cl_buffer_region.self
    _ = \cl_buffer_region.origin
    _ = \cl_buffer_region.size
    
    _ = cl_name_version.self
    _ = \cl_name_version.version
    _ = \cl_name_version.name
  }
}
