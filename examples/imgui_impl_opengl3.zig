// dear imgui: Renderer for modern OpenGL with shaders / programmatic pipeline
// - Desktop GL: 2.x 3.x 4.x
// - Embedded GL: ES 2.0 (WebGL 1.0), ES 3.0 (WebGL 2.0)
// This needs to be used along with a Platform Binding (e.g. GLFW, SDL, Win32, custom..)

// Implemented features:
//  [X] Renderer: User texture binding. Use 'GLuint' OpenGL texture identifier as void*/ImTextureID. Read the FAQ about ImTextureID!
//  [x] Renderer: Desktop GL only: Support for large meshes (64k+ vertices) with 16-bit indices.

// You can copy and use unmodified imgui_impl_* files in your project. See main.cpp for an example of using this.
// If you are new to dear imgui, read examples/README.txt and read the documentation at the top of imgui.cpp.
// https://github.com/ocornut/imgui

//----------------------------------------
// OpenGL    GLSL      GLSL
// version   version   string
//----------------------------------------
//  2.0       110       "#version 110"
//  2.1       120       "#version 120"
//  3.0       130       "#version 130"
//  3.1       140       "#version 140"
//  3.2       150       "#version 150"
//  3.3       330       "#version 330 core"
//  4.0       400       "#version 400 core"
//  4.1       410       "#version 410 core"
//  4.2       420       "#version 410 core"
//  4.3       430       "#version 430 core"
//  ES 2.0    100       "#version 100"      = WebGL 1.0
//  ES 3.0    300       "#version 300 es"   = WebGL 2.0
//----------------------------------------

const std = @import("std");
const imgui = @import("imgui");
const gl = @import("include/gl.zig");

// Desktop GL 3.2+ has glDrawElementsBaseVertex() which GL ES and WebGL don't have.
const IMGUI_IMPL_OPENGL_MAY_HAVE_VTX_OFFSET = true;

// OpenGL Data
var g_GlVersion: gl.GLuint = 0; // Extracted at runtime using GL_MAJOR_VERSION, GL_MINOR_VERSION queries.
var g_GlslVersionStringMem: [32]u8 = undefined; // Specified by user or detected based on compile time GL settings.
var g_GlslVersionString: []u8 = &g_GlslVersionStringMem; // slice of g_GlslVersionStringMem
var g_FontTexture: c_uint = 0;
var g_ShaderHandle: c_uint = 0;
var g_VertHandle: c_uint = 0;
var g_FragHandle: c_uint = 0;
var g_AttribLocationTex: i32 = 0;
var g_AttribLocationProjMtx: i32 = 0; // Uniforms location
var g_AttribLocationVtxPos: i32 = 0;
var g_AttribLocationVtxUV: i32 = 0;
var g_AttribLocationVtxColor: i32 = 0; // Vertex attributes location
var g_VboHandle: c_uint = 0;
var g_ElementsHandle: c_uint = 0;

// Functions
pub fn Init(glsl_version_opt: ?[:0]const u8) bool {
    // Query for GL version
    var major: gl.GLint = undefined;
    var minor: gl.GLint = undefined;
    gl.glGetIntegerv(gl.GL_MAJOR_VERSION, &major);
    gl.glGetIntegerv(gl.GL_MINOR_VERSION, &minor);
    g_GlVersion = @intCast(gl.GLuint, major * 1000 + minor);

    // Setup back-end capabilities flags
    var io = imgui.GetIO();
    io.BackendRendererName = "imgui_impl_opengl3";
    if (IMGUI_IMPL_OPENGL_MAY_HAVE_VTX_OFFSET) {
        if (g_GlVersion >= 3200)
            io.BackendFlags.RendererHasVtxOffset = true; // We can honor the ImDrawCmd::VtxOffset field, allowing for large meshes.
    }

    // Store GLSL version string so we can refer to it later in case we recreate shaders.
    // Note: GLSL version is NOT the same as GL version. Leave this to NULL if unsure.
    var glsl_version: [:0]const u8 = undefined;
    if (glsl_version_opt) |value| {
        glsl_version = value;
    } else {
        glsl_version = "#version 130";
    }

    std.debug.assert(glsl_version.len + 2 < g_GlslVersionStringMem.len);
    std.mem.copy(u8, g_GlslVersionStringMem[0..glsl_version.len], glsl_version);
    g_GlslVersionStringMem[glsl_version.len] = '\n';
    g_GlslVersionStringMem[glsl_version.len + 1] = 0;
    g_GlslVersionString = g_GlslVersionStringMem[0..glsl_version.len];

    // Make a dummy GL call (we don't actually need the result)
    // IF YOU GET A CRASH HERE: it probably means that you haven't initialized the OpenGL function loader used by this code.
    // Desktop OpenGL 3/4 need a function loader. See the IMGUI_IMPL_OPENGL_LOADER_xxx explanation above.
    var current_texture: gl.GLint = undefined;
    gl.glGetIntegerv(gl.GL_TEXTURE_BINDING_2D, &current_texture);

    return true;
}

