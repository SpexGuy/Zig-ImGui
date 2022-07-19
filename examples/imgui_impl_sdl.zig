const std = @import("std");
const imgui = @import("imgui");
const sdl = @import("sdl2");
const builtin = @import("builtin");

const assert = std.debug.assert;
const is_darwin = builtin.os.tag.isDarwin();

const Data = extern struct {
    Window: ?*sdl.SDL_Window = null,
    Renderer: ?*sdl.SDL_Renderer = null,
    Time: u64,
    MouseCursors: [imgui.MouseCursor.COUNT]?*sdl.SDL_Cursor = [_]?*sdl.SDL_Cursor{null} ** imgui.MouseCursor.COUNT,
    MouseButtonsDown: i32 = 0,
    PendingMouseLeaveFrame: i32 = 0,
    MouseCanUseGlobalState: bool = false,
    ClipboardTextData: ?[*:0]const u8 = null,
};

// Backend data stored in io.BackendPlatformUserData to allow support for multiple Dear ImGui contexts
// It is STRONGLY preferred that you use docking branch with multi-viewports (== single Dear ImGui context + multiple windows) instead of multiple Dear ImGui contexts.
// FIXME: multi-context support is not well tested and probably dysfunctional in this backend.
// FIXME: some shared resources (mouse cursor shape, gamepad) are mishandled when using multi-context.
fn GetBackendData() ?*Data {
    return if (imgui.GetCurrentContext() != null) @ptrCast(?*Data, @alignCast(@alignOf(Data), imgui.GetIO().BackendPlatformUserData)) else null;
}

// Functions
fn GetClipboardText(_: ?*anyopaque) callconv(.C) ?[*:0]const u8 {
    const bd = GetBackendData().?;
    if (bd.ClipboardTextData) |data| sdl.SDL_free(data);

    bd.ClipboardTextData = sdl.SDL_GetClipboardText();
    return bd.ClipboardTextData;
}

fn SetClipboardText(_: ?*anyopaque, text: ?[*:0]const u8) callconv(.C) void {
    _ = sdl.SDL_SetClipboardText(text.?);
}

