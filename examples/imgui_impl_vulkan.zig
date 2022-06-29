// dear imgui: Renderer Backend for Vulkan
// This needs to be used along with a Platform Backend (e.g. GLFW, SDL, Win32, custom..)

// Implemented features:
//  [X] Renderer: Support for large meshes (64k+ vertices) with 16-bit indices.
// Missing features:
//  [ ] Renderer: User texture binding. Changes of ImTextureID aren't supported by this binding! See https://github.com/ocornut/imgui/pull/914

// You can copy and use unmodified imgui_impl_* files in your project. See main.cpp for an example of using this.
// If you are new to dear imgui, read examples/README.txt and read the documentation at the top of imgui.cpp.
// https://github.com/ocornut/imgui

// The aim of imgui_impl_vulkan.h/.cpp is to be usable in your engine without any modification.
// IF YOU FEEL YOU NEED TO MAKE ANY CHANGE TO THIS CODE, please share them and your feedback at https://github.com/ocornut/imgui/

// Important note to the reader who wish to integrate imgui_impl_vulkan.cpp/.h in their own engine/app.
// - Common XXX functions and structures are used to interface with imgui_impl_vulkan.cpp/.h.
//   You will use those if you want to use this rendering back-end in your engine/app.
// - Helper XXX functions and structures are only used by this example (main.cpp) and by
//   the back-end itself (imgui_impl_vulkan.cpp), but should PROBABLY NOT be used by your own engine/app code.
// Read comments in imgui_impl_vulkan.h.

// CHANGELOG
// (minor and older changes stripped away, please see git history for details)
//  2019-08-01: Vulkan: Added support for specifying multisample count. Set InitInfo::MSAASamples to one of the vk.SampleCountFlags values to use, default is non-multisampled as before.
//  2019-05-29: Vulkan: Added support for large mesh (64K+ vertices), enable ImGuiBackendFlags_RendererHasVtxOffset flag.
//  2019-04-30: Vulkan: Added support for special ImDrawCallback_ResetRenderState callback to reset render state.
//  2019-04-04: *BREAKING CHANGE*: Vulkan: Added ImageCount/MinImageCount fields in InitInfo, required for initialization (was previously a hard #define IMGUI_VK_QUEUED_FRAMES 2). Added SetMinImageCount().
//  2019-04-04: Vulkan: Added vk.Instance argument to CreateWindow() optional helper.
//  2019-04-04: Vulkan: Avoid passing negative coordinates to vk.CmdSetScissor, which debug validation layers do not like.
//  2019-04-01: Vulkan: Support for 32-bit index buffer (#define ImDrawIdx unsigned int).
//  2019-02-16: Vulkan: Viewport and clipping rectangles correctly using draw_data.FramebufferScale to allow retina display.
//  2018-11-30: Misc: Setting up io.BackendRendererName so it can be displayed in the About Window.
//  2018-08-25: Vulkan: Fixed mishandled vk.SurfaceCapabilitiesKHR::maxImageCount=0 case.
//  2018-06-22: Inverted the parameters to RenderDrawData() to be consistent with other bindings.
//  2018-06-08: Misc: Extracted imgui_impl_vulkan.cpp/.h away from the old combined GLFW+Vulkan example.
//  2018-06-08: Vulkan: Use draw_data.DisplayPos and draw_data.DisplaySize to setup projection matrix and clipping rectangle.
//  2018-03-03: Vulkan: Various refactor, created a couple of XXX helper that the example can use and that viewport support will use.
//  2018-03-01: Vulkan: Renamed Init_Info to InitInfo and fields to match more closely Vulkan terminology.
//  2018-02-16: Misc: Obsoleted the io.RenderDrawListsFn callback, Render() calls RenderDrawData() itself.
//  2018-02-06: Misc: Removed call to ImGui::Shutdown() which is not available from 1.60 WIP, user needs to call CreateContext/DestroyContext themselves.
//  2017-05-15: Vulkan: Fix scissor offset being negative. Fix new Vulkan validation warnings. Set required depth member for buffer image copy.
//  2016-11-13: Vulkan: Fix validation layer warnings and errors and redeclare gl_PerVertex.
//  2016-10-18: Vulkan: Add location decorators & change to use structs as in/out in glsl, update embedded spv (produced with glslangValidator -x). Null the released resources.
//  2016-08-27: Vulkan: Fix Vulkan example for use when a depth buffer is active.

const imgui = @import("imgui");
const std = @import("std");
const vk = @import("include/vk.zig");
const assert = std.debug.assert;

const zig_allocator = std.heap.c_allocator;

pub const InitInfo = struct {
    Instance: vk.Instance,
    PhysicalDevice: vk.PhysicalDevice,
    Device: vk.Device,
    QueueFamily: u32,
    Queue: vk.Queue,
    PipelineCache: vk.PipelineCache,
    DescriptorPool: vk.DescriptorPool,
    Subpass: u32,
    MinImageCount: u32, // >= 2
    ImageCount: u32, // >= MinImageCount
    MSAASamples: vk.SampleCountFlags, // >= VK_SAMPLE_COUNT_1_BIT
    VkAllocator: ?*const vk.AllocationCallbacks,
    CheckVkResultFn: ?fn (i32) callconv(.C) void = null,
};

const Frame = struct {
    CommandPool: vk.CommandPool = undefined,
    CommandBuffer: vk.CommandBuffer = undefined,
    Fence: vk.Fence = undefined,
    Backbuffer: vk.Image,
    BackbufferView: vk.ImageView = undefined,
    Framebuffer: vk.Framebuffer = undefined,
};

const FrameSemaphores = struct {
    ImageAcquiredSemaphore: vk.Semaphore = undefined,
    RenderCompleteSemaphore: vk.Semaphore = undefined,
};

// Helper structure to hold the data needed by one rendering context into one OS window
// (Used by example's main.cpp. Used by multi-viewport features. Probably NOT used by your own engine/app.)
pub const Window = struct {
    Allocator: std.mem.Allocator = undefined,
    Width: u32 = 0,
    Height: u32 = 0,
    Swapchain: vk.SwapchainKHR = .Null,
    Surface: vk.SurfaceKHR = undefined,
    SurfaceFormat: vk.SurfaceFormatKHR = undefined,
    PresentMode: vk.PresentModeKHR = undefined,
    RenderPass: vk.RenderPass = .Null,
    Pipeline: vk.Pipeline = .Null,
    FrameIndex: u32 = 0, // Current frame being rendered to (0 <= FrameIndex < FrameInFlightCount)
    ImageCount: u32 = 0, // Number of simultaneous in-flight frames (returned by vk.GetSwapchainImagesKHR, usually derived from min_image_count)
    SemaphoreIndex: u32 = 0, // Current set of swapchain wait semaphores we're using (needs to be distinct from per frame data)
    Frames: []Frame = undefined,
    FrameSemaphores: []FrameSemaphores = undefined,
};

// Reusable buffers used for rendering 1 current in-flight frame, for RenderDrawData()
// [Please zero-clear before use!]
const FrameRenderBuffers = struct {
    VertexBufferMemory: vk.DeviceMemory = .Null,
    IndexBufferMemory: vk.DeviceMemory = .Null,
    VertexBufferSize: vk.DeviceSize = 0,
    IndexBufferSize: vk.DeviceSize = 0,
    VertexBuffer: vk.Buffer = .Null,
    IndexBuffer: vk.Buffer = .Null,
};

// Each viewport will hold 1 WindowRenderBuffers
const WindowRenderBuffers = struct {
    Index: u32 = 0,
    FrameRenderBuffers: []FrameRenderBuffers = &[_]FrameRenderBuffers{},
};

// Vulkan data
const Data = struct {
    VulkanInitInfo: InitInfo = undefined,
    RenderPass: vk.RenderPass = .Null,
    BufferMemoryAlignment: vk.DeviceSize = 256,
    PipelineCreateFlags: vk.PipelineCreateFlags = .{},
    DescriptorSetLayout: vk.DescriptorSetLayout = .Null,
    PipelineLayout: vk.PipelineLayout = .Null,
    Pipeline: vk.Pipeline = .Null,
    Subpass: u32 = 0,
    ShaderModuleVert: vk.ShaderModule = .Null,
    ShaderModuleFrag: vk.ShaderModule = .Null,

    //font data
    FontSampler: vk.Sampler = .Null,
    FontMemory: vk.DeviceMemory = .Null,
    FontImage: vk.Image = .Null,
    FontView: vk.ImageView = .Null,
    FontDescriptorSet: vk.DescriptorSet = .Null,
    UploadBufferMemory: vk.DeviceMemory = .Null,
    UploadBuffer: vk.Buffer = .Null,

    // Render buffers
    MainWindowRenderBuffers: WindowRenderBuffers = .{},
};

//-----------------------------------------------------------------------------
// SHADERS
//-----------------------------------------------------------------------------

