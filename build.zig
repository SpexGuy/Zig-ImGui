const std = @import("std");
const builtin = @import("builtin");
const path = std.fs.path;
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;

const imgui_build = @import("zig-imgui/imgui_build.zig");

const glslc_command = if (builtin.os.tag == .windows) "tools/win/glslc.exe" else "glslc";

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    imgui_build.addTestStep(b, "test", mode, target);

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
    const exe = b.addExecutable(name, "examples/" ++ name ++ ".zig");
    exe.setBuildMode(mode);
    exe.setTarget(target);
    imgui_build.link(exe);
    exe.install();

    const run_step = b.step(name, "Run " ++ name);
    const run_cmd = exe.run();
    run_step.dependOn(&run_cmd.step);

    return exe;
}

fn linkGlad(exe: *LibExeObjStep, target: std.zig.CrossTarget) void {
    _ = target;
    exe.addIncludeDir("examples/include/c_include");
    exe.addCSourceFile("examples/c_src/glad.c", &[_][]const u8{"-std=c99"});
    //exe.linkSystemLibrary("opengl");
}

fn linkGlfw(exe: *LibExeObjStep, target: std.zig.CrossTarget) void {
    if (target.isWindows()) {
        exe.addObjectFile(if (target.getAbi() == .msvc) "examples/lib/win/glfw3.lib" else "examples/lib/win/libglfw3.a");
        exe.linkSystemLibrary("gdi32");
        exe.linkSystemLibrary("shell32");
    } else {
        exe.linkSystemLibrary("glfw");
    }
}

fn linkVulkan(exe: *LibExeObjStep, target: std.zig.CrossTarget) void {
    if (target.isWindows()) {
        exe.addObjectFile("examples/lib/win/vulkan-1.lib");
    } else {
        exe.linkSystemLibrary("vulkan");
    }
}