fn SDLKeyToImGuiKey(key: i32) imgui.Key {
    return switch (key) {
        sdl.SDLK_TAB => .Tab,
        sdl.SDLK_LEFT => .LeftArrow,
        sdl.SDLK_RIGHT => .RightArrow,
        sdl.SDLK_UP => .UpArrow,
        sdl.SDLK_DOWN => .DownArrow,
        sdl.SDLK_PAGEUP => .PageUp,
        sdl.SDLK_PAGEDOWN => .PageDown,
        sdl.SDLK_HOME => .Home,
        sdl.SDLK_END => .End,
        sdl.SDLK_INSERT => .Insert,
        sdl.SDLK_DELETE => .Delete,
        sdl.SDLK_BACKSPACE => .Backspace,
        sdl.SDLK_SPACE => .Space,
        sdl.SDLK_RETURN => .Enter,
        sdl.SDLK_ESCAPE => .Escape,
        sdl.SDLK_QUOTE => .Apostrophe,
        sdl.SDLK_COMMA => .Comma,
        sdl.SDLK_MINUS => .Minus,
        sdl.SDLK_PERIOD => .Period,
        sdl.SDLK_SLASH => .Slash,
        sdl.SDLK_SEMICOLON => .Semicolon,
        sdl.SDLK_EQUALS => .Equal,
        sdl.SDLK_LEFTBRACKET => .LeftBracket,
        sdl.SDLK_BACKSLASH => .Backslash,
        sdl.SDLK_RIGHTBRACKET => .RightBracket,
        sdl.SDLK_BACKQUOTE => .GraveAccent,
        sdl.SDLK_CAPSLOCK => .CapsLock,
        sdl.SDLK_SCROLLLOCK => .ScrollLock,
        sdl.SDLK_NUMLOCKCLEAR => .NumLock,
        sdl.SDLK_PRINTSCREEN => .PrintScreen,
        sdl.SDLK_PAUSE => .Pause,
        sdl.SDLK_KP_0 => .Keypad0,
        sdl.SDLK_KP_1 => .Keypad1,
        sdl.SDLK_KP_2 => .Keypad2,
        sdl.SDLK_KP_3 => .Keypad3,
        sdl.SDLK_KP_4 => .Keypad4,
        sdl.SDLK_KP_5 => .Keypad5,
        sdl.SDLK_KP_6 => .Keypad6,
        sdl.SDLK_KP_7 => .Keypad7,
        sdl.SDLK_KP_8 => .Keypad8,
        sdl.SDLK_KP_9 => .Keypad9,
        sdl.SDLK_KP_PERIOD => .KeypadDecimal,
        sdl.SDLK_KP_DIVIDE => .KeypadDivide,
        sdl.SDLK_KP_MULTIPLY => .KeypadMultiply,
        sdl.SDLK_KP_MINUS => .KeypadSubtract,
        sdl.SDLK_KP_PLUS => .KeypadAdd,
        sdl.SDLK_KP_ENTER => .KeypadEnter,
        sdl.SDLK_KP_EQUALS => .KeypadEqual,
        sdl.SDLK_LCTRL => .LeftCtrl,
        sdl.SDLK_LSHIFT => .LeftShift,
        sdl.SDLK_LALT => .LeftAlt,
        sdl.SDLK_LGUI => .LeftSuper,
        sdl.SDLK_RCTRL => .RightCtrl,
        sdl.SDLK_RSHIFT => .RightShift,
        sdl.SDLK_RALT => .RightAlt,
        sdl.SDLK_RGUI => .RightSuper,
        sdl.SDLK_APPLICATION => .Menu,
        sdl.SDLK_0 => .@"0",
        sdl.SDLK_1 => .@"1",
        sdl.SDLK_2 => .@"2",
        sdl.SDLK_3 => .@"3",
        sdl.SDLK_4 => .@"4",
        sdl.SDLK_5 => .@"5",
        sdl.SDLK_6 => .@"6",
        sdl.SDLK_7 => .@"7",
        sdl.SDLK_8 => .@"8",
        sdl.SDLK_9 => .@"9",
        sdl.SDLK_a => .A,
        sdl.SDLK_b => .B,
        sdl.SDLK_c => .C,
        sdl.SDLK_d => .D,
        sdl.SDLK_e => .E,
        sdl.SDLK_f => .F,
        sdl.SDLK_g => .G,
        sdl.SDLK_h => .H,
        sdl.SDLK_i => .I,
        sdl.SDLK_j => .J,
        sdl.SDLK_k => .K,
        sdl.SDLK_l => .L,
        sdl.SDLK_m => .M,
        sdl.SDLK_n => .N,
        sdl.SDLK_o => .O,
        sdl.SDLK_p => .P,
        sdl.SDLK_q => .Q,
        sdl.SDLK_r => .R,
        sdl.SDLK_s => .S,
        sdl.SDLK_t => .T,
        sdl.SDLK_u => .U,
        sdl.SDLK_v => .V,
        sdl.SDLK_w => .W,
        sdl.SDLK_x => .X,
        sdl.SDLK_y => .Y,
        sdl.SDLK_z => .Z,
        sdl.SDLK_F1 => .F1,
        sdl.SDLK_F2 => .F2,
        sdl.SDLK_F3 => .F3,
        sdl.SDLK_F4 => .F4,
        sdl.SDLK_F5 => .F5,
        sdl.SDLK_F6 => .F6,
        sdl.SDLK_F7 => .F7,
        sdl.SDLK_F8 => .F8,
        sdl.SDLK_F9 => .F9,
        sdl.SDLK_F10 => .F10,
        sdl.SDLK_F11 => .F11,
        sdl.SDLK_F12 => .F12,
        else => .None,
    };
}

