const std = @import("std");
const imgui = @import("imgui");
const glfw = @import("include/glfw.zig");

const GLFW_HAS_WINDOW_TOPMOST = (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3200); // 3.2+ GLFW_FLOATING
const GLFW_HAS_WINDOW_HOVERED = (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3300); // 3.3+ GLFW_HOVERED
const GLFW_HAS_WINDOW_ALPHA = (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3300); // 3.3+ glfwSetWindowOpacity
const GLFW_HAS_PER_MONITOR_DPI = (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3300); // 3.3+ glfwGetMonitorContentScale
const GLFW_HAS_VULKAN = (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3200); // 3.2+ glfwCreateWindowSurface
const GLFW_HAS_NEW_CURSORS = @hasDecl(glfw, "GLFW_RESIZE_NESW_CURSOR") and (GLFW_VERSION_MAJOR * 1000 + GLFW_VERSION_MINOR * 100 >= 3400); // 3.4+ GLFW_RESIZE_ALL_CURSOR, GLFW_RESIZE_NESW_CURSOR, GLFW_RESIZE_NWSE_CURSOR, GLFW_NOT_ALLOWED_CURSOR

const FLT_MAX = std.math.f32_max;

const GlfwClientApi = enum {
    Unknown,
    OpenGL,
    Vulkan,
};

var g_Window: ?*glfw.GLFWwindow = null;
var g_ClientApi = GlfwClientApi.Unknown;
var g_Time = f64(0.0);
var g_MouseJustPressed = [_]bool{ false, false, false, false, false };
var g_MouseCursors = [_]?*glfw.GLFWcursor{null} ** imgui.MouseCursor.COUNT;
var g_InstalledCallbacks = false;

// Chain GLFW callbacks: our callbacks will call the user's previously installed callbacks, if any.
var g_PrevUserCallbackMousebutton: glfw.GLFWmousebuttonfun = null;
var g_PrevUserCallbackScroll: glfw.GLFWscrollfun = null;
var g_PrevUserCallbackKey: glfw.GLFWkeyfun = null;
var g_PrevUserCallbackChar: glfw.GLFWcharfun = null;

pub fn InitForOpenGL(window: *glfw.GLFWwindow, install_callbacks: bool) bool {
    return Init(window, install_callbacks, .OpenGL);
}

pub fn InitForVulkan(window: *glfw.GLFWwindow, install_callbacks: bool) bool {
    return Init(window, install_callbacks, .Vulkan);
}

pub fn Shutdown() void {
    if (g_InstalledCallbacks) {
        _ = glfw.glfwSetMouseButtonCallback(g_Window, g_PrevUserCallbackMousebutton);
        _ = glfw.glfwSetScrollCallback(g_Window, g_PrevUserCallbackScroll);
        _ = glfw.glfwSetKeyCallback(g_Window, g_PrevUserCallbackKey);
        _ = glfw.glfwSetCharCallback(g_Window, g_PrevUserCallbackChar);
        g_InstalledCallbacks = false;
    }

    for (g_MouseCursors) |*cursor| {
        glfw.glfwDestroyCursor(cursor.*);
        cursor.* = null;
    }
    g_ClientApi = .Unknown;
}

pub fn NewFrame() void {
    const io = imgui.GetIO();
    // "Font atlas not built! It is generally built by the renderer back-end. Missing call to renderer _NewFrame() function? e.g. ImGui_ImplOpenGL3_NewFrame()."
    std.debug.assert(io.Fonts.IsBuilt());

    // Setup display size (every frame to accommodate for window resizing)
    var w: c_int = undefined;
    var h: c_int = undefined;
    var display_w: c_int = undefined;
    var display_h: c_int = undefined;
    glfw.glfwGetWindowSize(g_Window, &w, &h);
    glfw.glfwGetFramebufferSize(g_Window, &display_w, &display_h);
    io.DisplaySize = imgui.Vec2{ .x = @intToFloat(f32, w), .y = @intToFloat(f32, h) };
    if (w > 0 and h > 0)
        io.DisplayFramebufferScale = imgui.Vec2{ .x = @intToFloat(f32, display_w) / @intToFloat(f32, w), .y = @intToFloat(f32, display_h) / @intToFloat(f32, h) };

    // Setup time step
    const current_time = glfw.glfwGetTime();
    io.DeltaTime = if (g_Time > 0.0) @floatCast(f32, current_time - g_Time) else @floatCast(f32, 1.0 / 60.0);
    g_Time = current_time;

    UpdateMousePosAndButtons();
    UpdateMouseCursor();

    // Update game controllers (if enabled and available)
    UpdateGamepads();
}