pub fn Shutdown() void {
    DestroyDeviceObjects();
}

pub fn NewFrame() void {
    if (g_ShaderHandle == 0) {
        _ = CreateDeviceObjects();
    }
}

fn SetupRenderState(draw_data: *imgui.DrawData, fb_width: c_int, fb_height: c_int, vertex_array_object: gl.GLuint) void {
    // Setup render state: alpha-blending enabled, no face culling, no depth testing, scissor enabled, polygon fill
    gl.glEnable(gl.GL_BLEND);
    gl.glBlendEquation(gl.GL_FUNC_ADD);
    gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA);
    gl.glDisable(gl.GL_CULL_FACE);
    gl.glDisable(gl.GL_DEPTH_TEST);
    gl.glEnable(gl.GL_SCISSOR_TEST);
    if (@hasDecl(gl, "glPolygonMode")) {
        gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
    }

    // Setup viewport, orthographic projection matrix
    // Our visible imgui space lies from draw_data.DisplayPos (top left) to draw_data.DisplayPos+data_data.DisplaySize (bottom right). DisplayPos is (0,0) for single viewport apps.
    gl.glViewport(0, 0, @intCast(gl.GLsizei, fb_width), @intCast(gl.GLsizei, fb_height));
    var L = draw_data.DisplayPos.x;
    var R = draw_data.DisplayPos.x + draw_data.DisplaySize.x;
    var T = draw_data.DisplayPos.y;
    var B = draw_data.DisplayPos.y + draw_data.DisplaySize.y;
    const ortho_projection = [4][4]f32{
        [4]f32{ 2.0 / (R - L), 0.0, 0.0, 0.0 },
        [4]f32{ 0.0, 2.0 / (T - B), 0.0, 0.0 },
        [4]f32{ 0.0, 0.0, -1.0, 0.0 },
        [4]f32{ (R + L) / (L - R), (T + B) / (B - T), 0.0, 1.0 },
    };
    gl.glUseProgram(g_ShaderHandle);
    gl.glUniform1i(g_AttribLocationTex, 0);
    gl.glUniformMatrix4fv(g_AttribLocationProjMtx, 1, gl.GL_FALSE, &ortho_projection[0][0]);
    if (@hasDecl(gl, "glBindSampler")) {
        glBindSampler(0, 0); // We use combined texture/sampler state. Applications using GL 3.3 may set that otherwise.
    }

    gl.glBindVertexArray(vertex_array_object);
    // Bind vertex/index buffers and setup attributes for ImDrawVert
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, g_VboHandle);
    gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, g_ElementsHandle);
    gl.glEnableVertexAttribArray(@intCast(c_uint, g_AttribLocationVtxPos));
    gl.glEnableVertexAttribArray(@intCast(c_uint, g_AttribLocationVtxUV));
    gl.glEnableVertexAttribArray(@intCast(c_uint, g_AttribLocationVtxColor));
    gl.glVertexAttribPointer(
        @intCast(c_uint, g_AttribLocationVtxPos),
        2,
        gl.GL_FLOAT,
        gl.GL_FALSE,
        @sizeOf(imgui.DrawVert),
        @intToPtr(?*c_void, @byteOffsetOf(imgui.DrawVert, "pos")),
    );
    gl.glVertexAttribPointer(
        @intCast(c_uint, g_AttribLocationVtxUV),
        2,
        gl.GL_FLOAT,
        gl.GL_FALSE,
        @sizeOf(imgui.DrawVert),
        @intToPtr(?*c_void, @byteOffsetOf(imgui.DrawVert, "uv")),
    );
    gl.glVertexAttribPointer(
        @intCast(c_uint, g_AttribLocationVtxColor),
        4,
        gl.GL_UNSIGNED_BYTE,
        gl.GL_TRUE,
        @sizeOf(imgui.DrawVert),
        @intToPtr(?*c_void, @byteOffsetOf(imgui.DrawVert, "col")),
    );
}