fn UpdateKeyModifiers(sdl_key_mods: sdl.SDL_Keymod) void {
    const io = imgui.GetIO();
    io.AddKeyEvent(.ModCtrl, sdl_key_mods & sdl.KMOD_CTRL != 0);
    io.AddKeyEvent(.ModShift, sdl_key_mods & sdl.KMOD_SHIFT != 0);
    io.AddKeyEvent(.ModAlt, sdl_key_mods & sdl.KMOD_ALT != 0);
    io.AddKeyEvent(.ModSuper, sdl_key_mods & sdl.KMOD_GUI != 0);
}

fn UpdateMouseData() void {
    const bd = GetBackendData().?;
    const io = imgui.GetIO();

    var is_app_focused = sdl.SDL_GetWindowFlags(bd.Window) & (if (@hasDecl(sdl, "SDL_WINDOW_INPUT_FOCUS")) 1 else 0) != 0;
    if (@hasDecl(sdl, "SDL_HAS_CAPTURE_AND_GLOBAL_MOUSE")) {
        _ = sdl.SDL_CaptureMouse(if (bd.MouseButtonsDown != 0) sdl.SDL_TRUE else sdl.SDL_FALSE);
        const focused_window = sdl.SDL_GetKeyboardFocus().?;
        is_app_focused = std.mem.eql(bd.Window.?, focused_window);
    }

    if (is_app_focused) {
        // (Optional) Set OS mouse position from Dear ImGui if requested (rarely used, only when ImGuiConfigFlags_NavEnableSetMousePos is enabled by user)
        if (io.WantSetMousePos) sdl.SDL_WarpMouseInWindow(bd.Window, @floatToInt(c_int, io.MousePos.x), @floatToInt(c_int, io.MousePos.y));

        // (Optional) Fallback to provide mouse position when focused (SDL_MOUSEMOTION already provides this when hovered or captured)
        if (bd.MouseCanUseGlobalState and bd.MouseButtonsDown == 0) {
            var window_x: c_int = 0;
            var window_y: c_int = 0;
            var mouse_x_global: c_int = 0;
            var mouse_y_global: c_int = 0;
            _ = sdl.SDL_GetGlobalMouseState(&mouse_x_global, &mouse_y_global);
            sdl.SDL_GetWindowPosition(bd.Window.?, &window_x, &window_y);
            io.AddMousePosEvent(@intToFloat(f32, mouse_x_global - window_x), @intToFloat(f32, mouse_y_global - window_y));
        }
    }
}

fn UpdateMouseCursor() void {
    const bd = GetBackendData().?;
    const io = imgui.GetIO();
    // if (imgui.ConfigFlags.NoMouseCursorChange) return;

    const imgui_cursor = imgui.GetMouseCursor();
    if (imgui_cursor == .None or io.MouseDrawCursor) {
        // Hide OS mouse cursor if imgui is drawing it or if it wants no cursor
        _ = sdl.SDL_ShowCursor(sdl.SDL_FALSE);
    } else {
        // Show OS mouse cursor
        _ = sdl.SDL_SetCursor(bd.MouseCursors[@intCast(usize, @enumToInt(imgui_cursor))] orelse bd.MouseCursors[@intCast(usize, @enumToInt(imgui.MouseCursor.Arrow))]);
        _ = sdl.SDL_ShowCursor(sdl.SDL_TRUE);
    }
}

// Update gamepad inputs
inline fn Saturate(v: f32) f32 {
    return if (v < 0) 0 else if (v > 1) 1 else v;
}