fn Init(window: *glfw.GLFWwindow, install_callbacks: bool, client_api: GlfwClientApi) bool {
    g_Window = window;
    g_Time = 0.0;

    // Setup back-end capabilities flags
    var io = imgui.GetIO();
    io.BackendFlags |= imgui.BackendFlagBits.HasMouseCursors; // We can honor GetMouseCursor() values (optional)
    io.BackendFlags |= imgui.BackendFlagBits.HasSetMousePos; // We can honor io.WantSetMousePos requests (optional, rarely used)
    io.BackendPlatformName = c"imgui_impl_glfw";

    // Keyboard mapping. ImGui will use those indices to peek into the io.KeysDown[] array.
    io.KeyMap[@enumToInt(imgui.Key.Tab)] = glfw.GLFW_KEY_TAB;
    io.KeyMap[@enumToInt(imgui.Key.LeftArrow)] = glfw.GLFW_KEY_LEFT;
    io.KeyMap[@enumToInt(imgui.Key.RightArrow)] = glfw.GLFW_KEY_RIGHT;
    io.KeyMap[@enumToInt(imgui.Key.UpArrow)] = glfw.GLFW_KEY_UP;
    io.KeyMap[@enumToInt(imgui.Key.DownArrow)] = glfw.GLFW_KEY_DOWN;
    io.KeyMap[@enumToInt(imgui.Key.PageUp)] = glfw.GLFW_KEY_PAGE_UP;
    io.KeyMap[@enumToInt(imgui.Key.PageDown)] = glfw.GLFW_KEY_PAGE_DOWN;
    io.KeyMap[@enumToInt(imgui.Key.Home)] = glfw.GLFW_KEY_HOME;
    io.KeyMap[@enumToInt(imgui.Key.End)] = glfw.GLFW_KEY_END;
    io.KeyMap[@enumToInt(imgui.Key.Insert)] = glfw.GLFW_KEY_INSERT;
    io.KeyMap[@enumToInt(imgui.Key.Delete)] = glfw.GLFW_KEY_DELETE;
    io.KeyMap[@enumToInt(imgui.Key.Backspace)] = glfw.GLFW_KEY_BACKSPACE;
    io.KeyMap[@enumToInt(imgui.Key.Space)] = glfw.GLFW_KEY_SPACE;
    io.KeyMap[@enumToInt(imgui.Key.Enter)] = glfw.GLFW_KEY_ENTER;
    io.KeyMap[@enumToInt(imgui.Key.Escape)] = glfw.GLFW_KEY_ESCAPE;
    io.KeyMap[@enumToInt(imgui.Key.KeyPadEnter)] = glfw.GLFW_KEY_KP_ENTER;
    io.KeyMap[@enumToInt(imgui.Key.A)] = glfw.GLFW_KEY_A;
    io.KeyMap[@enumToInt(imgui.Key.C)] = glfw.GLFW_KEY_C;
    io.KeyMap[@enumToInt(imgui.Key.V)] = glfw.GLFW_KEY_V;
    io.KeyMap[@enumToInt(imgui.Key.X)] = glfw.GLFW_KEY_X;
    io.KeyMap[@enumToInt(imgui.Key.Y)] = glfw.GLFW_KEY_Y;
    io.KeyMap[@enumToInt(imgui.Key.Z)] = glfw.GLFW_KEY_Z;

    io.SetClipboardTextFn = @ptrCast(@typeOf(io.SetClipboardTextFn), SetClipboardText);
    io.GetClipboardTextFn = @ptrCast(@typeOf(io.GetClipboardTextFn), GetClipboardText);
    io.ClipboardUserData = g_Window;
    if (std.os.windows.is_the_target) {
        io.ImeWindowHandle = glfw.glfwGetWin32Window(g_Window);
    }

    // Create mouse cursors
    // (By design, on X11 cursors are user configurable and some cursors may be missing. When a cursor doesn't exist,
    // GLFW will emit an error which will often be printed by the app, so we temporarily disable error reporting.
    // Missing cursors will return NULL and our _UpdateMouseCursor() function will use the Arrow cursor instead.)
    const prev_error_callback = glfw.glfwSetErrorCallback(null);
    g_MouseCursors[@enumToInt(imgui.MouseCursor.Arrow)] = glfw.glfwCreateStandardCursor(glfw.GLFW_ARROW_CURSOR);
    g_MouseCursors[@enumToInt(imgui.MouseCursor.TextInput)] = glfw.glfwCreateStandardCursor(glfw.GLFW_IBEAM_CURSOR);
    g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeNS)] = glfw.glfwCreateStandardCursor(glfw.GLFW_VRESIZE_CURSOR);
    g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeEW)] = glfw.glfwCreateStandardCursor(glfw.GLFW_HRESIZE_CURSOR);
    g_MouseCursors[@enumToInt(imgui.MouseCursor.Hand)] = glfw.glfwCreateStandardCursor(glfw.GLFW_HAND_CURSOR);
    if (GLFW_HAS_NEW_CURSORS) {
        g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeAll)] = glfw.glfwCreateStandardCursor(glfw.GLFW_RESIZE_ALL_CURSOR);
        g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeNESW)] = glfw.glfwCreateStandardCursor(glfw.GLFW_RESIZE_NESW_CURSOR);
        g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeNWSE)] = glfw.glfwCreateStandardCursor(glfw.GLFW_RESIZE_NWSE_CURSOR);
        g_MouseCursors[@enumToInt(imgui.MouseCursor.NotAllowed)] = glfw.glfwCreateStandardCursor(glfw.GLFW_NOT_ALLOWED_CURSOR);
    } else {
        g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeAll)] = glfw.glfwCreateStandardCursor(glfw.GLFW_ARROW_CURSOR);
        g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeNESW)] = glfw.glfwCreateStandardCursor(glfw.GLFW_ARROW_CURSOR);
        g_MouseCursors[@enumToInt(imgui.MouseCursor.ResizeNWSE)] = glfw.glfwCreateStandardCursor(glfw.GLFW_ARROW_CURSOR);
        g_MouseCursors[@enumToInt(imgui.MouseCursor.NotAllowed)] = glfw.glfwCreateStandardCursor(glfw.GLFW_ARROW_CURSOR);
    }
    _ = glfw.glfwSetErrorCallback(prev_error_callback);

    // Chain GLFW callbacks: our callbacks will call the user's previously installed callbacks, if any.
    g_PrevUserCallbackMousebutton = null;
    g_PrevUserCallbackScroll = null;
    g_PrevUserCallbackKey = null;
    g_PrevUserCallbackChar = null;
    if (install_callbacks) {
        g_InstalledCallbacks = true;
        g_PrevUserCallbackMousebutton = glfw.glfwSetMouseButtonCallback(window, MouseButtonCallback);
        g_PrevUserCallbackScroll = glfw.glfwSetScrollCallback(window, ScrollCallback);
        g_PrevUserCallbackKey = glfw.glfwSetKeyCallback(window, KeyCallback);
        g_PrevUserCallbackChar = glfw.glfwSetCharCallback(window, CharCallback);
    }

    g_ClientApi = client_api;
    return true;
}

