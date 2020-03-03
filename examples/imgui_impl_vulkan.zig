// dear imgui: Renderer for Vulkan
// This needs to be used along with a Platform Binding (e.g. GLFW, SDL, Win32, custom..)

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
//  2019-08-01: Vulkan: Added support for specifying multisample count. Set InitInfo::MSAASamples to one of the vk.SampleCountFlagBits values to use, default is non-multisampled as before.
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
const warn = std.debug.warn;

pub const InitInfo = struct {
    Instance: vk.Instance,
    PhysicalDevice: vk.PhysicalDevice,
    Device: vk.Device,
    QueueFamily: u32,
    Queue: vk.Queue,
    PipelineCache: vk.PipelineCache,
    DescriptorPool: vk.DescriptorPool,
    MinImageCount: u32, // >= 2
    ImageCount: u32, // >= MinImageCount
    MSAASamples: vk.SampleCountFlags, // >= VK_SAMPLE_COUNT_1_BIT
    VkAllocator: ?*const vk.AllocationCallbacks,
    Allocator: *std.mem.Allocator,
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
    Allocator: *std.mem.Allocator = undefined,
    Width: u32 = 0,
    Height: u32 = 0,
    Swapchain: ?vk.SwapchainKHR = null,
    Surface: vk.SurfaceKHR = undefined,
    SurfaceFormat: vk.SurfaceFormatKHR = undefined,
    PresentMode: vk.PresentModeKHR = undefined,
    RenderPass: ?vk.RenderPass = null,
    FrameIndex: u32 = 0, // Current frame being rendered to (0 <= FrameIndex < FrameInFlightCount)
    ImageCount: u32 = 0, // Number of simultaneous in-flight frames (returned by vk.GetSwapchainImagesKHR, usually derived from min_image_count)
    SemaphoreIndex: u32 = 0, // Current set of swapchain wait semaphores we're using (needs to be distinct from per frame data)
    Frames: []Frame = undefined,
    FrameSemaphores: []FrameSemaphores = undefined,
};

// Reusable buffers used for rendering 1 current in-flight frame, for RenderDrawData()
// [Please zero-clear before use!]
const FrameRenderBuffers = struct {
    VertexBufferMemory: ?vk.DeviceMemory = null,
    IndexBufferMemory: ?vk.DeviceMemory = null,
    VertexBufferSize: vk.DeviceSize = 0,
    IndexBufferSize: vk.DeviceSize = 0,
    VertexBuffer: ?vk.Buffer = null,
    IndexBuffer: ?vk.Buffer = null,
};

// Each viewport will hold 1 WindowRenderBuffers
const WindowRenderBuffers = struct {
    Index: u32 = 0,
    FrameRenderBuffers: []FrameRenderBuffers = &[_]FrameRenderBuffers{},
};

// Vulkan data
var g_VulkanInitInfo: InitInfo = undefined;
var g_RenderPass: ?vk.RenderPass = null;
var g_BufferMemoryAlignment: vk.DeviceSize = 256;
var g_PipelineCreateFlags: vk.PipelineCreateFlags = 0x00;
var g_DescriptorSetLayout: ?vk.DescriptorSetLayout = null;
var g_PipelineLayout: ?vk.PipelineLayout = null;
var g_DescriptorSet: ?vk.DescriptorSet = null;
var g_Pipeline: ?vk.Pipeline = null;

//font data
var g_FontSampler: ?vk.Sampler = null;
var g_FontMemory: ?vk.DeviceMemory = null;
var g_FontImage: ?vk.Image = null;
var g_FontView: ?vk.ImageView = null;
var g_UploadBufferMemory: ?vk.DeviceMemory = null;
var g_UploadBuffer: ?vk.Buffer = null;

// Render buffers
var g_MainWindowRenderBuffers = WindowRenderBuffers{};

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

fn MemoryType(properties: vk.MemoryPropertyFlags, type_bits: u32) ?u32 {
    var v = &g_VulkanInitInfo;
    var prop = vk.GetPhysicalDeviceMemoryProperties(v.PhysicalDevice);
    for (prop.memoryTypes[0..prop.memoryTypeCount]) |memType, i|
        if ((memType.propertyFlags & properties) == properties and type_bits & (u32(1) << @intCast(u5, i)) != 0)
            return @intCast(u32, i);
    return null; // Unable to find memoryType
}

