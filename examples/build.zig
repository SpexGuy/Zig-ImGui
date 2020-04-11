const std = @import("std");
const path = std.fs.path;
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;

const glslc_command = if (std.builtin.os.tag == .windows) "tools/win/glslc.exe" else "glslc";

pub fn build(b: *Builder) void {
    {
        const exe = exampleExe(b, "example_glfw_vulkan");
        linkGlfw(exe);
        linkVulkan(exe);
    }
    {
        const exe = exampleExe(b, "example_glfw_opengl3");
        linkGlfw(exe);
        linkGlad(exe);
    }
}

fn exampleExe(b: *Builder, comptime name: var) *LibExeObjStep {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable(name, name ++ ".zig");
    exe.setBuildMode(mode);
    exe.linkLibC();
    exe.addPackagePath("imgui", "../zig/imgui.zig");
    if (std.builtin.os.tag == .windows) {
        exe.linkSystemLibrary("../lib/win/cimguid");
    } else {
        @compileError("TODO: Build and link cimgui for non-windows platforms");
    }
    exe.install();

    const run_step = b.step(name, "Run " ++ name);
    const run_cmd = exe.run();
    run_step.dependOn(&run_cmd.step);

    return exe;
}

fn linkGlad(exe: *LibExeObjStep) void {
    exe.addIncludeDir("include/c_include");
    exe.addCSourceFile("c_src/glad.c", &[_][]const u8{"-std=c99"});
    //exe.linkSystemLibrary("opengl");
}

fn linkGlfw(exe: *LibExeObjStep) void {
    if (std.builtin.os.tag == .windows) {
        exe.linkSystemLibrary("lib/win/glfw3");
        exe.linkSystemLibrary("gdi32");
        exe.linkSystemLibrary("shell32");
    } else {
        exe.linkSystemLibrary("glfw");
    }
}

fn linkVulkan(exe: *LibExeObjStep) void {
    if (std.builtin.os.tag == .windows) {
        exe.linkSystemLibrary("lib/win/vulkan-1");
    } else {
        exe.linkSystemLibrary("vulkan");
    }
}

fn linkStbImage(exe: *LibExeObjStep) void {
    @compileError("This file hasn't actually been added to the project yet.");
    exe.addCSourceFile("c_src/stb_image.c", [_][]const u8{ "-std=c99", "-DSTB_IMAGE_IMPLEMENTATION=1" });
}

fn addShader(b: *Builder, exe: var, in_file: []const u8, out_file: []const u8) !void {
    // example:
    // glslc -o shaders/vert.spv shaders/shader.vert
    const dirname = "shaders";
    const full_in = try path.join(b.allocator, [_][]const u8{ dirname, in_file });
    const full_out = try path.join(b.allocator, [_][]const u8{ dirname, out_file });

    const run_cmd = b.addSystemCommand([_][]const u8{
        glslc_command,
        "-o",
        full_out,
        full_in,
    });
    exe.step.dependOn(&run_cmd.step);
}