fn UpdateMousePosAndButtons() void {
    // Update buttons
    var io = imgui.GetIO();
    for (io.MouseDown) |*down, i| {
        // If a mouse press event came, always pass it as "mouse held this frame", so we don't miss click-release events that are shorter than 1 frame.
        down.* = g_MouseJustPressed[i] or glfw.glfwGetMouseButton(g_Window, @intCast(c_int, i)) != 0;
        g_MouseJustPressed[i] = false;
    }

    // Update mouse position
    const mouse_pos_backup = io.MousePos;
    io.MousePos = imgui.Vec2{ .x = -FLT_MAX, .y = -FLT_MAX };
    const focused = glfw.glfwGetWindowAttrib(g_Window, glfw.GLFW_FOCUSED) != 0;
    if (focused) {
        if (io.WantSetMousePos) {
            glfw.glfwSetCursorPos(g_Window, @floatCast(f64, mouse_pos_backup.x), @floatCast(f64, mouse_pos_backup.y));
        } else {
            var mouse_x: f64 = undefined;
            var mouse_y: f64 = undefined;
            glfw.glfwGetCursorPos(g_Window, &mouse_x, &mouse_y);
            io.MousePos = imgui.Vec2{ .x = @floatCast(f32, mouse_x), .y = @floatCast(f32, mouse_y) };
        }
    }
}

