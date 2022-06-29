const std = @import("std");
const builtin = @import("builtin");
const path = std.fs.path;
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;

const glslc_command = if (builtin.os.tag == .windows) "tools/win/glslc.exe" else "glslc";

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    {
        const exe = exampleExe(b, "example_glfw_vulkan", mode, target);
        linkGlfw(exe, target);
        linkVulkan(exe, target);
    }
    {
        const exe = exampleExe(b, "example_glfw_opengl3", mode, target);
        linkGlfw(exe, target);
        linkGlad(exe, target);
    }
}

fn exampleExe(b: *Builder, comptime name: []const u8, mode: std.builtin.Mode, target: std.zig.CrossTarget) *LibExeObjStep {
    const exe = b.addExecutable(name, name ++ ".zig");
    exe.setBuildMode(mode);
    exe.setTarget(target);

    exe.linkLibCpp();
    exe.addPackagePath("imgui", "../generated/imgui.zig");
    exe.addIncludePath("../cimgui");
    exe.addCSourceFile("../cimgui_unity.cpp", &[_][]const u8{
        "-fno-sanitize=undefined",
    });

    exe.install();

    const run_step = b.step(name, "Run " ++ name);
    const run_cmd = exe.run();
    run_step.dependOn(&run_cmd.step);

    return exe;
}

fn linkGlad(exe: *LibExeObjStep, target: std.zig.CrossTarget) void {
    _ = target;
    exe.addIncludeDir("include/c_include");
    exe.addCSourceFile("c_src/glad.c", &[_][]const u8{"-std=c99"});
    //exe.linkSystemLibrary("opengl");
}

fn linkGlfw(exe: *LibExeObjStep, target: std.zig.CrossTarget) void {
    if (target.isWindows()) {
        exe.addObjectFile(if (target.getAbi() == .msvc) "lib/win/glfw3.lib" else "lib/win/libglfw3.a");
        exe.linkSystemLibrary("gdi32");
        exe.linkSystemLibrary("shell32");
    } else {
        exe.linkSystemLibrary("glfw");
    }
}

fn linkVulkan(exe: *LibExeObjStep, target: std.zig.CrossTarget) void {
    if (target.isWindows()) {
        exe.addObjectFile("lib/win/vulkan-1.lib");
    } else {
        exe.linkSystemLibrary("vulkan");
    }
}

fn addShader(b: *Builder, exe: *LibExeObjStep, in_file: []const u8, out_file: []const u8) !void {
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
