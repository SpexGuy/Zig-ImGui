//! ==========================================================
//! This file is generated from template.zig and generate.bat.
//! Do not modify it by hand.
//! ==========================================================

const std = @import("std");
const builtin = @import("builtin");
const assert = @import("std").debug.assert;
const imgui = @This();

pub const DrawCallback_ResetRenderState = @intToPtr(DrawCallback, ~@as(usize, 0));

pub const VERSION = "1.88";
pub fn CHECKVERSION() void {
    if (builtin.mode != .ReleaseFast) {
        assert(raw.igDebugCheckVersionAndDataLayout(VERSION, @sizeOf(IO), @sizeOf(Style), @sizeOf(Vec2), @sizeOf(Vec4), @sizeOf(DrawVert), @sizeOf(DrawIdx)));
    }
}

pub const FLT_MAX: f32 = @bitCast(f32, @as(u32, 0x7F7FFFFF));
pub const FLT_MIN: f32 = @bitCast(f32, @as(u32, 0x00800000));

pub const FlagsInt = u32;

pub fn FlagsMixin(comptime FlagType: type) type {
    comptime assert(@sizeOf(FlagType) == 4);
    return struct {
        pub fn toInt(self: FlagType) FlagsInt {
            return @bitCast(FlagsInt, self);
        }
        pub fn fromInt(value: FlagsInt) FlagType {
            return @bitCast(FlagType, value);
        }
        pub fn with(a: FlagType, b: FlagType) FlagType {
            return fromInt(toInt(a) | toInt(b));
        }
        pub fn only(a: FlagType, b: FlagType) FlagType {
            return fromInt(toInt(a) & toInt(b));
        }
        pub fn without(a: FlagType, b: FlagType) FlagType {
            return fromInt(toInt(a) & ~toInt(b));
        }
        pub fn hasAllSet(a: FlagType, b: FlagType) bool {
            return (toInt(a) & toInt(b)) == toInt(b);
        }
        pub fn hasAnySet(a: FlagType, b: FlagType) bool {
            return (toInt(a) & toInt(b)) != 0;
        }
        pub fn isEmpty(a: FlagType) bool {
            return toInt(a) == 0;
        }
        pub fn eql(a: FlagType, b: FlagType) bool {
            return toInt(a) == toInt(b);
        }
    };
}

fn destruct(comptime T: type, ptr: *T) void {
    if (@typeInfo(T) == .Struct or @typeInfo(T) == .Union) {
        if (@hasDecl(T, "deinit")) {
            ptr.deinit();
        }
    }
}

fn eql(comptime T: type, a: T, b: T) bool {
    if (@typeInfo(T) == .Struct or @typeInfo(T) == .Union) {
        if (@hasDecl(T, "eql")) {
            return a.eql(b);
        }
    }
    return a == b;
}