// glsl_shader.vert, compiled with:
// # glslangValidator -V -x -o glsl_shader.vert.u32 glsl_shader.vert
///*
//#version 450 core
//layout(location = 0) in vec2 aPos;
//layout(location = 1) in vec2 aUV;
//layout(location = 2) in vec4 aColor;
//layout(push_constant) uniform uPushConstant { vec2 uScale; vec2 uTranslate; } pc;
//
//out gl_PerVertex { vec4 gl_Position; };
//layout(location = 0) out struct { vec4 Color; vec2 UV; } Out;
//
//void main()
//{
//    Out.Color = aColor;
//    Out.UV = aUV;
//    gl_Position = vec4(aPos * pc.uScale + pc.uTranslate, 0, 1);
//}
//*/
const __glsl_shader_vert_spv = [_]u32{
    0x07230203, 0x00010000, 0x00080001, 0x0000002e, 0x00000000, 0x00020011, 0x00000001, 0x0006000b,
    0x00000001, 0x4c534c47, 0x6474732e, 0x3035342e, 0x00000000, 0x0003000e, 0x00000000, 0x00000001,
    0x000a000f, 0x00000000, 0x00000004, 0x6e69616d, 0x00000000, 0x0000000b, 0x0000000f, 0x00000015,
    0x0000001b, 0x0000001c, 0x00030003, 0x00000002, 0x000001c2, 0x00040005, 0x00000004, 0x6e69616d,
    0x00000000, 0x00030005, 0x00000009, 0x00000000, 0x00050006, 0x00000009, 0x00000000, 0x6f6c6f43,
    0x00000072, 0x00040006, 0x00000009, 0x00000001, 0x00005655, 0x00030005, 0x0000000b, 0x0074754f,
    0x00040005, 0x0000000f, 0x6c6f4361, 0x0000726f, 0x00030005, 0x00000015, 0x00565561, 0x00060005,
    0x00000019, 0x505f6c67, 0x65567265, 0x78657472, 0x00000000, 0x00060006, 0x00000019, 0x00000000,
    0x505f6c67, 0x7469736f, 0x006e6f69, 0x00030005, 0x0000001b, 0x00000000, 0x00040005, 0x0000001c,
    0x736f5061, 0x00000000, 0x00060005, 0x0000001e, 0x73755075, 0x6e6f4368, 0x6e617473, 0x00000074,
    0x00050006, 0x0000001e, 0x00000000, 0x61635375, 0x0000656c, 0x00060006, 0x0000001e, 0x00000001,
    0x61725475, 0x616c736e, 0x00006574, 0x00030005, 0x00000020, 0x00006370, 0x00040047, 0x0000000b,
    0x0000001e, 0x00000000, 0x00040047, 0x0000000f, 0x0000001e, 0x00000002, 0x00040047, 0x00000015,
    0x0000001e, 0x00000001, 0x00050048, 0x00000019, 0x00000000, 0x0000000b, 0x00000000, 0x00030047,
    0x00000019, 0x00000002, 0x00040047, 0x0000001c, 0x0000001e, 0x00000000, 0x00050048, 0x0000001e,
    0x00000000, 0x00000023, 0x00000000, 0x00050048, 0x0000001e, 0x00000001, 0x00000023, 0x00000008,
    0x00030047, 0x0000001e, 0x00000002, 0x00020013, 0x00000002, 0x00030021, 0x00000003, 0x00000002,
    0x00030016, 0x00000006, 0x00000020, 0x00040017, 0x00000007, 0x00000006, 0x00000004, 0x00040017,
    0x00000008, 0x00000006, 0x00000002, 0x0004001e, 0x00000009, 0x00000007, 0x00000008, 0x00040020,
    0x0000000a, 0x00000003, 0x00000009, 0x0004003b, 0x0000000a, 0x0000000b, 0x00000003, 0x00040015,
    0x0000000c, 0x00000020, 0x00000001, 0x0004002b, 0x0000000c, 0x0000000d, 0x00000000, 0x00040020,
    0x0000000e, 0x00000001, 0x00000007, 0x0004003b, 0x0000000e, 0x0000000f, 0x00000001, 0x00040020,
    0x00000011, 0x00000003, 0x00000007, 0x0004002b, 0x0000000c, 0x00000013, 0x00000001, 0x00040020,
    0x00000014, 0x00000001, 0x00000008, 0x0004003b, 0x00000014, 0x00000015, 0x00000001, 0x00040020,
    0x00000017, 0x00000003, 0x00000008, 0x0003001e, 0x00000019, 0x00000007, 0x00040020, 0x0000001a,
    0x00000003, 0x00000019, 0x0004003b, 0x0000001a, 0x0000001b, 0x00000003, 0x0004003b, 0x00000014,
    0x0000001c, 0x00000001, 0x0004001e, 0x0000001e, 0x00000008, 0x00000008, 0x00040020, 0x0000001f,
    0x00000009, 0x0000001e, 0x0004003b, 0x0000001f, 0x00000020, 0x00000009, 0x00040020, 0x00000021,
    0x00000009, 0x00000008, 0x0004002b, 0x00000006, 0x00000028, 0x00000000, 0x0004002b, 0x00000006,
    0x00000029, 0x3f800000, 0x00050036, 0x00000002, 0x00000004, 0x00000000, 0x00000003, 0x000200f8,
    0x00000005, 0x0004003d, 0x00000007, 0x00000010, 0x0000000f, 0x00050041, 0x00000011, 0x00000012,
    0x0000000b, 0x0000000d, 0x0003003e, 0x00000012, 0x00000010, 0x0004003d, 0x00000008, 0x00000016,
    0x00000015, 0x00050041, 0x00000017, 0x00000018, 0x0000000b, 0x00000013, 0x0003003e, 0x00000018,
    0x00000016, 0x0004003d, 0x00000008, 0x0000001d, 0x0000001c, 0x00050041, 0x00000021, 0x00000022,
    0x00000020, 0x0000000d, 0x0004003d, 0x00000008, 0x00000023, 0x00000022, 0x00050085, 0x00000008,
    0x00000024, 0x0000001d, 0x00000023, 0x00050041, 0x00000021, 0x00000025, 0x00000020, 0x00000013,
    0x0004003d, 0x00000008, 0x00000026, 0x00000025, 0x00050081, 0x00000008, 0x00000027, 0x00000024,
    0x00000026, 0x00050051, 0x00000006, 0x0000002a, 0x00000027, 0x00000000, 0x00050051, 0x00000006,
    0x0000002b, 0x00000027, 0x00000001, 0x00070050, 0x00000007, 0x0000002c, 0x0000002a, 0x0000002b,
    0x00000028, 0x00000029, 0x00050041, 0x00000011, 0x0000002d, 0x0000001b, 0x0000000d, 0x0003003e,
    0x0000002d, 0x0000002c, 0x000100fd, 0x00010038,
};

// glsl_shader.frag, compiled with:
// # glslangValidator -V -x -o glsl_shader.frag.u32 glsl_shader.frag
///*
//#version 450 core
//layout(location = 0) out vec4 fColor;
//layout(set=0, binding=0) uniform sampler2D sTexture;
//layout(location = 0) in struct { vec4 Color; vec2 UV; } In;
//void main()
//{
//    fColor = In.Color * texture(sTexture, In.UV.st);
//}
//*/
const __glsl_shader_frag_spv = [_]u32{
    0x07230203, 0x00010000, 0x00080001, 0x0000001e, 0x00000000, 0x00020011, 0x00000001, 0x0006000b,
    0x00000001, 0x4c534c47, 0x6474732e, 0x3035342e, 0x00000000, 0x0003000e, 0x00000000, 0x00000001,
    0x0007000f, 0x00000004, 0x00000004, 0x6e69616d, 0x00000000, 0x00000009, 0x0000000d, 0x00030010,
    0x00000004, 0x00000007, 0x00030003, 0x00000002, 0x000001c2, 0x00040005, 0x00000004, 0x6e69616d,
    0x00000000, 0x00040005, 0x00000009, 0x6c6f4366, 0x0000726f, 0x00030005, 0x0000000b, 0x00000000,
    0x00050006, 0x0000000b, 0x00000000, 0x6f6c6f43, 0x00000072, 0x00040006, 0x0000000b, 0x00000001,
    0x00005655, 0x00030005, 0x0000000d, 0x00006e49, 0x00050005, 0x00000016, 0x78655473, 0x65727574,
    0x00000000, 0x00040047, 0x00000009, 0x0000001e, 0x00000000, 0x00040047, 0x0000000d, 0x0000001e,
    0x00000000, 0x00040047, 0x00000016, 0x00000022, 0x00000000, 0x00040047, 0x00000016, 0x00000021,
    0x00000000, 0x00020013, 0x00000002, 0x00030021, 0x00000003, 0x00000002, 0x00030016, 0x00000006,
    0x00000020, 0x00040017, 0x00000007, 0x00000006, 0x00000004, 0x00040020, 0x00000008, 0x00000003,
    0x00000007, 0x0004003b, 0x00000008, 0x00000009, 0x00000003, 0x00040017, 0x0000000a, 0x00000006,
    0x00000002, 0x0004001e, 0x0000000b, 0x00000007, 0x0000000a, 0x00040020, 0x0000000c, 0x00000001,
    0x0000000b, 0x0004003b, 0x0000000c, 0x0000000d, 0x00000001, 0x00040015, 0x0000000e, 0x00000020,
    0x00000001, 0x0004002b, 0x0000000e, 0x0000000f, 0x00000000, 0x00040020, 0x00000010, 0x00000001,
    0x00000007, 0x00090019, 0x00000013, 0x00000006, 0x00000001, 0x00000000, 0x00000000, 0x00000000,
    0x00000001, 0x00000000, 0x0003001b, 0x00000014, 0x00000013, 0x00040020, 0x00000015, 0x00000000,
    0x00000014, 0x0004003b, 0x00000015, 0x00000016, 0x00000000, 0x0004002b, 0x0000000e, 0x00000018,
    0x00000001, 0x00040020, 0x00000019, 0x00000001, 0x0000000a, 0x00050036, 0x00000002, 0x00000004,
    0x00000000, 0x00000003, 0x000200f8, 0x00000005, 0x00050041, 0x00000010, 0x00000011, 0x0000000d,
    0x0000000f, 0x0004003d, 0x00000007, 0x00000012, 0x00000011, 0x0004003d, 0x00000014, 0x00000017,
    0x00000016, 0x00050041, 0x00000019, 0x0000001a, 0x0000000d, 0x00000018, 0x0004003d, 0x0000000a,
    0x0000001b, 0x0000001a, 0x00050057, 0x00000007, 0x0000001c, 0x00000017, 0x0000001b, 0x00050085,
    0x00000007, 0x0000001d, 0x00000012, 0x0000001c, 0x0003003e, 0x00000009, 0x0000001d, 0x000100fd,
    0x00010038,
};

