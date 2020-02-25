const std = @import("std");

const imgui = @import("imgui");
const glfw = @import("include/glfw.zig");
const vk = @import("include/vk.zig");

const impl_glfw = @import("imgui_impl_glfw.zig");
//const impl_vulkan = @import("../imgui_impl_vulkan.zig");
const impl_vulkan = struct {
    const Frame = struct {
        CommandPool: vk.CommandPool,
        CommandBuffer: vk.CommandBuffer,
        Fence: vk.Fence,
        Backbuffer: vk.Image,
        BackbufferView: vk.ImageView,
        Framebuffer: vk.Framebuffer,
    };

    const FrameSemaphores = struct {
        ImageAcquiredSemaphore: vk.Semaphore,
        RenderCompleteSemaphore: vk.Semaphore,
    };

    // Helper structure to hold the data needed by one rendering context into one OS window
    // (Used by example's main.cpp. Used by multi-viewport features. Probably NOT used by your own engine/app.)
    const Window = struct {
        Width: u32 = 0,
        Height: u32 = 0,
        Swapchain: vk.SwapchainKHR = undefined,
        Surface: vk.SurfaceKHR = undefined,
        SurfaceFormat: vk.SurfaceFormatKHR = undefined,
        PresentMode: vk.PresentModeKHR = undefined,
        RenderPass: vk.RenderPass = undefined,
        ClearEnable: bool = true,
        ClearValue: vk.ClearValue = vk.ClearValue{
            .color = vk.ClearColorValue{.int32 = [_]i32{0,0,0,0}},
            .depthStencil = vk.ClearDepthStencilValue{ .depth = 0, .stencil = 0 },
        },
        FrameIndex: u32 = 0,             // Current frame being rendered to (0 <= FrameIndex < FrameInFlightCount)
        ImageCount: u32 = 0,             // Number of simultaneous in-flight frames (returned by vkGetSwapchainImagesKHR, usually derived from min_image_count)
        SemaphoreIndex: u32 = 0,         // Current set of swapchain wait semaphores we're using (needs to be distinct from per frame data)
        Frames: [*]Frame = undefined,
        FrameSemaphores: [*]FrameSemaphores = undefined,
    };
    
    const InitInfo = struct {
        Instance: vk.Instance,
        PhysicalDevice: vk.PhysicalDevice,
        Device: vk.Device,
        QueueFamily: u32,
        Queue: vk.Queue,
        PipelineCache: vk.PipelineCache,
        DescriptorPool: vk.DescriptorPool,
        MinImageCount: u32,          // >= 2
        ImageCount: u32,             // >= MinImageCount
        MSAASamples: vk.SampleCountFlags,   // >= VK_SAMPLE_COUNT_1_BIT
        Allocator: ?*const vk.AllocationCallbacks,
    };
    
    fn SelectSurfaceFormat(device: vk.PhysicalDevice, surface: vk.SurfaceKHR, requests: []const vk.Format, colorSpace: vk.ColorSpaceKHR) vk.SurfaceFormatKHR {
        return undefined;
    }
    
    fn SelectPresentMode(device: vk.PhysicalDevice, surface: vk.SurfaceKHR, options: []const vk.PresentModeKHR) vk.PresentModeKHR {
        return options[0];
    }
    
    fn CreateWindow(instance: vk.Instance, pd: vk.PhysicalDevice, d: vk.Device, wd: *Window, qf: u32, alloc: ?*vk.AllocationCallbacks, width: u32, height: u32, minImages: u32) void {
        
    }
    
    fn Init(info: *InitInfo, rp: vk.RenderPass) void {}
    fn CreateFontsTexture(cb: vk.CommandBuffer) void {}
    fn DestroyFontUploadObjects() void {}
    fn SetMinImageCount(ct: u32) void {}
    fn NewFrame() void {}
    fn RenderDrawData(dd: *imgui.DrawData, cb: vk.CommandBuffer) void {}
    fn Shutdown() void {}
    fn DestroyWindow(inst: vk.Instance, dv: vk.Device, wd: *impl_vulkan.Window, allocator: ?*vk.AllocationCallbacks) void {}
};

