const std = @import("std");
const assert = std.debug.assert;

const imgui = @import("imgui");
const glfw = @import("include/glfw.zig");
const vk = @import("include/vk.zig");

const impl_glfw = @import("imgui_impl_glfw.zig");
const impl_vulkan = @import("imgui_impl_vulkan.zig");

const build_mode = @import("builtin").mode;
const build_safe = build_mode != .ReleaseFast;
const IMGUI_UNLIMITED_FRAME_RATE = false;
const IMGUI_VULKAN_DEBUG_REPORT = build_safe;

var g_Allocator: ?*vk.AllocationCallbacks = null;
var g_Instance: vk.Instance = undefined;
var g_PhysicalDevice: vk.PhysicalDevice = undefined;
var g_Device: vk.Device = undefined;
var g_QueueFamily = ~@as(u32, 0);
var g_Queue: vk.Queue = undefined;
var g_DebugReport: vk.DebugReportCallbackEXT = undefined;
var g_PipelineCache: vk.PipelineCache = undefined;
var g_DescriptorPool: vk.DescriptorPool = undefined;

var g_MainWindowData = impl_vulkan.Window{};
var g_MinImageCount = @as(u32, 2);
var g_SwapChainRebuild = false;
var g_ClearColor = imgui.Vec4{ .x = 0.5, .y = 0, .z = 1, .w = 1 };

fn debug_report(flags: vk.DebugReportFlagsEXT.IntType, objectType: vk.DebugReportObjectTypeEXT, object: u64, location: usize, messageCode: i32, pLayerPrefix: ?[*:0]const u8, pMessage: ?[*:0]const u8, pUserData: ?*anyopaque) callconv(vk.CallConv) vk.Bool32 {
    _ = pUserData;
    _ = pLayerPrefix;
    _ = messageCode;
    _ = location;
    _ = object;
    _ = flags;
    std.debug.print("[vulkan] ObjectType: {}\nMessage: {s}\n\n", .{ objectType, pMessage });
    @panic("VK Error");
    //return vk.FALSE;
}