//-----------------------------------------------------------------------------
// FUNCTIONS
//-----------------------------------------------------------------------------

// Backend data stored in io.BackendRendererUserData to allow support for multiple Dear ImGui contexts
// It is STRONGLY preferred that you use docking branch with multi-viewports (== single Dear ImGui context + multiple windows) instead of multiple Dear ImGui contexts.
// FIXME: multi-context support is not tested and probably dysfunctional in this backend.
fn GetBackendData() ?*Data {
    return if (imgui.GetCurrentContext() != null)
        @ptrCast(?*Data, @alignCast(@alignOf(Data), imgui.GetIO().BackendRendererUserData))
    else null;
}

fn MemoryType(properties: vk.MemoryPropertyFlags, type_bits: u32) ?u32 {
    const bd = GetBackendData().?;
    var v = &bd.VulkanInitInfo;
    var prop = vk.GetPhysicalDeviceMemoryProperties(v.PhysicalDevice);
    for (prop.memoryTypes[0..prop.memoryTypeCount]) |memType, i|
        if (memType.propertyFlags.hasAllSet(properties) and type_bits & (@as(u32, 1) << @intCast(u5, i)) != 0)
            return @intCast(u32, i);
    return null; // Unable to find memoryType
}

fn CreateOrResizeBuffer(buffer: *vk.Buffer, buffer_memory: *vk.DeviceMemory, p_buffer_size: *vk.DeviceSize, new_size: usize, usage: vk.BufferUsageFlags) !void {
    const bd = GetBackendData().?;
    var v = &bd.VulkanInitInfo;
    if (buffer.* != .Null)
        vk.DestroyBuffer(v.Device, buffer.*, v.VkAllocator);
    if (buffer_memory.* != .Null)
        vk.FreeMemory(v.Device, buffer_memory.*, v.VkAllocator);

    var vertex_buffer_size_aligned = ((new_size - 1) / bd.BufferMemoryAlignment + 1) * bd.BufferMemoryAlignment;
    const buffer_info = vk.BufferCreateInfo{
        .size = vertex_buffer_size_aligned,
        .usage = usage,
        .sharingMode = .EXCLUSIVE,
    };
    buffer.* = try vk.CreateBuffer(v.Device, buffer_info, v.VkAllocator);

    var req = vk.GetBufferMemoryRequirements(v.Device, buffer.*);
    bd.BufferMemoryAlignment = if (bd.BufferMemoryAlignment > req.alignment) bd.BufferMemoryAlignment else req.alignment;
    var alloc_info = vk.MemoryAllocateInfo{
        .allocationSize = req.size,
        .memoryTypeIndex = MemoryType(.{ .hostVisible = true }, req.memoryTypeBits).?,
    };
    buffer_memory.* = try vk.AllocateMemory(v.Device, alloc_info, v.VkAllocator);

    try vk.BindBufferMemory(v.Device, buffer.*, buffer_memory.*, 0);
    p_buffer_size.* = req.size;
}

fn SetupRenderState(draw_data: *imgui.DrawData, pipeline: vk.Pipeline, command_buffer: vk.CommandBuffer, rb: *FrameRenderBuffers, fb_width: u32, fb_height: u32) void {
    const bd = GetBackendData().?;

    // Bind pipeline and descriptor sets:
    {
        vk.CmdBindPipeline(command_buffer, .GRAPHICS, pipeline);
    }

    // Bind Vertex And Index Buffer:
    if (draw_data.TotalVtxCount > 0) {
        var vertex_buffers = [_]vk.Buffer{rb.VertexBuffer};
        var vertex_offset = [_]vk.DeviceSize{0};
        vk.CmdBindVertexBuffers(command_buffer, 0, &vertex_buffers, &vertex_offset);
        vk.CmdBindIndexBuffer(command_buffer, rb.IndexBuffer, 0, if (@sizeOf(imgui.DrawIdx) == 2) .UINT16 else .UINT32);
    }

    // Setup viewport:
    {
        const viewport = vk.Viewport{
            .x = 0,
            .y = 0,
            .width = @intToFloat(f32, fb_width),
            .height = @intToFloat(f32, fb_height),
            .minDepth = 0.0,
            .maxDepth = 1.0,
        };
        vk.CmdSetViewport(command_buffer, 0, arrayPtr(&viewport));
    }

    // Setup scale and translation:
    // Our visible imgui space lies from draw_data.DisplayPps (top left) to draw_data.DisplayPos+data_data.DisplaySize (bottom right). DisplayPos is (0,0) for single viewport apps.
    {
        var scale = [2]f32{
            2.0 / draw_data.DisplaySize.x,
            2.0 / draw_data.DisplaySize.y,
        };
        var translate = [2]f32{
            -1.0 - draw_data.DisplayPos.x * scale[0],
            -1.0 - draw_data.DisplayPos.y * scale[1],
        };
        vk.CmdPushConstants(command_buffer, bd.PipelineLayout, .{ .vertex = true }, @sizeOf(f32) * 0, std.mem.asBytes(&scale));
        vk.CmdPushConstants(command_buffer, bd.PipelineLayout, .{ .vertex = true }, @sizeOf(f32) * 2, std.mem.asBytes(&translate));
    }
}