fn getGLInt(name: gl.GLenum) gl.GLint {
    var value: gl.GLint = undefined;
    gl.glGetIntegerv(name, &value);
    return value;
}
fn getGLInts(name: gl.GLenum, comptime N: comptime_int) [N]gl.GLint {
    var value: [N]gl.GLint = undefined;
    gl.glGetIntegerv(name, &value);
    return value;
}

// OpenGL3 Render function.
// (this used to be set in io.RenderDrawListsFn and called by ImGui::Render(), but you can now call this directly from your main loop)
// Note that this implementation is little overcomplicated because we are saving/setting up/restoring every OpenGL state explicitly, in order to be able to run within any OpenGL engine that doesn't do so.
pub fn RenderDrawData(draw_data: *imgui.DrawData) void {
    // Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
    var fb_width = @floatToInt(c_int, draw_data.DisplaySize.x * draw_data.FramebufferScale.x);
    var fb_height = @floatToInt(c_int, draw_data.DisplaySize.y * draw_data.FramebufferScale.y);
    if (fb_width <= 0 or fb_height <= 0)
        return;

    // Backup GL state
    var last_active_texture = @intCast(gl.GLenum, getGLInt(gl.GL_ACTIVE_TEXTURE));
    gl.glActiveTexture(gl.GL_TEXTURE0);
    var last_program = getGLInt(gl.GL_CURRENT_PROGRAM);
    var last_texture = getGLInt(gl.GL_TEXTURE_BINDING_2D);

    var last_sampler = if (@hasDecl(gl, "GL_SAMPLER_BINDING")) getGLInt(gl.GL_SAMPLER_BINDING) else void{};
    var last_array_buffer = getGLInt(gl.GL_ARRAY_BUFFER_BINDING);
    var last_vertex_array_object = getGLInt(gl.GL_VERTEX_ARRAY_BINDING);
    var last_polygon_mode = if (@hasDecl(gl, "GL_POLYGON_MODE")) getGLInts(gl.GL_POLYGON_MODE, 2) else void{};

    var last_viewport = getGLInts(gl.GL_VIEWPORT, 4);
    var last_scissor_box = getGLInts(gl.GL_SCISSOR_BOX, 4);
    var last_blend_src_rgb = @intCast(gl.GLenum, getGLInt(gl.GL_BLEND_SRC_RGB));
    var last_blend_dst_rgb = @intCast(gl.GLenum, getGLInt(gl.GL_BLEND_DST_RGB));
    var last_blend_src_alpha = @intCast(gl.GLenum, getGLInt(gl.GL_BLEND_SRC_ALPHA));
    var last_blend_dst_alpha = @intCast(gl.GLenum, getGLInt(gl.GL_BLEND_DST_ALPHA));
    var last_blend_equation_rgb = @intCast(gl.GLenum, getGLInt(gl.GL_BLEND_EQUATION_RGB));
    var last_blend_equation_alpha = @intCast(gl.GLenum, getGLInt(gl.GL_BLEND_EQUATION_ALPHA));
    var last_enable_blend = gl.glIsEnabled(gl.GL_BLEND);
    var last_enable_cull_face = gl.glIsEnabled(gl.GL_CULL_FACE);
    var last_enable_depth_test = gl.glIsEnabled(gl.GL_DEPTH_TEST);
    var last_enable_scissor_test = gl.glIsEnabled(gl.GL_SCISSOR_TEST);

    var clip_origin_lower_left = true;
    if (@hasDecl(gl, "GL_CLIP_ORIGIN") and !os.darwin.is_the_target) {
        var last_clip_origin = getGLInt(gl.GL_CLIP_ORIGIN); // Support for GL 4.5's glClipControl(GL_UPPER_LEFT)
        if (last_clip_origin == gl.GL_UPPER_LEFT)
            clip_origin_lower_left = false;
    }

    // Setup desired GL state
    // Recreate the VAO every time (this is to easily allow multiple GL contexts to be rendered to. VAO are not shared among GL contexts)
    // The renderer would actually work without any VAO bound, but then our VertexAttrib calls would overwrite the default one currently bound.
    var vertex_array_object: gl.GLuint = 0;

    gl.glGenVertexArrays(1, &vertex_array_object);

    SetupRenderState(draw_data, fb_width, fb_height, vertex_array_object);

    // Will project scissor/clipping rectangles into framebuffer space
    var clip_off = draw_data.DisplayPos; // (0,0) unless using multi-viewports
    var clip_scale = draw_data.FramebufferScale; // (1,1) unless using retina display which are often (2,2)

    // Render command lists
    if (draw_data.CmdListsCount > 0) {
        for (draw_data.CmdLists.?[0..@intCast(usize, draw_data.CmdListsCount)]) |cmd_list| {
            // Upload vertex/index buffers
            gl.glBufferData(gl.GL_ARRAY_BUFFER, @intCast(gl.GLsizeiptr, cmd_list.VtxBuffer.len * @sizeOf(imgui.DrawVert)), cmd_list.VtxBuffer.items, gl.GL_STREAM_DRAW);
            gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, @intCast(gl.GLsizeiptr, cmd_list.IdxBuffer.len * @sizeOf(imgui.DrawIdx)), cmd_list.IdxBuffer.items, gl.GL_STREAM_DRAW);

            for (cmd_list.CmdBuffer.items[0..@intCast(usize, cmd_list.CmdBuffer.len)]) |pcmd| {
                if (pcmd.UserCallback) |fnPtr| {
                    // User callback, registered via ImDrawList::AddCallback()
                    // (ImDrawCallback_ResetRenderState is a special callback value used by the user to request the renderer to reset render state.)
                    if (fnPtr == imgui.DrawCallback_ResetRenderState) {
                        SetupRenderState(draw_data, fb_width, fb_height, vertex_array_object);
                    } else {
                        fnPtr(cmd_list, &pcmd);
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
                        // Apply scissor/clipping rectangle
                        if (clip_origin_lower_left) {
                            gl.glScissor(@floatToInt(c_int, clip_rect.x), fb_height - @floatToInt(c_int, clip_rect.w), @floatToInt(c_int, clip_rect.z - clip_rect.x), @floatToInt(c_int, clip_rect.w - clip_rect.y));
                        } else {
                            gl.glScissor(@floatToInt(c_int, clip_rect.x), @floatToInt(c_int, clip_rect.y), @floatToInt(c_int, clip_rect.z), @floatToInt(c_int, clip_rect.w)); // Support for GL 4.5 rarely used glClipControl(GL_UPPER_LEFT)
                        }

                        // Bind texture, Draw
                        gl.glBindTexture(gl.GL_TEXTURE_2D, @intCast(gl.GLuint, @ptrToInt(pcmd.TextureId)));
                        if (IMGUI_IMPL_OPENGL_MAY_HAVE_VTX_OFFSET and g_GlVersion >= 3200) {
                            gl.glDrawElementsBaseVertex(
                                gl.GL_TRIANGLES,
                                @intCast(gl.GLsizei, pcmd.ElemCount),
                                if (@sizeOf(imgui.DrawIdx) == 2) gl.GL_UNSIGNED_SHORT else gl.GL_UNSIGNED_INT,
                                @intToPtr(?*const c_void, pcmd.IdxOffset * @sizeOf(imgui.DrawIdx)),
                                @intCast(gl.GLint, pcmd.VtxOffset),
                            );
                        } else {
                            gl.glDrawElements(
                                gl.GL_TRIANGLES,
                                @intCast(gl.GLsizei, pcmd.ElemCount),
                                if (@sizeOf(imgui.DrawIdx) == 2) gl.GL_UNSIGNED_SHORT else gl.GL_UNSIGNED_INT,
                                @intToPtr(?*const c_void, pcmd.IdxOffset * @sizeOf(imgui.DrawIdx)),
                            );
                        }
                    }
                }
            }
        }
    }

    // Destroy the temporary VAO
    gl.glDeleteVertexArrays(1, &vertex_array_object);

    // Restore modified GL state
    gl.glUseProgram(@intCast(c_uint, last_program));
    gl.glBindTexture(gl.GL_TEXTURE_2D, @intCast(c_uint, last_texture));
    if (@hasDecl(gl, "GL_SAMPLER_BINDING")) gl.glBindSampler(0, last_sampler);
    gl.glActiveTexture(last_active_texture);
    gl.glBindVertexArray(@intCast(c_uint, last_vertex_array_object));
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, @intCast(c_uint, last_array_buffer));
    gl.glBlendEquationSeparate(last_blend_equation_rgb, last_blend_equation_alpha);
    gl.glBlendFuncSeparate(last_blend_src_rgb, last_blend_dst_rgb, last_blend_src_alpha, last_blend_dst_alpha);
    if (last_enable_blend != 0) gl.glEnable(gl.GL_BLEND) else gl.glDisable(gl.GL_BLEND);
    if (last_enable_cull_face != 0) gl.glEnable(gl.GL_CULL_FACE) else gl.glDisable(gl.GL_CULL_FACE);
    if (last_enable_depth_test != 0) gl.glEnable(gl.GL_DEPTH_TEST) else gl.glDisable(gl.GL_DEPTH_TEST);
    if (last_enable_scissor_test != 0) gl.glEnable(gl.GL_SCISSOR_TEST) else gl.glDisable(gl.GL_SCISSOR_TEST);
    if (@hasDecl(gl, "GL_POLYGON_MODE")) gl.glPolygonMode(gl.GL_FRONT_AND_BACK, @intCast(gl.GLenum, last_polygon_mode[0]));
    gl.glViewport(last_viewport[0], last_viewport[1], @intCast(gl.GLsizei, last_viewport[2]), @intCast(gl.GLsizei, last_viewport[3]));
    gl.glScissor(last_scissor_box[0], last_scissor_box[1], @intCast(gl.GLsizei, last_scissor_box[2]), @intCast(gl.GLsizei, last_scissor_box[3]));
}

