// dear imgui: standalone example application for GLFW + OpenGL 3, using programmable pipeline
// If you are new to dear imgui, see examples/README.txt and documentation at the top of imgui.cpp.
// (GLFW is a cross-platform general purpose library for handling windows, inputs, OpenGL/Vulkan graphics context creation, etc.)

const std = @import("std");
const builtin = @import("builtin");

const sdl = @import("sdl2");
const imgui = @import("imgui");

const impl_sdl = @import("imgui_impl_sdl.zig");
const impl_gl3 = @import("imgui_impl_opengl3.zig");

const gl = @import("include/gl.zig");

fn sdlPanic() noreturn {
    const str = @as(?[*:0]const u8, sdl.SDL_GetError()) orelse "unknown error";
    @panic(std.mem.sliceTo(str, 0));
}

pub fn main() !void {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO | sdl.SDL_INIT_TIMER | sdl.SDL_INIT_GAMECONTROLLER) < 0) sdlPanic();

    defer sdl.SDL_Quit();

    // Decide GL+GLSL versions
    var glsl_version = "#version 100";
    if (@hasDecl(sdl, "IMGUI_IMPL_OPENGL_ES2")) {
        // GL ES 2.0 + GLSL 100
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_FLAGS, 0);
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_PROFILE_MASK, sdl.SDL_GL_CONTEXT_PROFILE_ES);
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MAJOR_VERSION, 2);
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MINOR_VERSION, 0);
    } else if (builtin.os.tag.isDarwin()) {
        // GL 3.2 Core + GLSL 150
        glsl_version = "#version 150";
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_FLAGS, sdl.SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG); // Always required on Mac
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_PROFILE_MASK, sdl.SDL_GL_CONTEXT_PROFILE_CORE);
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MAJOR_VERSION, 3);
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MINOR_VERSION, 2);
    } else {
        // GL 3.0 + GLSL 130
        glsl_version = "#version 130";
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_FLAGS, 0);
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_PROFILE_MASK, sdl.SDL_GL_CONTEXT_PROFILE_CORE);
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MAJOR_VERSION, 3);
        _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MINOR_VERSION, 0);
    }

    // Create window with graphics context
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_DOUBLEBUFFER, 1);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_DEPTH_SIZE, 24);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_STENCIL_SIZE, 8);

    const window_flags = (sdl.SDL_WINDOW_OPENGL | sdl.SDL_WINDOW_RESIZABLE | sdl.SDL_WINDOW_ALLOW_HIGHDPI);
    const window = sdl.SDL_CreateWindow("Dear ImGui SDL2+OpenGL3 example", sdl.SDL_WINDOWPOS_CENTERED, sdl.SDL_WINDOWPOS_CENTERED, 1280, 720, window_flags) orelse sdlPanic();
    const gl_context = sdl.SDL_GL_CreateContext(window);

    _ = sdl.SDL_GL_MakeCurrent(window, gl_context);
    _ = sdl.SDL_GL_SetSwapInterval(1); // Enable vsync

    // Initialize OpenGL loader
    if (gl.gladLoadGL() == 0) return error.GladLoadGLFailed;

    // Setup Dear ImGui context
    imgui.CHECKVERSION();
    _ = imgui.CreateContext();
    const io = imgui.GetIO();
    //io.ConfigFlags |= imgui.ConfigFlags.NavEnableKeyboard;     // Enable Keyboard Controls
    //io.ConfigFlags |= imgui.ConfigFlags.NavEnableGamepad;      // Enable Gamepad Controls

    // Setup Dear ImGui style
    imgui.StyleColorsDark();
    //imgui.StyleColorsClassic();

    // Setup Platform/Renderer bindings
    _ = impl_sdl.InitForOpenGL(window, gl_context);
    _ = impl_gl3.Init(glsl_version);

    // Load Fonts
    // - If no fonts are loaded, dear imgui will use the default font. You can also load multiple fonts and use ImGui::PushFont()/PopFont() to select them.
    // - AddFontFromFileTTF() will return the ImFont* so you can store it if you need to select the font among multiple.
    // - If the file cannot be loaded, the function will return NULL. Please handle those errors in your application (e.g. use an assertion, or display an error and quit).
    // - The fonts will be rasterized at a given size (w/ oversampling) and stored into a texture when calling ImFontAtlas::Build()/GetTexDataAsXXXX(), which ImGui_ImplXXXX_NewFrame below will call.
    // - Read 'docs/FONTS.txt' for more instructions and details.
    // - Remember that in C/C++ if you want to include a backslash \ in a string literal you need to write a double backslash \\ !
    //io.Fonts.AddFontDefault();
    //io.Fonts.AddFontFromFileTTF("../../misc/fonts/Roboto-Medium.ttf", 16.0);
    //io.Fonts.AddFontFromFileTTF("../../misc/fonts/Cousine-Regular.ttf", 15.0);
    //io.Fonts.AddFontFromFileTTF("../../misc/fonts/DroidSans.ttf", 16.0);
    //io.Fonts.AddFontFromFileTTF("../../misc/fonts/ProggyTiny.ttf", 10.0);
    //ImFont* font = io.Fonts.AddFontFromFileTTF("c:\\Windows\\Fonts\\ArialUni.ttf", 18.0, null, io.Fonts->GetGlyphRangesJapanese());
    //IM_ASSERT(font != NULL);

    // Our state
    var show_demo_window = true;
    var show_another_window = false;
    var clear_color = imgui.Vec4{ .x = 0.45, .y = 0.55, .z = 0.60, .w = 1.00 };
    var slider_value: f32 = 0;
    var counter: i32 = 0;

    // Main loop
    mainLoop: while (true) {
        // Poll and handle events (inputs, window resize, etc.)
        // You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
        // - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application, or clear/overwrite your copy of the mouse data.
        // - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application, or clear/overwrite your copy of the keyboard data.
        // Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.

        var ev: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&ev) != 0) {
            _ = impl_sdl.ProcessEvent(&ev);

            if (ev.type == sdl.SDL_QUIT) {
                break :mainLoop;
            } else if (ev.type == sdl.SDL_WINDOWEVENT and ev.window.event == sdl.SDL_WINDOWEVENT_CLOSE and ev.window.windowID == sdl.SDL_GetWindowID(window)) {
                break :mainLoop;
            } else if (ev.type == sdl.SDL_KEYDOWN) {
                switch (ev.key.keysym.sym) {
                    sdl.SDLK_ESCAPE => break :mainLoop,
                    sdl.SDLK_UP, sdl.SDLK_w => std.log.info("UP", .{}),
                    sdl.SDLK_DOWN, sdl.SDLK_s => std.log.info("DOWN", .{}),

                    sdl.SDLK_LEFT, sdl.SDLK_a => std.log.info("LEFT", .{}),
                    sdl.SDLK_RIGHT, sdl.SDLK_d => std.log.info("RIGHT", .{}),

                    else => {},
                }
            }
        }

        // Start the Dear ImGui frame
        impl_gl3.NewFrame();
        impl_sdl.NewFrame();
        imgui.NewFrame();

        // 1. Show the big demo window (Most of the sample code is in imgui.ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
        if (show_demo_window) imgui.ShowDemoWindowExt(&show_demo_window);

        // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
        {
            _ = imgui.Begin("Hello, world!"); // Create a window called "Hello, world!" and append into it.

            imgui.Text("This is some useful text."); // Display some text (you can use a format strings too)
            _ = imgui.Checkbox("Demo Window", &show_demo_window); // Edit bools storing our window open/close state
            _ = imgui.Checkbox("Another Window", &show_another_window);

            _ = imgui.SliderFloat("float", &slider_value, 0.0, 1.0); // Edit 1 float using a slider from 0.0 to 1.0
            _ = imgui.ColorEdit3("clear color", @ptrCast(*[3]f32, &clear_color)); // Edit 3 floats representing a color

            if (imgui.Button("Button")) counter += 1; // Buttons return true when clicked (most widgets return true when edited/activated)
            imgui.SameLine();
            imgui.Text("counter = %d", counter);

            imgui.Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0 / imgui.GetIO().Framerate, imgui.GetIO().Framerate);
            imgui.End();
        }

        // 3. Show another simple window.
        if (show_another_window) {
            _ = imgui.BeginExt("Another Window", &show_another_window, .{}); // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
            imgui.Text("Hello from another window!");
            if (imgui.Button("Close Me")) show_another_window = false;
            imgui.End();
        }

        // Rendering
        imgui.Render();
        gl.glViewport(0, 0, @floatToInt(c_int, io.DisplaySize.x), @floatToInt(c_int, io.DisplaySize.y));
        gl.glClearColor(
            clear_color.x * clear_color.w,
            clear_color.y * clear_color.w,
            clear_color.z * clear_color.w,
            clear_color.w,
        );
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);

        impl_gl3.RenderDrawData(imgui.GetDrawData());
        sdl.SDL_GL_SwapWindow(window);
    }

    // Cleanup
    impl_gl3.Shutdown();
    impl_sdl.Shutdown();
    imgui.DestroyContext();

    sdl.SDL_GL_DeleteContext(gl_context);
    sdl.SDL_DestroyWindow(window);
    sdl.SDL_Quit();
}