fn SetupVulkan(extensions: []const [*:0]const u8, allocator: std.mem.Allocator) !void {
    // Create Vulkan Instance
    {
        var create_info = vk.InstanceCreateInfo{
            .enabledExtensionCount = @intCast(u32, extensions.len),
            .ppEnabledExtensionNames = extensions.ptr,
        };

        if (IMGUI_VULKAN_DEBUG_REPORT) {
            // Enabling multiple validation layers grouped as VK_LAYER_KHRONOS_validation
            const layers = [_][*:0]const u8{"VK_LAYER_KHRONOS_validation"};
            create_info.enabledLayerCount = 1;
            create_info.ppEnabledLayerNames = &layers;

            // Enable debug report extension (we need additional storage, so we duplicate the user array to add our new extension to it)
            const extensions_ext = try allocator.alloc([*:0]const u8, extensions.len + 1);
            defer allocator.free(extensions_ext);
            std.mem.copy([*:0]const u8, extensions_ext[0..extensions.len], extensions);
            extensions_ext[extensions.len] = "VK_EXT_debug_report";

            create_info.enabledExtensionCount = @intCast(u32, extensions_ext.len);
            create_info.ppEnabledExtensionNames = extensions_ext.ptr;

            // Create Vulkan Instance
            g_Instance = try vk.CreateInstance(create_info, g_Allocator);

            // Get the function pointer (required for any extensions)
            var vkCreateDebugReportCallbackEXT = @ptrCast(?@TypeOf(vk.vkCreateDebugReportCallbackEXT), vk.GetInstanceProcAddr(g_Instance, "vkCreateDebugReportCallbackEXT")).?;

            // Setup the debug report callback
            var debug_report_ci = vk.DebugReportCallbackCreateInfoEXT{
                .flags = .{ .errorBit = true, .warning = true, .performanceWarning = true },
                .pfnCallback = debug_report,
                .pUserData = null,
            };
            var err = vkCreateDebugReportCallbackEXT(g_Instance, &debug_report_ci, g_Allocator, &g_DebugReport);
            if (@enumToInt(err) < 0) {
                return error.CreateDebugCallbackFailed;
            }
        } else {
            // Create Vulkan Instance without any debug feature
            g_Instance = try vk.CreateInstance(create_info, g_Allocator);
        }
    }

    // Select GPU
    {
        var gpu_count = try vk.EnumeratePhysicalDevicesCount(g_Instance);
        assert(gpu_count > 0);

        var gpus = try allocator.alloc(vk.PhysicalDevice, gpu_count);
        defer allocator.free(gpus);
        _ = try vk.EnumeratePhysicalDevices(g_Instance, gpus);

        // If a number >1 of GPUs got reported, find discrete GPU if present, or use first one available. This covers
        // most common cases (multi-gpu/integrated+dedicated graphics). Handling more complicated setups (multiple
        // dedicated GPUs) is out of scope of this sample.
        const use_gpu = for (gpus) |gpu, i| {
            const properties = vk.GetPhysicalDeviceProperties(gpu);
            if (properties.deviceType == .DISCRETE_GPU) break i;
        } else 0;
        g_PhysicalDevice = gpus[use_gpu];
    }

    // Select graphics queue family
    {
        var count = vk.GetPhysicalDeviceQueueFamilyPropertiesCount(g_PhysicalDevice);
        var queues = try allocator.alloc(vk.QueueFamilyProperties, count);
        defer allocator.free(queues);
        _ = vk.GetPhysicalDeviceQueueFamilyProperties(g_PhysicalDevice, queues);
        for (queues) |queue, i| {
            if (queue.queueFlags.graphics) {
                g_QueueFamily = @intCast(u32, i);
                break;
            }
        }
        assert(g_QueueFamily != ~@as(u32, 0));
    }

    // Create Logical Device (with 1 queue)
    {
        var device_extensions = [_][*:0]const u8{"VK_KHR_swapchain"};
        var queue_priority = [_]f32{1.0};
        var queue_info = [_]vk.DeviceQueueCreateInfo{
            vk.DeviceQueueCreateInfo{
                .queueFamilyIndex = g_QueueFamily,
                .queueCount = 1,
                .pQueuePriorities = &queue_priority,
            },
        };
        var create_info = vk.DeviceCreateInfo{
            .queueCreateInfoCount = @intCast(u32, queue_info.len),
            .pQueueCreateInfos = &queue_info,
            .enabledExtensionCount = @intCast(u32, device_extensions.len),
            .ppEnabledExtensionNames = &device_extensions,
        };
        g_Device = try vk.CreateDevice(g_PhysicalDevice, create_info, g_Allocator);
        g_Queue = vk.GetDeviceQueue(g_Device, g_QueueFamily, 0);
    }

    // Create Descriptor Pool
    {
        var pool_sizes = [_]vk.DescriptorPoolSize{
            vk.DescriptorPoolSize{ .inType = .SAMPLER, .descriptorCount = 1000 },
            vk.DescriptorPoolSize{ .inType = .COMBINED_IMAGE_SAMPLER, .descriptorCount = 1000 },
            vk.DescriptorPoolSize{ .inType = .SAMPLED_IMAGE, .descriptorCount = 1000 },
            vk.DescriptorPoolSize{ .inType = .STORAGE_IMAGE, .descriptorCount = 1000 },
            vk.DescriptorPoolSize{ .inType = .UNIFORM_TEXEL_BUFFER, .descriptorCount = 1000 },
            vk.DescriptorPoolSize{ .inType = .STORAGE_TEXEL_BUFFER, .descriptorCount = 1000 },
            vk.DescriptorPoolSize{ .inType = .UNIFORM_BUFFER, .descriptorCount = 1000 },
            vk.DescriptorPoolSize{ .inType = .STORAGE_BUFFER, .descriptorCount = 1000 },
            vk.DescriptorPoolSize{ .inType = .UNIFORM_BUFFER_DYNAMIC, .descriptorCount = 1000 },
            vk.DescriptorPoolSize{ .inType = .STORAGE_BUFFER_DYNAMIC, .descriptorCount = 1000 },
            vk.DescriptorPoolSize{ .inType = .INPUT_ATTACHMENT, .descriptorCount = 1000 },
        };
        var pool_info = vk.DescriptorPoolCreateInfo{
            .flags = .{ .freeDescriptorSet = true },
            .maxSets = 1000 * @intCast(u32, pool_sizes.len),
            .poolSizeCount = @intCast(u32, pool_sizes.len),
            .pPoolSizes = &pool_sizes,
        };
        g_DescriptorPool = try vk.CreateDescriptorPool(g_Device, pool_info, g_Allocator);
    }
}