fn CreateFontsTexture() bool {
    // Build texture atlas
    const io = imgui.GetIO();
    var pixels: ?[*]u8 = undefined;
    var width: i32 = undefined;
    var height: i32 = undefined;
    var bpp: i32 = undefined;
    io.Fonts.?.GetTexDataAsRGBA32(&pixels, &width, &height, &bpp); // Load as RGBA 32-bit (75% of the memory is wasted, but default font is so small) because it is more likely to be compatible with user's existing shaders. If your ImTextureId represent a higher-level concept than just a GL texture id, consider calling GetTexDataAsAlpha8() instead to save on GPU memory.

    // Upload texture to graphics system
    var last_texture: gl.GLint = undefined;
    gl.glGetIntegerv(gl.GL_TEXTURE_BINDING_2D, &last_texture);
    gl.glGenTextures(1, &g_FontTexture);
    gl.glBindTexture(gl.GL_TEXTURE_2D, g_FontTexture);
    gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR);
    gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR);
    if (@hasDecl(gl, "GL_UNPACK_ROW_LENGTH"))
        gl.glPixelStorei(gl.GL_UNPACK_ROW_LENGTH, 0);
    gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, gl.GL_RGBA, width, height, 0, gl.GL_RGBA, gl.GL_UNSIGNED_BYTE, pixels);

    // Store our identifier
    io.Fonts.?.TexID = @intToPtr(imgui.TextureID, g_FontTexture);

    // Restore state
    gl.glBindTexture(gl.GL_TEXTURE_2D, @intCast(c_uint, last_texture));

    return true;
}