pub fn Vector(comptime T: type) type {
    return extern struct {
        Size: u32 = 0,
        Capacity: u32 = 0,
        Data: ?[*]T = null,

        // Provide standard typedefs but we don't use them ourselves.
        pub const value_type = T;

        // Constructors, destructor
        pub fn deinit(self: *@This()) void {
            if (self.Data) |d| raw.igMemFree(@ptrCast(*anyopaque, d));
            self.* = undefined;
        }

        pub fn clone(self: @This()) @This() {
            var cloned = @This(){};
            if (self.Size != 0) {
                cloned.resize_undefined(self.Size);
                @memcpy(@ptrCast([*]u8, cloned.Data.?), @ptrCast([*]const u8, self.Data.?), self.Size * @sizeOf(T));
            }
            return cloned;
        }

        pub fn copy(self: *@This(), other: @This()) void {
            self.Size = 0;
            if (other.Size != 0) {
                self.resize_undefined(other.Size);
                @memcpy(@ptrCast([*]u8, self.Data.?), @ptrCast([*]const u8, other.Data.?), other.Size * @sizeOf(T));
            }
        }

        pub fn from_slice(slice: []const T) @This() {
            var result = @This(){};
            if (slice.len != 0) {
                result.resize_undefined(@intCast(u32, slice.len));
                @memcpy(@ptrCast([*]u8, result.Data.?), @ptrCast([*]const u8, slice.ptr), slice.len * @sizeOf(T));
            }
            return result;
        }

        /// Important: does not destruct anything
        pub fn clear(self: *@This()) void {
            if (self.Data) |d| raw.igMemFree(@ptrCast(?*anyopaque, d));
            self.* = .{};
        }

        /// Destruct and delete all pointer values, then clear the array.
        /// T must be a pointer or optional pointer.
        pub fn clear_delete(self: *@This()) void {
            comptime var ti = @typeInfo(T);
            const is_optional = (ti == .Optional);
            if (is_optional) ti = @typeInfo(ti.Optional.child);
            if (ti != .Pointer or ti.Pointer.is_const or ti.Pointer.size != .One)
                @compileError("clear_delete() can only be called on vectors of mutable single-item pointers, cannot apply to Vector(" ++ @typeName(T) ++ ").");
            const ValueT = ti.Pointer.child;

            if (is_optional) {
                for (self.items()) |it| {
                    if (it) |_ptr| {
                        const ptr: *ValueT = _ptr;
                        destruct(ValueT, ptr);
                        raw.igMemFree(ptr);
                    }
                }
            } else {
                for (self.items()) |_ptr| {
                    const ptr: *ValueT = _ptr;
                    destruct(ValueT, ptr);
                    raw.igMemFree(@ptrCast(?*anyopaque, ptr));
                }
            }
            self.clear();
        }

        pub fn clear_destruct(self: *@This()) void {
            for (self.items()) |*ptr| {
                destruct(T, ptr);
            }
            self.clear();
        }

        pub fn empty(self: @This()) bool {
            return self.Size == 0;
        }

        pub fn size(self: @This()) u32 {
            return self.Size;
        }

        pub fn size_in_bytes(self: @This()) u32 {
            return self.Size * @sizeOf(T);
        }

        pub fn max_size(self: @This()) u32 {
            _ = self;
            return 0x7FFFFFFF / @sizeOf(T);
        }

        pub fn items(self: @This()) []T {
            return if (self.Size == 0) &[_]T{} else self.Data.?[0..self.Size];
        }

        pub fn _grow_capacity(self: @This(), sz: u32) u32 {
            const new_cap: u32 = if (self.Capacity == 0) 8 else (self.Capacity + self.Capacity / 2);
            return if (new_cap > sz) new_cap else sz;
        }

        pub fn resize_undefined(self: *@This(), new_size: u32) void {
            if (new_size > self.Capacity)
                self.reserve(self._grow_capacity(new_size));
            self.Size = new_size;
        }
        pub fn resize_splat(self: *@This(), new_size: u32, value: T) void {
            if (new_size > self.Capacity)
                self.reserve(self._grow_capacity(new_size));
            if (new_size > self.Size)
                std.mem.set(T, self.Data.?[self.Size..new_size], value);
            self.Size = new_size;
        }
        /// Resize a vector to a smaller size, guaranteed not to cause a reallocation
        pub fn shrink(self: *@This(), new_size: u32) void {
            assert(new_size <= self.Size);
            self.Size = new_size;
        }
        pub fn reserve(self: *@This(), new_capacity: u32) void {
            if (new_capacity <= self.Capacity) return;
            const new_data = @ptrCast(?[*]T, @alignCast(@alignOf(T), raw.igMemAlloc(new_capacity * @sizeOf(T))));
            if (self.Data) |sd| {
                if (self.Size != 0) {
                    @memcpy(@ptrCast([*]u8, new_data.?), @ptrCast([*]const u8, sd), self.Size * @sizeOf(T));
                }
                raw.igMemFree(@ptrCast(*anyopaque, sd));
            }
            self.Data = new_data;
            self.Capacity = new_capacity;
        }
        pub fn reserve_discard(self: *@This(), new_capacity: u32) void {
            if (new_capacity <= self.Capacity) return;
            if (self.Data) |sd| raw.igMemFree(@ptrCast(*anyopaque, sd));
            self.Data = @ptrCast(?[*]T, @alignCast(@alignOf(T), raw.igMemAlloc(new_capacity * @sizeOf(T))));
            self.Capacity = new_capacity;
        }

        // NB: It is illegal to call push_back/push_front/insert with a reference pointing inside the ImVector data itself! e.g. v.push_back(v.items()[10]) is forbidden.
        pub fn push_back(self: *@This(), v: T) void {
            if (self.Size == self.Capacity)
                self.reserve(self._grow_capacity(self.Size + 1));
            self.Data.?[self.Size] = v;
            self.Size += 1;
        }
        pub fn pop_back(self: *@This()) void {
            self.Size -= 1;
        }
        pub fn push_front(self: *@This(), v: T) void {
            if (self.Size == 0) self.push_back(v) else self.insert(0, v);
        }
        pub fn erase(self: *@This(), index: u32) void {
            assert(index < self.Size);
            self.Size -= 1;
            const len = self.Size;
            if (index < len) {
                var it = index;
                const data = self.Data.?;
                while (it < len) : (it += 1) {
                    data[it] = data[it + 1];
                }
            }
        }
        pub fn erase_range(self: *@This(), start: u32, end: u32) void {
            assert(start <= end);
            assert(end <= self.Size);
            if (start == end) return;
            const len = self.Size;
            self.Size -= (end - start);
            if (end < len) {
                var it = start;
                var end_it = end;
                const data = self.Data.?;
                while (end_it < len) : ({ it += 1; end_it += 1; }) {
                    data[it] = data[end_it];
                }
            }
        }
        pub fn erase_unsorted(self: *@This(), index: u32) void {
            assert(index < self.Size);
            self.Size -= 1;
            if (index != self.Size) {
                self.Data.?[index] = self.Data.?[self.Size];
            }
        }
        pub fn insert(self: *@This(), index: u32, v: T) void {
            assert(index <= self.Size);
            if (self.Size == self.Capacity)
                self.reserve(self._grow_capacity(self.Size + 1));
            const data = self.Data.?;
            if (index < self.Size) {
                var it = self.Size;
                while (it > index) : (it -= 1) {
                    data[it] = data[it-1];
                }
            }
            data[index] = v;
            self.Size += 1;
        }
        pub fn contains(self: @This(), v: T) bool {
            for (self.items()) |*it| {
                if (imgui.eql(T, v, it.*)) return true;
            }
            return false;
        }
        pub fn find(self: @This(), v: T) ?u32 {
            return for (self.items()) |*it, i| {
                if (imgui.eql(T, v, it.*)) break @intCast(u32, i);
            } else null;
        }
        pub fn find_erase(self: *@This(), v: T) bool {
            if (self.find(v)) |idx| {
                self.erase(idx);
                return true;
            }
            return false;
        }
        pub fn find_erase_unsorted(self: *@This(), v: T) bool {
            if (self.find(v)) |idx| {
                self.erase_unsorted(idx);
                return true;
            }
            return false;
        }

        pub fn eql(self: @This(), other: @This()) bool {
            if (self.Size != other.Size) return false;
            var i: u32 = 0;
            while (i < self.Size) : (i += 1) {
                if (!imgui.eql(T, self.Data.?[i], other.Data.?[i]))
                    return false;
            }
            return true;
        }
    };
}