fn UpdateGamepads() void {
    const io = imgui.GetIO();
    // if (imgui.ConfigFlags.NavEnableGamepad) return;

    const thumb_dead_zone = 8000;
    const InputKind = enum { Button, Analog };
    const Mapping = struct { kind: InputKind, key: imgui.Key, btn: c_int, low: f32 = 0, high: f32 = 0 };
    const mappings = [_]Mapping{
        .{ .kind = .Button, .key = .GamepadStart, .btn = sdl.SDL_CONTROLLER_BUTTON_START },
        .{ .kind = .Button, .key = .GamepadBack, .btn = sdl.SDL_CONTROLLER_BUTTON_BACK },
        .{ .kind = .Button, .key = .GamepadFaceDown, .btn = sdl.SDL_CONTROLLER_BUTTON_A }, // Xbox A, PS Cross
        .{ .kind = .Button, .key = .GamepadFaceRight, .btn = sdl.SDL_CONTROLLER_BUTTON_B }, // Xbox B, PS Circle
        .{ .kind = .Button, .key = .GamepadFaceLeft, .btn = sdl.SDL_CONTROLLER_BUTTON_X }, // Xbox X, PS Square
        .{ .kind = .Button, .key = .GamepadFaceUp, .btn = sdl.SDL_CONTROLLER_BUTTON_Y }, // Xbox Y, PS Triangle
        .{ .kind = .Button, .key = .GamepadDpadLeft, .btn = sdl.SDL_CONTROLLER_BUTTON_DPAD_LEFT },
        .{ .kind = .Button, .key = .GamepadDpadRight, .btn = sdl.SDL_CONTROLLER_BUTTON_DPAD_RIGHT },
        .{ .kind = .Button, .key = .GamepadDpadUp, .btn = sdl.SDL_CONTROLLER_BUTTON_DPAD_UP },
        .{ .kind = .Button, .key = .GamepadDpadDown, .btn = sdl.SDL_CONTROLLER_BUTTON_DPAD_DOWN },
        .{ .kind = .Button, .key = .GamepadL1, .btn = sdl.SDL_CONTROLLER_BUTTON_LEFTSHOULDER },
        .{ .kind = .Button, .key = .GamepadR1, .btn = sdl.SDL_CONTROLLER_BUTTON_RIGHTSHOULDER },
        .{ .kind = .Analog, .key = .GamepadL2, .btn = sdl.SDL_CONTROLLER_AXIS_TRIGGERLEFT, .low = 0, .high = 32767 },
        .{ .kind = .Analog, .key = .GamepadR2, .btn = sdl.SDL_CONTROLLER_AXIS_TRIGGERLEFT, .low = 0, .high = 32767 },
        .{ .kind = .Button, .key = .GamepadL3, .btn = sdl.SDL_CONTROLLER_BUTTON_LEFTSTICK },
        .{ .kind = .Button, .key = .GamepadR3, .btn = sdl.SDL_CONTROLLER_BUTTON_RIGHTSTICK },
        .{ .kind = .Analog, .key = .GamepadLStickLeft, .btn = sdl.SDL_CONTROLLER_AXIS_LEFTX, .low = -thumb_dead_zone, .high = -32768 },
        .{ .kind = .Analog, .key = .GamepadLStickRight, .btn = sdl.SDL_CONTROLLER_AXIS_LEFTX, .low = thumb_dead_zone, .high = 32767 },
        .{ .kind = .Analog, .key = .GamepadLStickUp, .btn = sdl.SDL_CONTROLLER_AXIS_LEFTY, .low = -thumb_dead_zone, .high = -32768 },
        .{ .kind = .Analog, .key = .GamepadLStickDown, .btn = sdl.SDL_CONTROLLER_AXIS_LEFTY, .low = thumb_dead_zone, .high = 32767 },
        .{ .kind = .Analog, .key = .GamepadRStickLeft, .btn = sdl.SDL_CONTROLLER_AXIS_RIGHTX, .low = -thumb_dead_zone, .high = -32768 },
        .{ .kind = .Analog, .key = .GamepadRStickRight, .btn = sdl.SDL_CONTROLLER_AXIS_RIGHTX, .low = thumb_dead_zone, .high = 32767 },
        .{ .kind = .Analog, .key = .GamepadRStickUp, .btn = sdl.SDL_CONTROLLER_AXIS_RIGHTY, .low = -thumb_dead_zone, .high = -32768 },
        .{ .kind = .Analog, .key = .GamepadRStickDown, .btn = sdl.SDL_CONTROLLER_AXIS_RIGHTY, .low = thumb_dead_zone, .high = 32767 },
    };

    // Get gamepad
    // io.BackendFlags &= ~imgui.BackendFlags.HasGamepad;
    const game_controller = sdl.SDL_GameControllerOpen(0);
    if (game_controller == null) return;
    // io.BackendFlags |= imgui.BackendFlags.HasGamepad;

    // float vn = (float)(SDL_GameControllerGetAxis(game_controller, AXIS_NO) - V0) / (float)(V1 - V0); vn = IM_SATURATE(vn); io.AddKeyAnalogEvent(KEY_NO, vn > 0.1f, vn);
    inline for (mappings) |m| switch (m.kind) {
        .Button => io.AddKeyEvent(m.key, sdl.SDL_GameControllerGetButton(game_controller, m.btn) != 0),
        .Analog => {
            var v = @intToFloat(f32, sdl.SDL_GameControllerGetAxis(game_controller, m.btn)) - m.low;
            v = (v - m.low) / (m.high - m.low);
            io.AddKeyAnalogEvent(m.key, v > 0.1, Saturate(v));
        },
    };
}