fn DestroyFontsTexture() void {
    if (g_FontTexture != 0) {
        const io = imgui.GetIO();
        gl.glDeleteTextures(1, &g_FontTexture);
        io.Fonts.?.TexID = null;
        g_FontTexture = 0;
    }
}

// If you get an error please report on github. You may try different GL context version or GLSL version. See GL<>GLSL version table at the top of this file.
fn CheckShader(handle: gl.GLuint, desc: []const u8) bool {
    var status: gl.GLint = 0;
    var log_length: gl.GLint = 0;
    gl.glGetShaderiv(handle, gl.GL_COMPILE_STATUS, &status);
    gl.glGetShaderiv(handle, gl.GL_INFO_LOG_LENGTH, &log_length);
    if (status == gl.GL_FALSE)
        std.debug.warn("ERROR: imgui_impl_opengl3.CreateDeviceObjects: failed to compile {}!\n", .{desc});
    if (log_length > 1) {
        var buf: imgui.Vector(u8) = undefined;
        buf.init();
        defer buf.deinit();
        buf.resize(@intCast(c_int, log_length + 1));
        gl.glGetShaderInfoLog(handle, log_length, null, @ptrCast([*]gl.GLchar, buf.begin()));
        std.debug.warn("{}\n", .{buf.begin()});
    }
    return status != gl.GL_FALSE;
}