const build_mode = @import("builtin").mode;
const build_safe = build_mode != .ReleaseFast;
const IMGUI_UNLIMITED_FRAME_RATE = false;
const IMGUI_VULKAN_DEBUG_REPORT = build_safe;

var g_Allocator: ?*vk.AllocationCallbacks = null;
var g_Instance: vk.Instance = undefined;
var g_PhysicalDevice: vk.PhysicalDevice = undefined;
var g_Device: vk.Device = undefined;
var g_QueueFamily = ~u32(0);
var g_Queue: vk.Queue = undefined;
var g_DebugReport: vk.DebugReportCallbackEXT = undefined;
var g_PipelineCache: vk.PipelineCache = undefined;
var g_DescriptorPool: vk.DescriptorPool = undefined;

var g_MainWindowData: impl_vulkan.Window = undefined;
var g_MinImageCount = u32(2);
var g_SwapChainRebuild = false;
var g_SwapChainResizeWidth = u32(0);
var g_SwapChainResizeHeight = u32(0);

extern fn debug_report(flags: vk.DebugReportFlagsEXT, objectType: vk.DebugReportObjectTypeEXT, object: u64, location: usize, messageCode: i32, pLayerPrefix: ?[*]const u8, pMessage: ?[*]const u8, pUserData: ?*c_void) vk.Bool32 {
    std.debug.warn("[vulkan] ObjectType: {}\nMessage: {}\n\n", objectType, pMessage);
    return vk.FALSE;
}