// Render function
pub fn RenderDrawData(draw_data: *imgui.DrawData, command_buffer: vk.CommandBuffer, opt_pipeline: vk.Pipeline) !void {
    // Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
    const fb_width = @floatToInt(u32, draw_data.DisplaySize.x * draw_data.FramebufferScale.x);
    const fb_height = @floatToInt(u32, draw_data.DisplaySize.y * draw_data.FramebufferScale.y);
    if (fb_width <= 0 or fb_height <= 0)
        return;

    const bd = GetBackendData().?;
    const v = &bd.VulkanInitInfo;
    const pipeline = if (opt_pipeline == .Null) bd.Pipeline else opt_pipeline;

    // Allocate array to store enough vertex/index buffers
    const wrb = &bd.MainWindowRenderBuffers;
    if (wrb.FrameRenderBuffers.len == 0) {
        wrb.Index = 0;
        wrb.FrameRenderBuffers = try zig_allocator.alloc(FrameRenderBuffers, v.ImageCount);
        for (wrb.FrameRenderBuffers) |*elem| {
            elem.* = FrameRenderBuffers{};
        }
    }
    assert(wrb.FrameRenderBuffers.len == v.ImageCount);
    wrb.Index = (wrb.Index + 1) % @intCast(u32, wrb.FrameRenderBuffers.len);
    const rb = &wrb.FrameRenderBuffers[wrb.Index];

    if (draw_data.TotalVtxCount > 0) {
        // Create or resize the vertex/index buffers
        var vertex_size = @intCast(usize, draw_data.TotalVtxCount) * @sizeOf(imgui.DrawVert);
        var index_size = @intCast(usize, draw_data.TotalIdxCount) * @sizeOf(imgui.DrawIdx);
        if (rb.VertexBuffer == .Null or rb.VertexBufferSize < vertex_size)
            try CreateOrResizeBuffer(&rb.VertexBuffer, &rb.VertexBufferMemory, &rb.VertexBufferSize, vertex_size, .{ .vertexBuffer = true });
        if (rb.IndexBuffer == .Null or rb.IndexBufferSize < index_size)
            try CreateOrResizeBuffer(&rb.IndexBuffer, &rb.IndexBufferMemory, &rb.IndexBufferSize, index_size, .{ .indexBuffer = true });

        // Upload vertex/index data into a single contiguous GPU buffer
        var vtx_dst: [*]imgui.DrawVert = undefined;
        var idx_dst: [*]imgui.DrawIdx = undefined;
        try vk.MapMemory(v.Device, rb.VertexBufferMemory, 0, vertex_size, .{}, @ptrCast(**anyopaque, &vtx_dst));
        try vk.MapMemory(v.Device, rb.IndexBufferMemory, 0, index_size, .{}, @ptrCast(**anyopaque, &idx_dst));
        var n: i32 = 0;
        while (n < draw_data.CmdListsCount) : (n += 1) {
            const cmd_list = draw_data.CmdLists.?[@intCast(u32, n)];
            std.mem.copy(imgui.DrawVert, vtx_dst[0..cmd_list.VtxBuffer.size()], cmd_list.VtxBuffer.items());
            std.mem.copy(imgui.DrawIdx, idx_dst[0..cmd_list.IdxBuffer.size()], cmd_list.IdxBuffer.items());
            vtx_dst += cmd_list.VtxBuffer.size();
            idx_dst += cmd_list.IdxBuffer.size();
        }

        var ranges = [2]vk.MappedMemoryRange{
            vk.MappedMemoryRange{
                .memory = rb.VertexBufferMemory,
                .size = vk.WHOLE_SIZE,
                .offset = 0,
            },
            vk.MappedMemoryRange{
                .memory = rb.IndexBufferMemory,
                .size = vk.WHOLE_SIZE,
                .offset = 0,
            },
        };
        try vk.FlushMappedMemoryRanges(v.Device, &ranges);

        vk.UnmapMemory(v.Device, rb.VertexBufferMemory);
        vk.UnmapMemory(v.Device, rb.IndexBufferMemory);
    }

    // Setup desired Vulkan state
    SetupRenderState(draw_data, pipeline, command_buffer, rb, fb_width, fb_height);

    // Will project scissor/clipping rectangles into framebuffer space
    var clip_off = draw_data.DisplayPos; // (0,0) unless using multi-viewports
    var clip_scale = draw_data.FramebufferScale; // (1,1) unless using retina display which are often (2,2)

    // Render command lists
    // (Because we merged all buffers into a single one, we maintain our own offset into them)
    var global_vtx_offset = @as(u32, 0);
    var global_idx_offset = @as(u32, 0);
    var n: usize = 0;
    while (n < @intCast(usize, draw_data.CmdListsCount)) : (n += 1) {
        const cmd_list = draw_data.CmdLists.?[n];
        for (cmd_list.CmdBuffer.items()) |*pcmd| {
            if (pcmd.UserCallback) |fnPtr| {
                // User callback, registered via imgui.DrawList::AddCallback()
                // (imgui.DrawCallback_ResetRenderState is a special callback value used by the user to request the renderer to reset render state.)
                if (fnPtr == imgui.DrawCallback_ResetRenderState) {
                    SetupRenderState(draw_data, pipeline, command_buffer, rb, fb_width, fb_height);
                } else {
                    fnPtr(cmd_list, pcmd);
                }
            } else {
                // Project scissor/clipping rectangles into framebuffer space
                var clip_min = imgui.Vec2{
                    .x = (pcmd.ClipRect.x - clip_off.x) * clip_scale.x,
                    .y = (pcmd.ClipRect.y - clip_off.y) * clip_scale.y,
                };
                var clip_max = imgui.Vec2{
                    .x = (pcmd.ClipRect.z - clip_off.x) * clip_scale.x,
                    .y = (pcmd.ClipRect.w - clip_off.y) * clip_scale.y,
                };

                // Clamp to viewport as vkCmdSetScissor() won't accept values that are off bounds
                const fb_width_f = @intToFloat(f32, fb_width);
                const fb_height_f = @intToFloat(f32, fb_height);
                if (clip_min.x < 0) clip_min.x = 0;
                if (clip_min.y < 0) clip_min.y = 0;
                if (clip_max.x > fb_width_f) clip_max.x = fb_width_f;
                if (clip_max.y > fb_height_f) clip_max.y = fb_height_f;
                if (clip_max.x <= clip_min.x or clip_max.y <= clip_min.y)
                    continue;

                // Apply scissor/clipping rectangle
                const scissor = vk.Rect2D{
                    .offset = vk.Offset2D{
                        .x = @floatToInt(i32, clip_min.x),
                        .y = @floatToInt(i32, clip_min.y),
                    },
                    .extent = vk.Extent2D{
                        .width = @floatToInt(u32, clip_max.x - clip_min.x),
                        .height = @floatToInt(u32, clip_max.y - clip_min.y),
                    },
                };
                vk.CmdSetScissor(command_buffer, 0, arrayPtr(&scissor));

                var desc_set = @intToEnum(vk.DescriptorSet, @ptrToInt(pcmd.TextureId));
                if (@sizeOf(imgui.TextureID) < @sizeOf(u64)) {
                    // We don't support texture switches if ImTextureID hasn't been redefined to be 64-bit. Do a flaky check that other textures haven't been used.
                    assert(@intToEnum(vk.DescriptorSet, @ptrToInt(pcmd.TextureId)) == bd.FontDescriptorSet);
                    desc_set = bd.FontDescriptorSet;
                }
                vk.CmdBindDescriptorSets(command_buffer, .GRAPHICS, bd.PipelineLayout, 0, arrayPtr(&desc_set), &[_]u32{});

                // Draw
                const idxStart = @intCast(u32, pcmd.IdxOffset + global_idx_offset);
                const vtxStart = @intCast(i32, pcmd.VtxOffset + global_vtx_offset);
                vk.CmdDrawIndexed(command_buffer, pcmd.ElemCount, 1, idxStart, vtxStart, 0);
            }
        }
        global_idx_offset += cmd_list.IdxBuffer.size();
        global_vtx_offset += cmd_list.VtxBuffer.size();
    }

    // Note: at this point both vkCmdSetViewport() and vkCmdSetScissor() have been called.
    // Our last values will leak into user/application rendering IF:
    // - Your app uses a pipeline with VK_DYNAMIC_STATE_VIEWPORT or VK_DYNAMIC_STATE_SCISSOR dynamic state
    // - And you forgot to call vkCmdSetViewport() and vkCmdSetScissor() yourself to explicitely set that state.
    // If you use VK_DYNAMIC_STATE_VIEWPORT or VK_DYNAMIC_STATE_SCISSOR you are responsible for setting the values before rendering.
    // In theory we should aim to backup/restore those values but I am not sure this is possible.
    // We perform a call to vkCmdSetScissor() to set back a full viewport which is likely to fix things for 99% users but technically this is not perfect. (See github #4644)
    const scissor = vk.Rect2D{
        .offset = .{ .x = 0, .y = 0 },
        .extent = .{ .width = fb_width, .height = fb_height },
    };
    vk.CmdSetScissor(command_buffer, 0, arrayPtr(&scissor));
}

pub fn CreateFontsTexture(command_buffer: vk.CommandBuffer) !void {
    const bd = GetBackendData().?;
    const v = &bd.VulkanInitInfo;
    const io = imgui.GetIO();

    var pixels: ?[*]u8 = undefined;
    var width: i32 = 0;
    var height: i32 = 0;
    io.Fonts.?.GetTexDataAsRGBA32(&pixels, &width, &height);
    var upload_size = @intCast(usize, width * height * 4);

    // Create the Image:
    {
        var info = vk.ImageCreateInfo{
            .imageType = .T_2D,
            .format = .R8G8B8A8_UNORM,
            .extent = vk.Extent3D{
                .width = @intCast(u32, width),
                .height = @intCast(u32, height),
                .depth = 1,
            },
            .mipLevels = 1,
            .arrayLayers = 1,
            .samples = .{ .t1 = true },
            .tiling = .OPTIMAL,
            .usage = .{ .sampled = true, .transferDst = true },
            .sharingMode = .EXCLUSIVE,
            .initialLayout = .UNDEFINED,
        };
        bd.FontImage = try vk.CreateImage(v.Device, info, v.VkAllocator);
        var req = vk.GetImageMemoryRequirements(v.Device, bd.FontImage);
        var alloc_info = vk.MemoryAllocateInfo{
            .allocationSize = req.size,
            .memoryTypeIndex = MemoryType(.{ .deviceLocal = true }, req.memoryTypeBits).?,
        };
        bd.FontMemory = try vk.AllocateMemory(v.Device, alloc_info, v.VkAllocator);
        try vk.BindImageMemory(v.Device, bd.FontImage, bd.FontMemory, 0);
    }

    // Create the Image View:
    {
        var info = vk.ImageViewCreateInfo{
            .image = bd.FontImage,
            .viewType = .T_2D,
            .format = .R8G8B8A8_UNORM,
            .subresourceRange = vk.ImageSubresourceRange{
                .aspectMask = .{ .color = true },
                .levelCount = 1,
                .layerCount = 1,
                .baseMipLevel = 0,
                .baseArrayLayer = 0,
            },
            .components = vk.ComponentMapping{
                .r = .R,
                .g = .G,
                .b = .B,
                .a = .A,
            },
        };
        bd.FontView = try vk.CreateImageView(v.Device, info, v.VkAllocator);
    }

    // Create the Descriptor Set:
    bd.FontDescriptorSet = try AddTexture(bd.FontSampler, bd.FontView, .SHADER_READ_ONLY_OPTIMAL);

    // Create the Upload Buffer:
    {
        var buffer_info = vk.BufferCreateInfo{
            .size = upload_size,
            .usage = .{ .transferSrc = true },
            .sharingMode = .EXCLUSIVE,
        };
        bd.UploadBuffer = try vk.CreateBuffer(v.Device, buffer_info, v.VkAllocator);
        var req = vk.GetBufferMemoryRequirements(v.Device, bd.UploadBuffer);
        if (req.alignment > bd.BufferMemoryAlignment) {
            bd.BufferMemoryAlignment = req.alignment;
        }
        var alloc_info = vk.MemoryAllocateInfo{
            .allocationSize = req.size,
            .memoryTypeIndex = MemoryType(.{ .hostVisible = true }, req.memoryTypeBits).?,
        };
        bd.UploadBufferMemory = try vk.AllocateMemory(v.Device, alloc_info, v.VkAllocator);
        try vk.BindBufferMemory(v.Device, bd.UploadBuffer, bd.UploadBufferMemory, 0);
    }

    // Upload to Buffer:
    {
        var map: [*]u8 = undefined;
        try vk.MapMemory(v.Device, bd.UploadBufferMemory, 0, upload_size, .{}, @ptrCast(**anyopaque, &map));
        std.mem.copy(u8, map[0..upload_size], pixels.?[0..upload_size]);
        var range = [_]vk.MappedMemoryRange{vk.MappedMemoryRange{
            .memory = bd.UploadBufferMemory,
            .size = upload_size,
            .offset = 0,
        }};
        try vk.FlushMappedMemoryRanges(v.Device, &range);
        vk.UnmapMemory(v.Device, bd.UploadBufferMemory);
    }

    // Copy to Image:
    {
        var copy_barrier = [1]vk.ImageMemoryBarrier{vk.ImageMemoryBarrier{
            .srcAccessMask = .{},
            .dstAccessMask = .{ .transferWrite = true },
            .oldLayout = .UNDEFINED,
            .newLayout = .TRANSFER_DST_OPTIMAL,
            .srcQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
            .dstQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
            .image = bd.FontImage,
            .subresourceRange = vk.ImageSubresourceRange{
                .aspectMask = .{ .color = true },
                .levelCount = 1,
                .layerCount = 1,
                .baseMipLevel = 0,
                .baseArrayLayer = 0,
            },
        }};
        vk.CmdPipelineBarrier(command_buffer, .{ .host = true }, .{ .transfer = true }, .{}, &[_]vk.MemoryBarrier{}, &[_]vk.BufferMemoryBarrier{}, &copy_barrier);

        var region = [_]vk.BufferImageCopy{vk.BufferImageCopy{
            .imageSubresource = vk.ImageSubresourceLayers{
                .aspectMask = .{ .color = true },
                .mipLevel = 0,
                .baseArrayLayer = 0,
                .layerCount = 1,
            },
            .bufferOffset = 0,
            .bufferRowLength = 0,
            .bufferImageHeight = 0,
            .imageOffset = vk.Offset3D{ .x = 0, .y = 0, .z = 0 },
            .imageExtent = vk.Extent3D{ .width = @intCast(u32, width), .height = @intCast(u32, height), .depth = 1 },
        }};
        vk.CmdCopyBufferToImage(command_buffer, bd.UploadBuffer, bd.FontImage, .TRANSFER_DST_OPTIMAL, &region);

        var use_barrier = [_]vk.ImageMemoryBarrier{vk.ImageMemoryBarrier{
            .srcAccessMask = .{ .transferWrite = true },
            .dstAccessMask = .{ .shaderRead = true },
            .oldLayout = .TRANSFER_DST_OPTIMAL,
            .newLayout = .SHADER_READ_ONLY_OPTIMAL,
            .srcQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
            .dstQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
            .image = bd.FontImage,
            .subresourceRange = vk.ImageSubresourceRange{
                .aspectMask = .{ .color = true },
                .levelCount = 1,
                .layerCount = 1,
                .baseMipLevel = 0,
                .baseArrayLayer = 0,
            },
        }};
        vk.CmdPipelineBarrier(command_buffer, .{ .transfer = true }, .{ .fragmentShader = true }, .{}, &[_]vk.MemoryBarrier{}, &[_]vk.BufferMemoryBarrier{}, &use_barrier);
    }

    // Store our identifier
    io.Fonts.?.SetTexID(@intToPtr(imgui.TextureID, @enumToInt(bd.FontDescriptorSet)));
}