fn UpdateMouseCursor() void {
    const io = imgui.GetIO();
    if ((io.ConfigFlags & imgui.ConfigFlagBits.NoMouseCursorChange) != 0 or glfw.glfwGetInputMode(g_Window, glfw.GLFW_CURSOR) == glfw.GLFW_CURSOR_DISABLED)
        return;

    var imgui_cursor = imgui.GetMouseCursor();
    if (imgui_cursor == .None or io.MouseDrawCursor) {
        // Hide OS mouse cursor if imgui is drawing it or if it wants no cursor
        glfw.glfwSetInputMode(g_Window, glfw.GLFW_CURSOR, glfw.GLFW_CURSOR_HIDDEN);
    } else {
        // Show OS mouse cursor
        // FIXME-PLATFORM: Unfocused windows seems to fail changing the mouse cursor with GLFW 3.2, but 3.3 works here.
        glfw.glfwSetCursor(g_Window, if (g_MouseCursors[@intCast(u32, @enumToInt(imgui_cursor))]) |cursor| cursor else g_MouseCursors[@intCast(u32, @enumToInt(imgui.MouseCursor.Arrow))]);
        glfw.glfwSetInputMode(g_Window, glfw.GLFW_CURSOR, glfw.GLFW_CURSOR_NORMAL);
    }
}

fn MAP_BUTTON(io: *imgui.IO, buttons: []const u8, NAV_NO: imgui.NavInput, BUTTON_NO: u32) void {
    if (buttons.len > BUTTON_NO and buttons[BUTTON_NO] == glfw.GLFW_PRESS)
        io.NavInputs[@intCast(u32, @enumToInt(NAV_NO))] = 1.0;
}

fn MAP_ANALOG(io: *imgui.IO, axes: []const f32, NAV_NO: imgui.NavInput, AXIS_NO: u32, V0: f32, V1: f32) void {
    var v = if (axes.len > AXIS_NO) axes[AXIS_NO] else V0;
    v = (v - V0) / (V1 - V0);
    if (v > 1.0) v = 1.0;
    if (io.NavInputs[@intCast(u32, @enumToInt(NAV_NO))] < v)
        io.NavInputs[@intCast(u32, @enumToInt(NAV_NO))] = v;
}