// You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
// - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application, or clear/overwrite your copy of the mouse data.
// - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application, or clear/overwrite your copy of the keyboard data.
// Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
// If you have multiple SDL events and some of them are not meant to be used by dear imgui, you may need to filter events based on their windowID field.
pub fn ProcessEvent(event: ?*sdl.SDL_Event) bool {
    const io = imgui.GetIO();
    const bd = GetBackendData().?;
    const event_type: sdl.SDL_EventType = event.?.type;

    switch (event_type) {
        sdl.SDL_MOUSEMOTION => {
            const motion: sdl.SDL_MouseMotionEvent = event.?.motion;
            io.AddMousePosEvent(@intToFloat(f32, motion.x), @intToFloat(f32, motion.y));
            return true;
        },
        sdl.SDL_MOUSEWHEEL => {
            const wheel: sdl.SDL_MouseWheelEvent = event.?.wheel;
            io.AddMouseWheelEvent(@intToFloat(f32, wheel.x), @intToFloat(f32, wheel.y));
            return true;
        },
        sdl.SDL_MOUSEBUTTONDOWN, sdl.SDL_MOUSEBUTTONUP => {
            const mouse_button: i32 = switch (event.?.button.button) {
                sdl.SDL_BUTTON_LEFT => 0,
                sdl.SDL_BUTTON_RIGHT => 1,
                sdl.SDL_BUTTON_MIDDLE => 2,
                sdl.SDL_BUTTON_X1 => 3,
                sdl.SDL_BUTTON_X2 => 4,
                else => -1,
            };

            if (mouse_button >= 0) {
                const shl = std.math.shl(i32, 1, mouse_button);
                io.AddMouseButtonEvent(mouse_button, event_type == sdl.SDL_MOUSEBUTTONDOWN);
                bd.MouseButtonsDown = if (event_type == sdl.SDL_MOUSEBUTTONDOWN) bd.MouseButtonsDown | shl else bd.MouseButtonsDown & ~shl;

                return true;
            } else return false;
        },
        sdl.SDL_TEXTINPUT => {
            io.AddInputCharactersUTF8(&event.?.text.text);
            return true;
        },
        sdl.SDL_KEYDOWN, sdl.SDL_KEYUP => {
            const keysym: sdl.SDL_Keysym = event.?.key.keysym;
            UpdateKeyModifiers(keysym.mod);
            const key: imgui.Key = SDLKeyToImGuiKey(keysym.sym);
            io.AddKeyEvent(key, event.?.type == sdl.SDL_KEYDOWN);
            io.SetKeyEventNativeData(key, keysym.sym, @intCast(i32, keysym.scancode)); // To support legacy indexing (<1.87 user code). Legacy backend uses SDLK_*** as indices to IsKeyXXX() functions.
            return true;
        },
        sdl.SDL_WINDOWEVENT => {
            // - When capturing mouse, SDL will send a bunch of conflicting LEAVE/ENTER event on every mouse move, but the final ENTER tends to be right.
            // - However we won't get a correct LEAVE event for a captured window.
            // - In some cases, when detaching a window from main viewport SDL may send SDL_WINDOWEVENT_ENTER one frame too late,
            //   causing SDL_WINDOWEVENT_LEAVE on previous frame to interrupt drag operation by clear mouse position. This is why
            //   we delay process the SDL_WINDOWEVENT_LEAVE events by one frame. See issue #5012 for details.
            switch (event.?.window.event) {
                sdl.SDL_WINDOWEVENT_ENTER => bd.PendingMouseLeaveFrame = 0,
                sdl.SDL_WINDOWEVENT_LEAVE => bd.PendingMouseLeaveFrame = imgui.GetFrameCount() + 1,
                sdl.SDL_WINDOWEVENT_FOCUS_GAINED => io.AddFocusEvent(true),
                sdl.SDL_WINDOWEVENT_FOCUS_LOST => io.AddFocusEvent(false),
                else => {},
            }
            return true;
        },
        else => {},
    }

    return false;
}