fn CreateShaderModules(device: vk.Device, allocator: ?*const vk.AllocationCallbacks) !void {
    // Create The Shader Modules:
    const bd = GetBackendData().?;
    if (bd.ShaderModuleVert == .Null) {
        const vert_info = vk.ShaderModuleCreateInfo{
            .codeSize = @sizeOf(@TypeOf(__glsl_shader_vert_spv)),
            .pCode = &__glsl_shader_vert_spv,
        };
        bd.ShaderModuleVert = try vk.CreateShaderModule(device, vert_info, allocator);
    }
    if (bd.ShaderModuleFrag == .Null) {
        const frag_info = vk.ShaderModuleCreateInfo{
            .codeSize = @sizeOf(@TypeOf(__glsl_shader_frag_spv)),
            .pCode = &__glsl_shader_frag_spv,
        };
        bd.ShaderModuleFrag = try vk.CreateShaderModule(device, frag_info, allocator);
    }
}

fn CreateFontSampler(device: vk.Device, allocator: ?*const vk.AllocationCallbacks) !void {
    const bd = GetBackendData().?;
    if (bd.FontSampler != .Null) return;

    const info = vk.SamplerCreateInfo{
        .magFilter = .LINEAR,
        .minFilter = .LINEAR,
        .mipmapMode = .LINEAR,
        .addressModeU = .REPEAT,
        .addressModeV = .REPEAT,
        .addressModeW = .REPEAT,
        .minLod = -1000,
        .maxLod = 1000,
        .maxAnisotropy = 1.0,

        .mipLodBias = 0,
        .anisotropyEnable = vk.FALSE,
        .compareEnable = vk.FALSE,
        .compareOp = .NEVER,
        .borderColor = .FLOAT_TRANSPARENT_BLACK,
        .unnormalizedCoordinates = vk.FALSE,
    };
    bd.FontSampler = try vk.CreateSampler(device, info, allocator);
}

fn CreateDescriptorSetLayout(device: vk.Device, allocator: ?*const vk.AllocationCallbacks) !void {
    const bd = GetBackendData().?;
    if (bd.DescriptorSetLayout != .Null) return;

    try CreateFontSampler(device, allocator);
    const sampler = [_]vk.Sampler{bd.FontSampler};
    const binding = [_]vk.DescriptorSetLayoutBinding{vk.DescriptorSetLayoutBinding{
        .binding = 0,
        .descriptorType = .COMBINED_IMAGE_SAMPLER,
        .descriptorCount = 1,
        .stageFlags = .{ .fragment = true },
        .pImmutableSamplers = &sampler,
    }};
    const info = vk.DescriptorSetLayoutCreateInfo{
        .bindingCount = 1,
        .pBindings = &binding,
    };
    bd.DescriptorSetLayout = try vk.CreateDescriptorSetLayout(device, info, allocator);
}

fn CreatePipelineLayout(device: vk.Device, allocator: ?*const vk.AllocationCallbacks) !void {
    const bd = GetBackendData().?;
    if (bd.PipelineLayout != .Null) return;

    try CreateDescriptorSetLayout(device, allocator);
    const push_constants = [_]vk.PushConstantRange{vk.PushConstantRange{
        .stageFlags = .{ .vertex = true },
        .offset = 0 * @sizeOf(f32),
        .size = 4 * @sizeOf(f32),
    }};
    const set_layout = [_]vk.DescriptorSetLayout{bd.DescriptorSetLayout};
    const layout_info = vk.PipelineLayoutCreateInfo{
        .setLayoutCount = 1,
        .pSetLayouts = &set_layout,
        .pushConstantRangeCount = 1,
        .pPushConstantRanges = &push_constants,
    };
    bd.PipelineLayout = try vk.CreatePipelineLayout(device, layout_info, allocator);
}

fn CreatePipeline(device: vk.Device, allocator: ?*const vk.AllocationCallbacks, pipeline_cache: vk.PipelineCache, render_pass: vk.RenderPass, msaa_samples: vk.SampleCountFlags, subpass: u32) !vk.Pipeline {
    const bd = GetBackendData().?;
    try CreateShaderModules(device, allocator);

    const stage = [_]vk.PipelineShaderStageCreateInfo{
        vk.PipelineShaderStageCreateInfo{
            .stage = .{ .vertex = true },
            .module = bd.ShaderModuleVert,
            .pName = "main",
        },
        vk.PipelineShaderStageCreateInfo{
            .stage = .{ .fragment = true },
            .module = bd.ShaderModuleFrag,
            .pName = "main",
        },
    };

    const binding_desc = [_]vk.VertexInputBindingDescription{vk.VertexInputBindingDescription{
        .binding = 0,
        .stride = @sizeOf(imgui.DrawVert),
        .inputRate = .VERTEX,
    }};

    const attribute_desc = [_]vk.VertexInputAttributeDescription{
        vk.VertexInputAttributeDescription{
            .location = 0,
            .binding = binding_desc[0].binding,
            .format = .R32G32_SFLOAT,
            .offset = @offsetOf(imgui.DrawVert, "pos"),
        },
        vk.VertexInputAttributeDescription{
            .location = 1,
            .binding = binding_desc[0].binding,
            .format = .R32G32_SFLOAT,
            .offset = @offsetOf(imgui.DrawVert, "uv"),
        },
        vk.VertexInputAttributeDescription{
            .location = 2,
            .binding = binding_desc[0].binding,
            .format = .R8G8B8A8_UNORM,
            .offset = @offsetOf(imgui.DrawVert, "col"),
        },
    };

    const vertex_info = vk.PipelineVertexInputStateCreateInfo{
        .vertexBindingDescriptionCount = binding_desc.len,
        .pVertexBindingDescriptions = &binding_desc,
        .vertexAttributeDescriptionCount = attribute_desc.len,
        .pVertexAttributeDescriptions = &attribute_desc,
    };

    const ia_info = vk.PipelineInputAssemblyStateCreateInfo{
        .topology = .TRIANGLE_LIST,
        .primitiveRestartEnable = vk.FALSE,
    };

    const viewport_info = vk.PipelineViewportStateCreateInfo{
        .viewportCount = 1,
        .scissorCount = 1,
    };

    const raster_info = vk.PipelineRasterizationStateCreateInfo{
        .polygonMode = .FILL,
        .cullMode = vk.CullModeFlags.none,
        .frontFace = .COUNTER_CLOCKWISE,
        .lineWidth = 1.0,

        .depthClampEnable = vk.FALSE,
        .rasterizerDiscardEnable = vk.FALSE,
        .depthBiasEnable = vk.FALSE,
        .depthBiasConstantFactor = 0,
        .depthBiasClamp = 0,
        .depthBiasSlopeFactor = 0,
    };

    const ms_info = vk.PipelineMultisampleStateCreateInfo{
        .rasterizationSamples = if (!msaa_samples.isEmpty()) msaa_samples else .{ .t1 = true },

        .sampleShadingEnable = vk.FALSE,
        .minSampleShading = 0,
        .alphaToCoverageEnable = vk.FALSE,
        .alphaToOneEnable = vk.FALSE,
    };

    const color_attachment = [_]vk.PipelineColorBlendAttachmentState{vk.PipelineColorBlendAttachmentState{
        .blendEnable = vk.TRUE,
        .srcColorBlendFactor = .SRC_ALPHA,
        .dstColorBlendFactor = .ONE_MINUS_SRC_ALPHA,
        .colorBlendOp = .ADD,
        .srcAlphaBlendFactor = .ONE,
        .dstAlphaBlendFactor = .ONE_MINUS_SRC_ALPHA,
        .alphaBlendOp = .ADD,
        .colorWriteMask = .{ .r = true, .g = true, .b = true, .a = true },
    }};

    const depth_info = vk.PipelineDepthStencilStateCreateInfo{
        .depthTestEnable = vk.FALSE,
        .depthWriteEnable = vk.FALSE,
        .depthCompareOp = .NEVER,
        .depthBoundsTestEnable = vk.FALSE,
        .stencilTestEnable = vk.FALSE,
        .front = undefined,
        .back = undefined,
        .minDepthBounds = 0,
        .maxDepthBounds = 0,
    };

    const blend_info = vk.PipelineColorBlendStateCreateInfo{
        .attachmentCount = color_attachment.len,
        .pAttachments = &color_attachment,
        .logicOpEnable = vk.FALSE,
        .logicOp = .CLEAR,
        .blendConstants = [_]f32{ 0, 0, 0, 0 },
    };

    const dynamic_states = [_]vk.DynamicState{ .VIEWPORT, .SCISSOR };
    const dynamic_state = vk.PipelineDynamicStateCreateInfo{
        .dynamicStateCount = dynamic_states.len,
        .pDynamicStates = &dynamic_states,
    };

    try CreatePipelineLayout(device, allocator);

    const info = vk.GraphicsPipelineCreateInfo{
        .flags = bd.PipelineCreateFlags,
        .stageCount = stage.len,
        .pStages = &stage,
        .pVertexInputState = &vertex_info,
        .pInputAssemblyState = &ia_info,
        .pViewportState = &viewport_info,
        .pRasterizationState = &raster_info,
        .pMultisampleState = &ms_info,
        .pDepthStencilState = &depth_info,
        .pColorBlendState = &blend_info,
        .pDynamicState = &dynamic_state,
        .layout = bd.PipelineLayout,
        .renderPass = render_pass,
        .subpass = subpass,
        .basePipelineIndex = 0,
    };

    var out_pipeline: vk.Pipeline = undefined;
    try vk.CreateGraphicsPipelines(device, pipeline_cache, arrayPtr(&info), allocator, arrayPtr(&out_pipeline));
    return out_pipeline;
}

