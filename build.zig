const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    const test_exe = b.addTest("tests.zig");
    test_exe.setBuildMode(mode);
    test_exe.setTarget(target);
    
    link(test_exe, "cimgui/imgui");

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&test_exe.step);
}

fn srcFile() []const u8 {
    return @src().file;
}

const zig_imgui_path = std.fs.path.dirname(srcFile()).?;
const zig_file_path = zig_imgui_path ++ std.fs.path.sep_str ++ "generated" ++ std.fs.path.sep_str ++ "imgui.zig";
pub const pkg = std.build.Pkg{
    .name = "imgui",
    .source = .{ .path = zig_file_path },
};

pub fn link(exe: *std.build.LibExeObjStep, dear_imgui_path: []const u8) void {
    if (!std.mem.eql(u8, std.fs.path.basename(dear_imgui_path), "imgui")) {
        std.debug.print("Error: Zig-ImGui requires that Dear ImGui is inside a folder named 'imgui'\n    Cannot use the specified location: {s}\n", .{dear_imgui_path});
        std.os.exit(1);
    }
    const dir_containing_imgui = std.fs.path.dirname(dear_imgui_path) orelse ".";
    const imgui_cpp_file = zig_imgui_path ++ std.fs.path.sep_str ++ "cimgui_unity.cpp";

    exe.addPackage(pkg);
    exe.linkLibCpp();
    exe.addIncludePath(dir_containing_imgui);
    exe.addCSourceFile(imgui_cpp_file, &[_][]const u8 {
        "-fno-sanitize=undefined",
    });
}