// If you get an error please report on GitHub. You may try different GL context version or GLSL version.
fn CheckProgram(handle: gl.GLuint, desc: []const u8) bool {
    var status: gl.GLint = 0;
    var log_length: gl.GLint = 0;
    gl.glGetProgramiv(handle, gl.GL_LINK_STATUS, &status);
    gl.glGetProgramiv(handle, gl.GL_INFO_LOG_LENGTH, &log_length);
    if (status == gl.GL_FALSE)
        std.debug.warn("ERROR: imgui_impl_opengl3.CreateDeviceObjects: failed to link {}! (with GLSL '{}')\n", .{ desc, g_GlslVersionString });
    if (log_length > 1) {
        var buf: imgui.Vector(u8) = undefined;
        buf.init();
        defer buf.deinit();
        buf.resize(@intCast(c_int, log_length + 1));
        gl.glGetProgramInfoLog(handle, log_length, null, @ptrCast([*]gl.GLchar, buf.begin()));
        std.debug.warn("{}\n", .{buf.begin()});
    }
    return status != gl.GL_FALSE;
}

fn CreateDeviceObjects() bool {
    // Backup GL state
    var last_texture = getGLInt(gl.GL_TEXTURE_BINDING_2D);
    var last_array_buffer = getGLInt(gl.GL_ARRAY_BUFFER_BINDING);
    var last_vertex_array = getGLInt(gl.GL_VERTEX_ARRAY_BINDING);

    // Parse GLSL version string
    var glsl_version: u32 = 130;

    const numberPart = g_GlslVersionStringMem["#version ".len..g_GlslVersionString.len];
    if (std.fmt.parseInt(u32, numberPart, 10)) |value| {
        glsl_version = value;
    } else |err| {
        std.debug.warn("Couldn't parse glsl version from '{}', '{}'\n", .{ g_GlslVersionString, numberPart });
    }

    const vertex_shader_glsl_120 = "uniform mat4 ProjMtx;\n" ++
        "attribute vec2 Position;\n" ++
        "attribute vec2 UV;\n" ++
        "attribute vec4 Color;\n" ++
        "varying vec2 Frag_UV;\n" ++
        "varying vec4 Frag_Color;\n" ++
        "void main()\n" ++
        "{\n" ++
        "    Frag_UV = UV;\n" ++
        "    Frag_Color = Color;\n" ++
        "    gl_Position = ProjMtx * vec4(Position.xy,0,1);\n" ++
        "}\n";

    const vertex_shader_glsl_130 = "uniform mat4 ProjMtx;\n" ++
        "in vec2 Position;\n" ++
        "in vec2 UV;\n" ++
        "in vec4 Color;\n" ++
        "out vec2 Frag_UV;\n" ++
        "out vec4 Frag_Color;\n" ++
        "void main()\n" ++
        "{\n" ++
        "    Frag_UV = UV;\n" ++
        "    Frag_Color = Color;\n" ++
        "    gl_Position = ProjMtx * vec4(Position.xy,0,1);\n" ++
        "}\n";

    const vertex_shader_glsl_300_es = "precision mediump float;\n" ++
        "layout (location = 0) in vec2 Position;\n" ++
        "layout (location = 1) in vec2 UV;\n" ++
        "layout (location = 2) in vec4 Color;\n" ++
        "uniform mat4 ProjMtx;\n" ++
        "out vec2 Frag_UV;\n" ++
        "out vec4 Frag_Color;\n" ++
        "void main()\n" ++
        "{\n" ++
        "    Frag_UV = UV;\n" ++
        "    Frag_Color = Color;\n" ++
        "    gl_Position = ProjMtx * vec4(Position.xy,0,1);\n" ++
        "}\n";

    const vertex_shader_glsl_410_core = "layout (location = 0) in vec2 Position;\n" ++
        "layout (location = 1) in vec2 UV;\n" ++
        "layout (location = 2) in vec4 Color;\n" ++
        "uniform mat4 ProjMtx;\n" ++
        "out vec2 Frag_UV;\n" ++
        "out vec4 Frag_Color;\n" ++
        "void main()\n" ++
        "{\n" ++
        "    Frag_UV = UV;\n" ++
        "    Frag_Color = Color;\n" ++
        "    gl_Position = ProjMtx * vec4(Position.xy,0,1);\n" ++
        "}\n";

    const fragment_shader_glsl_120 = "#ifdef GL_ES\n" ++
        "    precision mediump float;\n" ++
        "#endif\n" ++
        "uniform sampler2D Texture;\n" ++
        "varying vec2 Frag_UV;\n" ++
        "varying vec4 Frag_Color;\n" ++
        "void main()\n" ++
        "{\n" ++
        "    gl_FragColor = Frag_Color * texture2D(Texture, Frag_UV.st);\n" ++
        "}\n";

    const fragment_shader_glsl_130 = "uniform sampler2D Texture;\n" ++
        "in vec2 Frag_UV;\n" ++
        "in vec4 Frag_Color;\n" ++
        "out vec4 Out_Color;\n" ++
        "void main()\n" ++
        "{\n" ++
        "    Out_Color = Frag_Color * texture(Texture, Frag_UV.st);\n" ++
        "}\n";

    const fragment_shader_glsl_300_es = "precision mediump float;\n" ++
        "uniform sampler2D Texture;\n" ++
        "in vec2 Frag_UV;\n" ++
        "in vec4 Frag_Color;\n" ++
        "layout (location = 0) out vec4 Out_Color;\n" ++
        "void main()\n" ++
        "{\n" ++
        "    Out_Color = Frag_Color * texture(Texture, Frag_UV.st);\n" ++
        "}\n";

    const fragment_shader_glsl_410_core = "in vec2 Frag_UV;\n" ++
        "in vec4 Frag_Color;\n" ++
        "uniform sampler2D Texture;\n" ++
        "layout (location = 0) out vec4 Out_Color;\n" ++
        "void main()\n" ++
        "{\n" ++
        "    Out_Color = Frag_Color * texture(Texture, Frag_UV.st);\n" ++
        "}\n";

    // Select shaders matching our GLSL versions
    var vertex_shader: [*]const u8 = undefined;
    var fragment_shader: [*]const u8 = undefined;
    if (glsl_version < 130) {
        vertex_shader = vertex_shader_glsl_120;
        fragment_shader = fragment_shader_glsl_120;
    } else if (glsl_version >= 410) {
        vertex_shader = vertex_shader_glsl_410_core;
        fragment_shader = fragment_shader_glsl_410_core;
    } else if (glsl_version == 300) {
        vertex_shader = vertex_shader_glsl_300_es;
        fragment_shader = fragment_shader_glsl_300_es;
    } else {
        vertex_shader = vertex_shader_glsl_130;
        fragment_shader = fragment_shader_glsl_130;
    }

    // Create shaders
    const vertex_shader_with_version = [_][*]const u8{ &g_GlslVersionStringMem, vertex_shader };
    g_VertHandle = gl.glCreateShader(gl.GL_VERTEX_SHADER);
    gl.glShaderSource(g_VertHandle, 2, &vertex_shader_with_version, null);
    gl.glCompileShader(g_VertHandle);
    _ = CheckShader(g_VertHandle, "vertex shader");

    const fragment_shader_with_version = [_][*]const u8{ &g_GlslVersionStringMem, fragment_shader };
    g_FragHandle = gl.glCreateShader(gl.GL_FRAGMENT_SHADER);
    gl.glShaderSource(g_FragHandle, 2, &fragment_shader_with_version, null);
    gl.glCompileShader(g_FragHandle);
    _ = CheckShader(g_FragHandle, "fragment shader");

    g_ShaderHandle = gl.glCreateProgram();
    gl.glAttachShader(g_ShaderHandle, g_VertHandle);
    gl.glAttachShader(g_ShaderHandle, g_FragHandle);
    gl.glLinkProgram(g_ShaderHandle);
    _ = CheckProgram(g_ShaderHandle, "shader program");

    g_AttribLocationTex = gl.glGetUniformLocation(g_ShaderHandle, "Texture");
    g_AttribLocationProjMtx = gl.glGetUniformLocation(g_ShaderHandle, "ProjMtx");
    g_AttribLocationVtxPos = gl.glGetAttribLocation(g_ShaderHandle, "Position");
    g_AttribLocationVtxUV = gl.glGetAttribLocation(g_ShaderHandle, "UV");
    g_AttribLocationVtxColor = gl.glGetAttribLocation(g_ShaderHandle, "Color");

    // Create buffers
    gl.glGenBuffers(1, &g_VboHandle);
    gl.glGenBuffers(1, &g_ElementsHandle);

    _ = CreateFontsTexture();

    // Restore modified GL state
    gl.glBindTexture(gl.GL_TEXTURE_2D, @intCast(c_uint, last_texture));
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, @intCast(c_uint, last_array_buffer));
    gl.glBindVertexArray(@intCast(c_uint, last_vertex_array));

    return true;
}

fn DestroyDeviceObjects() void {
    if (g_VboHandle != 0) {
        gl.glDeleteBuffers(1, &g_VboHandle);
        g_VboHandle = 0;
    }
    if (g_ElementsHandle != 0) {
        gl.glDeleteBuffers(1, &g_ElementsHandle);
        g_ElementsHandle = 0;
    }
    if (g_ShaderHandle != 0 and g_VertHandle != 0) {
        gl.glDetachShader(g_ShaderHandle, g_VertHandle);
    }
    if (g_ShaderHandle != 0 and g_FragHandle != 0) {
        gl.glDetachShader(g_ShaderHandle, g_FragHandle);
    }
    if (g_VertHandle != 0) {
        gl.glDeleteShader(g_VertHandle);
        g_VertHandle = 0;
    }
    if (g_FragHandle != 0) {
        gl.glDeleteShader(g_FragHandle);
        g_FragHandle = 0;
    }
    if (g_ShaderHandle != 0) {
        gl.glDeleteProgram(g_ShaderHandle);
        g_ShaderHandle = 0;
    }

    DestroyFontsTexture();
}