fn CreateDeviceObjects() !void {
    const bd = GetBackendData().?;
    const v = &bd.VulkanInitInfo;

    if (bd.FontSampler == .Null) {
        const info = vk.SamplerCreateInfo{
            .magFilter = .LINEAR,
            .minFilter = .LINEAR,
            .mipmapMode = .LINEAR,
            .addressModeU = .REPEAT,
            .addressModeV = .REPEAT,
            .addressModeW = .REPEAT,
            .minLod = -1000,
            .maxLod = 1000,
            .maxAnisotropy = 1.0,

            .mipLodBias = 0,
            .anisotropyEnable = vk.FALSE,
            .compareEnable = vk.FALSE,
            .compareOp = .NEVER,
            .borderColor = .FLOAT_TRANSPARENT_BLACK,
            .unnormalizedCoordinates = vk.FALSE,
        };
        bd.FontSampler = try vk.CreateSampler(v.Device, info, v.VkAllocator);
    }

    if (bd.DescriptorSetLayout == .Null) {
        const sampler = [_]vk.Sampler{bd.FontSampler};
        const binding = [_]vk.DescriptorSetLayoutBinding{vk.DescriptorSetLayoutBinding{
            .binding = 0,
            .descriptorType = .COMBINED_IMAGE_SAMPLER,
            .descriptorCount = 1,
            .stageFlags = .{ .fragment = true },
            .pImmutableSamplers = &sampler,
        }};
        const info = vk.DescriptorSetLayoutCreateInfo{
            .bindingCount = 1,
            .pBindings = &binding,
        };
        bd.DescriptorSetLayout = try vk.CreateDescriptorSetLayout(v.Device, info, v.VkAllocator);
    }

    if (bd.PipelineLayout == .Null) {
        // Constants: we are using 'vec2 offset' and 'vec2 scale' instead of a full 3d projection matrix
        const push_constants = [_]vk.PushConstantRange{vk.PushConstantRange{
            .stageFlags = .{ .vertex = true },
            .offset = 0 * @sizeOf(f32),
            .size = 4 * @sizeOf(f32),
        }};
        const set_layout = [_]vk.DescriptorSetLayout{bd.DescriptorSetLayout};
        const layout_info = vk.PipelineLayoutCreateInfo{
            .setLayoutCount = 1,
            .pSetLayouts = &set_layout,
            .pushConstantRangeCount = 1,
            .pPushConstantRanges = &push_constants,
        };
        bd.PipelineLayout = try vk.CreatePipelineLayout(v.Device, layout_info, v.VkAllocator);
    }

    bd.Pipeline = try CreatePipeline(v.Device, v.VkAllocator, v.PipelineCache, bd.RenderPass, v.MSAASamples, bd.Subpass);
}

pub fn DestroyFontUploadObjects() void {
    const bd = GetBackendData().?;
    const v = &bd.VulkanInitInfo;
    if (bd.UploadBuffer != .Null) {
        vk.DestroyBuffer(v.Device, bd.UploadBuffer, v.VkAllocator);
        bd.UploadBuffer = .Null;
    }
    if (bd.UploadBufferMemory != .Null) {
        vk.FreeMemory(v.Device, bd.UploadBufferMemory, v.VkAllocator);
        bd.UploadBufferMemory = .Null;
    }
}

fn DestroyDeviceObjects() void {
    const bd = GetBackendData().?;
    const v = &bd.VulkanInitInfo;
    DestroyWindowRenderBuffers(v.Device, &bd.MainWindowRenderBuffers, v.VkAllocator, zig_allocator);
    DestroyFontUploadObjects();

    if (bd.ShaderModuleVert != .Null) {
        vk.DestroyShaderModule(v.Device, bd.ShaderModuleVert, v.VkAllocator);
        bd.ShaderModuleVert = .Null;
    }
    if (bd.ShaderModuleFrag != .Null) {
        vk.DestroyShaderModule(v.Device, bd.ShaderModuleFrag, v.VkAllocator);
        bd.ShaderModuleFrag = .Null;
    }
    if (bd.FontView != .Null) {
        vk.DestroyImageView(v.Device, bd.FontView, v.VkAllocator);
        bd.FontView = .Null;
    }
    if (bd.FontImage != .Null) {
        vk.DestroyImage(v.Device, bd.FontImage, v.VkAllocator);
        bd.FontImage = .Null;
    }
    if (bd.FontMemory != .Null) {
        vk.FreeMemory(v.Device, bd.FontMemory, v.VkAllocator);
        bd.FontMemory = .Null;
    }
    if (bd.FontSampler != .Null) {
        vk.DestroySampler(v.Device, bd.FontSampler, v.VkAllocator);
        bd.FontSampler = .Null;
    }
    if (bd.DescriptorSetLayout != .Null) {
        vk.DestroyDescriptorSetLayout(v.Device, bd.DescriptorSetLayout, v.VkAllocator);
        bd.DescriptorSetLayout = .Null;
    }
    if (bd.PipelineLayout != .Null) {
        vk.DestroyPipelineLayout(v.Device, bd.PipelineLayout, v.VkAllocator);
        bd.PipelineLayout = .Null;
    }
    if (bd.Pipeline != .Null) {
        vk.DestroyPipeline(v.Device, bd.Pipeline, v.VkAllocator);
        bd.Pipeline = .Null;
    }
}

pub fn Init(info: *InitInfo, render_pass: vk.RenderPass) !void {
    // Setup back-end capabilities flags
    const io = imgui.GetIO();
    assert(io.BackendRendererUserData == null); // Already initialized a renderer backend!

    assert(info.MinImageCount >= 2);
    assert(info.ImageCount >= info.MinImageCount);

    const bd = @ptrCast(*Data, @alignCast(@alignOf(Data), imgui.MemAlloc(@sizeOf(Data)).?));
    bd.* = .{
        .VulkanInitInfo = info.*,
        .RenderPass = render_pass,
        .Subpass = info.Subpass,
    };
    io.BackendRendererUserData = bd;
    io.BackendRendererName = "imgui_impl_vulkan";
    io.BackendFlags.RendererHasVtxOffset = true; // We can honor the imgui.DrawCmd::VtxOffset field, allowing for large meshes.

    try CreateDeviceObjects();
}

pub fn Shutdown() void {
    const bd = GetBackendData();
    assert(bd != null); // No renderer backend to shutdown, or already shutdown?
    const io = imgui.GetIO();

    DestroyDeviceObjects();
    io.BackendRendererName = null;
    io.BackendRendererUserData = null;
    imgui.MemFree(bd);
}

pub fn NewFrame() void {
    const bd = GetBackendData();
    assert(bd != null); // If this fails, you may not have called Init().
}