fn CreateOrResizeBuffer(buffer: *?vk.Buffer, buffer_memory: *?vk.DeviceMemory, p_buffer_size: *vk.DeviceSize, new_size: usize, usage: vk.BufferUsageFlags) !void {
    var v = &g_VulkanInitInfo;
    if (buffer.* != null)
        vk.DestroyBuffer(v.Device, buffer.*, v.VkAllocator);
    if (buffer_memory.* != null)
        vk.FreeMemory(v.Device, buffer_memory.*, v.VkAllocator);

    var vertex_buffer_size_aligned = ((new_size - 1) / g_BufferMemoryAlignment + 1) * g_BufferMemoryAlignment;
    const buffer_info = vk.BufferCreateInfo{
        .size = vertex_buffer_size_aligned,
        .usage = usage,
        .sharingMode = .EXCLUSIVE,
    };
    buffer.* = try vk.CreateBuffer(v.Device, buffer_info, v.VkAllocator);

    var req = vk.GetBufferMemoryRequirements(v.Device, buffer.*.?);
    g_BufferMemoryAlignment = if (g_BufferMemoryAlignment > req.alignment) g_BufferMemoryAlignment else req.alignment;
    var alloc_info = vk.MemoryAllocateInfo{
        .allocationSize = req.size,
        .memoryTypeIndex = MemoryType(vk.MemoryPropertyFlagBits.HOST_VISIBLE_BIT, req.memoryTypeBits).?,
    };
    buffer_memory.* = try vk.AllocateMemory(v.Device, alloc_info, v.VkAllocator);

    try vk.BindBufferMemory(v.Device, buffer.*.?, buffer_memory.*.?, 0);
    p_buffer_size.* = new_size;
}

fn SetupRenderState(draw_data: *imgui.DrawData, command_buffer: vk.CommandBuffer, rb: *FrameRenderBuffers, fb_width: u32, fb_height: u32) void {
    // Bind pipeline and descriptor sets:
    {
        vk.CmdBindPipeline(command_buffer, .GRAPHICS, g_Pipeline.?);
        var desc_set = [_]vk.DescriptorSet{g_DescriptorSet.?};

        vk.CmdBindDescriptorSets(command_buffer, .GRAPHICS, g_PipelineLayout.?, 0, &desc_set, &[_]u32{});
    }

    // Bind Vertex And Index Buffer:
    {
        var vertex_buffers = [_]vk.Buffer{rb.VertexBuffer.?};
        var vertex_offset = [_]vk.DeviceSize{0};
        vk.CmdBindVertexBuffers(command_buffer, 0, &vertex_buffers, &vertex_offset);
        vk.CmdBindIndexBuffer(command_buffer, rb.IndexBuffer.?, 0, if (@sizeOf(imgui.DrawIdx) == 2) .UINT16 else .UINT32);
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
        vk.CmdPushConstants(command_buffer, g_PipelineLayout.?, vk.ShaderStageFlagBits.VERTEX_BIT, @sizeOf(f32) * 0, std.mem.asBytes(&scale));
        vk.CmdPushConstants(command_buffer, g_PipelineLayout.?, vk.ShaderStageFlagBits.VERTEX_BIT, @sizeOf(f32) * 2, std.mem.asBytes(&translate));
    }
}