pub const Vec2 = extern struct {
    x: f32 = 0,
    y: f32 = 0,
    
    pub fn init(x: f32, y: f32) Vec4 {
        return .{ .x = x, .y = y };
    }

    pub fn eql(self: Vec2, other: Vec2) bool {
        return self.x == other.x and self.y == other.y;
    }
};

pub const Vec4 = extern struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
    w: f32 = 0,

    pub fn init(x: f32, y: f32, z: f32, w: f32) Vec4 {
        return .{ .x = x, .y = y, .z = z, .w = w };
    }

    pub fn eql(self: Vec4, other: Vec4) bool {
        return self.x == other.x
            and self.y == other.y
            and self.z == other.z
            and self.w == other.w;
    }
};

pub const Color = extern struct {
    Value: Vec4,

    pub fn initRGBA(r: f32, g: f32, b: f32, a: f32) Color {
        return .{ .Value = Vec4.init(r, g, b, a) };
    }
    pub fn initRGB(r: f32, g: f32, b: f32) Color {
        return initRGBA(r, g, b, 1.0);
    }

    pub fn initRGBAUnorm(r: u8, g: u8, b: u8, a: u8) Color {
        const inv_255: f32 = 1.0 / 255.0;
        return initRGBA(
            @intToFloat(f32, r) * inv_255,
            @intToFloat(f32, g) * inv_255,
            @intToFloat(f32, b) * inv_255,
            @intToFloat(f32, a) * inv_255,
        );
    }
    pub fn initRGBUnorm(r: u8, g: u8, b: u8) Color {
        const inv_255: f32 = 1.0 / 255.0;
        return initRGBA(
            @intToFloat(f32, r) * inv_255,
            @intToFloat(f32, g) * inv_255,
            @intToFloat(f32, b) * inv_255,
            1.0,
        );
    }

    /// Convert HSVA to RGBA color
    pub fn initHSVA(h: f32, s: f32, v: f32, a: f32) Color {
        var r: f32 = undefined;
        var g: f32 = undefined;
        var b: f32 = undefined;
        ColorConvertHSVtoRGB(h, s, v, &r, &g, &b);
        return initRGBA(r, g, b, a);
    }
    pub fn initHSV(h: f32, s: f32, v: f32) Color {
        return initHSVA(h, s, v, 1.0);
    }

    /// Convert an integer 0xaabbggrr to a floating point color
    pub fn initABGRPacked(value: u32) Color {
        return initRGBAUnorm(
            @truncate(u8, value >>  0),
            @truncate(u8, value >>  8),
            @truncate(u8, value >> 16),
            @truncate(u8, value >> 24),
        );
    }
    /// Convert from a floating point color to an integer 0xaabbggrr
    pub fn packABGR(self: Color) u32 {
        return ColorConvertFloat4ToU32(self.Value);
    }

    pub fn eql(self: Color, other: Color) bool {
        return self.Value.eql(other.Value);
    }
};