// All the ImGui_ImplVulkanH_XXX structures/functions are optional helpers used by the demo.
// Your real engine/app may not use them.
fn SetupVulkanWindow(wd: *impl_vulkan.Window, surface: vk.SurfaceKHR, width: u32, height: u32, allocator: std.mem.Allocator) !void {
    wd.Surface = surface;
    wd.Allocator = allocator;

    var res = try vk.GetPhysicalDeviceSurfaceSupportKHR(g_PhysicalDevice, g_QueueFamily, surface);
    if (res != vk.TRUE) {
        return error.NoWSISupport;
    }

    // Select Surface Format
    const requestSurfaceImageFormat = [_]vk.Format{ .B8G8R8A8_UNORM, .R8G8B8A8_UNORM, .B8G8R8_UNORM, .R8G8B8_UNORM };
    const requestSurfaceColorSpace = vk.ColorSpaceKHR.SRGB_NONLINEAR;
    wd.SurfaceFormat = try impl_vulkan.SelectSurfaceFormat(g_PhysicalDevice, surface, &requestSurfaceImageFormat, requestSurfaceColorSpace, allocator);

    // Select Present Mode
    if (IMGUI_UNLIMITED_FRAME_RATE) {
        var present_modes = [_]vk.PresentModeKHR{ .MAILBOX, .IMMEDIATE, .FIFO };
        wd.PresentMode = try impl_vulkan.SelectPresentMode(g_PhysicalDevice, surface, &present_modes, allocator);
    } else {
        var present_modes = [_]vk.PresentModeKHR{.FIFO};
        wd.PresentMode = try impl_vulkan.SelectPresentMode(g_PhysicalDevice, surface, &present_modes, allocator);
    }

    // Create SwapChain, RenderPass, Framebuffer, etc.
    assert(g_MinImageCount >= 2);
    try impl_vulkan.CreateOrResizeWindow(g_Instance, g_PhysicalDevice, g_Device, wd, g_QueueFamily, g_Allocator, width, height, g_MinImageCount);
}

fn CleanupVulkan() void {
    vk.DestroyDescriptorPool(g_Device, g_DescriptorPool, g_Allocator);

    if (IMGUI_VULKAN_DEBUG_REPORT) {
        // Remove the debug report callback
        const vkDestroyDebugReportCallbackEXT = @ptrCast(?@TypeOf(vk.vkDestroyDebugReportCallbackEXT), vk.GetInstanceProcAddr(g_Instance, "vkDestroyDebugReportCallbackEXT"));
        assert(vkDestroyDebugReportCallbackEXT != null);
        vkDestroyDebugReportCallbackEXT.?(g_Instance, g_DebugReport, g_Allocator);
    }

    vk.DestroyDevice(g_Device, g_Allocator);
    vk.DestroyInstance(g_Instance, g_Allocator);
}

fn CleanupVulkanWindow() !void {
    try impl_vulkan.DestroyWindow(g_Instance, g_Device, &g_MainWindowData, g_Allocator);
}