pub fn NewFrame() void {
    const bd = GetBackendData().?; // Did you call ImGui_ImplGlfw_InitForXXX()?
    const io = imgui.GetIO();

    // Setup display size (every frame to accommodate for window resizing)
    var w: c_int = 0;
    var h: c_int = 0;
    var display_w: c_int = 0;
    var display_h: c_int = 0;

    sdl.SDL_GetWindowSize(bd.Window.?, &w, &h);
    if ((sdl.SDL_GetWindowFlags(bd.Window.?) & sdl.SDL_WINDOW_MINIMIZED) != 0) {
        w = 0;
        h = 0;
    } else {
        sdl.SDL_GL_GetDrawableSize(bd.Window.?, &display_w, &display_h);
    }

    io.DisplaySize = .{ .x = @intToFloat(f32, w), .y = @intToFloat(f32, h) };
    if (w > 0 and h > 0) {
        io.DisplayFramebufferScale = .{
            .x = @intToFloat(f32, display_w) / @intToFloat(f32, w),
            .y = @intToFloat(f32, display_h) / @intToFloat(f32, h),
        };
    }

    // Setup time step (we don't use SDL_GetTicks() because it is using millisecond resolution)
    const frequency = sdl.SDL_GetPerformanceFrequency();
    const current_time = sdl.SDL_GetPerformanceCounter();
    io.DeltaTime = if (bd.Time > 0) @intToFloat(f32, current_time - bd.Time) / @intToFloat(f32, frequency) else (1.0 / 60.0);
    bd.Time = current_time;

    if (bd.PendingMouseLeaveFrame != 0 and bd.PendingMouseLeaveFrame >= imgui.GetFrameCount() and bd.MouseButtonsDown == 0) {
        io.AddMousePosEvent(std.math.f32_min, std.math.f32_max);
        bd.PendingMouseLeaveFrame = 0;
    }

    UpdateMouseData();
    UpdateMouseCursor();

    // Update game controllers (if enabled and available)
    UpdateGamepads();
}