fn SetupVulkan(extensions: []const[*]const u8, allocator: *std.mem.Allocator) !void {
    // Create Vulkan Instance
    {
        var create_info = vk.InstanceCreateInfo{
            .enabledExtensionCount = @intCast(u32, extensions.len),
            .ppEnabledExtensionNames = extensions.ptr,
        };

        if (IMGUI_VULKAN_DEBUG_REPORT) {
            // Enabling multiple validation layers grouped as LunarG standard validation
            const layers = [_][*]const u8{c"VK_LAYER_LUNARG_standard_validation"};
            create_info.enabledLayerCount = 1;
            create_info.ppEnabledLayerNames = &layers;

            // Enable debug report extension (we need additional storage, so we duplicate the user array to add our new extension to it)
            const extensions_ext = try allocator.alloc([*]const u8, extensions.len + 1);
            defer allocator.free(extensions_ext);
            std.mem.copy([*]const u8, extensions_ext[0..extensions.len], extensions);
            extensions_ext[extensions.len] = c"VK_EXT_debug_report";

            create_info.enabledExtensionCount = @intCast(u32, extensions_ext.len);
            create_info.ppEnabledExtensionNames = extensions_ext.ptr;

            // Create Vulkan Instance
            g_Instance = try vk.CreateInstance(create_info, g_Allocator);

            // Get the function pointer (required for any extensions)
            var vkCreateDebugReportCallbackEXT = @ptrCast(?@typeOf(vk.vkCreateDebugReportCallbackEXT), vk.GetInstanceProcAddr(g_Instance, c"vkCreateDebugReportCallbackEXT")).?;

            // Setup the debug report callback
            var debug_report_ci = vk.DebugReportCallbackCreateInfoEXT{
                .flags = vk.DebugReportFlagBitsEXT.ERROR_BIT | vk.DebugReportFlagBitsEXT.WARNING_BIT | vk.DebugReportFlagBitsEXT.PERFORMANCE_WARNING_BIT,
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
        std.debug.assert(gpu_count > 0);

        var gpus = try allocator.alloc(vk.PhysicalDevice, gpu_count);
        defer allocator.free(gpus);
        _ = try vk.EnumeratePhysicalDevices(g_Instance, gpus);

        // If a number >1 of GPUs got reported, you should find the best fit GPU for your purpose
        // e.g. VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU if available, or with the greatest memory available, etc.
        // for sake of simplicity we'll just take the first one, assuming it has a graphics queue family.
        g_PhysicalDevice = gpus[0];
    }

    // Select graphics queue family
    {
        var count = vk.GetPhysicalDeviceQueueFamilyPropertiesCount(g_PhysicalDevice);
        var queues = try allocator.alloc(vk.QueueFamilyProperties, count);
        defer allocator.free(queues);
        _ = vk.GetPhysicalDeviceQueueFamilyProperties(g_PhysicalDevice, queues);
        for (queues) |queue, i| {
            if (queue.queueFlags & vk.QueueFlagBits.GRAPHICS_BIT != 0) {
                g_QueueFamily = @intCast(u32, i);
                break;
            }
        }
        std.debug.assert(g_QueueFamily != ~u32(0));
    }

    // Create Logical Device (with 1 queue)
    {
        var device_extensions = [_][*]const u8{c"VK_KHR_swapchain"};
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
            .flags = vk.DescriptorPoolCreateFlagBits.FREE_DESCRIPTOR_SET_BIT,
            .maxSets = 1000 * @intCast(u32, pool_sizes.len),
            .poolSizeCount = @intCast(u32, pool_sizes.len),
            .pPoolSizes = &pool_sizes,
        };
        g_DescriptorPool = try vk.CreateDescriptorPool(g_Device, pool_info, g_Allocator);
    }
}

// All the ImGui_ImplVulkanH_XXX structures/functions are optional helpers used by the demo.
// Your real engine/app may not use them.
fn SetupVulkanWindow(wd: *impl_vulkan.Window, surface: vk.SurfaceKHR, width: u32, height: u32) !void {
    wd.Surface = surface;

    var res = try vk.GetPhysicalDeviceSurfaceSupportKHR(g_PhysicalDevice, g_QueueFamily, surface);
    if (res != vk.TRUE) {
        std.debug.warn("Error no WSI support on physical device 0\n");
        return error.NoWSISupport;
    }

    // Select Surface Format
    const requestSurfaceImageFormat = [_]vk.Format{ .B8G8R8A8_UNORM, .R8G8B8A8_UNORM, .B8G8R8_UNORM, .R8G8B8_UNORM };
    const requestSurfaceColorSpace = vk.ColorSpaceKHR.SRGB_NONLINEAR;
    wd.SurfaceFormat = impl_vulkan.SelectSurfaceFormat(g_PhysicalDevice, surface, &requestSurfaceImageFormat, requestSurfaceColorSpace);

    // Select Present Mode
    if (IMGUI_UNLIMITED_FRAME_RATE) {
        var present_modes = [_]vk.PresentModeKHR{ .MAILBOX, .IMMEDIATE, .FIFO };
        wd.PresentMode = impl_vulkan.SelectPresentMode(g_PhysicalDevice, surface, &present_modes);
    } else {
        var present_modes = [_]vk.PresentModeKHR{.FIFO};
        wd.PresentMode = impl_vulkan.SelectPresentMode(g_PhysicalDevice, surface, &present_modes);
    }
    //printf("[vulkan] Selected PresentMode = %d\n", wd.PresentMode);

    // Create SwapChain, RenderPass, Framebuffer, etc.
    std.debug.assert(g_MinImageCount >= 2);
    impl_vulkan.CreateWindow(g_Instance, g_PhysicalDevice, g_Device, wd, g_QueueFamily, g_Allocator, width, height, g_MinImageCount);
}

fn CleanupVulkan() void {
    vk.DestroyDescriptorPool(g_Device, g_DescriptorPool, g_Allocator);

    if (IMGUI_VULKAN_DEBUG_REPORT) {
        // Remove the debug report callback
        const vkDestroyDebugReportCallbackEXT = @ptrCast(?@typeOf(vk.vkDestroyDebugReportCallbackEXT), vk.GetInstanceProcAddr(g_Instance, c"vkDestroyDebugReportCallbackEXT"));
        std.debug.assert(vkDestroyDebugReportCallbackEXT != null);
        vkDestroyDebugReportCallbackEXT.?(g_Instance, g_DebugReport, g_Allocator);
    }

    vk.DestroyDevice(g_Device, g_Allocator);
    vk.DestroyInstance(g_Instance, g_Allocator);
}

fn CleanupVulkanWindow() void {
    impl_vulkan.DestroyWindow(g_Instance, g_Device, &g_MainWindowData, g_Allocator);
}

fn FrameRender(wd: *impl_vulkan.Window) !void {
    const image_acquired_semaphore = wd.FrameSemaphores[wd.SemaphoreIndex].ImageAcquiredSemaphore;
    const render_complete_semaphore = wd.FrameSemaphores[wd.SemaphoreIndex].RenderCompleteSemaphore;
    wd.FrameIndex = (try vk.AcquireNextImageKHR(g_Device, wd.Swapchain, ~u64(0), image_acquired_semaphore, null)).imageIndex;

    const fd = &wd.Frames[wd.FrameIndex];
    {
        _ = try vk.WaitForFences(g_Device, arrayPtr(&fd.Fence), vk.TRUE, ~u64(0)); // wait indefinitely instead of periodically checking
        try vk.ResetFences(g_Device, arrayPtr(&fd.Fence));
    }
    {
        try vk.ResetCommandPool(g_Device, fd.CommandPool, 0);
        var info = vk.CommandBufferBeginInfo{
            .flags = vk.CommandBufferUsageFlagBits.ONE_TIME_SUBMIT_BIT,
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
            .pClearValues = arrayPtr(&wd.ClearValue),
        };
        vk.CmdBeginRenderPass(fd.CommandBuffer, info, .INLINE);
    }

    // Record Imgui Draw Data and draw funcs into command buffer
    impl_vulkan.RenderDrawData(imgui.GetDrawData(), fd.CommandBuffer);

    // Submit command buffer
    vk.CmdEndRenderPass(fd.CommandBuffer);
    {
        const wait_stage = vk.PipelineStageFlagBits.COLOR_ATTACHMENT_OUTPUT_BIT;
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
    const render_complete_semaphore = wd.FrameSemaphores[wd.SemaphoreIndex].RenderCompleteSemaphore;
    var info = vk.PresentInfoKHR{
        .waitSemaphoreCount = 1,
        .pWaitSemaphores = arrayPtr(&render_complete_semaphore),
        .swapchainCount = 1,
        .pSwapchains = arrayPtr(&wd.Swapchain),
        .pImageIndices = arrayPtr(&wd.FrameIndex),
    };
    _ = try vk.QueuePresentKHR(g_Queue, info);
    wd.SemaphoreIndex = (wd.SemaphoreIndex + 1) % wd.ImageCount; // Now we can use the next set of semaphores
}

extern fn glfw_error_callback(err: c_int, description: ?[*]const u8) void {
    std.debug.warn("Glfw Error {}: {}\n", err, description);
}

extern fn glfw_resize_callback(window: ?*glfw.GLFWwindow, w: c_int, h: c_int) void {
    g_SwapChainRebuild = true;
    g_SwapChainResizeWidth = @intCast(u32, w);
    g_SwapChainResizeHeight = @intCast(u32, h);
}

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    // Setup GLFW window
    _ = glfw.glfwSetErrorCallback(glfw_error_callback);
    if (glfw.glfwInit() == 0)
        return error.GlfwInitFailed;

    glfw.glfwWindowHint(glfw.GLFW_CLIENT_API, glfw.GLFW_NO_API);
    var window = glfw.glfwCreateWindow(1280, 720, c"Dear ImGui GLFW+Vulkan example", null, null).?;

    // Setup Vulkan
    if (glfw.glfwVulkanSupported() == 0) {
        std.debug.warn("GLFW: Vulkan Not Supported\n");
        return error.VulkanNotSupported;
    }
    var extensions_count: u32 = 0;
    var extensions = glfw.glfwGetRequiredInstanceExtensions(&extensions_count);
    try SetupVulkan(extensions[0..extensions_count], allocator);

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
    _ = glfw.glfwSetFramebufferSizeCallback(window, glfw_resize_callback);
    const wd = &g_MainWindowData;
    try SetupVulkanWindow(wd, surface, @intCast(u32, w), @intCast(u32, h));

    // Setup Dear ImGui context
    imgui.CHECKVERSION();
    _ = imgui.CreateContext(null);
    var io = imgui.GetIO();
    //io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls
    //io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls

    // Setup Dear ImGui style
    imgui.StyleColorsDark(null);
    //imgui.StyleColorsClassic(null);

    // Setup Platform/Renderer bindings
    var initResult = impl_glfw.InitForVulkan(window, true);
    std.debug.assert(initResult);
    var init_info = impl_vulkan.InitInfo{
        .Instance = g_Instance,
        .PhysicalDevice = g_PhysicalDevice,
        .Device = g_Device,
        .QueueFamily = g_QueueFamily,
        .Queue = g_Queue,
        .PipelineCache = g_PipelineCache,
        .DescriptorPool = g_DescriptorPool,
        .Allocator = g_Allocator,
        .MinImageCount = g_MinImageCount,
        .MSAASamples = 0,
        .ImageCount = wd.ImageCount,
    };
    impl_vulkan.Init(&init_info, wd.RenderPass);

    // Load Fonts
    // - If no fonts are loaded, dear imgui will use the default font. You can also load multiple fonts and use imgui.PushFont()/PopFont() to select them.
    // - AddFontFromFileTTF() will return the ImFont* so you can store it if you need to select the font among multiple.
    // - If the file cannot be loaded, the function will return NULL. Please handle those errors in your application (e.g. use an assertion, or display an error and quit).
    // - The fonts will be rasterized at a given size (w/ oversampling) and stored into a texture when calling ImFontAtlas::Build()/GetTexDataAsXXXX(), which ImGui_ImplXXXX_NewFrame below will call.
    // - Read 'docs/FONTS.txt' for more instructions and details.
    // - Remember that in C/C++ if you want to include a backslash \ in a string literal you need to write a double backslash \\ !
    //io.Fonts.AddFontDefault();
    //io.Fonts.AddFontFromFileTTF("../../misc/fonts/Roboto-Medium.ttf", 16.0f);
    //io.Fonts.AddFontFromFileTTF("../../misc/fonts/Cousine-Regular.ttf", 15.0f);
    //io.Fonts.AddFontFromFileTTF("../../misc/fonts/DroidSans.ttf", 16.0f);
    //io.Fonts.AddFontFromFileTTF("../../misc/fonts/ProggyTiny.ttf", 10.0f);
    //ImFont* font = io.Fonts.AddFontFromFileTTF("c:\\Windows\\Fonts\\ArialUni.ttf", 18.0f, NULL, io.Fonts.GetGlyphRangesJapanese());
    //std.debug.assert(font != NULL);

    // Upload Fonts
    {
        // Use any command queue
        const command_pool = wd.Frames[wd.FrameIndex].CommandPool;
        const command_buffer = wd.Frames[wd.FrameIndex].CommandBuffer;

        try vk.ResetCommandPool(g_Device, command_pool, 0);
        const begin_info = vk.CommandBufferBeginInfo{
            .flags = vk.CommandBufferUsageFlagBits.ONE_TIME_SUBMIT_BIT,
        };
        try vk.BeginCommandBuffer(command_buffer, begin_info);

        impl_vulkan.CreateFontsTexture(command_buffer);

        const end_info = vk.SubmitInfo{
            .commandBufferCount = 1,
            .pCommandBuffers = arrayPtr(&command_buffer),
        };
        try vk.EndCommandBuffer(command_buffer);
        try vk.QueueSubmit(g_Queue, arrayPtr(&end_info), null);

        try vk.DeviceWaitIdle(g_Device);
        impl_vulkan.DestroyFontUploadObjects();
    }

    // Our state
    var show_demo_window = true;
    var show_another_window = false;
    var clear_color = imgui.Vec4{ .x = 0.45, .y = 0.55, .z = 0.60, .w = 1.00 };
    var slider_value: f32 = 0;
    var counter: i32 = 0;

    // Main loop
    while (glfw.glfwWindowShouldClose(window) == 0) {
        // Poll and handle events (inputs, window resize, etc.)
        // You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
        // - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application.
        // - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application.
        // Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
        glfw.glfwPollEvents();

        if (g_SwapChainRebuild) {
            g_SwapChainRebuild = false;
            impl_vulkan.SetMinImageCount(g_MinImageCount);
            impl_vulkan.CreateWindow(g_Instance, g_PhysicalDevice, g_Device, &g_MainWindowData, g_QueueFamily, g_Allocator, g_SwapChainResizeWidth, g_SwapChainResizeHeight, g_MinImageCount);
            g_MainWindowData.FrameIndex = 0;
        }

        // Start the Dear ImGui frame
        impl_vulkan.NewFrame();
        impl_glfw.NewFrame();
        imgui.NewFrame();

        // 1. Show the big demo window (Most of the sample code is in imgui.ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
        if (show_demo_window)
            imgui.ShowDemoWindow(&show_demo_window);

        // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
        {
            _ = imgui.Begin(c"Hello, world!", null, 0); // Create a window called "Hello, world!" and append into it.

            imgui.Text(c"This is some useful text."); // Display some text (you can use a format strings too)
            _ = imgui.Checkbox(c"Demo Window", &show_demo_window); // Edit bools storing our window open/close state
            _ = imgui.Checkbox(c"Another Window", &show_another_window);

            _ = imgui.SliderFloat(c"float", &slider_value, 0.0, 1.0, null, 1); // Edit 1 float using a slider from 0.0 to 1.0
            _ = imgui.ColorEdit3(c"clear color", @ptrCast(*[3]f32, &clear_color), 0); // Edit 3 floats representing a color

            if (imgui.Button(c"Button", imgui.Vec2{.x = 0, .y = 0})) // Buttons return true when clicked (most widgets return true when edited/activated)
                counter += 1;
            imgui.SameLine(0, -1);
            imgui.Text(c"counter = %d", counter);

            imgui.Text(c"Application average %.3f ms/frame (%.1f FPS)", 1000.0 / imgui.GetIO().Framerate, imgui.GetIO().Framerate);
            imgui.End();
        }

        // 3. Show another simple window.
        if (show_another_window) {
            _ = imgui.Begin(c"Another Window", &show_another_window, 0); // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
            imgui.Text(c"Hello from another window!");
            if (imgui.Button(c"Close Me", imgui.Vec2{.x = 0, .y = 0}))
                show_another_window = false;
            imgui.End();
        }

        // Rendering
        imgui.Render();
        //std.mem.copy(f32, &wd.ClearValue.color.float32, @ptrCast(*[4]f32, &clear_color));
        try FrameRender(wd);

        try FramePresent(wd);
    }

    // Cleanup
    try vk.DeviceWaitIdle(g_Device);
    impl_vulkan.Shutdown();
    impl_glfw.Shutdown();
    imgui.DestroyContext(null);

    CleanupVulkanWindow();
    CleanupVulkan();

    glfw.glfwDestroyWindow(window);
    glfw.glfwTerminate();
}

// converts *T to *[1]T
fn arrayPtrType(comptime ptrType: type) type {
    const info = @typeInfo(ptrType);
    if (info.Pointer.is_const) {
        return *const[1] ptrType.Child;
    } else {
        return *[1]ptrType.Child;
    }
}

fn arrayPtr(ptr: var) arrayPtrType(@typeOf(ptr)) {
    return @ptrCast(arrayPtrType(@typeOf(ptr)), ptr);
}