fn FrameRender(wd: *impl_vulkan.Window, draw_data: *imgui.DrawData) !void {
    const image_acquired_semaphore = wd.FrameSemaphores[wd.SemaphoreIndex].ImageAcquiredSemaphore;
    const render_complete_semaphore = wd.FrameSemaphores[wd.SemaphoreIndex].RenderCompleteSemaphore;
    const acquire_result = vk.AcquireNextImageKHR(g_Device, wd.Swapchain, ~@as(u64, 0), image_acquired_semaphore, .Null) catch |err| switch (err) {
        error.VK_OUT_OF_DATE_KHR => {
            g_SwapChainRebuild = true;
            return;
        },
        else => |e| return e,
    };
    if (acquire_result.result == .SUBOPTIMAL_KHR) {
        g_SwapChainRebuild = true;
        return;
    }
    wd.FrameIndex = acquire_result.imageIndex;

    const fd = &wd.Frames[wd.FrameIndex];
    {
        _ = try vk.WaitForFences(g_Device, arrayPtr(&fd.Fence), vk.TRUE, ~@as(u64, 0)); // wait indefinitely instead of periodically checking
        try vk.ResetFences(g_Device, arrayPtr(&fd.Fence));
    }
    {
        try vk.ResetCommandPool(g_Device, fd.CommandPool, .{});
        var info = vk.CommandBufferBeginInfo{
            .flags = .{ .oneTimeSubmit = true },
        };
        try vk.BeginCommandBuffer(fd.CommandBuffer, info);
    }
    {
        var info = vk.RenderPassBeginInfo{
            .renderPass = wd.RenderPass,
            .framebuffer = fd.Framebuffer,
            .renderArea = vk.Rect2D{
                .offset = vk.Offset2D{ .x = 0, .y = 0 },
                .extent = vk.Extent2D{ .width = wd.Width, .height = wd.Height },
            },
            .clearValueCount = 1,
            .pClearValues = @ptrCast([*]vk.ClearValue, &g_ClearColor),
        };
        vk.CmdBeginRenderPass(fd.CommandBuffer, info, .INLINE);
    }

    // Record Imgui Draw Data and draw funcs into command buffer
    try impl_vulkan.RenderDrawData(draw_data, fd.CommandBuffer, .Null);

    // Submit command buffer
    vk.CmdEndRenderPass(fd.CommandBuffer);
    {
        const wait_stage: vk.PipelineStageFlags align(4) = .{ .colorAttachmentOutput = true };
        var info = vk.SubmitInfo{
            .waitSemaphoreCount = 1,
            .pWaitSemaphores = arrayPtr(&image_acquired_semaphore),
            .pWaitDstStageMask = arrayPtr(&wait_stage),
            .commandBufferCount = 1,
            .pCommandBuffers = arrayPtr(&fd.CommandBuffer),
            .signalSemaphoreCount = 1,
            .pSignalSemaphores = arrayPtr(&render_complete_semaphore),
        };

        try vk.EndCommandBuffer(fd.CommandBuffer);
        try vk.QueueSubmit(g_Queue, arrayPtr(&info), fd.Fence);
    }
}

fn FramePresent(wd: *impl_vulkan.Window) !void {
    if (g_SwapChainRebuild)
        return;
    const render_complete_semaphore = wd.FrameSemaphores[wd.SemaphoreIndex].RenderCompleteSemaphore;
    var info = vk.PresentInfoKHR{
        .waitSemaphoreCount = 1,
        .pWaitSemaphores = arrayPtr(&render_complete_semaphore),
        .swapchainCount = 1,
        .pSwapchains = arrayPtr(&wd.Swapchain),
        .pImageIndices = arrayPtr(&wd.FrameIndex),
    };
    const result = vk.QueuePresentKHR(g_Queue, info) catch |err| switch (err) {
        error.VK_OUT_OF_DATE_KHR => {
            g_SwapChainRebuild = true;
            return;
        },
        else => |e| return e,
    };
    if (result == .SUBOPTIMAL_KHR) {
        g_SwapChainRebuild = true;
        return;
    }
    wd.SemaphoreIndex = (wd.SemaphoreIndex + 1) % wd.ImageCount; // Now we can use the next set of semaphores
}

