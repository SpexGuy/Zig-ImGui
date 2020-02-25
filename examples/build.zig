const std = @import("std");
const path = std.fs.path;
const Builder = std.build.Builder;

const glslc_command = if (std.os.windows.is_the_target) "tools/win/glslc.exe" else "glslc";

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    {
        const exe = b.addExecutable("example_glfw_vulkan", "example_glfw_vulkan/main.zig");
        exe.setBuildMode(mode);
        exe.linkLibC();
        //exe.addCSourceFile("extern_c/stb/stb_image.c", [_][]const u8{ "-std=c99", "-DSTB_IMAGE_IMPLEMENTATION=1" });
        if (std.os.windows.is_the_target) {
            exe.linkSystemLibrary("lib/win/glfw3dll");
            exe.linkSystemLibrary("lib/win/vulkan-1");
            exe.linkSystemLibrary("lib/win/cimguid");
        } else {
            exe.linkSystemLibrary("glfw");
            exe.linkSystemLibrary("vulkan");
            // @TODO: Build and link cimgui
        }

        //b.default_step.dependOn(&exe.step);
        exe.install();

        const run_step = b.step("example_glfw_vulkan_run", "Run the app");
        const run_cmd = exe.run();
        run_step.dependOn(&run_cmd.step);

        //try addShader(b, exe, "shader.vert", "vert.spv");
        //try addShader(b, exe, "shader.frag", "frag.spv");
    }
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