pub fn SetMinImageCount(min_image_count: u32) !void {
    const bd = GetBackendData().?;
    assert(min_image_count >= 2);
    if (bd.VulkanInitInfo.MinImageCount == min_image_count)
        return;

    const v = &bd.VulkanInitInfo;
    try vk.DeviceWaitIdle(v.Device);
    DestroyWindowRenderBuffers(v.Device, &bd.MainWindowRenderBuffers, v.VkAllocator, zig_allocator);
    bd.VulkanInitInfo.MinImageCount = min_image_count;
}

/// Register a texture
/// FIXME: This is experimental in the sense that we are unsure how to best design/tackle this problem, please post to https://github.com/ocornut/imgui/pull/914 if you have suggestions.
pub fn AddTexture(sampler: vk.Sampler, image_view: vk.ImageView, image_layout: vk.ImageLayout) !vk.DescriptorSet {
    const bd = GetBackendData().?;
    const v = &bd.VulkanInitInfo;

    var descriptor_sets: [1]vk.DescriptorSet = .{ .Null };
    try vk.AllocateDescriptorSets(v.Device, .{
        .descriptorPool = v.DescriptorPool,
        .descriptorSetCount = 1,
        .pSetLayouts = arrayPtr(&bd.DescriptorSetLayout),
    }, &descriptor_sets);

    // Update the Descriptor Set:
    {
        var desc_image = [_]vk.DescriptorImageInfo{vk.DescriptorImageInfo{
            .sampler = sampler,
            .imageView = image_view,
            .imageLayout = image_layout,
        }};
        var write_desc = [_]vk.WriteDescriptorSet{vk.WriteDescriptorSet{
            .dstSet = descriptor_sets[0],
            .descriptorCount = 1,
            .descriptorType = .COMBINED_IMAGE_SAMPLER,
            .pImageInfo = &desc_image,

            .dstBinding = 0,
            .dstArrayElement = 0,
            .pBufferInfo = undefined,
            .pTexelBufferView = undefined,
        }};
        vk.UpdateDescriptorSets(v.Device, &write_desc, &[_]vk.CopyDescriptorSet{});
    }

    return descriptor_sets[0];
}

//-------------------------------------------------------------------------
// Internal / Miscellaneous Vulkan Helpers
// (Used by example's main.cpp. Used by multi-viewport features. PROBABLY NOT used by your own app.)
//-------------------------------------------------------------------------
// You probably do NOT need to use or care about those functions.
// Those functions only exist because:
//   1) they facilitate the readability and maintenance of the multiple main.cpp examples files.
//   2) the upcoming multi-viewport feature will need them internally.
// Generally we avoid exposing any kind of superfluous high-level helpers in the backends,
// but it is too much code to duplicate everywhere so we exceptionally expose them.
//
// Your engine/app will likely _already_ have code to setup all that stuff (swap chain, render pass, frame buffers, etc.).
// You may read this code to learn about Vulkan, but it is recommended you use you own custom tailored code to do equivalent work.
// (The XXX functions do not interact with any of the state used by the regular XXX functions)
//-------------------------------------------------------------------------

pub fn SelectSurfaceFormat(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR, request_formats: []const vk.Format, request_color_space: vk.ColorSpaceKHR, allocator: std.mem.Allocator) !vk.SurfaceFormatKHR {
    // Per Spec Format and View Format are expected to be the same unless VK_IMAGE_CREATE_MUTABLE_BIT was set at image creation
    // Assuming that the default behavior is without setting this bit, there is no need for separate Swapchain image and image view format
    // Additionally several new color spaces were introduced with Vulkan Spec v1.0.40,
    // hence we must make sure that a format with the mostly available color space, VK_COLOR_SPACE_SRGB_NONLINEAR_KHR, is found and used.
    const count = try vk.GetPhysicalDeviceSurfaceFormatsCountKHR(physical_device, surface);
    const formats = try allocator.alloc(vk.SurfaceFormatKHR, count);
    defer allocator.free(formats);
    _ = try vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, formats);

    // First check if only one format, VK_FORMAT_UNDEFINED, is available, which would imply that any format is available
    if (formats.len == 1) {
        if (formats[0].format == .UNDEFINED) {
            return vk.SurfaceFormatKHR{
                .format = request_formats[0],
                .colorSpace = request_color_space,
            };
        } else {
            // No point in searching another format
            return formats[0];
        }
    } else {
        // Request several formats, the first found will be used
        for (request_formats) |request|
            for (formats) |avail|
                if (avail.format == request and avail.colorSpace == request_color_space)
                    return avail;

        // If none of the requested image formats could be found, use the first available
        return formats[0];
    }
}

pub fn SelectPresentMode(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR, request_modes: []const vk.PresentModeKHR, allocator: std.mem.Allocator) !vk.PresentModeKHR {
    // Request a certain mode and confirm that it is available. If not use VK_PRESENT_MODE_FIFO_KHR which is mandatory
    const count = try vk.GetPhysicalDeviceSurfacePresentModesCountKHR(physical_device, surface);
    const modes = try allocator.alloc(vk.PresentModeKHR, count);
    defer allocator.free(modes);
    _ = try vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, modes);
    //for (modes) |mode, i|
    //    std.debug.print("[vulkan] avail_modes[{}] = {}\n", i, mode);

    for (request_modes) |request|
        for (modes) |avail|
            if (request == avail)
                return avail;

    return .FIFO; // Always available
}

fn CreateWindowCommandBuffers(physical_device: vk.PhysicalDevice, device: vk.Device, wd: *Window, queue_family: u32, allocator: ?*const vk.AllocationCallbacks) !void {
    _ = physical_device;
    // Create Command Buffers
    var i = @as(u32, 0);
    while (i < wd.ImageCount) : (i += 1) {
        const fd = &wd.Frames[i];
        const fsd = &wd.FrameSemaphores[i];
        {
            const info = vk.CommandPoolCreateInfo{
                .flags = .{ .resetCommandBuffer = true },
                .queueFamilyIndex = queue_family,
            };
            fd.CommandPool = try vk.CreateCommandPool(device, info, allocator);
        }
        {
            const info = vk.CommandBufferAllocateInfo{
                .commandPool = fd.CommandPool,
                .level = .PRIMARY,
                .commandBufferCount = 1,
            };
            try vk.AllocateCommandBuffers(device, info, arrayPtr(&fd.CommandBuffer));
        }
        {
            const info = vk.FenceCreateInfo{
                .flags = .{ .signaled = true },
            };
            fd.Fence = try vk.CreateFence(device, info, allocator);
        }
        {
            const info = vk.SemaphoreCreateInfo{};
            fsd.ImageAcquiredSemaphore = try vk.CreateSemaphore(device, info, allocator);
            fsd.RenderCompleteSemaphore = try vk.CreateSemaphore(device, info, allocator);
        }
    }
}

fn GetMinImageCountFromPresentMode(present_mode: vk.PresentModeKHR) u32 {
    if (present_mode == .MAILBOX)
        return 3;
    if (present_mode == .FIFO or present_mode == .FIFO_RELAXED)
        return 2;
    if (present_mode == .IMMEDIATE)
        return 1;
    unreachable;
}