// Render function
// (this used to be set in io.RenderDrawListsFn and called by ImGui::Render(), but you can now call this directly from your main loop)
pub fn RenderDrawData(draw_data: *imgui.DrawData, command_buffer: vk.CommandBuffer) !void {
    // Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
    var fb_width = @floatToInt(u32, draw_data.DisplaySize.x * draw_data.FramebufferScale.x);
    var fb_height = @floatToInt(u32, draw_data.DisplaySize.y * draw_data.FramebufferScale.y);
    if (fb_width <= 0 or fb_height <= 0 or draw_data.TotalVtxCount == 0)
        return;

    var v = &g_VulkanInitInfo;

    // Allocate array to store enough vertex/index buffers
    var wrb = &g_MainWindowRenderBuffers;
    if (wrb.FrameRenderBuffers.len == 0) {
        wrb.Index = 0;
        wrb.FrameRenderBuffers = try v.Allocator.alloc(FrameRenderBuffers, v.ImageCount);
        for (wrb.FrameRenderBuffers) |*elem| {
            elem.* = FrameRenderBuffers{};
        }
    }
    std.debug.assert(wrb.FrameRenderBuffers.len == v.ImageCount);
    wrb.Index = (wrb.Index + 1) % @intCast(u32, wrb.FrameRenderBuffers.len);
    const rb = &wrb.FrameRenderBuffers[wrb.Index];

    // Create or resize the vertex/index buffers
    var vertex_size = @intCast(usize, draw_data.TotalVtxCount) * @sizeOf(imgui.DrawVert);
    var index_size = @intCast(usize, draw_data.TotalIdxCount) * @sizeOf(imgui.DrawIdx);
    if (rb.VertexBuffer == null or rb.VertexBufferSize < vertex_size)
        try CreateOrResizeBuffer(&rb.VertexBuffer, &rb.VertexBufferMemory, &rb.VertexBufferSize, vertex_size, vk.BufferUsageFlagBits.VERTEX_BUFFER_BIT);
    if (rb.IndexBuffer == null or rb.IndexBufferSize < index_size)
        try CreateOrResizeBuffer(&rb.IndexBuffer, &rb.IndexBufferMemory, &rb.IndexBufferSize, index_size, vk.BufferUsageFlagBits.INDEX_BUFFER_BIT);

    // Upload vertex/index data into a single contiguous GPU buffer
    {
        var vtx_dst: [*]imgui.DrawVert = undefined;
        var idx_dst: [*]imgui.DrawIdx = undefined;
        try vk.MapMemory(v.Device, rb.VertexBufferMemory.?, 0, vertex_size, 0, @ptrCast(**c_void, &vtx_dst));
        try vk.MapMemory(v.Device, rb.IndexBufferMemory.?, 0, index_size, 0, @ptrCast(**c_void, &idx_dst));
        var n: i32 = 0;
        while (n < draw_data.CmdListsCount) : (n += 1) {
            const cmd_list = draw_data.CmdLists[@intCast(u32, n)];
            std.mem.copy(imgui.DrawVert, vtx_dst[0..@intCast(u32, cmd_list.VtxBuffer.len)], cmd_list.VtxBuffer.items[0..@intCast(u32, cmd_list.VtxBuffer.len)]);
            std.mem.copy(imgui.DrawIdx, idx_dst[0..@intCast(u32, cmd_list.IdxBuffer.len)], cmd_list.IdxBuffer.items[0..@intCast(u32, cmd_list.IdxBuffer.len)]);
            vtx_dst += @intCast(u32, cmd_list.VtxBuffer.len);
            idx_dst += @intCast(u32, cmd_list.IdxBuffer.len);
        }

        var ranges = [2]vk.MappedMemoryRange{
            vk.MappedMemoryRange{
                .memory = rb.VertexBufferMemory.?,
                .size = vk.WHOLE_SIZE,
                .offset = 0,
            },
            vk.MappedMemoryRange{
                .memory = rb.IndexBufferMemory.?,
                .size = vk.WHOLE_SIZE,
                .offset = 0,
            },
        };
        try vk.FlushMappedMemoryRanges(v.Device, &ranges);

        vk.UnmapMemory(v.Device, rb.VertexBufferMemory.?);
        vk.UnmapMemory(v.Device, rb.IndexBufferMemory.?);
    }

    // Setup desired Vulkan state
    SetupRenderState(draw_data, command_buffer, rb, fb_width, fb_height);

    // Will project scissor/clipping rectangles into framebuffer space
    var clip_off = draw_data.DisplayPos; // (0,0) unless using multi-viewports
    var clip_scale = draw_data.FramebufferScale; // (1,1) unless using retina display which are often (2,2)

    // Render command lists
    // (Because we merged all buffers into a single one, we maintain our own offset into them)
    var global_vtx_offset = u32(0);
    var global_idx_offset = u32(0);
    var n: usize = 0;
    while (n < @intCast(usize, draw_data.CmdListsCount)) : (n += 1) {
        const cmd_list = draw_data.CmdLists[n];
        var cmd_i: usize = 0;
        while (cmd_i < @intCast(usize, cmd_list.CmdBuffer.len)) : (cmd_i += 1) {
            const pcmd = &cmd_list.CmdBuffer.items[cmd_i];
            if (pcmd.UserCallback) |fnPtr| {
                // User callback, registered via imgui.DrawList::AddCallback()
                // (imgui.DrawCallback_ResetRenderState is a special callback value used by the user to request the renderer to reset render state.)
                if (fnPtr == imgui.DrawCallback_ResetRenderState) {
                    SetupRenderState(draw_data, command_buffer, rb, fb_width, fb_height);
                } else {
                    fnPtr(cmd_list, pcmd);
                }
            } else {
                // Project scissor/clipping rectangles into framebuffer space
                var clip_rect = imgui.Vec4{
                    .x = (pcmd.ClipRect.x - clip_off.x) * clip_scale.x,
                    .y = (pcmd.ClipRect.y - clip_off.y) * clip_scale.y,
                    .z = (pcmd.ClipRect.z - clip_off.x) * clip_scale.x,
                    .w = (pcmd.ClipRect.w - clip_off.y) * clip_scale.y,
                };

                if (clip_rect.x < @intToFloat(f32, fb_width) and clip_rect.y < @intToFloat(f32, fb_height) and clip_rect.z >= 0.0 and clip_rect.w >= 0.0) {
                    // Negative offsets are illegal for vk.CmdSetScissor
                    if (clip_rect.x < 0.0)
                        clip_rect.x = 0.0;
                    if (clip_rect.y < 0.0)
                        clip_rect.y = 0.0;

                    // Apply scissor/clipping rectangle
                    var scissor = vk.Rect2D{
                        .offset = vk.Offset2D{
                            .x = @floatToInt(i32, clip_rect.x),
                            .y = @floatToInt(i32, clip_rect.y),
                        },
                        .extent = vk.Extent2D{
                            .width = @floatToInt(u32, clip_rect.z - clip_rect.x),
                            .height = @floatToInt(u32, clip_rect.w - clip_rect.y),
                        },
                    };
                    vk.CmdSetScissor(command_buffer, 0, arrayPtr(&scissor));

                    // Draw
                    const idxStart = @intCast(u32, pcmd.IdxOffset + global_idx_offset);
                    const vtxStart = @intCast(i32, pcmd.VtxOffset + global_vtx_offset);
                    vk.CmdDrawIndexed(command_buffer, pcmd.ElemCount, 1, idxStart, vtxStart, 0);
                }
            }
        }
        global_idx_offset += @intCast(u32, cmd_list.IdxBuffer.len);
        global_vtx_offset += @intCast(u32, cmd_list.VtxBuffer.len);
    }
}