fn glfw_error_callback(err: c_int, description: ?[*:0]const u8) callconv(.C) void {
    var nonnull_desc: [*:0]const u8 = description orelse "";
    std.debug.print("Glfw Error {}: {s}\n", .{ err, nonnull_desc });
}

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    // Setup GLFW window
    _ = glfw.glfwSetErrorCallback(glfw_error_callback);
    if (glfw.glfwInit() == 0)
        return error.GlfwInitFailed;

    glfw.glfwWindowHint(glfw.GLFW_CLIENT_API, glfw.GLFW_NO_API);
    var window = glfw.glfwCreateWindow(1280, 720, "Dear ImGui GLFW+Vulkan example", null, null).?;

    // Setup Vulkan
    if (glfw.glfwVulkanSupported() == 0) {
        return error.VulkanNotSupported;
    }
    var extensions_count: u32 = 0;
    var extensions_ptr = glfw.glfwGetRequiredInstanceExtensions(&extensions_count);
    const extensions = if (extensions_count > 0) extensions_ptr.?[0..extensions_count] else &[_][*:0]const u8{};
    try SetupVulkan(extensions, allocator);

    // Create Window Surface
    var surface: vk.SurfaceKHR = undefined;
    const err = glfw.glfwCreateWindowSurface(g_Instance, window, g_Allocator, &surface);
    if (@enumToInt(err) < 0) {
        return error.CouldntCreateSufrace;
    }

    // Create Framebuffers
    var w: c_int = 0;
    var h: c_int = 0;
    glfw.glfwGetFramebufferSize(window, &w, &h);
    const wd = &g_MainWindowData;
    try SetupVulkanWindow(wd, surface, @intCast(u32, w), @intCast(u32, h), allocator);

    // Setup Dear ImGui context
    imgui.CHECKVERSION();
    _ = imgui.CreateContext();
    var io = imgui.GetIO();
    //io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls
    //io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls

    // Setup Dear ImGui style
    imgui.StyleColorsDark();
    //imgui.StyleColorsClassic(null);

    // Setup Platform/Renderer backends
    var initResult = impl_glfw.InitForVulkan(window, true);
    assert(initResult);

    var init_info = impl_vulkan.InitInfo{
        .Instance = g_Instance,
        .PhysicalDevice = g_PhysicalDevice,
        .Device = g_Device,
        .QueueFamily = g_QueueFamily,
        .Queue = g_Queue,
        .PipelineCache = g_PipelineCache,
        .DescriptorPool = g_DescriptorPool,
        .Subpass = 0,
        .MinImageCount = g_MinImageCount,
        .MSAASamples = .{ .t1 = true },
        .VkAllocator = g_Allocator,
        .ImageCount = wd.ImageCount,
    };
    try impl_vulkan.Init(&init_info, wd.RenderPass);

    // Load Fonts
    // - If no fonts are loaded, dear imgui will use the default font. You can also load multiple fonts and use imgui.PushFont()/PopFont() to select them.
    // - AddFontFromFileTTF() will return the ImFont* so you can store it if you need to select the font among multiple.
    // - If the file cannot be loaded, the function will return NULL. Please handle those errors in your application (e.g. use an assertion, or display an error and quit).
    // - The fonts will be rasterized at a given size (w/ oversampling) and stored into a texture when calling ImFontAtlas::Build()/GetTexDataAsXXXX(), which ImGui_ImplXXXX_NewFrame below will call.
    // - Read 'docs/FONTS.txt' for more instructions and details.
    // - Remember that in C/C++ if you want to include a backslash \ in a string literal you need to write a double backslash \\ !
    //io.Fonts.?.AddFontDefault();
    //io.Fonts.?.AddFontFromFileTTF("../../misc/fonts/Roboto-Medium.ttf", 16.0f);
    //io.Fonts.?.AddFontFromFileTTF("../../misc/fonts/Cousine-Regular.ttf", 15.0f);
    //io.Fonts.?.AddFontFromFileTTF("../../misc/fonts/DroidSans.ttf", 16.0f);
    //io.Fonts.?.AddFontFromFileTTF("../../misc/fonts/ProggyTiny.ttf", 10.0f);
    //ImFont* font = io.Fonts.?.AddFontFromFileTTF("c:\\Windows\\Fonts\\ArialUni.ttf", 18.0f, NULL, io.Fonts.?.GetGlyphRangesJapanese());
    //assert(font != NULL);

    // Upload Fonts
    if (true) {
        // Use any command queue
        const command_pool = wd.Frames[wd.FrameIndex].CommandPool;
        const command_buffer = wd.Frames[wd.FrameIndex].CommandBuffer;

        try vk.ResetCommandPool(g_Device, command_pool, .{});
        const begin_info = vk.CommandBufferBeginInfo{
            .flags = .{ .oneTimeSubmit = true },
        };
        try vk.BeginCommandBuffer(command_buffer, begin_info);

        try impl_vulkan.CreateFontsTexture(command_buffer);

        const end_info = vk.SubmitInfo{
            .commandBufferCount = 1,
            .pCommandBuffers = arrayPtr(&command_buffer),
        };
        try vk.EndCommandBuffer(command_buffer);
        try vk.QueueSubmit(g_Queue, arrayPtr(&end_info), .Null);

        try vk.DeviceWaitIdle(g_Device);
        impl_vulkan.DestroyFontUploadObjects();
    } else {
        // Trick imgui into thinking we've built fonts
        var pixels: [*]u8 = undefined;
        var width: i32 = 0;
        var height: i32 = 0;
        var bpp: i32 = 0;
        io.Fonts.?.GetTexDataAsRGBA32(&pixels, &width, &height, &bpp);
    }

    // Our state
    var show_demo_window = true;
    var show_another_window = false;
    var slider_value: f32 = 0;
    var counter: i32 = 0;

    // Main loop
    while (glfw.glfwWindowShouldClose(window) == 0) {
        // Poll and handle events (inputs, window resize, etc.)
        // You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
        // - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application, or clear/overwrite your copy of the mouse data.
        // - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application, or clear/overwrite your copy of the mouse data.
        // Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
        glfw.glfwPollEvents();

        // Resize swap chain?
        if (g_SwapChainRebuild) {
            var width: c_int = 0;
            var height: c_int = 0;
            glfw.glfwGetFramebufferSize(window, &width, &height);
            if (width > 0 and height > 0) {
                try impl_vulkan.SetMinImageCount(g_MinImageCount);
                try impl_vulkan.CreateOrResizeWindow(g_Instance, g_PhysicalDevice, g_Device, &g_MainWindowData, g_QueueFamily, g_Allocator, @intCast(u32, width), @intCast(u32, height), g_MinImageCount);
                g_MainWindowData.FrameIndex = 0;
                g_SwapChainRebuild = false;
            }
        }

        // Start the Dear ImGui frame
        impl_vulkan.NewFrame();
        impl_glfw.NewFrame();
        imgui.NewFrame();

        // 1. Show the big demo window (Most of the sample code is in imgui.ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
        if (show_demo_window)
            imgui.ShowDemoWindowExt(&show_demo_window);

        // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
        {
            _ = imgui.Begin("Hello, world!"); // Create a window called "Hello, world!" and append into it.

            imgui.Text("This is some useful text."); // Display some text (you can use a format strings too)
            _ = imgui.Checkbox("Demo Window", &show_demo_window); // Edit bools storing our window open/close state
            _ = imgui.Checkbox("Another Window", &show_another_window);

            _ = imgui.SliderFloat("float", &slider_value, 0.0, 1.0); // Edit 1 float using a slider from 0.0 to 1.0
            _ = imgui.ColorEdit3("clear color", @ptrCast(*[3]f32, &g_ClearColor)); // Edit 3 floats representing a color

            if (imgui.Button("Button")) // Buttons return true when clicked (most widgets return true when edited/activated)
                counter += 1;
            imgui.SameLine();
            imgui.Text("counter = %d", counter);

            imgui.Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0 / imgui.GetIO().Framerate, imgui.GetIO().Framerate);
            imgui.End();
        }

        // 3. Show another simple window.
        if (show_another_window) {
            _ = imgui.BeginExt("Another Window", &show_another_window, .{}); // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
            imgui.Text("Hello from another window!");
            if (imgui.Button("Close Me"))
                show_another_window = false;
            imgui.End();
        }

        // Rendering
        imgui.Render();

        const draw_data = imgui.GetDrawData();
        const is_minimized = draw_data.DisplaySize.x <= 0 or draw_data.DisplaySize.y <= 0;
        if (!is_minimized) {
            try FrameRender(wd, draw_data);
            try FramePresent(wd);
        }
    }

    // Cleanup
    try vk.DeviceWaitIdle(g_Device);
    impl_vulkan.Shutdown();
    impl_glfw.Shutdown();
    imgui.DestroyContext();

    try CleanupVulkanWindow();
    CleanupVulkan();

    glfw.glfwDestroyWindow(window);
    glfw.glfwTerminate();
}

/// Takes a pointer type like *T, *const T, *align(4)T, etc,
/// returns the pointer type *[1]T, *const [1]T, *align(4) [1]T, etc.
fn ArrayPtrType(comptime ptrType: type) type {
    comptime {
        // Check that the input is of type *T
        var info = @typeInfo(ptrType);
        assert(info == .Pointer);
        assert(info.Pointer.size == .One);
        assert(info.Pointer.sentinel == null);

        // Create the new value type, [1]T
        const arrayInfo = std.builtin.TypeInfo{
            .Array = .{
                .len = 1,
                .child = info.Pointer.child,
                .sentinel = @as(?info.Pointer.child, null),
            },
        };

        // Patch the type to be *[1]T, preserving other modifiers
        const singleArrayType = @Type(arrayInfo);
        info.Pointer.child = singleArrayType;
        // also need to change the type of the sentinel
        // we checked that this is null above so no work needs to be done here.
        info.Pointer.sentinel = @as(?singleArrayType, null);
        return @Type(info);
    }
}

fn arrayPtr(ptr: anytype) ArrayPtrType(@TypeOf(ptr)) {
    return @as(ArrayPtrType(@TypeOf(ptr)), ptr);
}