// Also destroy old swap chain and in-flight frames data, if any.
fn CreateWindowSwapChain(physical_device: vk.PhysicalDevice, device: vk.Device, wd: *Window, allocator: ?*const vk.AllocationCallbacks, w: u32, h: u32, min_image_count_in: u32) !void {
    const old_swapchain = wd.Swapchain;
    wd.Swapchain = .Null;

    try vk.DeviceWaitIdle(device);

    // We don't use DestroyWindow() because we want to preserve the old swapchain to create the new one.
    // Destroy old Framebuffer
    if (wd.ImageCount > 0) {
        var i = @as(u32, 0);
        while (i < wd.ImageCount) : (i += 1) {
            DestroyFrame(device, &wd.Frames[i], allocator);
            DestroyFrameSemaphores(device, &wd.FrameSemaphores[i], allocator);
        }
        wd.Allocator.free(wd.Frames);
        wd.Allocator.free(wd.FrameSemaphores);
        wd.Frames = &[_]Frame{};
        wd.FrameSemaphores = &[_]FrameSemaphores{};
        wd.ImageCount = 0;
    }

    if (wd.RenderPass != .Null) {
        vk.DestroyRenderPass(device, wd.RenderPass, allocator);
        wd.RenderPass = .Null;
    }
    if (wd.Pipeline != .Null) {
        vk.DestroyPipeline(device, wd.Pipeline, allocator);
        wd.Pipeline = .Null;
    }

    // If min image count was not specified, request different count of images dependent on selected present mode
    var min_image_count = min_image_count_in;
    if (min_image_count == 0)
        min_image_count = GetMinImageCountFromPresentMode(wd.PresentMode);

    // Create Swapchain
    {
        var info = vk.SwapchainCreateInfoKHR{
            .surface = wd.Surface,
            .minImageCount = min_image_count,
            .imageFormat = wd.SurfaceFormat.format,
            .imageColorSpace = wd.SurfaceFormat.colorSpace,
            .imageArrayLayers = 1,
            .imageUsage = .{ .colorAttachment = true },
            .imageExtent = undefined, // we will fill this in later
            .imageSharingMode = .EXCLUSIVE, // Assume that graphics family == present family
            .preTransform = .{ .identity = true },
            .compositeAlpha = .{ .@"opaque" = true },
            .presentMode = wd.PresentMode,
            .clipped = vk.TRUE,
            .oldSwapchain = old_swapchain,
        };

        const cap = try vk.GetPhysicalDeviceSurfaceCapabilitiesKHR(physical_device, wd.Surface);
        if (info.minImageCount < cap.minImageCount) {
            info.minImageCount = cap.minImageCount;
        } else if (cap.maxImageCount != 0 and info.minImageCount > cap.maxImageCount) {
            info.minImageCount = cap.maxImageCount;
        }

        if (cap.currentExtent.width == 0xffffffff) {
            wd.Width = w;
            wd.Height = h;
            info.imageExtent = vk.Extent2D{ .width = w, .height = h };
        } else {
            wd.Width = cap.currentExtent.width;
            wd.Height = cap.currentExtent.height;
            info.imageExtent = cap.currentExtent;
        }
        wd.Swapchain = try vk.CreateSwapchainKHR(device, info, allocator);
        wd.ImageCount = try vk.GetSwapchainImagesCountKHR(device, wd.Swapchain);

        var backbuffers: [16]vk.Image = undefined;
        const imagesResult = try vk.GetSwapchainImagesKHR(device, wd.Swapchain, backbuffers[0..wd.ImageCount]);
        assert(imagesResult.result == .SUCCESS);

        wd.ImageCount = @intCast(u32, imagesResult.swapchainImages.len);
        assert(wd.Frames.len == 0);
        wd.Frames = try wd.Allocator.alloc(Frame, wd.ImageCount);
        wd.FrameSemaphores = try wd.Allocator.alloc(FrameSemaphores, wd.ImageCount);

        for (wd.Frames) |*frame, i| frame.* = Frame{ .Backbuffer = imagesResult.swapchainImages[i] };
        for (wd.FrameSemaphores) |*fs| fs.* = FrameSemaphores{};
    }
    if (old_swapchain != .Null)
        vk.DestroySwapchainKHR(device, old_swapchain, allocator);

    // Create the Render Pass
    {
        const attachment = vk.AttachmentDescription{
            .format = wd.SurfaceFormat.format,
            .samples = .{ .t1 = true },
            .loadOp = .CLEAR,
            .storeOp = .STORE,
            .stencilLoadOp = .DONT_CARE,
            .stencilStoreOp = .DONT_CARE,
            .initialLayout = .UNDEFINED,
            .finalLayout = .PRESENT_SRC_KHR,
        };

        const color_attachment = vk.AttachmentReference{
            .attachment = 0,
            .layout = .COLOR_ATTACHMENT_OPTIMAL,
        };
        const subpass = vk.SubpassDescription{
            .pipelineBindPoint = .GRAPHICS,
            .colorAttachmentCount = 1,
            .pColorAttachments = arrayPtr(&color_attachment),
        };
        const dependency = vk.SubpassDependency{
            .srcSubpass = vk.SUBPASS_EXTERNAL,
            .dstSubpass = 0,
            .srcStageMask = .{ .colorAttachmentOutput = true },
            .dstStageMask = .{ .colorAttachmentOutput = true },
            .srcAccessMask = .{},
            .dstAccessMask = .{ .colorAttachmentWrite = true },
        };
        const info = vk.RenderPassCreateInfo{
            .attachmentCount = 1,
            .pAttachments = arrayPtr(&attachment),
            .subpassCount = 1,
            .pSubpasses = arrayPtr(&subpass),
            .dependencyCount = 1,
            .pDependencies = arrayPtr(&dependency),
        };
        wd.RenderPass = try vk.CreateRenderPass(device, info, allocator);

        // We do not create a pipeline by default as this is also used by examples' main.cpp,
        // but secondary viewport in multi-viewport mode may want to create one with:
        //wd.Pipeline = CreatePipeline(device, allocator, .Null, wd.RenderPass, .{ .t1 = true }, bd.Subpass);
    }

    // Create The Image Views
    {
        var info = vk.ImageViewCreateInfo{
            .image = undefined, // we will set this later
            .viewType = .T_2D,
            .format = wd.SurfaceFormat.format,
            .components = vk.ComponentMapping{
                .r = .IDENTITY,
                .g = .IDENTITY,
                .b = .IDENTITY,
                .a = .IDENTITY,
            },
            .subresourceRange = vk.ImageSubresourceRange{
                .aspectMask = .{ .color = true },
                .baseMipLevel = 0,
                .levelCount = 1,
                .baseArrayLayer = 0,
                .layerCount = 1,
            },
        };

        for (wd.Frames) |*fd| {
            info.image = fd.Backbuffer;
            fd.BackbufferView = try vk.CreateImageView(device, info, allocator);
        }
    }

    // Create Framebuffer
    {
        var attachment = [_]vk.ImageView{undefined}; // we will set this later
        const info = vk.FramebufferCreateInfo{
            .renderPass = wd.RenderPass,
            .attachmentCount = attachment.len,
            .pAttachments = &attachment,
            .width = wd.Width,
            .height = wd.Height,
            .layers = 1,
        };
        for (wd.Frames) |*fd| {
            attachment[0] = fd.BackbufferView;
            fd.Framebuffer = try vk.CreateFramebuffer(device, info, allocator);
        }
    }
}

pub fn CreateOrResizeWindow(instance: vk.Instance, physical_device: vk.PhysicalDevice, device: vk.Device, wd: *Window, queue_family: u32, allocator: ?*const vk.AllocationCallbacks, width: u32, height: u32, min_image_count: u32) !void {
    _ = instance;
    try CreateWindowSwapChain(physical_device, device, wd, allocator, width, height, min_image_count);
    try CreateWindowCommandBuffers(physical_device, device, wd, queue_family, allocator);
}

pub fn DestroyWindow(instance: vk.Instance, device: vk.Device, wd: *Window, allocator: ?*const vk.AllocationCallbacks) !void {
    try vk.DeviceWaitIdle(device); // FIXME: We could wait on the Queue if we had the queue in wd. (otherwise VulkanH functions can't use globals)
    //vk.QueueWaitIdle(bd.Queue);

    for (wd.Frames) |_, i| {
        DestroyFrame(device, &wd.Frames[i], allocator);
        DestroyFrameSemaphores(device, &wd.FrameSemaphores[i], allocator);
    }
    wd.Allocator.free(wd.Frames);
    wd.Allocator.free(wd.FrameSemaphores);
    wd.Frames = &[_]Frame{};
    wd.FrameSemaphores = &[_]FrameSemaphores{};
    vk.DestroyPipeline(device, wd.Pipeline, allocator);
    vk.DestroyRenderPass(device, wd.RenderPass, allocator);
    vk.DestroySwapchainKHR(device, wd.Swapchain, allocator);
    vk.DestroySurfaceKHR(instance, wd.Surface, allocator);

    wd.* = Window{};
}

fn DestroyFrame(device: vk.Device, fd: *Frame, allocator: ?*const vk.AllocationCallbacks) void {
    vk.DestroyFence(device, fd.Fence, allocator);
    vk.FreeCommandBuffers(device, fd.CommandPool, arrayPtr(&fd.CommandBuffer));
    vk.DestroyCommandPool(device, fd.CommandPool, allocator);
    fd.Fence = undefined;
    fd.CommandBuffer = undefined;
    fd.CommandPool = undefined;

    vk.DestroyImageView(device, fd.BackbufferView, allocator);
    vk.DestroyFramebuffer(device, fd.Framebuffer, allocator);
}

fn DestroyFrameSemaphores(device: vk.Device, fsd: *FrameSemaphores, allocator: ?*const vk.AllocationCallbacks) void {
    vk.DestroySemaphore(device, fsd.ImageAcquiredSemaphore, allocator);
    vk.DestroySemaphore(device, fsd.RenderCompleteSemaphore, allocator);
    fsd.ImageAcquiredSemaphore = undefined;
    fsd.RenderCompleteSemaphore = undefined;
}

fn DestroyFrameRenderBuffers(device: vk.Device, buffers: *FrameRenderBuffers, allocator: ?*const vk.AllocationCallbacks) void {
    if (buffers.VertexBuffer != .Null) {
        vk.DestroyBuffer(device, buffers.VertexBuffer, allocator);
        buffers.VertexBuffer = undefined;
    }
    if (buffers.VertexBufferMemory != .Null) {
        vk.FreeMemory(device, buffers.VertexBufferMemory, allocator);
        buffers.VertexBufferMemory = undefined;
    }
    if (buffers.IndexBuffer != .Null) {
        vk.DestroyBuffer(device, buffers.IndexBuffer, allocator);
        buffers.IndexBuffer = undefined;
    }
    if (buffers.IndexBufferMemory != .Null) {
        vk.FreeMemory(device, buffers.IndexBufferMemory, allocator);
        buffers.IndexBufferMemory = undefined;
    }
    buffers.VertexBufferSize = 0;
    buffers.IndexBufferSize = 0;
}

fn DestroyWindowRenderBuffers(device: vk.Device, buffers: *WindowRenderBuffers, vkAllocator: ?*const vk.AllocationCallbacks, allocator: std.mem.Allocator) void {
    for (buffers.FrameRenderBuffers) |*frb|
        DestroyFrameRenderBuffers(device, frb, vkAllocator);
    allocator.free(buffers.FrameRenderBuffers);
    buffers.FrameRenderBuffers = &[_]FrameRenderBuffers{};
    buffers.Index = 0;
}

// converts *T to *[1]T
fn arrayPtrType(comptime ptrType: type) type {
    var info = @typeInfo(ptrType);
    info.Pointer.child = [1]info.Pointer.child;
    return @Type(info);
}

fn arrayPtr(ptr: anytype) arrayPtrType(@TypeOf(ptr)) {
    return @ptrCast(arrayPtrType(@TypeOf(ptr)), ptr);
}