pub fn CreateFontsTexture(command_buffer: vk.CommandBuffer) !void {
    var v = &g_VulkanInitInfo;
    var io = imgui.GetIO();

    var pixels: [*]u8 = undefined;
    var width: i32 = 0;
    var height: i32 = 0;
    var bpp: i32 = 0;
    io.Fonts.GetTexDataAsRGBA32(&pixels, &width, &height, &bpp);
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
            .samples = vk.SampleCountFlagBits.T_1_BIT,
            .tiling = .OPTIMAL,
            .usage = vk.ImageUsageFlagBits.SAMPLED_BIT | vk.ImageUsageFlagBits.TRANSFER_DST_BIT,
            .sharingMode = .EXCLUSIVE,
            .initialLayout = .UNDEFINED,
        };
        g_FontImage = try vk.CreateImage(v.Device, info, v.VkAllocator);
        var req = vk.GetImageMemoryRequirements(v.Device, g_FontImage.?);
        var alloc_info = vk.MemoryAllocateInfo{
            .allocationSize = req.size,
            .memoryTypeIndex = MemoryType(vk.MemoryPropertyFlagBits.DEVICE_LOCAL_BIT, req.memoryTypeBits).?,
        };
        g_FontMemory = try vk.AllocateMemory(v.Device, alloc_info, v.VkAllocator);
        try vk.BindImageMemory(v.Device, g_FontImage.?, g_FontMemory.?, 0);
    }

    // Create the Image View:
    {
        var info = vk.ImageViewCreateInfo{
            .image = g_FontImage.?,
            .viewType = .T_2D,
            .format = .R8G8B8A8_UNORM,
            .subresourceRange = vk.ImageSubresourceRange{
                .aspectMask = vk.ImageAspectFlagBits.COLOR_BIT,
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
        g_FontView = try vk.CreateImageView(v.Device, info, v.VkAllocator);
    }

    // Update the Descriptor Set:
    {
        var desc_image = [_]vk.DescriptorImageInfo{vk.DescriptorImageInfo{
            .sampler = g_FontSampler.?,
            .imageView = g_FontView.?,
            .imageLayout = .SHADER_READ_ONLY_OPTIMAL,
        }};
        var write_desc = [_]vk.WriteDescriptorSet{vk.WriteDescriptorSet{
            .dstSet = g_DescriptorSet.?,
            .descriptorCount = 1,
            .descriptorType = .COMBINED_IMAGE_SAMPLER,
            .pImageInfo = &desc_image,

            .dstBinding = 0,
            .dstArrayElement = 0,
            .pBufferInfo = undefined,
            .pTexelBufferView = undefined,
        }};
        vk.UpdateDescriptorSets(v.Device, write_desc, &[_]vk.CopyDescriptorSet{});
    }

    // Create the Upload Buffer:
    {
        var buffer_info = vk.BufferCreateInfo{
            .size = upload_size,
            .usage = vk.BufferUsageFlagBits.TRANSFER_SRC_BIT,
            .sharingMode = .EXCLUSIVE,
        };
        g_UploadBuffer = try vk.CreateBuffer(v.Device, buffer_info, v.VkAllocator);
        var req = vk.GetBufferMemoryRequirements(v.Device, g_UploadBuffer.?);
        if (req.alignment > g_BufferMemoryAlignment) {
            g_BufferMemoryAlignment = req.alignment;
        }
        var alloc_info = vk.MemoryAllocateInfo{
            .allocationSize = req.size,
            .memoryTypeIndex = MemoryType(vk.MemoryPropertyFlagBits.HOST_VISIBLE_BIT, req.memoryTypeBits).?,
        };
        g_UploadBufferMemory = try vk.AllocateMemory(v.Device, alloc_info, v.VkAllocator);
        try vk.BindBufferMemory(v.Device, g_UploadBuffer.?, g_UploadBufferMemory.?, 0);
    }

    // Upload to Buffer:
    {
        var map: [*]u8 = undefined;
        try vk.MapMemory(v.Device, g_UploadBufferMemory.?, 0, upload_size, 0, @ptrCast(**c_void, &map));
        std.mem.copy(u8, map[0..upload_size], pixels[0..upload_size]);
        var range = [_]vk.MappedMemoryRange{vk.MappedMemoryRange{
            .memory = g_UploadBufferMemory.?,
            .size = upload_size,
            .offset = 0,
        }};
        try vk.FlushMappedMemoryRanges(v.Device, &range);
        vk.UnmapMemory(v.Device, g_UploadBufferMemory.?);
    }

    // Copy to Image:
    {
        var copy_barrier = [1]vk.ImageMemoryBarrier{vk.ImageMemoryBarrier{
            .srcAccessMask = 0,
            .dstAccessMask = vk.AccessFlagBits.TRANSFER_WRITE_BIT,
            .oldLayout = .UNDEFINED,
            .newLayout = .TRANSFER_DST_OPTIMAL,
            .srcQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
            .dstQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
            .image = g_FontImage.?,
            .subresourceRange = vk.ImageSubresourceRange{
                .aspectMask = vk.ImageAspectFlagBits.COLOR_BIT,
                .levelCount = 1,
                .layerCount = 1,
                .baseMipLevel = 0,
                .baseArrayLayer = 0,
            },
        }};
        vk.CmdPipelineBarrier(command_buffer, vk.PipelineStageFlagBits.HOST_BIT, vk.PipelineStageFlagBits.TRANSFER_BIT, 0, &[_]vk.MemoryBarrier{}, &[_]vk.BufferMemoryBarrier{}, &copy_barrier);

        var region = [_]vk.BufferImageCopy{vk.BufferImageCopy{
            .imageSubresource = vk.ImageSubresourceLayers{
                .aspectMask = vk.ImageAspectFlagBits.COLOR_BIT,
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
        vk.CmdCopyBufferToImage(command_buffer, g_UploadBuffer.?, g_FontImage.?, .TRANSFER_DST_OPTIMAL, &region);

        var use_barrier = [_]vk.ImageMemoryBarrier{vk.ImageMemoryBarrier{
            .srcAccessMask = vk.AccessFlagBits.TRANSFER_WRITE_BIT,
            .dstAccessMask = vk.AccessFlagBits.SHADER_READ_BIT,
            .oldLayout = .TRANSFER_DST_OPTIMAL,
            .newLayout = .SHADER_READ_ONLY_OPTIMAL,
            .srcQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
            .dstQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
            .image = g_FontImage.?,
            .subresourceRange = vk.ImageSubresourceRange{
                .aspectMask = vk.ImageAspectFlagBits.COLOR_BIT,
                .levelCount = 1,
                .layerCount = 1,
                .baseMipLevel = 0,
                .baseArrayLayer = 0,
            },
        }};
        vk.CmdPipelineBarrier(command_buffer, vk.PipelineStageFlagBits.TRANSFER_BIT, vk.PipelineStageFlagBits.FRAGMENT_SHADER_BIT, 0, &[_]vk.MemoryBarrier{}, &[_]vk.BufferMemoryBarrier{}, &use_barrier);
    }

    // Store our identifier
    io.Fonts.TexID = @ptrCast(imgui.TextureID, g_FontImage.?);
}
fn CreateDeviceObjects() !void {
    const v = &g_VulkanInitInfo;
    var vert_module: vk.ShaderModule = undefined;
    var frag_module: vk.ShaderModule = undefined;

    // Create The Shader Modules:
    {
        const vert_info = vk.ShaderModuleCreateInfo{
            .codeSize = @sizeOf(@typeOf(__glsl_shader_vert_spv)),
            .pCode = &__glsl_shader_vert_spv,
        };
        vert_module = try vk.CreateShaderModule(v.Device, vert_info, v.VkAllocator);

        const frag_info = vk.ShaderModuleCreateInfo{
            .codeSize = @sizeOf(@typeOf(__glsl_shader_frag_spv)),
            .pCode = &__glsl_shader_frag_spv,
        };
        frag_module = try vk.CreateShaderModule(v.Device, frag_info, v.VkAllocator);
        std.debug.warn("Created vert with {} bytes, frag with {} bytes.\n", vert_info.codeSize, frag_info.codeSize);
    }

    if (g_FontSampler == null) {
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
        g_FontSampler = try vk.CreateSampler(v.Device, info, v.VkAllocator);
    }

    if (g_DescriptorSetLayout == null) {
        const sampler = [_]vk.Sampler{g_FontSampler.?};
        const binding = [_]vk.DescriptorSetLayoutBinding{vk.DescriptorSetLayoutBinding{
            .binding = 0,
            .descriptorType = .COMBINED_IMAGE_SAMPLER,
            .descriptorCount = 1,
            .stageFlags = vk.ShaderStageFlagBits.FRAGMENT_BIT,
            .pImmutableSamplers = &sampler,
        }};
        const info = vk.DescriptorSetLayoutCreateInfo{
            .bindingCount = 1,
            .pBindings = &binding,
        };
        g_DescriptorSetLayout = try vk.CreateDescriptorSetLayout(v.Device, info, v.VkAllocator);
    }

    // Create Descriptor Set:
    {
        const alloc_info = vk.DescriptorSetAllocateInfo{
            .descriptorPool = v.DescriptorPool,
            .descriptorSetCount = 1,
            .pSetLayouts = arrayPtr(&g_DescriptorSetLayout.?),
        };
        var out_descriptorSet: vk.DescriptorSet = undefined;
        try vk.AllocateDescriptorSets(v.Device, alloc_info, arrayPtr(&out_descriptorSet));
        g_DescriptorSet = out_descriptorSet;
    }

    if (g_PipelineLayout == null) {
        // Constants: we are using 'vec2 offset' and 'vec2 scale' instead of a full 3d projection matrix
        const push_constants = [_]vk.PushConstantRange{vk.PushConstantRange{
            .stageFlags = vk.ShaderStageFlagBits.VERTEX_BIT,
            .offset = 0 * @sizeOf(f32),
            .size = 4 * @sizeOf(f32),
        }};
        const set_layout = [_]vk.DescriptorSetLayout{g_DescriptorSetLayout.?};
        const layout_info = vk.PipelineLayoutCreateInfo{
            .setLayoutCount = 1,
            .pSetLayouts = &set_layout,
            .pushConstantRangeCount = 1,
            .pPushConstantRanges = &push_constants,
        };
        g_PipelineLayout = try vk.CreatePipelineLayout(v.Device, layout_info, v.VkAllocator);
    }

    const stage = [_]vk.PipelineShaderStageCreateInfo{
        vk.PipelineShaderStageCreateInfo{
            .stage = vk.ShaderStageFlagBits.VERTEX_BIT,
            .module = vert_module,
            .pName = c"main",
        },
        vk.PipelineShaderStageCreateInfo{
            .stage = vk.ShaderStageFlagBits.FRAGMENT_BIT,
            .module = frag_module,
            .pName = c"main",
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
            .offset = @byteOffsetOf(imgui.DrawVert, "pos"),
        },
        vk.VertexInputAttributeDescription{
            .location = 1,
            .binding = binding_desc[0].binding,
            .format = .R32G32_SFLOAT,
            .offset = @byteOffsetOf(imgui.DrawVert, "uv"),
        },
        vk.VertexInputAttributeDescription{
            .location = 2,
            .binding = binding_desc[0].binding,
            .format = .R8G8B8A8_UNORM,
            .offset = @byteOffsetOf(imgui.DrawVert, "col"),
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
        .cullMode = vk.CullModeFlagBits.NONE,
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
        .rasterizationSamples = if (v.MSAASamples != 0) v.MSAASamples else vk.SampleCountFlagBits.T_1_BIT,

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
        .srcAlphaBlendFactor = .ONE_MINUS_SRC_ALPHA,
        .dstAlphaBlendFactor = .ZERO,
        .alphaBlendOp = .ADD,
        .colorWriteMask = vk.ColorComponentFlagBits.R_BIT | vk.ColorComponentFlagBits.G_BIT | vk.ColorComponentFlagBits.B_BIT | vk.ColorComponentFlagBits.A_BIT,
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

    const info = vk.GraphicsPipelineCreateInfo{
        .flags = g_PipelineCreateFlags,
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
        .layout = g_PipelineLayout.?,
        .renderPass = g_RenderPass.?,
        .subpass = 0,
        .basePipelineIndex = 0,
    };

    var out_pipeline: vk.Pipeline = undefined;
    try vk.CreateGraphicsPipelines(v.Device, v.PipelineCache, arrayPtr(&info), v.VkAllocator, arrayPtr(&out_pipeline));
    g_Pipeline = out_pipeline;

    vk.DestroyShaderModule(v.Device, vert_module, v.VkAllocator);
    vk.DestroyShaderModule(v.Device, frag_module, v.VkAllocator);
}
pub fn DestroyFontUploadObjects() void {
    const v = &g_VulkanInitInfo;
    if (g_UploadBuffer != null) {
        vk.DestroyBuffer(v.Device, g_UploadBuffer, v.VkAllocator);
        g_UploadBuffer = null;
    }
    if (g_UploadBufferMemory != null) {
        vk.FreeMemory(v.Device, g_UploadBufferMemory, v.VkAllocator);
        g_UploadBufferMemory = null;
    }
}

fn DestroyDeviceObjects() void {
    const v = &g_VulkanInitInfo;
    DestroyWindowRenderBuffers(v.Device, &g_MainWindowRenderBuffers, v.VkAllocator, v.Allocator);
    DestroyFontUploadObjects();

    if (g_FontView != null) {
        vk.DestroyImageView(v.Device, g_FontView, v.VkAllocator);
        g_FontView = null;
    }
    if (g_FontImage != null) {
        vk.DestroyImage(v.Device, g_FontImage, v.VkAllocator);
        g_FontImage = null;
    }
    if (g_FontMemory != null) {
        vk.FreeMemory(v.Device, g_FontMemory, v.VkAllocator);
        g_FontMemory = null;
    }
    if (g_FontSampler != null) {
        vk.DestroySampler(v.Device, g_FontSampler, v.VkAllocator);
        g_FontSampler = null;
    }
    if (g_DescriptorSetLayout != null) {
        vk.DestroyDescriptorSetLayout(v.Device, g_DescriptorSetLayout, v.VkAllocator);
        g_DescriptorSetLayout = null;
    }
    if (g_PipelineLayout != null) {
        vk.DestroyPipelineLayout(v.Device, g_PipelineLayout, v.VkAllocator);
        g_PipelineLayout = null;
    }
    if (g_Pipeline != null) {
        vk.DestroyPipeline(v.Device, g_Pipeline, v.VkAllocator);
        g_Pipeline = null;
    }
}

pub fn Init(info: *InitInfo, render_pass: ?vk.RenderPass) !void {
    // Setup back-end capabilities flags
    const io = imgui.GetIO();
    io.BackendRendererName = c"imgui_impl_vulkan";
    io.BackendFlags |= imgui.BackendFlagBits.RendererHasVtxOffset; // We can honor the imgui.DrawCmd::VtxOffset field, allowing for large meshes.

    if (info.MinImageCount < 2) return error.FailedStuff;
    std.debug.assert(info.MinImageCount >= 2);
    std.debug.assert(info.ImageCount >= info.MinImageCount);

    g_VulkanInitInfo = info.*;
    g_RenderPass = render_pass;
    try CreateDeviceObjects();
}

pub fn Shutdown() void {
    DestroyDeviceObjects();
}

pub fn NewFrame() void {}

pub fn SetMinImageCount(min_image_count: u32) !void {
    std.debug.assert(min_image_count >= 2);
    if (g_VulkanInitInfo.MinImageCount == min_image_count)
        return;

    const v = &g_VulkanInitInfo;
    try vk.DeviceWaitIdle(v.Device);
    DestroyWindowRenderBuffers(v.Device, &g_MainWindowRenderBuffers, v.VkAllocator, v.Allocator);
    g_VulkanInitInfo.MinImageCount = min_image_count;
}

//-------------------------------------------------------------------------
// Internal / Miscellaneous Vulkan Helpers
// (Used by example's main.cpp. Used by multi-viewport features. PROBABLY NOT used by your own app.)
//-------------------------------------------------------------------------
// You probably do NOT need to use or care about those functions.
// Those functions only exist because:
//   1) they facilitate the readability and maintenance of the multiple main.cpp examples files.
//   2) the upcoming multi-viewport feature will need them internally.
// Generally we avoid exposing any kind of superfluous high-level helpers in the bindings,
// but it is too much code to duplicate everywhere so we exceptionally expose them.
//
// Your engine/app will likely _already_ have code to setup all that stuff (swap chain, render pass, frame buffers, etc.).
// You may read this code to learn about Vulkan, but it is recommended you use you own custom tailored code to do equivalent work.
// (The XXX functions do not interact with any of the state used by the regular XXX functions)
//-------------------------------------------------------------------------

pub fn SelectSurfaceFormat(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR, request_formats: []const vk.Format, request_color_space: vk.ColorSpaceKHR, allocator: *std.mem.Allocator) !vk.SurfaceFormatKHR {
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

pub fn SelectPresentMode(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR, request_modes: []const vk.PresentModeKHR, allocator: *std.mem.Allocator) !vk.PresentModeKHR {
    // Request a certain mode and confirm that it is available. If not use VK_PRESENT_MODE_FIFO_KHR which is mandatory
    const count = try vk.GetPhysicalDeviceSurfacePresentModesCountKHR(physical_device, surface);
    const modes = try allocator.alloc(vk.PresentModeKHR, count);
    defer allocator.free(modes);
    _ = try vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, modes);
    //for (modes) |mode, i|
    //    std.debug.warn("[vulkan] avail_modes[{}] = {}\n", i, mode);

    for (request_modes) |request|
        for (modes) |avail|
            if (request == avail)
                return avail;

    return .FIFO; // Always available
}

fn CreateWindowCommandBuffers(physical_device: vk.PhysicalDevice, device: vk.Device, wd: *Window, queue_family: u32, allocator: ?*const vk.AllocationCallbacks) !void {
    // Create Command Buffers
    var i = u32(0);
    while (i < wd.ImageCount) : (i += 1) {
        const fd = &wd.Frames[i];
        const fsd = &wd.FrameSemaphores[i];
        {
            const info = vk.CommandPoolCreateInfo{
                .flags = vk.CommandPoolCreateFlagBits.RESET_COMMAND_BUFFER_BIT,
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
                .flags = vk.FenceCreateFlagBits.SIGNALED_BIT,
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
    warn("CreateWindowSwapChain\n");
    const old_swapchain = wd.Swapchain;
    warn("old_swapchain = {}\n", old_swapchain);

    try vk.DeviceWaitIdle(device);

    // We don't use DestroyWindow() because we want to preserve the old swapchain to create the new one.
    // Destroy old Framebuffer
    if (wd.ImageCount > 0) {
        warn("Destroying old images\n");
        var i = u32(0);
        while (i < wd.ImageCount) : (i += 1) {
            warn("Destroy frame {}\n", i);
            DestroyFrame(device, &wd.Frames[i], allocator);
            DestroyFrameSemaphores(device, &wd.FrameSemaphores[i], allocator);
        }
        wd.Allocator.free(wd.Frames);
        wd.Allocator.free(wd.FrameSemaphores);
        wd.Frames = &[_]Frame{};
        wd.FrameSemaphores = &[_]FrameSemaphores{};
        wd.ImageCount = 0;
    }

    if (wd.RenderPass != null) {
        warn("Destroying render pass\n");
        vk.DestroyRenderPass(device, wd.RenderPass, allocator);
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
            .imageUsage = vk.ImageUsageFlagBits.COLOR_ATTACHMENT_BIT,
            .imageExtent = undefined, // we will fill this in later
            .imageSharingMode = .EXCLUSIVE, // Assume that graphics family == present family
            .preTransform = vk.SurfaceTransformFlagBitsKHR.IDENTITY_BIT,
            .compositeAlpha = vk.CompositeAlphaFlagBitsKHR.OPAQUE_BIT,
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
        wd.ImageCount = try vk.GetSwapchainImagesCountKHR(device, wd.Swapchain.?);

        var backbuffers: [16]vk.Image = undefined;
        const imagesResult = try vk.GetSwapchainImagesKHR(device, wd.Swapchain.?, &backbuffers);
        std.debug.assert(imagesResult.result == .SUCCESS);

        wd.ImageCount = @intCast(u32, imagesResult.swapchainImages.len);
        std.debug.assert(wd.Frames.len == 0);
        wd.Frames = try wd.Allocator.alloc(Frame, wd.ImageCount);
        wd.FrameSemaphores = try wd.Allocator.alloc(FrameSemaphores, wd.ImageCount);

        for (wd.Frames) |*frame, i| frame.* = Frame{ .Backbuffer = imagesResult.swapchainImages[i] };
        for (wd.FrameSemaphores) |*fs| fs.* = FrameSemaphores{};
    }
    if (old_swapchain != null)
        vk.DestroySwapchainKHR(device, old_swapchain, allocator);

    // Create the Render Pass
    {
        const attachment = vk.AttachmentDescription{
            .format = wd.SurfaceFormat.format,
            .samples = vk.SampleCountFlagBits.T_1_BIT,
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
            .srcStageMask = vk.PipelineStageFlagBits.COLOR_ATTACHMENT_OUTPUT_BIT,
            .dstStageMask = vk.PipelineStageFlagBits.COLOR_ATTACHMENT_OUTPUT_BIT,
            .srcAccessMask = 0,
            .dstAccessMask = vk.AccessFlagBits.COLOR_ATTACHMENT_WRITE_BIT,
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
                .aspectMask = vk.ImageAspectFlagBits.COLOR_BIT,
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
            .renderPass = wd.RenderPass.?,
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

pub fn CreateWindow(instance: vk.Instance, physical_device: vk.PhysicalDevice, device: vk.Device, wd: *Window, queue_family: u32, allocator: ?*const vk.AllocationCallbacks, width: u32, height: u32, min_image_count: u32) !void {
    try CreateWindowSwapChain(physical_device, device, wd, allocator, width, height, min_image_count);
    try CreateWindowCommandBuffers(physical_device, device, wd, queue_family, allocator);
}

pub fn DestroyWindow(instance: vk.Instance, device: vk.Device, wd: *Window, allocator: ?*const vk.AllocationCallbacks) !void {
    try vk.DeviceWaitIdle(device); // FIXME: We could wait on the Queue if we had the queue in wd. (otherwise VulkanH functions can't use globals)
    //vk.QueueWaitIdle(g_Queue);

    for (wd.Frames) |_, i| {
        DestroyFrame(device, &wd.Frames[i], allocator);
        DestroyFrameSemaphores(device, &wd.FrameSemaphores[i], allocator);
    }
    wd.Allocator.free(wd.Frames);
    wd.Allocator.free(wd.FrameSemaphores);
    wd.Frames = &[_]Frame{};
    wd.FrameSemaphores = &[_]FrameSemaphores{};
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
    if (buffers.VertexBuffer != null) {
        vk.DestroyBuffer(device, buffers.VertexBuffer, allocator);
        buffers.VertexBuffer = undefined;
    }
    if (buffers.VertexBufferMemory != null) {
        vk.FreeMemory(device, buffers.VertexBufferMemory, allocator);
        buffers.VertexBufferMemory = undefined;
    }
    if (buffers.IndexBuffer != null) {
        vk.DestroyBuffer(device, buffers.IndexBuffer, allocator);
        buffers.IndexBuffer = undefined;
    }
    if (buffers.IndexBufferMemory != null) {
        vk.FreeMemory(device, buffers.IndexBufferMemory, allocator);
        buffers.IndexBufferMemory = undefined;
    }
    buffers.VertexBufferSize = 0;
    buffers.IndexBufferSize = 0;
}

fn DestroyWindowRenderBuffers(device: vk.Device, buffers: *WindowRenderBuffers, vkAllocator: ?*const vk.AllocationCallbacks, allocator: *std.mem.Allocator) void {
    for (buffers.FrameRenderBuffers) |*frb|
        DestroyFrameRenderBuffers(device, frb, vkAllocator);
    allocator.free(buffers.FrameRenderBuffers);
    buffers.FrameRenderBuffers = &[_]FrameRenderBuffers{};
    buffers.Index = 0;
}

// converts *T to *[1]T
fn arrayPtrType(comptime ptrType: type) type {
    const info = @typeInfo(ptrType);
    if (info.Pointer.is_const) {
        return *const [1]ptrType.Child;
    } else {
        return *[1]ptrType.Child;
    }
}

fn arrayPtr(ptr: var) arrayPtrType(@typeOf(ptr)) {
    return @ptrCast(arrayPtrType(@typeOf(ptr)), ptr);
}