fn imguiZigAlloc(_: *anyopaque, len: usize, ptr_align: u29, len_align: u29, ret_addr: usize) std.mem.Allocator.Error![]u8 {
    _ = len_align; _ = ret_addr;
    assert(ptr_align <= @alignOf(*anyopaque)); // Alignment larger than pointers is not supported
    return @ptrCast([*]u8, raw.igMemAlloc(len) orelse return error.OutOfMemory)[0..len];
}
fn imguiZigResize(_: *anyopaque, buf: []u8, buf_align: u29, new_len: usize, len_align: u29, ret_addr: usize) ?usize {
    _ = len_align; _ = ret_addr;
    assert(buf_align <= @alignOf(*anyopaque)); // Alignment larger than pointers is not supported
    if (new_len > buf.len) return null;
    if (new_len == 0 and buf.len != 0) raw.igMemFree(buf.ptr);
    return new_len;
}
fn imguiZigFree(_: *anyopaque, buf: []u8, buf_align: u29, ret_addr: usize) void {
    _ = buf_align; _ = ret_addr;
    if (buf.len != 0) raw.igMemFree(buf.ptr);
}

const allocator_vtable: std.mem.Allocator.VTable = .{
    .alloc = imguiZigAlloc,
    .resize = imguiZigResize,
    .free = imguiZigFree,
};

pub const allocator: std.mem.Allocator = .{
    .ptr = undefined,
    .vtable = &allocator_vtable,
};

// ---------------- Everything above here comes from template.zig ------------------
// ---------------- Everything below here is generated -----------------------------

