const std = @import("std");
const ig = @import("imgui");
const builtin = @import("builtin");
const assert = std.debug.assert;

extern fn igGET_FLT_MAX() callconv(.C) f32;
extern fn igGET_FLT_MIN() callconv(.C) f32;

test "FLT_MAX" {
    assert(@bitCast(u32, ig.FLT_MAX) == @bitCast(u32, igGET_FLT_MAX()));
    const zig_flt_max: f32 = if (@hasDecl(std.math, "floatMax")) std.math.floatMax(f32) else std.math.f32_max;
    assert(@bitCast(u32, ig.FLT_MAX) == @bitCast(u32, zig_flt_max));
}

test "FLT_MIN" {
    assert(@bitCast(u32, ig.FLT_MIN) == @bitCast(u32, igGET_FLT_MIN()));
    const zig_flt_min: f32 = if (@hasDecl(std.math, "floatMin")) std.math.floatMin(f32) else std.math.f32_min;
    assert(@bitCast(u32, ig.FLT_MIN) == @bitCast(u32, zig_flt_min));
}

test "Check version" {
    ig.CHECKVERSION();
}

const skip_none = &[_][]const u8{};
fn compileEverything(comptime Outer: type, comptime skip_items: []const []const u8) void {
    inline for (@typeInfo(Outer).Struct.decls) |decl| {
        if (decl.is_pub) {
            const skip = comptime for (skip_items) |item| {
                if (std.mem.eql(u8, item, decl.name)) {
                    break true;
                }
            } else false;
            if (!skip) {
                const T = @TypeOf(@field(Outer, decl.name));
                if (T == type and @typeInfo(@field(Outer, decl.name)) == .Struct) {
                    compileEverything(@field(Outer, decl.name), skip_none);
                }
            }
        }
    }
}

test "Compile everything" {
    // This forces ig.FontAtlas to be analyzed before ig.Font,
    // which avoids a false positive circular dependency bug in stage 1.
    var atlas: ig.FontAtlas = undefined;
    _ = atlas;

    @setEvalBranchQuota(10000);
    // Compile static function wrappers
    compileEverything(ig, skip_none);

    // Compile instantiations of Vector
    // The skipping logic doesn't work in 0.9.1 or earlier
    if (comptime builtin.zig_version.order(std.SemanticVersion.parse("0.9.1") catch unreachable) == .gt) {
        const skip_value_type = &[_][]const u8{ "value_type" };
        const skip_clear_delete = skip_value_type ++ &[_][]const u8{ "clear_delete" };
        const skip_comparisons = skip_clear_delete ++ &[_][]const u8{ "contains", "find", "find_erase", "find_erase_unsorted", "eql" };
        compileEverything(ig.Vector(ig.Vec2), skip_clear_delete);
        compileEverything(ig.Vector(*ig.Vec4), skip_value_type);
        compileEverything(ig.Vector(?*ig.Vec4), skip_value_type);
        compileEverything(ig.Vector(*const ig.Vec4), skip_clear_delete);
        compileEverything(ig.Vector(?*const ig.Vec4), skip_clear_delete);
        compileEverything(ig.Vector(*ig.Vec4), skip_value_type);
        compileEverything(ig.Vector(?*ig.Vec4), skip_value_type);
        compileEverything(ig.Vector(u32), skip_clear_delete);
        compileEverything(ig.Vector(i32), skip_clear_delete);
        compileEverything(ig.Vector(*ig.Vector(u32)), skip_value_type);
        compileEverything(ig.Vector(?*ig.Vector(u32)), skip_value_type);
        compileEverything(ig.Vector(ig.Vector(u32)), skip_clear_delete);
        compileEverything(ig.Vector([*:0]u8), skip_clear_delete);
        compileEverything(ig.Vector(?[*:0]u8), skip_clear_delete);
        compileEverything(ig.Vector([*]u8), skip_clear_delete);
        compileEverything(ig.Vector(?[*]u8), skip_clear_delete);
        compileEverything(ig.Vector([]u8), skip_comparisons);
        compileEverything(ig.Vector(?[]u8), skip_comparisons);
    }
}