fn Init(window: *sdl.SDL_Window, renderer: ?*sdl.SDL_Renderer) bool {
    const io = imgui.GetIO();
    assert(io.BackendPlatformUserData == null); // Already initialized a platform backend!

    var mouse_can_use_global_state = false;
    if (@hasDecl(sdl, "SDL_HAS_CAPTURE_AND_GLOBAL_MOUSE")) {
        const sdl_backend = sdl.SDL_GetCurrentVideoDriver();
        const global_mouse_whitelist = [_][]const u8{ "windows", "cocoa", "x11", "DIVE", "VMAN" };
        inline for (global_mouse_whitelist) |m| {
            if (std.mem.eql(u8, m, sdl_backend)) {
                mouse_can_use_global_state = true;
                break;
            }
        }
    }

    // Setup backend capabilities flags
    const bd = @ptrCast(*Data, @alignCast(@alignOf(Data), imgui.MemAlloc(@sizeOf(Data))));
    bd.* = .{ .Window = window, .Time = 0, .MouseCanUseGlobalState = mouse_can_use_global_state, .Renderer = renderer };

    // Load mouse cursors
    bd.MouseCursors[@enumToInt(imgui.MouseCursor.Arrow)] = sdl.SDL_CreateSystemCursor(sdl.SDL_SYSTEM_CURSOR_ARROW);
    bd.MouseCursors[@enumToInt(imgui.MouseCursor.TextInput)] = sdl.SDL_CreateSystemCursor(sdl.SDL_SYSTEM_CURSOR_IBEAM);
    bd.MouseCursors[@enumToInt(imgui.MouseCursor.ResizeAll)] = sdl.SDL_CreateSystemCursor(sdl.SDL_SYSTEM_CURSOR_SIZEALL);
    bd.MouseCursors[@enumToInt(imgui.MouseCursor.ResizeNS)] = sdl.SDL_CreateSystemCursor(sdl.SDL_SYSTEM_CURSOR_SIZENS);
    bd.MouseCursors[@enumToInt(imgui.MouseCursor.ResizeEW)] = sdl.SDL_CreateSystemCursor(sdl.SDL_SYSTEM_CURSOR_SIZEWE);
    bd.MouseCursors[@enumToInt(imgui.MouseCursor.ResizeNESW)] = sdl.SDL_CreateSystemCursor(sdl.SDL_SYSTEM_CURSOR_SIZENESW);
    bd.MouseCursors[@enumToInt(imgui.MouseCursor.ResizeNWSE)] = sdl.SDL_CreateSystemCursor(sdl.SDL_SYSTEM_CURSOR_SIZENWSE);
    bd.MouseCursors[@enumToInt(imgui.MouseCursor.Hand)] = sdl.SDL_CreateSystemCursor(sdl.SDL_SYSTEM_CURSOR_HAND);
    bd.MouseCursors[@enumToInt(imgui.MouseCursor.NotAllowed)] = sdl.SDL_CreateSystemCursor(sdl.SDL_SYSTEM_CURSOR_NO);

    io.BackendPlatformUserData = bd;
    io.BackendPlatformName = "imgui_impl_sdl";
    io.BackendFlags.HasMouseCursors = true; // We can honor GetMouseCursor() values (optional)
    io.BackendFlags.HasSetMousePos = true; // We can honor io.WantSetMousePos requests (optional, rarely used)

    io.SetClipboardTextFn = SetClipboardText;
    io.GetClipboardTextFn = GetClipboardText;
    io.ClipboardUserData = window;

    // TODO: Set platform dependent data in viewport
    //
    // if (builtin.os.tag == .windows) {
    //     imgui.GetMainViewport().?.PlatformHandleRaw = sdl.SDL_WM .glfwGetWin32Window(window);
    // }

    if (@hasDecl(sdl, "SDL_HAS_MOUSE_FOCUS_CLICKTHROUGH")) sdl.SDL_SetHint("SDL_HINT_MOUSE_FOCUS_CLICKTHROUGH", 1);

    return true;
}

pub fn InitForOpenGL(window: *sdl.SDL_Window, _: ?*anyopaque) callconv(.C) bool {
    return Init(window, null);
}

pub fn InitForVulkan(window: *sdl.SDL_Window) bool {
    return Init(window, null);
}

pub fn InitForMetal(window: *sdl.SDL_Window) bool {
    return Init(window, null);
}

pub fn Shutdown() void {
    const bd = GetBackendData();
    assert(bd != null); // No platform backend to shutdown, or already shutdown?
    const io = imgui.GetIO();

    if (bd.?.ClipboardTextData != null) sdl.SDL_free(bd.?.ClipboardTextData);

    for (bd.?.MouseCursors) |cursor| {
        if (cursor != null) sdl.SDL_FreeCursor(cursor);
    }

    io.BackendPlatformName = null;
    io.BackendPlatformUserData = null;
    imgui.MemFree(bd.?);
}