fn UpdateGamepads() void {
    const io = imgui.GetIO();
    std.mem.set(f32, &io.NavInputs, 0);
    if ((io.ConfigFlags & imgui.ConfigFlagBits.NavEnableGamepad) == 0)
        return;

    // Update gamepad inputs
    var axes_count: c_int = 0;
    var buttons_count: c_int = 0;
    const axesRaw = glfw.glfwGetJoystickAxes(glfw.GLFW_JOYSTICK_1, &axes_count);
    const buttonsRaw = glfw.glfwGetJoystickButtons(glfw.GLFW_JOYSTICK_1, &buttons_count);
    const axes = axesRaw.?[0..@intCast(u32, axes_count)];
    const buttons = buttonsRaw.?[0..@intCast(u32, buttons_count)];
    MAP_BUTTON(io, buttons, .Activate, 0); // Cross / A
    MAP_BUTTON(io, buttons, .Cancel, 1); // Circle / B
    MAP_BUTTON(io, buttons, .Menu, 2); // Square / X
    MAP_BUTTON(io, buttons, .Input, 3); // Triangle / Y
    MAP_BUTTON(io, buttons, .DpadLeft, 13); // D-Pad Left
    MAP_BUTTON(io, buttons, .DpadRight, 11); // D-Pad Right
    MAP_BUTTON(io, buttons, .DpadUp, 10); // D-Pad Up
    MAP_BUTTON(io, buttons, .DpadDown, 12); // D-Pad Down
    MAP_BUTTON(io, buttons, .FocusPrev, 4); // L1 / LB
    MAP_BUTTON(io, buttons, .FocusNext, 5); // R1 / RB
    MAP_BUTTON(io, buttons, .TweakSlow, 4); // L1 / LB
    MAP_BUTTON(io, buttons, .TweakFast, 5); // R1 / RB
    MAP_ANALOG(io, axes, .LStickLeft, 0, -0.3, -0.9);
    MAP_ANALOG(io, axes, .LStickRight, 0, 0.3, 0.9);
    MAP_ANALOG(io, axes, .LStickUp, 1, 0.3, 0.9);
    MAP_ANALOG(io, axes, .LStickDown, 1, -0.3, -0.9);
    if (axes_count > 0 and buttons_count > 0) {
        io.BackendFlags |= imgui.BackendFlagBits.HasGamepad;
    } else {
        io.BackendFlags &= ~imgui.BackendFlagBits.HasGamepad;
    }
}

extern fn GetClipboardText(user_data: ?*c_void) ?[*]const u8 {
    return glfw.glfwGetClipboardString(@ptrCast(?*glfw.GLFWwindow, user_data));
}

extern fn SetClipboardText(user_data: ?*c_void, text: ?[*]const u8) void {
    glfw.glfwSetClipboardString(@ptrCast(?*glfw.GLFWwindow, user_data), text);
}

extern fn MouseButtonCallback(window: ?*glfw.GLFWwindow, button: c_int, action: c_int, mods: c_int) void {
    if (g_PrevUserCallbackMousebutton) |fnPtr| {
        fnPtr(window, button, action, mods);
    }

    if (action == glfw.GLFW_PRESS and button >= 0 and @intCast(usize, button) < g_MouseJustPressed.len)
        g_MouseJustPressed[@intCast(usize, button)] = true;
}

extern fn ScrollCallback(window: ?*glfw.GLFWwindow, xoffset: f64, yoffset: f64) void {
    if (g_PrevUserCallbackScroll) |fnPtr| {
        fnPtr(window, xoffset, yoffset);
    }

    const io = imgui.GetIO();
    io.MouseWheelH += @floatCast(f32, xoffset);
    io.MouseWheel += @floatCast(f32, yoffset);
}

extern fn KeyCallback(window: ?*glfw.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) void {
    if (g_PrevUserCallbackKey) |fnPtr| {
        fnPtr(window, key, scancode, action, mods);
    }

    const io = imgui.GetIO();
    if (action == glfw.GLFW_PRESS)
        io.KeysDown[@intCast(usize, key)] = true;
    if (action == glfw.GLFW_RELEASE)
        io.KeysDown[@intCast(usize, key)] = false;

    // Modifiers are not reliable across systems
    io.KeyCtrl = io.KeysDown[glfw.GLFW_KEY_LEFT_CONTROL] or io.KeysDown[glfw.GLFW_KEY_RIGHT_CONTROL];
    io.KeyShift = io.KeysDown[glfw.GLFW_KEY_LEFT_SHIFT] or io.KeysDown[glfw.GLFW_KEY_RIGHT_SHIFT];
    io.KeyAlt = io.KeysDown[glfw.GLFW_KEY_LEFT_ALT] or io.KeysDown[glfw.GLFW_KEY_RIGHT_ALT];
    if (std.os.windows.is_the_target) {
        io.KeySuper = false;
    } else {
        io.KeySuper = io.KeysDown[glfw.GLFW_KEY_LEFT_SUPER] or io.KeysDown[glfw.GLFW_KEY_RIGHT_SUPER];
    }
}

extern fn CharCallback(window: ?*glfw.GLFWwindow, c: c_uint) void {
    if (g_PrevUserCallbackChar) |fnPtr| {
        fnPtr(window, c);
    }

    var io = imgui.GetIO();
    io.AddInputCharacter(c);
}
