//! ==========================================================
//! This file is generated from template.zig and generate.bat.
//! Do not modify it by hand.
//! ==========================================================

const std = @import("std");
const builtin = @import("builtin");
const assert = @import("std").debug.assert;
const imgui = @This();

pub const DrawCallback_ResetRenderState = @intToPtr(DrawCallback, ~@as(usize, 3));

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
                while (end_it < len) : ({
                    it += 1;
                    end_it += 1;
                }) {
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
                    data[it] = data[it - 1];
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
        return self.x == other.x and self.y == other.y and self.z == other.z and self.w == other.w;
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
            @truncate(u8, value >> 0),
            @truncate(u8, value >> 8),
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
    _ = len_align;
    _ = ret_addr;
    assert(ptr_align <= @alignOf(*anyopaque)); // Alignment larger than pointers is not supported
    return @ptrCast([*]u8, raw.igMemAlloc(len) orelse return error.OutOfMemory)[0..len];
}
fn imguiZigResize(_: *anyopaque, buf: []u8, buf_align: u29, new_len: usize, len_align: u29, ret_addr: usize) ?usize {
    _ = len_align;
    _ = ret_addr;
    assert(buf_align <= @alignOf(*anyopaque)); // Alignment larger than pointers is not supported
    if (new_len > buf.len) return null;
    if (new_len == 0 and buf.len != 0) raw.igMemFree(buf.ptr);
    return new_len;
}
fn imguiZigFree(_: *anyopaque, buf: []u8, buf_align: u29, ret_addr: usize) void {
    _ = buf_align;
    _ = ret_addr;
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

pub const DrawListSharedData = opaque {};
pub const FontBuilderIO = opaque {};
pub const Context = opaque {};
pub const DrawCallback = ?*const fn (parent_list: ?*const DrawList, cmd: ?*const DrawCmd) callconv(.C) void;
pub const DrawIdx = u16;
pub const ID = u32;
pub const InputTextCallback = ?*const fn (data: ?*InputTextCallbackData) callconv(.C) i32;
pub const MemAllocFunc = ?*const fn (sz: usize, user_data: ?*anyopaque) callconv(.C) ?*anyopaque;
pub const MemFreeFunc = ?*const fn (ptr: ?*anyopaque, user_data: ?*anyopaque) callconv(.C) void;
pub const SizeCallback = ?*const fn (data: ?*SizeCallbackData) callconv(.C) void;
pub const TextureID = ?*anyopaque;
pub const Wchar = Wchar16;
pub const Wchar16 = u16;
pub const Wchar32 = u32;

pub const DrawFlagsInt = FlagsInt;
pub const DrawFlags = packed struct {
    Closed: bool = false,
    __reserved_bit_01: bool = false,
    __reserved_bit_02: bool = false,
    __reserved_bit_03: bool = false,
    RoundCornersTopLeft: bool = false,
    RoundCornersTopRight: bool = false,
    RoundCornersBottomLeft: bool = false,
    RoundCornersBottomRight: bool = false,
    RoundCornersNone: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const RoundCornersTop: @This() = .{ .RoundCornersTopLeft=true, .RoundCornersTopRight=true };
    pub const RoundCornersBottom: @This() = .{ .RoundCornersBottomLeft=true, .RoundCornersBottomRight=true };
    pub const RoundCornersLeft: @This() = .{ .RoundCornersTopLeft=true, .RoundCornersBottomLeft=true };
    pub const RoundCornersRight: @This() = .{ .RoundCornersTopRight=true, .RoundCornersBottomRight=true };
    pub const RoundCornersAll: @This() = .{ .RoundCornersTopLeft=true, .RoundCornersTopRight=true, .RoundCornersBottomLeft=true, .RoundCornersBottomRight=true };
    pub const RoundCornersDefault_: @This() = .{ .RoundCornersTopLeft=true, .RoundCornersTopRight=true, .RoundCornersBottomLeft=true, .RoundCornersBottomRight=true };
    pub const RoundCornersMask_: @This() = .{ .RoundCornersTopLeft=true, .RoundCornersTopRight=true, .RoundCornersBottomLeft=true, .RoundCornersBottomRight=true, .RoundCornersNone=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const DrawListFlagsInt = FlagsInt;
pub const DrawListFlags = packed struct {
    AntiAliasedLines: bool = false,
    AntiAliasedLinesUseTex: bool = false,
    AntiAliasedFill: bool = false,
    AllowVtxOffset: bool = false,
    __reserved_bit_04: bool = false,
    __reserved_bit_05: bool = false,
    __reserved_bit_06: bool = false,
    __reserved_bit_07: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};

    pub usingnamespace FlagsMixin(@This());
};

pub const FontAtlasFlagsInt = FlagsInt;
pub const FontAtlasFlags = packed struct {
    NoPowerOfTwoHeight: bool = false,
    NoMouseCursors: bool = false,
    NoBakedLines: bool = false,
    __reserved_bit_03: bool = false,
    __reserved_bit_04: bool = false,
    __reserved_bit_05: bool = false,
    __reserved_bit_06: bool = false,
    __reserved_bit_07: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};

    pub usingnamespace FlagsMixin(@This());
};

pub const BackendFlagsInt = FlagsInt;
pub const BackendFlags = packed struct {
    HasGamepad: bool = false,
    HasMouseCursors: bool = false,
    HasSetMousePos: bool = false,
    RendererHasVtxOffset: bool = false,
    __reserved_bit_04: bool = false,
    __reserved_bit_05: bool = false,
    __reserved_bit_06: bool = false,
    __reserved_bit_07: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};

    pub usingnamespace FlagsMixin(@This());
};

pub const ButtonFlagsInt = FlagsInt;
pub const ButtonFlags = packed struct {
    MouseButtonLeft: bool = false,
    MouseButtonRight: bool = false,
    MouseButtonMiddle: bool = false,
    __reserved_bit_03: bool = false,
    __reserved_bit_04: bool = false,
    __reserved_bit_05: bool = false,
    __reserved_bit_06: bool = false,
    __reserved_bit_07: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const MouseButtonMask_: @This() = .{ .MouseButtonLeft=true, .MouseButtonRight=true, .MouseButtonMiddle=true };
    pub const MouseButtonDefault_: @This() = .{ .MouseButtonLeft=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const ColorEditFlagsInt = FlagsInt;
pub const ColorEditFlags = packed struct {
    __reserved_bit_00: bool = false,
    NoAlpha: bool = false,
    NoPicker: bool = false,
    NoOptions: bool = false,
    NoSmallPreview: bool = false,
    NoInputs: bool = false,
    NoTooltip: bool = false,
    NoLabel: bool = false,
    NoSidePreview: bool = false,
    NoDragDrop: bool = false,
    NoBorder: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    AlphaBar: bool = false,
    AlphaPreview: bool = false,
    AlphaPreviewHalf: bool = false,
    HDR: bool = false,
    DisplayRGB: bool = false,
    DisplayHSV: bool = false,
    DisplayHex: bool = false,
    Uint8: bool = false,
    Float: bool = false,
    PickerHueBar: bool = false,
    PickerHueWheel: bool = false,
    InputRGB: bool = false,
    InputHSV: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const DefaultOptions_: @This() = .{ .DisplayRGB=true, .Uint8=true, .PickerHueBar=true, .InputRGB=true };
    pub const DisplayMask_: @This() = .{ .DisplayRGB=true, .DisplayHSV=true, .DisplayHex=true };
    pub const DataTypeMask_: @This() = .{ .Uint8=true, .Float=true };
    pub const PickerMask_: @This() = .{ .PickerHueBar=true, .PickerHueWheel=true };
    pub const InputMask_: @This() = .{ .InputRGB=true, .InputHSV=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const ComboFlagsInt = FlagsInt;
pub const ComboFlags = packed struct {
    PopupAlignLeft: bool = false,
    HeightSmall: bool = false,
    HeightRegular: bool = false,
    HeightLarge: bool = false,
    HeightLargest: bool = false,
    NoArrowButton: bool = false,
    NoPreview: bool = false,
    __reserved_bit_07: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const HeightMask_: @This() = .{ .HeightSmall=true, .HeightRegular=true, .HeightLarge=true, .HeightLargest=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const CondFlagsInt = FlagsInt;
pub const CondFlags = packed struct {
    Always: bool = false,
    Once: bool = false,
    FirstUseEver: bool = false,
    Appearing: bool = false,
    __reserved_bit_04: bool = false,
    __reserved_bit_05: bool = false,
    __reserved_bit_06: bool = false,
    __reserved_bit_07: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};

    pub usingnamespace FlagsMixin(@This());
};

pub const ConfigFlagsInt = FlagsInt;
pub const ConfigFlags = packed struct {
    NavEnableKeyboard: bool = false,
    NavEnableGamepad: bool = false,
    NavEnableSetMousePos: bool = false,
    NavNoCaptureKeyboard: bool = false,
    NoMouse: bool = false,
    NoMouseCursorChange: bool = false,
    __reserved_bit_06: bool = false,
    __reserved_bit_07: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    IsSRGB: bool = false,
    IsTouchScreen: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};

    pub usingnamespace FlagsMixin(@This());
};

pub const DragDropFlagsInt = FlagsInt;
pub const DragDropFlags = packed struct {
    SourceNoPreviewTooltip: bool = false,
    SourceNoDisableHover: bool = false,
    SourceNoHoldToOpenOthers: bool = false,
    SourceAllowNullID: bool = false,
    SourceExtern: bool = false,
    SourceAutoExpirePayload: bool = false,
    __reserved_bit_06: bool = false,
    __reserved_bit_07: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    AcceptBeforeDelivery: bool = false,
    AcceptNoDrawDefaultRect: bool = false,
    AcceptNoPreviewTooltip: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const AcceptPeekOnly: @This() = .{ .AcceptBeforeDelivery=true, .AcceptNoDrawDefaultRect=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const FocusedFlagsInt = FlagsInt;
pub const FocusedFlags = packed struct {
    ChildWindows: bool = false,
    RootWindow: bool = false,
    AnyWindow: bool = false,
    NoPopupHierarchy: bool = false,
    __reserved_bit_04: bool = false,
    __reserved_bit_05: bool = false,
    __reserved_bit_06: bool = false,
    __reserved_bit_07: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const RootAndChildWindows: @This() = .{ .ChildWindows=true, .RootWindow=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const HoveredFlagsInt = FlagsInt;
pub const HoveredFlags = packed struct {
    ChildWindows: bool = false,
    RootWindow: bool = false,
    AnyWindow: bool = false,
    NoPopupHierarchy: bool = false,
    __reserved_bit_04: bool = false,
    AllowWhenBlockedByPopup: bool = false,
    __reserved_bit_06: bool = false,
    AllowWhenBlockedByActiveItem: bool = false,
    AllowWhenOverlapped: bool = false,
    AllowWhenDisabled: bool = false,
    NoNavOverride: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const RectOnly: @This() = .{ .AllowWhenBlockedByPopup=true, .AllowWhenBlockedByActiveItem=true, .AllowWhenOverlapped=true };
    pub const RootAndChildWindows: @This() = .{ .ChildWindows=true, .RootWindow=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const InputTextFlagsInt = FlagsInt;
pub const InputTextFlags = packed struct {
    CharsDecimal: bool = false,
    CharsHexadecimal: bool = false,
    CharsUppercase: bool = false,
    CharsNoBlank: bool = false,
    AutoSelectAll: bool = false,
    EnterReturnsTrue: bool = false,
    CallbackCompletion: bool = false,
    CallbackHistory: bool = false,
    CallbackAlways: bool = false,
    CallbackCharFilter: bool = false,
    AllowTabInput: bool = false,
    CtrlEnterForNewLine: bool = false,
    NoHorizontalScroll: bool = false,
    AlwaysOverwrite: bool = false,
    ReadOnly: bool = false,
    Password: bool = false,
    NoUndoRedo: bool = false,
    CharsScientific: bool = false,
    CallbackResize: bool = false,
    CallbackEdit: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};

    pub usingnamespace FlagsMixin(@This());
};

pub const ModFlagsInt = FlagsInt;
pub const ModFlags = packed struct {
    Ctrl: bool = false,
    Shift: bool = false,
    Alt: bool = false,
    Super: bool = false,
    __reserved_bit_04: bool = false,
    __reserved_bit_05: bool = false,
    __reserved_bit_06: bool = false,
    __reserved_bit_07: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};

    pub usingnamespace FlagsMixin(@This());
};

pub const PopupFlagsInt = FlagsInt;
pub const PopupFlags = packed struct {
    MouseButtonRight: bool = false,
    MouseButtonMiddle: bool = false,
    __reserved_bit_02: bool = false,
    __reserved_bit_03: bool = false,
    __reserved_bit_04: bool = false,
    NoOpenOverExistingPopup: bool = false,
    NoOpenOverItems: bool = false,
    AnyPopupId: bool = false,
    AnyPopupLevel: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const MouseButtonLeft: @This() = .{};
    pub const MouseButtonMask_: @This() = .{ .MouseButtonRight=true, .MouseButtonMiddle=true, .__reserved_bit_02=true, .__reserved_bit_03=true, .__reserved_bit_04=true };
    pub const MouseButtonDefault_: @This() = .{ .MouseButtonRight=true };
    pub const AnyPopup: @This() = .{ .AnyPopupId=true, .AnyPopupLevel=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const SelectableFlagsInt = FlagsInt;
pub const SelectableFlags = packed struct {
    DontClosePopups: bool = false,
    SpanAllColumns: bool = false,
    AllowDoubleClick: bool = false,
    Disabled: bool = false,
    AllowItemOverlap: bool = false,
    __reserved_bit_05: bool = false,
    __reserved_bit_06: bool = false,
    __reserved_bit_07: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};

    pub usingnamespace FlagsMixin(@This());
};

pub const SliderFlagsInt = FlagsInt;
pub const SliderFlags = packed struct {
    __reserved_bit_00: bool = false,
    __reserved_bit_01: bool = false,
    __reserved_bit_02: bool = false,
    __reserved_bit_03: bool = false,
    AlwaysClamp: bool = false,
    Logarithmic: bool = false,
    NoRoundToFormat: bool = false,
    NoInput: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const InvalidMask_: @This() = .{ .__reserved_bit_00=true, .__reserved_bit_01=true, .__reserved_bit_02=true, .__reserved_bit_03=true, .__reserved_bit_28=true, .__reserved_bit_29=true, .__reserved_bit_30=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const TabBarFlagsInt = FlagsInt;
pub const TabBarFlags = packed struct {
    Reorderable: bool = false,
    AutoSelectNewTabs: bool = false,
    TabListPopupButton: bool = false,
    NoCloseWithMiddleMouseButton: bool = false,
    NoTabListScrollingButtons: bool = false,
    NoTooltip: bool = false,
    FittingPolicyResizeDown: bool = false,
    FittingPolicyScroll: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const FittingPolicyMask_: @This() = .{ .FittingPolicyResizeDown=true, .FittingPolicyScroll=true };
    pub const FittingPolicyDefault_: @This() = .{ .FittingPolicyResizeDown=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const TabItemFlagsInt = FlagsInt;
pub const TabItemFlags = packed struct {
    UnsavedDocument: bool = false,
    SetSelected: bool = false,
    NoCloseWithMiddleMouseButton: bool = false,
    NoPushId: bool = false,
    NoTooltip: bool = false,
    NoReorder: bool = false,
    Leading: bool = false,
    Trailing: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};

    pub usingnamespace FlagsMixin(@This());
};

pub const TableColumnFlagsInt = FlagsInt;
pub const TableColumnFlags = packed struct {
    Disabled: bool = false,
    DefaultHide: bool = false,
    DefaultSort: bool = false,
    WidthStretch: bool = false,
    WidthFixed: bool = false,
    NoResize: bool = false,
    NoReorder: bool = false,
    NoHide: bool = false,
    NoClip: bool = false,
    NoSort: bool = false,
    NoSortAscending: bool = false,
    NoSortDescending: bool = false,
    NoHeaderLabel: bool = false,
    NoHeaderWidth: bool = false,
    PreferSortAscending: bool = false,
    PreferSortDescending: bool = false,
    IndentEnable: bool = false,
    IndentDisable: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    IsEnabled: bool = false,
    IsVisible: bool = false,
    IsSorted: bool = false,
    IsHovered: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    NoDirectResize_: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const WidthMask_: @This() = .{ .WidthStretch=true, .WidthFixed=true };
    pub const IndentMask_: @This() = .{ .IndentEnable=true, .IndentDisable=true };
    pub const StatusMask_: @This() = .{ .IsEnabled=true, .IsVisible=true, .IsSorted=true, .IsHovered=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const TableFlagsInt = FlagsInt;
pub const TableFlags = packed struct {
    Resizable: bool = false,
    Reorderable: bool = false,
    Hideable: bool = false,
    Sortable: bool = false,
    NoSavedSettings: bool = false,
    ContextMenuInBody: bool = false,
    RowBg: bool = false,
    BordersInnerH: bool = false,
    BordersOuterH: bool = false,
    BordersInnerV: bool = false,
    BordersOuterV: bool = false,
    NoBordersInBody: bool = false,
    NoBordersInBodyUntilResize: bool = false,
    SizingFixedFit: bool = false,
    SizingFixedSame: bool = false,
    SizingStretchSame: bool = false,
    NoHostExtendX: bool = false,
    NoHostExtendY: bool = false,
    NoKeepColumnsVisible: bool = false,
    PreciseWidths: bool = false,
    NoClip: bool = false,
    PadOuterX: bool = false,
    NoPadOuterX: bool = false,
    NoPadInnerX: bool = false,
    ScrollX: bool = false,
    ScrollY: bool = false,
    SortMulti: bool = false,
    SortTristate: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const BordersH: @This() = .{ .BordersInnerH=true, .BordersOuterH=true };
    pub const BordersV: @This() = .{ .BordersInnerV=true, .BordersOuterV=true };
    pub const BordersInner: @This() = .{ .BordersInnerH=true, .BordersInnerV=true };
    pub const BordersOuter: @This() = .{ .BordersOuterH=true, .BordersOuterV=true };
    pub const Borders: @This() = .{ .BordersInnerH=true, .BordersOuterH=true, .BordersInnerV=true, .BordersOuterV=true };
    pub const SizingStretchProp: @This() = .{ .SizingFixedFit=true, .SizingFixedSame=true };
    pub const SizingMask_: @This() = .{ .SizingFixedFit=true, .SizingFixedSame=true, .SizingStretchSame=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const TableRowFlagsInt = FlagsInt;
pub const TableRowFlags = packed struct {
    Headers: bool = false,
    __reserved_bit_01: bool = false,
    __reserved_bit_02: bool = false,
    __reserved_bit_03: bool = false,
    __reserved_bit_04: bool = false,
    __reserved_bit_05: bool = false,
    __reserved_bit_06: bool = false,
    __reserved_bit_07: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};

    pub usingnamespace FlagsMixin(@This());
};

pub const TreeNodeFlagsInt = FlagsInt;
pub const TreeNodeFlags = packed struct {
    Selected: bool = false,
    Framed: bool = false,
    AllowItemOverlap: bool = false,
    NoTreePushOnOpen: bool = false,
    NoAutoOpenOnLog: bool = false,
    DefaultOpen: bool = false,
    OpenOnDoubleClick: bool = false,
    OpenOnArrow: bool = false,
    Leaf: bool = false,
    Bullet: bool = false,
    FramePadding: bool = false,
    SpanAvailWidth: bool = false,
    SpanFullWidth: bool = false,
    NavLeftJumpsBackHere: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const CollapsingHeader: @This() = .{ .Framed=true, .NoTreePushOnOpen=true, .NoAutoOpenOnLog=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const ViewportFlagsInt = FlagsInt;
pub const ViewportFlags = packed struct {
    IsPlatformWindow: bool = false,
    IsPlatformMonitor: bool = false,
    OwnedByApp: bool = false,
    __reserved_bit_03: bool = false,
    __reserved_bit_04: bool = false,
    __reserved_bit_05: bool = false,
    __reserved_bit_06: bool = false,
    __reserved_bit_07: bool = false,
    __reserved_bit_08: bool = false,
    __reserved_bit_09: bool = false,
    __reserved_bit_10: bool = false,
    __reserved_bit_11: bool = false,
    __reserved_bit_12: bool = false,
    __reserved_bit_13: bool = false,
    __reserved_bit_14: bool = false,
    __reserved_bit_15: bool = false,
    __reserved_bit_16: bool = false,
    __reserved_bit_17: bool = false,
    __reserved_bit_18: bool = false,
    __reserved_bit_19: bool = false,
    __reserved_bit_20: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    __reserved_bit_23: bool = false,
    __reserved_bit_24: bool = false,
    __reserved_bit_25: bool = false,
    __reserved_bit_26: bool = false,
    __reserved_bit_27: bool = false,
    __reserved_bit_28: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};

    pub usingnamespace FlagsMixin(@This());
};

pub const WindowFlagsInt = FlagsInt;
pub const WindowFlags = packed struct {
    NoTitleBar: bool = false,
    NoResize: bool = false,
    NoMove: bool = false,
    NoScrollbar: bool = false,
    NoScrollWithMouse: bool = false,
    NoCollapse: bool = false,
    AlwaysAutoResize: bool = false,
    NoBackground: bool = false,
    NoSavedSettings: bool = false,
    NoMouseInputs: bool = false,
    MenuBar: bool = false,
    HorizontalScrollbar: bool = false,
    NoFocusOnAppearing: bool = false,
    NoBringToFrontOnFocus: bool = false,
    AlwaysVerticalScrollbar: bool = false,
    AlwaysHorizontalScrollbar: bool = false,
    AlwaysUseWindowPadding: bool = false,
    __reserved_bit_17: bool = false,
    NoNavInputs: bool = false,
    NoNavFocus: bool = false,
    UnsavedDocument: bool = false,
    __reserved_bit_21: bool = false,
    __reserved_bit_22: bool = false,
    NavFlattened: bool = false,
    ChildWindow: bool = false,
    Tooltip: bool = false,
    Popup: bool = false,
    Modal: bool = false,
    ChildMenu: bool = false,
    __reserved_bit_29: bool = false,
    __reserved_bit_30: bool = false,
    __reserved_bit_31: bool = false,

    pub const None: @This() = .{};
    pub const NoNav: @This() = .{ .NoNavInputs=true, .NoNavFocus=true };
    pub const NoDecoration: @This() = .{ .NoTitleBar=true, .NoResize=true, .NoScrollbar=true, .NoCollapse=true };
    pub const NoInputs: @This() = .{ .NoMouseInputs=true, .NoNavInputs=true, .NoNavFocus=true };

    pub usingnamespace FlagsMixin(@This());
};

pub const Col = enum (i32) {
    Text = 0,
    TextDisabled = 1,
    WindowBg = 2,
    ChildBg = 3,
    PopupBg = 4,
    Border = 5,
    BorderShadow = 6,
    FrameBg = 7,
    FrameBgHovered = 8,
    FrameBgActive = 9,
    TitleBg = 10,
    TitleBgActive = 11,
    TitleBgCollapsed = 12,
    MenuBarBg = 13,
    ScrollbarBg = 14,
    ScrollbarGrab = 15,
    ScrollbarGrabHovered = 16,
    ScrollbarGrabActive = 17,
    CheckMark = 18,
    SliderGrab = 19,
    SliderGrabActive = 20,
    Button = 21,
    ButtonHovered = 22,
    ButtonActive = 23,
    Header = 24,
    HeaderHovered = 25,
    HeaderActive = 26,
    Separator = 27,
    SeparatorHovered = 28,
    SeparatorActive = 29,
    ResizeGrip = 30,
    ResizeGripHovered = 31,
    ResizeGripActive = 32,
    Tab = 33,
    TabHovered = 34,
    TabActive = 35,
    TabUnfocused = 36,
    TabUnfocusedActive = 37,
    PlotLines = 38,
    PlotLinesHovered = 39,
    PlotHistogram = 40,
    PlotHistogramHovered = 41,
    TableHeaderBg = 42,
    TableBorderStrong = 43,
    TableBorderLight = 44,
    TableRowBg = 45,
    TableRowBgAlt = 46,
    TextSelectedBg = 47,
    DragDropTarget = 48,
    NavHighlight = 49,
    NavWindowingHighlight = 50,
    NavWindowingDimBg = 51,
    ModalWindowDimBg = 52,
    _,

    pub const COUNT = 53;
};

pub const DataType = enum (i32) {
    S8 = 0,
    U8 = 1,
    S16 = 2,
    U16 = 3,
    S32 = 4,
    U32 = 5,
    S64 = 6,
    U64 = 7,
    Float = 8,
    Double = 9,
    _,

    pub const COUNT = 10;
};

pub const Dir = enum (i32) {
    None = -1,
    Left = 0,
    Right = 1,
    Up = 2,
    Down = 3,
    _,

    pub const COUNT = 4;
};

pub const Key = enum (i32) {
    None = 0,
    Tab = 512,
    LeftArrow = 513,
    RightArrow = 514,
    UpArrow = 515,
    DownArrow = 516,
    PageUp = 517,
    PageDown = 518,
    Home = 519,
    End = 520,
    Insert = 521,
    Delete = 522,
    Backspace = 523,
    Space = 524,
    Enter = 525,
    Escape = 526,
    LeftCtrl = 527,
    LeftShift = 528,
    LeftAlt = 529,
    LeftSuper = 530,
    RightCtrl = 531,
    RightShift = 532,
    RightAlt = 533,
    RightSuper = 534,
    Menu = 535,
    @"0" = 536,
    @"1" = 537,
    @"2" = 538,
    @"3" = 539,
    @"4" = 540,
    @"5" = 541,
    @"6" = 542,
    @"7" = 543,
    @"8" = 544,
    @"9" = 545,
    A = 546,
    B = 547,
    C = 548,
    D = 549,
    E = 550,
    F = 551,
    G = 552,
    H = 553,
    I = 554,
    J = 555,
    K = 556,
    L = 557,
    M = 558,
    N = 559,
    O = 560,
    P = 561,
    Q = 562,
    R = 563,
    S = 564,
    T = 565,
    U = 566,
    V = 567,
    W = 568,
    X = 569,
    Y = 570,
    Z = 571,
    F1 = 572,
    F2 = 573,
    F3 = 574,
    F4 = 575,
    F5 = 576,
    F6 = 577,
    F7 = 578,
    F8 = 579,
    F9 = 580,
    F10 = 581,
    F11 = 582,
    F12 = 583,
    Apostrophe = 584,
    Comma = 585,
    Minus = 586,
    Period = 587,
    Slash = 588,
    Semicolon = 589,
    Equal = 590,
    LeftBracket = 591,
    Backslash = 592,
    RightBracket = 593,
    GraveAccent = 594,
    CapsLock = 595,
    ScrollLock = 596,
    NumLock = 597,
    PrintScreen = 598,
    Pause = 599,
    Keypad0 = 600,
    Keypad1 = 601,
    Keypad2 = 602,
    Keypad3 = 603,
    Keypad4 = 604,
    Keypad5 = 605,
    Keypad6 = 606,
    Keypad7 = 607,
    Keypad8 = 608,
    Keypad9 = 609,
    KeypadDecimal = 610,
    KeypadDivide = 611,
    KeypadMultiply = 612,
    KeypadSubtract = 613,
    KeypadAdd = 614,
    KeypadEnter = 615,
    KeypadEqual = 616,
    GamepadStart = 617,
    GamepadBack = 618,
    GamepadFaceUp = 619,
    GamepadFaceDown = 620,
    GamepadFaceLeft = 621,
    GamepadFaceRight = 622,
    GamepadDpadUp = 623,
    GamepadDpadDown = 624,
    GamepadDpadLeft = 625,
    GamepadDpadRight = 626,
    GamepadL1 = 627,
    GamepadR1 = 628,
    GamepadL2 = 629,
    GamepadR2 = 630,
    GamepadL3 = 631,
    GamepadR3 = 632,
    GamepadLStickUp = 633,
    GamepadLStickDown = 634,
    GamepadLStickLeft = 635,
    GamepadLStickRight = 636,
    GamepadRStickUp = 637,
    GamepadRStickDown = 638,
    GamepadRStickLeft = 639,
    GamepadRStickRight = 640,
    ModCtrl = 641,
    ModShift = 642,
    ModAlt = 643,
    ModSuper = 644,
    _,

    pub const COUNT = 645;
    pub const NamedKey_BEGIN = 512;
    pub const NamedKey_END = @This().COUNT;
    pub const NamedKey_COUNT = @This().NamedKey_END - @This().NamedKey_BEGIN;
    pub const KeysData_SIZE = @This().NamedKey_COUNT;
    pub const KeysData_OFFSET = @This().NamedKey_BEGIN;
};

pub const MouseButton = enum (i32) {
    Left = 0,
    Right = 1,
    Middle = 2,
    _,

    pub const COUNT = 5;
};

pub const MouseCursor = enum (i32) {
    None = -1,
    Arrow = 0,
    TextInput = 1,
    ResizeAll = 2,
    ResizeNS = 3,
    ResizeEW = 4,
    ResizeNESW = 5,
    ResizeNWSE = 6,
    Hand = 7,
    NotAllowed = 8,
    _,

    pub const COUNT = 9;
};

pub const NavInput = enum (i32) {
    Activate = 0,
    Cancel = 1,
    Input = 2,
    Menu = 3,
    DpadLeft = 4,
    DpadRight = 5,
    DpadUp = 6,
    DpadDown = 7,
    LStickLeft = 8,
    LStickRight = 9,
    LStickUp = 10,
    LStickDown = 11,
    FocusPrev = 12,
    FocusNext = 13,
    TweakSlow = 14,
    TweakFast = 15,
    KeyLeft_ = 16,
    KeyRight_ = 17,
    KeyUp_ = 18,
    KeyDown_ = 19,
    _,

    pub const COUNT = 20;
};

pub const SortDirection = enum (i32) {
    None = 0,
    Ascending = 1,
    Descending = 2,
    _,
};

pub const StyleVar = enum (i32) {
    Alpha = 0,
    DisabledAlpha = 1,
    WindowPadding = 2,
    WindowRounding = 3,
    WindowBorderSize = 4,
    WindowMinSize = 5,
    WindowTitleAlign = 6,
    ChildRounding = 7,
    ChildBorderSize = 8,
    PopupRounding = 9,
    PopupBorderSize = 10,
    FramePadding = 11,
    FrameRounding = 12,
    FrameBorderSize = 13,
    ItemSpacing = 14,
    ItemInnerSpacing = 15,
    IndentSpacing = 16,
    CellPadding = 17,
    ScrollbarSize = 18,
    ScrollbarRounding = 19,
    GrabMinSize = 20,
    GrabRounding = 21,
    TabRounding = 22,
    ButtonTextAlign = 23,
    SelectableTextAlign = 24,
    _,

    pub const COUNT = 25;
};

pub const TableBgTarget = enum (i32) {
    None = 0,
    RowBg0 = 1,
    RowBg1 = 2,
    CellBg = 3,
    _,
};

pub const DrawChannel = extern struct {
    _CmdBuffer: Vector(DrawCmd),
    _IdxBuffer: Vector(DrawIdx),
};

pub const DrawCmd = extern struct {
    ClipRect: Vec4,
    TextureId: TextureID,
    VtxOffset: u32,
    IdxOffset: u32,
    ElemCount: u32,
    UserCallback: DrawCallback,
    UserCallbackData: ?*anyopaque,

    /// GetTexID(self: *const DrawCmd) TextureID
    pub const GetTexID = raw.ImDrawCmd_GetTexID;

    /// init_ImDrawCmd(self: ?*anyopaque) void
    pub const init_ImDrawCmd = raw.ImDrawCmd_ImDrawCmd;

    /// deinit(self: *DrawCmd) void
    pub const deinit = raw.ImDrawCmd_destroy;
};

pub const DrawCmdHeader = extern struct {
    ClipRect: Vec4,
    TextureId: TextureID,
    VtxOffset: u32,
};

pub const DrawData = extern struct {
    Valid: bool,
    CmdListsCount: i32,
    TotalIdxCount: i32,
    TotalVtxCount: i32,
    CmdLists: ?[*]*DrawList,
    DisplayPos: Vec2,
    DisplaySize: Vec2,
    FramebufferScale: Vec2,

    /// Clear(self: *DrawData) void
    pub const Clear = raw.ImDrawData_Clear;

    /// DeIndexAllBuffers(self: *DrawData) void
    pub const DeIndexAllBuffers = raw.ImDrawData_DeIndexAllBuffers;

    /// init_ImDrawData(self: ?*anyopaque) void
    pub const init_ImDrawData = raw.ImDrawData_ImDrawData;

    pub inline fn ScaleClipRects(self: *DrawData, fb_scale: Vec2) void {
        return raw.ImDrawData_ScaleClipRects(self, &fb_scale);
    }

    /// deinit(self: *DrawData) void
    pub const deinit = raw.ImDrawData_destroy;
};

pub const DrawList = extern struct {
    CmdBuffer: Vector(DrawCmd),
    IdxBuffer: Vector(DrawIdx),
    VtxBuffer: Vector(DrawVert),
    Flags: DrawListFlags align(4),
    _VtxCurrentIdx: u32,
    _Data: ?*const DrawListSharedData,
    _OwnerName: ?[*:0]const u8,
    _VtxWritePtr: ?[*]DrawVert,
    _IdxWritePtr: ?[*]DrawIdx,
    _ClipRectStack: Vector(Vec4),
    _TextureIdStack: Vector(TextureID),
    _Path: Vector(Vec2),
    _CmdHeader: DrawCmdHeader,
    _Splitter: DrawListSplitter,
    _FringeScale: f32,

    pub inline fn AddBezierCubicExt(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32, thickness: f32, num_segments: i32) void {
        return raw.ImDrawList_AddBezierCubic(self, &p1, &p2, &p3, &p4, col, thickness, num_segments);
    }
    pub inline fn AddBezierCubic(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32, thickness: f32) void {
        return @This().AddBezierCubicExt(self, p1, p2, p3, p4, col, thickness, 0);
    }

    pub inline fn AddBezierQuadraticExt(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32, thickness: f32, num_segments: i32) void {
        return raw.ImDrawList_AddBezierQuadratic(self, &p1, &p2, &p3, col, thickness, num_segments);
    }
    pub inline fn AddBezierQuadratic(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32, thickness: f32) void {
        return @This().AddBezierQuadraticExt(self, p1, p2, p3, col, thickness, 0);
    }

    /// AddCallback(self: *DrawList, callback: DrawCallback, callback_data: ?*anyopaque) void
    pub const AddCallback = raw.ImDrawList_AddCallback;

    pub inline fn AddCircleExt(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32, thickness: f32) void {
        return raw.ImDrawList_AddCircle(self, &center, radius, col, num_segments, thickness);
    }
    pub inline fn AddCircle(self: *DrawList, center: Vec2, radius: f32, col: u32) void {
        return @This().AddCircleExt(self, center, radius, col, 0, 1.0);
    }

    pub inline fn AddCircleFilledExt(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32) void {
        return raw.ImDrawList_AddCircleFilled(self, &center, radius, col, num_segments);
    }
    pub inline fn AddCircleFilled(self: *DrawList, center: Vec2, radius: f32, col: u32) void {
        return @This().AddCircleFilledExt(self, center, radius, col, 0);
    }

    /// AddConvexPolyFilled(self: *DrawList, points: ?[*]const Vec2, num_points: i32, col: u32) void
    pub const AddConvexPolyFilled = raw.ImDrawList_AddConvexPolyFilled;

    /// AddDrawCmd(self: *DrawList) void
    pub const AddDrawCmd = raw.ImDrawList_AddDrawCmd;

    pub inline fn AddImageExt(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2, uv_min: Vec2, uv_max: Vec2, col: u32) void {
        return raw.ImDrawList_AddImage(self, user_texture_id, &p_min, &p_max, &uv_min, &uv_max, col);
    }
    pub inline fn AddImage(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2) void {
        return @This().AddImageExt(self, user_texture_id, p_min, p_max, .{.x=0,.y=0}, .{.x=1,.y=1}, 4294967295);
    }

    pub inline fn AddImageQuadExt(self: *DrawList, user_texture_id: TextureID, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, uv1: Vec2, uv2: Vec2, uv3: Vec2, uv4: Vec2, col: u32) void {
        return raw.ImDrawList_AddImageQuad(self, user_texture_id, &p1, &p2, &p3, &p4, &uv1, &uv2, &uv3, &uv4, col);
    }
    pub inline fn AddImageQuad(self: *DrawList, user_texture_id: TextureID, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2) void {
        return @This().AddImageQuadExt(self, user_texture_id, p1, p2, p3, p4, .{.x=0,.y=0}, .{.x=1,.y=0}, .{.x=1,.y=1}, .{.x=0,.y=1}, 4294967295);
    }

    pub inline fn AddImageRoundedExt(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2, uv_min: Vec2, uv_max: Vec2, col: u32, rounding: f32, flags: DrawFlags) void {
        return raw.ImDrawList_AddImageRounded(self, user_texture_id, &p_min, &p_max, &uv_min, &uv_max, col, rounding, flags.toInt());
    }
    pub inline fn AddImageRounded(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2, uv_min: Vec2, uv_max: Vec2, col: u32, rounding: f32) void {
        return @This().AddImageRoundedExt(self, user_texture_id, p_min, p_max, uv_min, uv_max, col, rounding, .{});
    }

    pub inline fn AddLineExt(self: *DrawList, p1: Vec2, p2: Vec2, col: u32, thickness: f32) void {
        return raw.ImDrawList_AddLine(self, &p1, &p2, col, thickness);
    }
    pub inline fn AddLine(self: *DrawList, p1: Vec2, p2: Vec2, col: u32) void {
        return @This().AddLineExt(self, p1, p2, col, 1.0);
    }

    pub inline fn AddNgonExt(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32, thickness: f32) void {
        return raw.ImDrawList_AddNgon(self, &center, radius, col, num_segments, thickness);
    }
    pub inline fn AddNgon(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32) void {
        return @This().AddNgonExt(self, center, radius, col, num_segments, 1.0);
    }

    pub inline fn AddNgonFilled(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32) void {
        return raw.ImDrawList_AddNgonFilled(self, &center, radius, col, num_segments);
    }

    pub inline fn AddPolyline(self: *DrawList, points: ?[*]const Vec2, num_points: i32, col: u32, flags: DrawFlags, thickness: f32) void {
        return raw.ImDrawList_AddPolyline(self, points, num_points, col, flags.toInt(), thickness);
    }

    pub inline fn AddQuadExt(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32, thickness: f32) void {
        return raw.ImDrawList_AddQuad(self, &p1, &p2, &p3, &p4, col, thickness);
    }
    pub inline fn AddQuad(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32) void {
        return @This().AddQuadExt(self, p1, p2, p3, p4, col, 1.0);
    }

    pub inline fn AddQuadFilled(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32) void {
        return raw.ImDrawList_AddQuadFilled(self, &p1, &p2, &p3, &p4, col);
    }

    pub inline fn AddRectExt(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32, rounding: f32, flags: DrawFlags, thickness: f32) void {
        return raw.ImDrawList_AddRect(self, &p_min, &p_max, col, rounding, flags.toInt(), thickness);
    }
    pub inline fn AddRect(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32) void {
        return @This().AddRectExt(self, p_min, p_max, col, 0.0, .{}, 1.0);
    }

    pub inline fn AddRectFilledExt(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32, rounding: f32, flags: DrawFlags) void {
        return raw.ImDrawList_AddRectFilled(self, &p_min, &p_max, col, rounding, flags.toInt());
    }
    pub inline fn AddRectFilled(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32) void {
        return @This().AddRectFilledExt(self, p_min, p_max, col, 0.0, .{});
    }

    pub inline fn AddRectFilledMultiColor(self: *DrawList, p_min: Vec2, p_max: Vec2, col_upr_left: u32, col_upr_right: u32, col_bot_right: u32, col_bot_left: u32) void {
        return raw.ImDrawList_AddRectFilledMultiColor(self, &p_min, &p_max, col_upr_left, col_upr_right, col_bot_right, col_bot_left);
    }

    pub inline fn AddText_Vec2Ext(self: *DrawList, pos: Vec2, col: u32, text_begin: ?[*]const u8, text_end: ?[*]const u8) void {
        return raw.ImDrawList_AddText_Vec2(self, &pos, col, text_begin, text_end);
    }
    pub inline fn AddText_Vec2(self: *DrawList, pos: Vec2, col: u32, text_begin: ?[*]const u8) void {
        return @This().AddText_Vec2Ext(self, pos, col, text_begin, null);
    }

    pub inline fn AddText_FontPtrExt(self: *DrawList, font: ?*const Font, font_size: f32, pos: Vec2, col: u32, text_begin: ?[*]const u8, text_end: ?[*]const u8, wrap_width: f32, cpu_fine_clip_rect: ?*const Vec4) void {
        return raw.ImDrawList_AddText_FontPtr(self, font, font_size, &pos, col, text_begin, text_end, wrap_width, cpu_fine_clip_rect);
    }
    pub inline fn AddText_FontPtr(self: *DrawList, font: ?*const Font, font_size: f32, pos: Vec2, col: u32, text_begin: ?[*]const u8) void {
        return @This().AddText_FontPtrExt(self, font, font_size, pos, col, text_begin, null, 0.0, null);
    }

    pub inline fn AddTriangleExt(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32, thickness: f32) void {
        return raw.ImDrawList_AddTriangle(self, &p1, &p2, &p3, col, thickness);
    }
    pub inline fn AddTriangle(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32) void {
        return @This().AddTriangleExt(self, p1, p2, p3, col, 1.0);
    }

    pub inline fn AddTriangleFilled(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32) void {
        return raw.ImDrawList_AddTriangleFilled(self, &p1, &p2, &p3, col);
    }

    /// ChannelsMerge(self: *DrawList) void
    pub const ChannelsMerge = raw.ImDrawList_ChannelsMerge;

    /// ChannelsSetCurrent(self: *DrawList, n: i32) void
    pub const ChannelsSetCurrent = raw.ImDrawList_ChannelsSetCurrent;

    /// ChannelsSplit(self: *DrawList, count: i32) void
    pub const ChannelsSplit = raw.ImDrawList_ChannelsSplit;

    /// CloneOutput(self: *const DrawList) ?*DrawList
    pub const CloneOutput = raw.ImDrawList_CloneOutput;

    pub inline fn GetClipRectMax(self: *const DrawList) Vec2 {
        var out: Vec2 = undefined;
        raw.ImDrawList_GetClipRectMax(&out, self);
        return out;
    }

    pub inline fn GetClipRectMin(self: *const DrawList) Vec2 {
        var out: Vec2 = undefined;
        raw.ImDrawList_GetClipRectMin(&out, self);
        return out;
    }

    /// init_ImDrawList(self: ?*anyopaque, shared_data: ?*const DrawListSharedData) void
    pub const init_ImDrawList = raw.ImDrawList_ImDrawList;

    pub inline fn PathArcToExt(self: *DrawList, center: Vec2, radius: f32, a_min: f32, a_max: f32, num_segments: i32) void {
        return raw.ImDrawList_PathArcTo(self, &center, radius, a_min, a_max, num_segments);
    }
    pub inline fn PathArcTo(self: *DrawList, center: Vec2, radius: f32, a_min: f32, a_max: f32) void {
        return @This().PathArcToExt(self, center, radius, a_min, a_max, 0);
    }

    pub inline fn PathArcToFast(self: *DrawList, center: Vec2, radius: f32, a_min_of_12: i32, a_max_of_12: i32) void {
        return raw.ImDrawList_PathArcToFast(self, &center, radius, a_min_of_12, a_max_of_12);
    }

    pub inline fn PathBezierCubicCurveToExt(self: *DrawList, p2: Vec2, p3: Vec2, p4: Vec2, num_segments: i32) void {
        return raw.ImDrawList_PathBezierCubicCurveTo(self, &p2, &p3, &p4, num_segments);
    }
    pub inline fn PathBezierCubicCurveTo(self: *DrawList, p2: Vec2, p3: Vec2, p4: Vec2) void {
        return @This().PathBezierCubicCurveToExt(self, p2, p3, p4, 0);
    }

    pub inline fn PathBezierQuadraticCurveToExt(self: *DrawList, p2: Vec2, p3: Vec2, num_segments: i32) void {
        return raw.ImDrawList_PathBezierQuadraticCurveTo(self, &p2, &p3, num_segments);
    }
    pub inline fn PathBezierQuadraticCurveTo(self: *DrawList, p2: Vec2, p3: Vec2) void {
        return @This().PathBezierQuadraticCurveToExt(self, p2, p3, 0);
    }

    /// PathClear(self: *DrawList) void
    pub const PathClear = raw.ImDrawList_PathClear;

    /// PathFillConvex(self: *DrawList, col: u32) void
    pub const PathFillConvex = raw.ImDrawList_PathFillConvex;

    pub inline fn PathLineTo(self: *DrawList, pos: Vec2) void {
        return raw.ImDrawList_PathLineTo(self, &pos);
    }

    pub inline fn PathLineToMergeDuplicate(self: *DrawList, pos: Vec2) void {
        return raw.ImDrawList_PathLineToMergeDuplicate(self, &pos);
    }

    pub inline fn PathRectExt(self: *DrawList, rect_min: Vec2, rect_max: Vec2, rounding: f32, flags: DrawFlags) void {
        return raw.ImDrawList_PathRect(self, &rect_min, &rect_max, rounding, flags.toInt());
    }
    pub inline fn PathRect(self: *DrawList, rect_min: Vec2, rect_max: Vec2) void {
        return @This().PathRectExt(self, rect_min, rect_max, 0.0, .{});
    }

    pub inline fn PathStrokeExt(self: *DrawList, col: u32, flags: DrawFlags, thickness: f32) void {
        return raw.ImDrawList_PathStroke(self, col, flags.toInt(), thickness);
    }
    pub inline fn PathStroke(self: *DrawList, col: u32) void {
        return @This().PathStrokeExt(self, col, .{}, 1.0);
    }

    /// PopClipRect(self: *DrawList) void
    pub const PopClipRect = raw.ImDrawList_PopClipRect;

    /// PopTextureID(self: *DrawList) void
    pub const PopTextureID = raw.ImDrawList_PopTextureID;

    pub inline fn PrimQuadUV(self: *DrawList, a: Vec2, b: Vec2, c: Vec2, d: Vec2, uv_a: Vec2, uv_b: Vec2, uv_c: Vec2, uv_d: Vec2, col: u32) void {
        return raw.ImDrawList_PrimQuadUV(self, &a, &b, &c, &d, &uv_a, &uv_b, &uv_c, &uv_d, col);
    }

    pub inline fn PrimRect(self: *DrawList, a: Vec2, b: Vec2, col: u32) void {
        return raw.ImDrawList_PrimRect(self, &a, &b, col);
    }

    pub inline fn PrimRectUV(self: *DrawList, a: Vec2, b: Vec2, uv_a: Vec2, uv_b: Vec2, col: u32) void {
        return raw.ImDrawList_PrimRectUV(self, &a, &b, &uv_a, &uv_b, col);
    }

    /// PrimReserve(self: *DrawList, idx_count: i32, vtx_count: i32) void
    pub const PrimReserve = raw.ImDrawList_PrimReserve;

    /// PrimUnreserve(self: *DrawList, idx_count: i32, vtx_count: i32) void
    pub const PrimUnreserve = raw.ImDrawList_PrimUnreserve;

    pub inline fn PrimVtx(self: *DrawList, pos: Vec2, uv: Vec2, col: u32) void {
        return raw.ImDrawList_PrimVtx(self, &pos, &uv, col);
    }

    /// PrimWriteIdx(self: *DrawList, idx: DrawIdx) void
    pub const PrimWriteIdx = raw.ImDrawList_PrimWriteIdx;

    pub inline fn PrimWriteVtx(self: *DrawList, pos: Vec2, uv: Vec2, col: u32) void {
        return raw.ImDrawList_PrimWriteVtx(self, &pos, &uv, col);
    }

    pub inline fn PushClipRectExt(self: *DrawList, clip_rect_min: Vec2, clip_rect_max: Vec2, intersect_with_current_clip_rect: bool) void {
        return raw.ImDrawList_PushClipRect(self, &clip_rect_min, &clip_rect_max, intersect_with_current_clip_rect);
    }
    pub inline fn PushClipRect(self: *DrawList, clip_rect_min: Vec2, clip_rect_max: Vec2) void {
        return @This().PushClipRectExt(self, clip_rect_min, clip_rect_max, false);
    }

    /// PushClipRectFullScreen(self: *DrawList) void
    pub const PushClipRectFullScreen = raw.ImDrawList_PushClipRectFullScreen;

    /// PushTextureID(self: *DrawList, texture_id: TextureID) void
    pub const PushTextureID = raw.ImDrawList_PushTextureID;

    /// _CalcCircleAutoSegmentCount(self: *const DrawList, radius: f32) i32
    pub const _CalcCircleAutoSegmentCount = raw.ImDrawList__CalcCircleAutoSegmentCount;

    /// _ClearFreeMemory(self: *DrawList) void
    pub const _ClearFreeMemory = raw.ImDrawList__ClearFreeMemory;

    /// _OnChangedClipRect(self: *DrawList) void
    pub const _OnChangedClipRect = raw.ImDrawList__OnChangedClipRect;

    /// _OnChangedTextureID(self: *DrawList) void
    pub const _OnChangedTextureID = raw.ImDrawList__OnChangedTextureID;

    /// _OnChangedVtxOffset(self: *DrawList) void
    pub const _OnChangedVtxOffset = raw.ImDrawList__OnChangedVtxOffset;

    pub inline fn _PathArcToFastEx(self: *DrawList, center: Vec2, radius: f32, a_min_sample: i32, a_max_sample: i32, a_step: i32) void {
        return raw.ImDrawList__PathArcToFastEx(self, &center, radius, a_min_sample, a_max_sample, a_step);
    }

    pub inline fn _PathArcToN(self: *DrawList, center: Vec2, radius: f32, a_min: f32, a_max: f32, num_segments: i32) void {
        return raw.ImDrawList__PathArcToN(self, &center, radius, a_min, a_max, num_segments);
    }

    /// _PopUnusedDrawCmd(self: *DrawList) void
    pub const _PopUnusedDrawCmd = raw.ImDrawList__PopUnusedDrawCmd;

    /// _ResetForNewFrame(self: *DrawList) void
    pub const _ResetForNewFrame = raw.ImDrawList__ResetForNewFrame;

    /// _TryMergeDrawCmds(self: *DrawList) void
    pub const _TryMergeDrawCmds = raw.ImDrawList__TryMergeDrawCmds;

    /// deinit(self: *DrawList) void
    pub const deinit = raw.ImDrawList_destroy;
};

pub const DrawListSplitter = extern struct {
    _Current: i32,
    _Count: i32,
    _Channels: Vector(DrawChannel),

    /// Clear(self: *DrawListSplitter) void
    pub const Clear = raw.ImDrawListSplitter_Clear;

    /// ClearFreeMemory(self: *DrawListSplitter) void
    pub const ClearFreeMemory = raw.ImDrawListSplitter_ClearFreeMemory;

    /// init_ImDrawListSplitter(self: ?*anyopaque) void
    pub const init_ImDrawListSplitter = raw.ImDrawListSplitter_ImDrawListSplitter;

    /// Merge(self: *DrawListSplitter, draw_list: ?*DrawList) void
    pub const Merge = raw.ImDrawListSplitter_Merge;

    /// SetCurrentChannel(self: *DrawListSplitter, draw_list: ?*DrawList, channel_idx: i32) void
    pub const SetCurrentChannel = raw.ImDrawListSplitter_SetCurrentChannel;

    /// Split(self: *DrawListSplitter, draw_list: ?*DrawList, count: i32) void
    pub const Split = raw.ImDrawListSplitter_Split;

    /// deinit(self: *DrawListSplitter) void
    pub const deinit = raw.ImDrawListSplitter_destroy;
};

pub const DrawVert = extern struct {
    pos: Vec2,
    uv: Vec2,
    col: u32,
};

pub const Font = extern struct {
    IndexAdvanceX: Vector(f32),
    FallbackAdvanceX: f32,
    FontSize: f32,
    IndexLookup: Vector(Wchar),
    Glyphs: Vector(FontGlyph),
    FallbackGlyph: ?*const FontGlyph,
    ContainerAtlas: ?*FontAtlas,
    ConfigData: ?*const FontConfig,
    ConfigDataCount: i16,
    FallbackChar: Wchar,
    EllipsisChar: Wchar,
    DotChar: Wchar,
    DirtyLookupTables: bool,
    Scale: f32,
    Ascent: f32,
    Descent: f32,
    MetricsTotalSurface: i32,
    Used4kPagesMap: [(0xFFFF+1)/4096/8]u8,

    /// AddGlyph(self: *Font, src_cfg: ?*const FontConfig, c: Wchar, x0: f32, y0: f32, x1: f32, y1: f32, u0: f32, v0: f32, u1: f32, v1: f32, advance_x: f32) void
    pub const AddGlyph = raw.ImFont_AddGlyph;

    /// AddRemapCharExt(self: *Font, dst: Wchar, src: Wchar, overwrite_dst: bool) void
    pub const AddRemapCharExt = raw.ImFont_AddRemapChar;
    pub inline fn AddRemapChar(self: *Font, dst: Wchar, src: Wchar) void {
        return @This().AddRemapCharExt(self, dst, src, true);
    }

    /// BuildLookupTable(self: *Font) void
    pub const BuildLookupTable = raw.ImFont_BuildLookupTable;

    pub inline fn CalcTextSizeAExt(self: *const Font, size: f32, max_width: f32, wrap_width: f32, text_begin: ?[*]const u8, text_end: ?[*]const u8, remaining: ?*?[*:0]const u8) Vec2 {
        var out: Vec2 = undefined;
        raw.ImFont_CalcTextSizeA(&out, self, size, max_width, wrap_width, text_begin, text_end, remaining);
        return out;
    }
    pub inline fn CalcTextSizeA(self: *const Font, size: f32, max_width: f32, wrap_width: f32, text_begin: ?[*]const u8) Vec2 {
        return @This().CalcTextSizeAExt(self, size, max_width, wrap_width, text_begin, null, null);
    }

    /// CalcWordWrapPositionA(self: *const Font, scale: f32, text: ?[*]const u8, text_end: ?[*]const u8, wrap_width: f32) ?[*]const u8
    pub const CalcWordWrapPositionA = raw.ImFont_CalcWordWrapPositionA;

    /// ClearOutputData(self: *Font) void
    pub const ClearOutputData = raw.ImFont_ClearOutputData;

    /// FindGlyph(self: *const Font, c: Wchar) ?*const FontGlyph
    pub const FindGlyph = raw.ImFont_FindGlyph;

    /// FindGlyphNoFallback(self: *const Font, c: Wchar) ?*const FontGlyph
    pub const FindGlyphNoFallback = raw.ImFont_FindGlyphNoFallback;

    /// GetCharAdvance(self: *const Font, c: Wchar) f32
    pub const GetCharAdvance = raw.ImFont_GetCharAdvance;

    /// GetDebugName(self: *const Font) ?[*:0]const u8
    pub const GetDebugName = raw.ImFont_GetDebugName;

    /// GrowIndex(self: *Font, new_size: i32) void
    pub const GrowIndex = raw.ImFont_GrowIndex;

    /// init_ImFont(self: ?*anyopaque) void
    pub const init_ImFont = raw.ImFont_ImFont;

    /// IsGlyphRangeUnused(self: *Font, c_begin: u32, c_last: u32) bool
    pub const IsGlyphRangeUnused = raw.ImFont_IsGlyphRangeUnused;

    /// IsLoaded(self: *const Font) bool
    pub const IsLoaded = raw.ImFont_IsLoaded;

    pub inline fn RenderChar(self: *const Font, draw_list: ?*DrawList, size: f32, pos: Vec2, col: u32, c: Wchar) void {
        return raw.ImFont_RenderChar(self, draw_list, size, &pos, col, c);
    }

    pub inline fn RenderTextExt(self: *const Font, draw_list: ?*DrawList, size: f32, pos: Vec2, col: u32, clip_rect: Vec4, text_begin: ?[*]const u8, text_end: ?[*]const u8, wrap_width: f32, cpu_fine_clip: bool) void {
        return raw.ImFont_RenderText(self, draw_list, size, &pos, col, &clip_rect, text_begin, text_end, wrap_width, cpu_fine_clip);
    }
    pub inline fn RenderText(self: *const Font, draw_list: ?*DrawList, size: f32, pos: Vec2, col: u32, clip_rect: Vec4, text_begin: ?[*]const u8, text_end: ?[*]const u8) void {
        return @This().RenderTextExt(self, draw_list, size, pos, col, clip_rect, text_begin, text_end, 0.0, false);
    }

    /// SetGlyphVisible(self: *Font, c: Wchar, visible: bool) void
    pub const SetGlyphVisible = raw.ImFont_SetGlyphVisible;

    /// deinit(self: *Font) void
    pub const deinit = raw.ImFont_destroy;
};

pub const FontAtlas = extern struct {
    Flags: FontAtlasFlags align(4),
    TexID: TextureID,
    TexDesiredWidth: i32,
    TexGlyphPadding: i32,
    Locked: bool,
    TexReady: bool,
    TexPixelsUseColors: bool,
    TexPixelsAlpha8: ?[*]u8,
    TexPixelsRGBA32: ?[*]u32,
    TexWidth: i32,
    TexHeight: i32,
    TexUvScale: Vec2,
    TexUvWhitePixel: Vec2,
    Fonts: Vector(?*Font),
    CustomRects: Vector(FontAtlasCustomRect),
    ConfigData: Vector(FontConfig),
    TexUvLines: [(63)+1]Vec4,
    FontBuilderIO: ?*const FontBuilderIO,
    FontBuilderFlags: u32,
    PackIdMouseCursors: i32,
    PackIdLines: i32,

    pub inline fn AddCustomRectFontGlyphExt(self: *FontAtlas, font: ?*Font, id: Wchar, width: i32, height: i32, advance_x: f32, offset: Vec2) i32 {
        return raw.ImFontAtlas_AddCustomRectFontGlyph(self, font, id, width, height, advance_x, &offset);
    }
    pub inline fn AddCustomRectFontGlyph(self: *FontAtlas, font: ?*Font, id: Wchar, width: i32, height: i32, advance_x: f32) i32 {
        return @This().AddCustomRectFontGlyphExt(self, font, id, width, height, advance_x, .{.x=0,.y=0});
    }

    /// AddCustomRectRegular(self: *FontAtlas, width: i32, height: i32) i32
    pub const AddCustomRectRegular = raw.ImFontAtlas_AddCustomRectRegular;

    /// AddFont(self: *FontAtlas, font_cfg: ?*const FontConfig) ?*Font
    pub const AddFont = raw.ImFontAtlas_AddFont;

    /// AddFontDefaultExt(self: *FontAtlas, font_cfg: ?*const FontConfig) ?*Font
    pub const AddFontDefaultExt = raw.ImFontAtlas_AddFontDefault;
    pub inline fn AddFontDefault(self: *FontAtlas) ?*Font {
        return @This().AddFontDefaultExt(self, null);
    }

    /// AddFontFromFileTTFExt(self: *FontAtlas, filename: ?[*:0]const u8, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) ?*Font
    pub const AddFontFromFileTTFExt = raw.ImFontAtlas_AddFontFromFileTTF;
    pub inline fn AddFontFromFileTTF(self: *FontAtlas, filename: ?[*:0]const u8, size_pixels: f32) ?*Font {
        return @This().AddFontFromFileTTFExt(self, filename, size_pixels, null, null);
    }

    /// AddFontFromMemoryCompressedBase85TTFExt(self: *FontAtlas, compressed_font_data_base85: ?[*]const u8, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) ?*Font
    pub const AddFontFromMemoryCompressedBase85TTFExt = raw.ImFontAtlas_AddFontFromMemoryCompressedBase85TTF;
    pub inline fn AddFontFromMemoryCompressedBase85TTF(self: *FontAtlas, compressed_font_data_base85: ?[*]const u8, size_pixels: f32) ?*Font {
        return @This().AddFontFromMemoryCompressedBase85TTFExt(self, compressed_font_data_base85, size_pixels, null, null);
    }

    /// AddFontFromMemoryCompressedTTFExt(self: *FontAtlas, compressed_font_data: ?*const anyopaque, compressed_font_size: i32, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) ?*Font
    pub const AddFontFromMemoryCompressedTTFExt = raw.ImFontAtlas_AddFontFromMemoryCompressedTTF;
    pub inline fn AddFontFromMemoryCompressedTTF(self: *FontAtlas, compressed_font_data: ?*const anyopaque, compressed_font_size: i32, size_pixels: f32) ?*Font {
        return @This().AddFontFromMemoryCompressedTTFExt(self, compressed_font_data, compressed_font_size, size_pixels, null, null);
    }

    /// AddFontFromMemoryTTFExt(self: *FontAtlas, font_data: ?*anyopaque, font_size: i32, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) ?*Font
    pub const AddFontFromMemoryTTFExt = raw.ImFontAtlas_AddFontFromMemoryTTF;
    pub inline fn AddFontFromMemoryTTF(self: *FontAtlas, font_data: ?*anyopaque, font_size: i32, size_pixels: f32) ?*Font {
        return @This().AddFontFromMemoryTTFExt(self, font_data, font_size, size_pixels, null, null);
    }

    /// Build(self: *FontAtlas) bool
    pub const Build = raw.ImFontAtlas_Build;

    /// CalcCustomRectUV(self: *const FontAtlas, rect: ?*const FontAtlasCustomRect, out_uv_min: ?*Vec2, out_uv_max: ?*Vec2) void
    pub const CalcCustomRectUV = raw.ImFontAtlas_CalcCustomRectUV;

    /// Clear(self: *FontAtlas) void
    pub const Clear = raw.ImFontAtlas_Clear;

    /// ClearFonts(self: *FontAtlas) void
    pub const ClearFonts = raw.ImFontAtlas_ClearFonts;

    /// ClearInputData(self: *FontAtlas) void
    pub const ClearInputData = raw.ImFontAtlas_ClearInputData;

    /// ClearTexData(self: *FontAtlas) void
    pub const ClearTexData = raw.ImFontAtlas_ClearTexData;

    /// GetCustomRectByIndex(self: *FontAtlas, index: i32) ?*FontAtlasCustomRect
    pub const GetCustomRectByIndex = raw.ImFontAtlas_GetCustomRectByIndex;

    /// GetGlyphRangesChineseFull(self: *FontAtlas) ?*const Wchar
    pub const GetGlyphRangesChineseFull = raw.ImFontAtlas_GetGlyphRangesChineseFull;

    /// GetGlyphRangesChineseSimplifiedCommon(self: *FontAtlas) ?*const Wchar
    pub const GetGlyphRangesChineseSimplifiedCommon = raw.ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon;

    /// GetGlyphRangesCyrillic(self: *FontAtlas) ?*const Wchar
    pub const GetGlyphRangesCyrillic = raw.ImFontAtlas_GetGlyphRangesCyrillic;

    /// GetGlyphRangesDefault(self: *FontAtlas) ?*const Wchar
    pub const GetGlyphRangesDefault = raw.ImFontAtlas_GetGlyphRangesDefault;

    /// GetGlyphRangesJapanese(self: *FontAtlas) ?*const Wchar
    pub const GetGlyphRangesJapanese = raw.ImFontAtlas_GetGlyphRangesJapanese;

    /// GetGlyphRangesKorean(self: *FontAtlas) ?*const Wchar
    pub const GetGlyphRangesKorean = raw.ImFontAtlas_GetGlyphRangesKorean;

    /// GetGlyphRangesThai(self: *FontAtlas) ?*const Wchar
    pub const GetGlyphRangesThai = raw.ImFontAtlas_GetGlyphRangesThai;

    /// GetGlyphRangesVietnamese(self: *FontAtlas) ?*const Wchar
    pub const GetGlyphRangesVietnamese = raw.ImFontAtlas_GetGlyphRangesVietnamese;

    /// GetMouseCursorTexData(self: *FontAtlas, cursor: MouseCursor, out_offset: ?*Vec2, out_size: ?*Vec2, out_uv_border: *[2]Vec2, out_uv_fill: *[2]Vec2) bool
    pub const GetMouseCursorTexData = raw.ImFontAtlas_GetMouseCursorTexData;

    /// GetTexDataAsAlpha8Ext(self: *FontAtlas, out_pixels: *?[*]u8, out_width: *i32, out_height: *i32, out_bytes_per_pixel: ?*i32) void
    pub const GetTexDataAsAlpha8Ext = raw.ImFontAtlas_GetTexDataAsAlpha8;
    pub inline fn GetTexDataAsAlpha8(self: *FontAtlas, out_pixels: *?[*]u8, out_width: *i32, out_height: *i32) void {
        return @This().GetTexDataAsAlpha8Ext(self, out_pixels, out_width, out_height, null);
    }

    /// GetTexDataAsRGBA32Ext(self: *FontAtlas, out_pixels: *?[*]u8, out_width: *i32, out_height: *i32, out_bytes_per_pixel: ?*i32) void
    pub const GetTexDataAsRGBA32Ext = raw.ImFontAtlas_GetTexDataAsRGBA32;
    pub inline fn GetTexDataAsRGBA32(self: *FontAtlas, out_pixels: *?[*]u8, out_width: *i32, out_height: *i32) void {
        return @This().GetTexDataAsRGBA32Ext(self, out_pixels, out_width, out_height, null);
    }

    /// init_ImFontAtlas(self: ?*anyopaque) void
    pub const init_ImFontAtlas = raw.ImFontAtlas_ImFontAtlas;

    /// IsBuilt(self: *const FontAtlas) bool
    pub const IsBuilt = raw.ImFontAtlas_IsBuilt;

    /// SetTexID(self: *FontAtlas, id: TextureID) void
    pub const SetTexID = raw.ImFontAtlas_SetTexID;

    /// deinit(self: *FontAtlas) void
    pub const deinit = raw.ImFontAtlas_destroy;
};

pub const FontAtlasCustomRect = extern struct {
    Width: u16,
    Height: u16,
    X: u16,
    Y: u16,
    GlyphID: u32,
    GlyphAdvanceX: f32,
    GlyphOffset: Vec2,
    Font: ?*Font,

    /// init_ImFontAtlasCustomRect(self: ?*anyopaque) void
    pub const init_ImFontAtlasCustomRect = raw.ImFontAtlasCustomRect_ImFontAtlasCustomRect;

    /// IsPacked(self: *const FontAtlasCustomRect) bool
    pub const IsPacked = raw.ImFontAtlasCustomRect_IsPacked;

    /// deinit(self: *FontAtlasCustomRect) void
    pub const deinit = raw.ImFontAtlasCustomRect_destroy;
};

pub const FontConfig = extern struct {
    FontData: ?*anyopaque,
    FontDataSize: i32,
    FontDataOwnedByAtlas: bool,
    FontNo: i32,
    SizePixels: f32,
    OversampleH: i32,
    OversampleV: i32,
    PixelSnapH: bool,
    GlyphExtraSpacing: Vec2,
    GlyphOffset: Vec2,
    GlyphRanges: ?[*:0]const Wchar,
    GlyphMinAdvanceX: f32,
    GlyphMaxAdvanceX: f32,
    MergeMode: bool,
    FontBuilderFlags: u32,
    RasterizerMultiply: f32,
    EllipsisChar: Wchar,
    Name: [40]u8,
    DstFont: ?*Font,

    /// init_ImFontConfig(self: ?*anyopaque) void
    pub const init_ImFontConfig = raw.ImFontConfig_ImFontConfig;

    /// deinit(self: *FontConfig) void
    pub const deinit = raw.ImFontConfig_destroy;
};

pub const FontGlyph = extern struct {
    Colored: u32,
    Visible: u32,
    Codepoint: u32,
    AdvanceX: f32,
    X0: f32,
    Y0: f32,
    X1: f32,
    Y1: f32,
    U0: f32,
    V0: f32,
    U1: f32,
    V1: f32,
};

pub const FontGlyphRangesBuilder = extern struct {
    UsedChars: Vector(u32),

    /// AddChar(self: *FontGlyphRangesBuilder, c: Wchar) void
    pub const AddChar = raw.ImFontGlyphRangesBuilder_AddChar;

    /// AddRanges(self: *FontGlyphRangesBuilder, ranges: ?[*:0]const Wchar) void
    pub const AddRanges = raw.ImFontGlyphRangesBuilder_AddRanges;

    /// AddTextExt(self: *FontGlyphRangesBuilder, text: ?[*]const u8, text_end: ?[*]const u8) void
    pub const AddTextExt = raw.ImFontGlyphRangesBuilder_AddText;
    pub inline fn AddText(self: *FontGlyphRangesBuilder, text: ?[*]const u8) void {
        return @This().AddTextExt(self, text, null);
    }

    /// BuildRanges(self: *FontGlyphRangesBuilder, out_ranges: *Vector(Wchar)) void
    pub const BuildRanges = raw.ImFontGlyphRangesBuilder_BuildRanges;

    /// Clear(self: *FontGlyphRangesBuilder) void
    pub const Clear = raw.ImFontGlyphRangesBuilder_Clear;

    /// GetBit(self: *const FontGlyphRangesBuilder, n: usize) bool
    pub const GetBit = raw.ImFontGlyphRangesBuilder_GetBit;

    /// init_ImFontGlyphRangesBuilder(self: ?*anyopaque) void
    pub const init_ImFontGlyphRangesBuilder = raw.ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder;

    /// SetBit(self: *FontGlyphRangesBuilder, n: usize) void
    pub const SetBit = raw.ImFontGlyphRangesBuilder_SetBit;

    /// deinit(self: *FontGlyphRangesBuilder) void
    pub const deinit = raw.ImFontGlyphRangesBuilder_destroy;
};

pub const IO = extern struct {
    ConfigFlags: ConfigFlags align(4),
    BackendFlags: BackendFlags align(4),
    DisplaySize: Vec2,
    DeltaTime: f32,
    IniSavingRate: f32,
    IniFilename: ?[*:0]const u8,
    LogFilename: ?[*:0]const u8,
    MouseDoubleClickTime: f32,
    MouseDoubleClickMaxDist: f32,
    MouseDragThreshold: f32,
    KeyRepeatDelay: f32,
    KeyRepeatRate: f32,
    UserData: ?*anyopaque,
    Fonts: ?*FontAtlas,
    FontGlobalScale: f32,
    FontAllowUserScaling: bool,
    FontDefault: ?*Font,
    DisplayFramebufferScale: Vec2,
    MouseDrawCursor: bool,
    ConfigMacOSXBehaviors: bool,
    ConfigInputTrickleEventQueue: bool,
    ConfigInputTextCursorBlink: bool,
    ConfigDragClickToInputText: bool,
    ConfigWindowsResizeFromEdges: bool,
    ConfigWindowsMoveFromTitleBarOnly: bool,
    ConfigMemoryCompactTimer: f32,
    BackendPlatformName: ?[*:0]const u8,
    BackendRendererName: ?[*:0]const u8,
    BackendPlatformUserData: ?*anyopaque,
    BackendRendererUserData: ?*anyopaque,
    BackendLanguageUserData: ?*anyopaque,
    GetClipboardTextFn: ?*const fn (user_data: ?*anyopaque) callconv(.C) ?[*:0]const u8,
    SetClipboardTextFn: ?*const fn (user_data: ?*anyopaque, text: ?[*:0]const u8) callconv(.C) void,
    ClipboardUserData: ?*anyopaque,
    SetPlatformImeDataFn: ?*const fn (viewport: ?*Viewport, data: ?*PlatformImeData) callconv(.C) void,
    _UnusedPadding: ?*anyopaque,
    WantCaptureMouse: bool,
    WantCaptureKeyboard: bool,
    WantTextInput: bool,
    WantSetMousePos: bool,
    WantSaveIniSettings: bool,
    NavActive: bool,
    NavVisible: bool,
    Framerate: f32,
    MetricsRenderVertices: i32,
    MetricsRenderIndices: i32,
    MetricsRenderWindows: i32,
    MetricsActiveWindows: i32,
    MetricsActiveAllocations: i32,
    MouseDelta: Vec2,
    MousePos: Vec2,
    MouseDown: [5]bool,
    MouseWheel: f32,
    MouseWheelH: f32,
    KeyCtrl: bool,
    KeyShift: bool,
    KeyAlt: bool,
    KeySuper: bool,
    NavInputs: [NavInput.COUNT]f32,
    KeyMods: ModFlags align(4),
    KeysData: [Key.KeysData_SIZE]KeyData,
    WantCaptureMouseUnlessPopupClose: bool,
    MousePosPrev: Vec2,
    MouseClickedPos: [5]Vec2,
    MouseClickedTime: [5]f64,
    MouseClicked: [5]bool,
    MouseDoubleClicked: [5]bool,
    MouseClickedCount: [5]u16,
    MouseClickedLastCount: [5]u16,
    MouseReleased: [5]bool,
    MouseDownOwned: [5]bool,
    MouseDownOwnedUnlessPopupClose: [5]bool,
    MouseDownDuration: [5]f32,
    MouseDownDurationPrev: [5]f32,
    MouseDragMaxDistanceSqr: [5]f32,
    NavInputsDownDuration: [NavInput.COUNT]f32,
    NavInputsDownDurationPrev: [NavInput.COUNT]f32,
    PenPressure: f32,
    AppFocusLost: bool,
    AppAcceptingEvents: bool,
    BackendUsingLegacyKeyArrays: i8,
    BackendUsingLegacyNavInputArray: bool,
    InputQueueSurrogate: Wchar16,
    InputQueueCharacters: Vector(Wchar),

    /// AddFocusEvent(self: *IO, focused: bool) void
    pub const AddFocusEvent = raw.ImGuiIO_AddFocusEvent;

    /// AddInputCharacter(self: *IO, c: u32) void
    pub const AddInputCharacter = raw.ImGuiIO_AddInputCharacter;

    /// AddInputCharacterUTF16(self: *IO, c: Wchar16) void
    pub const AddInputCharacterUTF16 = raw.ImGuiIO_AddInputCharacterUTF16;

    /// AddInputCharactersUTF8(self: *IO, str: ?[*:0]const u8) void
    pub const AddInputCharactersUTF8 = raw.ImGuiIO_AddInputCharactersUTF8;

    /// AddKeyAnalogEvent(self: *IO, key: Key, down: bool, v: f32) void
    pub const AddKeyAnalogEvent = raw.ImGuiIO_AddKeyAnalogEvent;

    /// AddKeyEvent(self: *IO, key: Key, down: bool) void
    pub const AddKeyEvent = raw.ImGuiIO_AddKeyEvent;

    /// AddMouseButtonEvent(self: *IO, button: i32, down: bool) void
    pub const AddMouseButtonEvent = raw.ImGuiIO_AddMouseButtonEvent;

    /// AddMousePosEvent(self: *IO, x: f32, y: f32) void
    pub const AddMousePosEvent = raw.ImGuiIO_AddMousePosEvent;

    /// AddMouseWheelEvent(self: *IO, wh_x: f32, wh_y: f32) void
    pub const AddMouseWheelEvent = raw.ImGuiIO_AddMouseWheelEvent;

    /// ClearInputCharacters(self: *IO) void
    pub const ClearInputCharacters = raw.ImGuiIO_ClearInputCharacters;

    /// ClearInputKeys(self: *IO) void
    pub const ClearInputKeys = raw.ImGuiIO_ClearInputKeys;

    /// init_ImGuiIO(self: ?*anyopaque) void
    pub const init_ImGuiIO = raw.ImGuiIO_ImGuiIO;

    /// SetAppAcceptingEvents(self: *IO, accepting_events: bool) void
    pub const SetAppAcceptingEvents = raw.ImGuiIO_SetAppAcceptingEvents;

    /// SetKeyEventNativeDataExt(self: *IO, key: Key, native_keycode: i32, native_scancode: i32, native_legacy_index: i32) void
    pub const SetKeyEventNativeDataExt = raw.ImGuiIO_SetKeyEventNativeData;
    pub inline fn SetKeyEventNativeData(self: *IO, key: Key, native_keycode: i32, native_scancode: i32) void {
        return @This().SetKeyEventNativeDataExt(self, key, native_keycode, native_scancode, -1);
    }

    /// deinit(self: *IO) void
    pub const deinit = raw.ImGuiIO_destroy;
};

pub const InputTextCallbackData = extern struct {
    EventFlag: InputTextFlags align(4),
    Flags: InputTextFlags align(4),
    UserData: ?*anyopaque,
    EventChar: Wchar,
    EventKey: Key,
    Buf: ?[*]u8,
    BufTextLen: i32,
    BufSize: i32,
    BufDirty: bool,
    CursorPos: i32,
    SelectionStart: i32,
    SelectionEnd: i32,

    /// ClearSelection(self: *InputTextCallbackData) void
    pub const ClearSelection = raw.ImGuiInputTextCallbackData_ClearSelection;

    /// DeleteChars(self: *InputTextCallbackData, pos: i32, bytes_count: i32) void
    pub const DeleteChars = raw.ImGuiInputTextCallbackData_DeleteChars;

    /// HasSelection(self: *const InputTextCallbackData) bool
    pub const HasSelection = raw.ImGuiInputTextCallbackData_HasSelection;

    /// init_ImGuiInputTextCallbackData(self: ?*anyopaque) void
    pub const init_ImGuiInputTextCallbackData = raw.ImGuiInputTextCallbackData_ImGuiInputTextCallbackData;

    /// InsertCharsExt(self: *InputTextCallbackData, pos: i32, text: ?[*]const u8, text_end: ?[*]const u8) void
    pub const InsertCharsExt = raw.ImGuiInputTextCallbackData_InsertChars;
    pub inline fn InsertChars(self: *InputTextCallbackData, pos: i32, text: ?[*]const u8) void {
        return @This().InsertCharsExt(self, pos, text, null);
    }

    /// SelectAll(self: *InputTextCallbackData) void
    pub const SelectAll = raw.ImGuiInputTextCallbackData_SelectAll;

    /// deinit(self: *InputTextCallbackData) void
    pub const deinit = raw.ImGuiInputTextCallbackData_destroy;
};

pub const KeyData = extern struct {
    Down: bool,
    DownDuration: f32,
    DownDurationPrev: f32,
    AnalogValue: f32,
};

pub const ListClipper = extern struct {
    DisplayStart: i32,
    DisplayEnd: i32,
    ItemsCount: i32,
    ItemsHeight: f32,
    StartPosY: f32,
    TempData: ?*anyopaque,

    /// BeginExt(self: *ListClipper, items_count: i32, items_height: f32) void
    pub const BeginExt = raw.ImGuiListClipper_Begin;
    pub inline fn Begin(self: *ListClipper, items_count: i32) void {
        return @This().BeginExt(self, items_count, -1.0);
    }

    /// End(self: *ListClipper) void
    pub const End = raw.ImGuiListClipper_End;

    /// ForceDisplayRangeByIndices(self: *ListClipper, item_min: i32, item_max: i32) void
    pub const ForceDisplayRangeByIndices = raw.ImGuiListClipper_ForceDisplayRangeByIndices;

    /// init_ImGuiListClipper(self: ?*anyopaque) void
    pub const init_ImGuiListClipper = raw.ImGuiListClipper_ImGuiListClipper;

    /// Step(self: *ListClipper) bool
    pub const Step = raw.ImGuiListClipper_Step;

    /// deinit(self: *ListClipper) void
    pub const deinit = raw.ImGuiListClipper_destroy;
};

pub const OnceUponAFrame = extern struct {
    RefFrame: i32,

    /// init_ImGuiOnceUponAFrame(self: ?*anyopaque) void
    pub const init_ImGuiOnceUponAFrame = raw.ImGuiOnceUponAFrame_ImGuiOnceUponAFrame;

    /// deinit(self: *OnceUponAFrame) void
    pub const deinit = raw.ImGuiOnceUponAFrame_destroy;
};

pub const Payload = extern struct {
    Data: ?*anyopaque,
    DataSize: i32,
    SourceId: ID,
    SourceParentId: ID,
    DataFrameCount: i32,
    DataType: [32+1]u8,
    Preview: bool,
    Delivery: bool,

    /// Clear(self: *Payload) void
    pub const Clear = raw.ImGuiPayload_Clear;

    /// init_ImGuiPayload(self: ?*anyopaque) void
    pub const init_ImGuiPayload = raw.ImGuiPayload_ImGuiPayload;

    /// IsDataType(self: *const Payload, kind: ?[*:0]const u8) bool
    pub const IsDataType = raw.ImGuiPayload_IsDataType;

    /// IsDelivery(self: *const Payload) bool
    pub const IsDelivery = raw.ImGuiPayload_IsDelivery;

    /// IsPreview(self: *const Payload) bool
    pub const IsPreview = raw.ImGuiPayload_IsPreview;

    /// deinit(self: *Payload) void
    pub const deinit = raw.ImGuiPayload_destroy;
};

pub const PlatformImeData = extern struct {
    WantVisible: bool,
    InputPos: Vec2,
    InputLineHeight: f32,

    /// init_ImGuiPlatformImeData(self: ?*anyopaque) void
    pub const init_ImGuiPlatformImeData = raw.ImGuiPlatformImeData_ImGuiPlatformImeData;

    /// deinit(self: *PlatformImeData) void
    pub const deinit = raw.ImGuiPlatformImeData_destroy;
};

pub const SizeCallbackData = extern struct {
    UserData: ?*anyopaque,
    Pos: Vec2,
    CurrentSize: Vec2,
    DesiredSize: Vec2,
};

pub const Storage = extern struct {
    Data: Vector(StoragePair),

    /// BuildSortByKey(self: *Storage) void
    pub const BuildSortByKey = raw.ImGuiStorage_BuildSortByKey;

    /// Clear(self: *Storage) void
    pub const Clear = raw.ImGuiStorage_Clear;

    /// GetBoolExt(self: *const Storage, key: ID, default_val: bool) bool
    pub const GetBoolExt = raw.ImGuiStorage_GetBool;
    pub inline fn GetBool(self: *const Storage, key: ID) bool {
        return @This().GetBoolExt(self, key, false);
    }

    /// GetBoolRefExt(self: *Storage, key: ID, default_val: bool) ?*bool
    pub const GetBoolRefExt = raw.ImGuiStorage_GetBoolRef;
    pub inline fn GetBoolRef(self: *Storage, key: ID) ?*bool {
        return @This().GetBoolRefExt(self, key, false);
    }

    /// GetFloatExt(self: *const Storage, key: ID, default_val: f32) f32
    pub const GetFloatExt = raw.ImGuiStorage_GetFloat;
    pub inline fn GetFloat(self: *const Storage, key: ID) f32 {
        return @This().GetFloatExt(self, key, 0.0);
    }

    /// GetFloatRefExt(self: *Storage, key: ID, default_val: f32) ?*f32
    pub const GetFloatRefExt = raw.ImGuiStorage_GetFloatRef;
    pub inline fn GetFloatRef(self: *Storage, key: ID) ?*f32 {
        return @This().GetFloatRefExt(self, key, 0.0);
    }

    /// GetIntExt(self: *const Storage, key: ID, default_val: i32) i32
    pub const GetIntExt = raw.ImGuiStorage_GetInt;
    pub inline fn GetInt(self: *const Storage, key: ID) i32 {
        return @This().GetIntExt(self, key, 0);
    }

    /// GetIntRefExt(self: *Storage, key: ID, default_val: i32) ?*i32
    pub const GetIntRefExt = raw.ImGuiStorage_GetIntRef;
    pub inline fn GetIntRef(self: *Storage, key: ID) ?*i32 {
        return @This().GetIntRefExt(self, key, 0);
    }

    /// GetVoidPtr(self: *const Storage, key: ID) ?*anyopaque
    pub const GetVoidPtr = raw.ImGuiStorage_GetVoidPtr;

    /// GetVoidPtrRefExt(self: *Storage, key: ID, default_val: ?*anyopaque) ?*?*anyopaque
    pub const GetVoidPtrRefExt = raw.ImGuiStorage_GetVoidPtrRef;
    pub inline fn GetVoidPtrRef(self: *Storage, key: ID) ?*?*anyopaque {
        return @This().GetVoidPtrRefExt(self, key, null);
    }

    /// SetAllInt(self: *Storage, val: i32) void
    pub const SetAllInt = raw.ImGuiStorage_SetAllInt;

    /// SetBool(self: *Storage, key: ID, val: bool) void
    pub const SetBool = raw.ImGuiStorage_SetBool;

    /// SetFloat(self: *Storage, key: ID, val: f32) void
    pub const SetFloat = raw.ImGuiStorage_SetFloat;

    /// SetInt(self: *Storage, key: ID, val: i32) void
    pub const SetInt = raw.ImGuiStorage_SetInt;

    /// SetVoidPtr(self: *Storage, key: ID, val: ?*anyopaque) void
    pub const SetVoidPtr = raw.ImGuiStorage_SetVoidPtr;
};

pub const StoragePair = extern struct {
    key: ID,
    value: extern union { val_i: i32, val_f: f32, val_p: ?*anyopaque },

    /// init_Int(self: ?*anyopaque, _key: ID, _val_i: i32) void
    pub const init_Int = raw.ImGuiStoragePair_ImGuiStoragePair_Int;

    /// init_Float(self: ?*anyopaque, _key: ID, _val_f: f32) void
    pub const init_Float = raw.ImGuiStoragePair_ImGuiStoragePair_Float;

    /// init_Ptr(self: ?*anyopaque, _key: ID, _val_p: ?*anyopaque) void
    pub const init_Ptr = raw.ImGuiStoragePair_ImGuiStoragePair_Ptr;

    /// deinit(self: *StoragePair) void
    pub const deinit = raw.ImGuiStoragePair_destroy;
};

pub const Style = extern struct {
    Alpha: f32,
    DisabledAlpha: f32,
    WindowPadding: Vec2,
    WindowRounding: f32,
    WindowBorderSize: f32,
    WindowMinSize: Vec2,
    WindowTitleAlign: Vec2,
    WindowMenuButtonPosition: Dir,
    ChildRounding: f32,
    ChildBorderSize: f32,
    PopupRounding: f32,
    PopupBorderSize: f32,
    FramePadding: Vec2,
    FrameRounding: f32,
    FrameBorderSize: f32,
    ItemSpacing: Vec2,
    ItemInnerSpacing: Vec2,
    CellPadding: Vec2,
    TouchExtraPadding: Vec2,
    IndentSpacing: f32,
    ColumnsMinSpacing: f32,
    ScrollbarSize: f32,
    ScrollbarRounding: f32,
    GrabMinSize: f32,
    GrabRounding: f32,
    LogSliderDeadzone: f32,
    TabRounding: f32,
    TabBorderSize: f32,
    TabMinWidthForCloseButton: f32,
    ColorButtonPosition: Dir,
    ButtonTextAlign: Vec2,
    SelectableTextAlign: Vec2,
    DisplayWindowPadding: Vec2,
    DisplaySafeAreaPadding: Vec2,
    MouseCursorScale: f32,
    AntiAliasedLines: bool,
    AntiAliasedLinesUseTex: bool,
    AntiAliasedFill: bool,
    CurveTessellationTol: f32,
    CircleTessellationMaxError: f32,
    Colors: [Col.COUNT]Vec4,

    /// init_ImGuiStyle(self: ?*anyopaque) void
    pub const init_ImGuiStyle = raw.ImGuiStyle_ImGuiStyle;

    /// ScaleAllSizes(self: *Style, scale_factor: f32) void
    pub const ScaleAllSizes = raw.ImGuiStyle_ScaleAllSizes;

    /// deinit(self: *Style) void
    pub const deinit = raw.ImGuiStyle_destroy;
};

pub const TableColumnSortSpecs = extern struct {
    ColumnUserID: ID,
    ColumnIndex: i16,
    SortOrder: i16,
    SortDirection: SortDirection,

    /// init_ImGuiTableColumnSortSpecs(self: ?*anyopaque) void
    pub const init_ImGuiTableColumnSortSpecs = raw.ImGuiTableColumnSortSpecs_ImGuiTableColumnSortSpecs;

    /// deinit(self: *TableColumnSortSpecs) void
    pub const deinit = raw.ImGuiTableColumnSortSpecs_destroy;
};

pub const TableSortSpecs = extern struct {
    Specs: ?[*]const TableColumnSortSpecs,
    SpecsCount: i32,
    SpecsDirty: bool,

    /// init_ImGuiTableSortSpecs(self: ?*anyopaque) void
    pub const init_ImGuiTableSortSpecs = raw.ImGuiTableSortSpecs_ImGuiTableSortSpecs;

    /// deinit(self: *TableSortSpecs) void
    pub const deinit = raw.ImGuiTableSortSpecs_destroy;
};

pub const TextBuffer = extern struct {
    Buf: Vector(u8),

    /// init_ImGuiTextBuffer(self: ?*anyopaque) void
    pub const init_ImGuiTextBuffer = raw.ImGuiTextBuffer_ImGuiTextBuffer;

    /// appendExt(self: *TextBuffer, str: ?[*]const u8, str_end: ?[*]const u8) void
    pub const appendExt = raw.ImGuiTextBuffer_append;
    pub inline fn append(self: *TextBuffer, str: ?[*]const u8) void {
        return @This().appendExt(self, str, null);
    }

    /// appendf(self: *TextBuffer, fmt: ?[*:0]const u8, ...: ...) void
    pub const appendf = raw.ImGuiTextBuffer_appendf;

    /// begin(self: *const TextBuffer) [*]const u8
    pub const begin = raw.ImGuiTextBuffer_begin;

    /// c_str(self: *const TextBuffer) [*:0]const u8
    pub const c_str = raw.ImGuiTextBuffer_c_str;

    /// clear(self: *TextBuffer) void
    pub const clear = raw.ImGuiTextBuffer_clear;

    /// deinit(self: *TextBuffer) void
    pub const deinit = raw.ImGuiTextBuffer_destroy;

    /// empty(self: *const TextBuffer) bool
    pub const empty = raw.ImGuiTextBuffer_empty;

    /// end(self: *const TextBuffer) [*]const u8
    pub const end = raw.ImGuiTextBuffer_end;

    /// reserve(self: *TextBuffer, capacity: i32) void
    pub const reserve = raw.ImGuiTextBuffer_reserve;

    /// size(self: *const TextBuffer) i32
    pub const size = raw.ImGuiTextBuffer_size;
};

pub const TextFilter = extern struct {
    InputBuf: [256]u8,
    Filters: Vector(TextRange),
    CountGrep: i32,

    /// Build(self: *TextFilter) void
    pub const Build = raw.ImGuiTextFilter_Build;

    /// Clear(self: *TextFilter) void
    pub const Clear = raw.ImGuiTextFilter_Clear;

    /// DrawExt(self: *TextFilter, label: ?[*:0]const u8, width: f32) bool
    pub const DrawExt = raw.ImGuiTextFilter_Draw;
    pub inline fn Draw(self: *TextFilter) bool {
        return @This().DrawExt(self, "Filter(inc,-exc)", 0.0);
    }

    /// init_ImGuiTextFilterExt(self: ?*anyopaque, default_filter: ?[*:0]const u8) void
    pub const init_ImGuiTextFilterExt = raw.ImGuiTextFilter_ImGuiTextFilter;
    pub inline fn init_ImGuiTextFilter(self: ?*anyopaque) void {
        return @This().init_ImGuiTextFilterExt(self, "");
    }

    /// IsActive(self: *const TextFilter) bool
    pub const IsActive = raw.ImGuiTextFilter_IsActive;

    /// PassFilterExt(self: *const TextFilter, text: ?[*]const u8, text_end: ?[*]const u8) bool
    pub const PassFilterExt = raw.ImGuiTextFilter_PassFilter;
    pub inline fn PassFilter(self: *const TextFilter, text: ?[*]const u8) bool {
        return @This().PassFilterExt(self, text, null);
    }

    /// deinit(self: *TextFilter) void
    pub const deinit = raw.ImGuiTextFilter_destroy;
};

pub const TextRange = extern struct {
    b: ?[*]const u8,
    e: ?[*]const u8,

    /// init_Nil(self: ?*anyopaque) void
    pub const init_Nil = raw.ImGuiTextRange_ImGuiTextRange_Nil;

    /// init_Str(self: ?*anyopaque, _b: ?[*]const u8, _e: ?[*]const u8) void
    pub const init_Str = raw.ImGuiTextRange_ImGuiTextRange_Str;

    /// deinit(self: *TextRange) void
    pub const deinit = raw.ImGuiTextRange_destroy;

    /// empty(self: *const TextRange) bool
    pub const empty = raw.ImGuiTextRange_empty;

    /// split(self: *const TextRange, separator: u8, out: ?*Vector(TextRange)) void
    pub const split = raw.ImGuiTextRange_split;
};

pub const Viewport = extern struct {
    Flags: ViewportFlags align(4),
    Pos: Vec2,
    Size: Vec2,
    WorkPos: Vec2,
    WorkSize: Vec2,
    PlatformHandleRaw: ?*anyopaque,

    pub inline fn GetCenter(self: *const Viewport) Vec2 {
        var out: Vec2 = undefined;
        raw.ImGuiViewport_GetCenter(&out, self);
        return out;
    }

    pub inline fn GetWorkCenter(self: *const Viewport) Vec2 {
        var out: Vec2 = undefined;
        raw.ImGuiViewport_GetWorkCenter(&out, self);
        return out;
    }

    /// init_ImGuiViewport(self: ?*anyopaque) void
    pub const init_ImGuiViewport = raw.ImGuiViewport_ImGuiViewport;

    /// deinit(self: *Viewport) void
    pub const deinit = raw.ImGuiViewport_destroy;
};


pub inline fn AcceptDragDropPayloadExt(kind: ?[*:0]const u8, flags: DragDropFlags) ?*const Payload {
    return raw.igAcceptDragDropPayload(kind, flags.toInt());
}
pub inline fn AcceptDragDropPayload(kind: ?[*:0]const u8) ?*const Payload {
    return @This().AcceptDragDropPayloadExt(kind, .{});
}

/// AlignTextToFramePadding() void
pub const AlignTextToFramePadding = raw.igAlignTextToFramePadding;

/// ArrowButton(str_id: ?[*:0]const u8, dir: Dir) bool
pub const ArrowButton = raw.igArrowButton;

pub inline fn BeginExt(name: ?[*:0]const u8, p_open: ?*bool, flags: WindowFlags) bool {
    return raw.igBegin(name, p_open, flags.toInt());
}
pub inline fn Begin(name: ?[*:0]const u8) bool {
    return @This().BeginExt(name, null, .{});
}

pub inline fn BeginChild_StrExt(str_id: ?[*:0]const u8, size: Vec2, border: bool, flags: WindowFlags) bool {
    return raw.igBeginChild_Str(str_id, &size, border, flags.toInt());
}
pub inline fn BeginChild_Str(str_id: ?[*:0]const u8) bool {
    return @This().BeginChild_StrExt(str_id, .{.x=0,.y=0}, false, .{});
}

pub inline fn BeginChild_IDExt(id: ID, size: Vec2, border: bool, flags: WindowFlags) bool {
    return raw.igBeginChild_ID(id, &size, border, flags.toInt());
}
pub inline fn BeginChild_ID(id: ID) bool {
    return @This().BeginChild_IDExt(id, .{.x=0,.y=0}, false, .{});
}

pub inline fn BeginChildFrameExt(id: ID, size: Vec2, flags: WindowFlags) bool {
    return raw.igBeginChildFrame(id, &size, flags.toInt());
}
pub inline fn BeginChildFrame(id: ID, size: Vec2) bool {
    return @This().BeginChildFrameExt(id, size, .{});
}

pub inline fn BeginComboExt(label: ?[*:0]const u8, preview_value: ?[*:0]const u8, flags: ComboFlags) bool {
    return raw.igBeginCombo(label, preview_value, flags.toInt());
}
pub inline fn BeginCombo(label: ?[*:0]const u8, preview_value: ?[*:0]const u8) bool {
    return @This().BeginComboExt(label, preview_value, .{});
}

/// BeginDisabledExt(disabled: bool) void
pub const BeginDisabledExt = raw.igBeginDisabled;
pub inline fn BeginDisabled() void {
    return @This().BeginDisabledExt(true);
}

pub inline fn BeginDragDropSourceExt(flags: DragDropFlags) bool {
    return raw.igBeginDragDropSource(flags.toInt());
}
pub inline fn BeginDragDropSource() bool {
    return @This().BeginDragDropSourceExt(.{});
}

/// BeginDragDropTarget() bool
pub const BeginDragDropTarget = raw.igBeginDragDropTarget;

/// BeginGroup() void
pub const BeginGroup = raw.igBeginGroup;

pub inline fn BeginListBoxExt(label: ?[*:0]const u8, size: Vec2) bool {
    return raw.igBeginListBox(label, &size);
}
pub inline fn BeginListBox(label: ?[*:0]const u8) bool {
    return @This().BeginListBoxExt(label, .{.x=0,.y=0});
}

/// BeginMainMenuBar() bool
pub const BeginMainMenuBar = raw.igBeginMainMenuBar;

/// BeginMenuExt(label: ?[*:0]const u8, enabled: bool) bool
pub const BeginMenuExt = raw.igBeginMenu;
pub inline fn BeginMenu(label: ?[*:0]const u8) bool {
    return @This().BeginMenuExt(label, true);
}

/// BeginMenuBar() bool
pub const BeginMenuBar = raw.igBeginMenuBar;

pub inline fn BeginPopupExt(str_id: ?[*:0]const u8, flags: WindowFlags) bool {
    return raw.igBeginPopup(str_id, flags.toInt());
}
pub inline fn BeginPopup(str_id: ?[*:0]const u8) bool {
    return @This().BeginPopupExt(str_id, .{});
}

pub inline fn BeginPopupContextItemExt(str_id: ?[*:0]const u8, popup_flags: PopupFlags) bool {
    return raw.igBeginPopupContextItem(str_id, popup_flags.toInt());
}
pub inline fn BeginPopupContextItem() bool {
    return @This().BeginPopupContextItemExt(null, .{ .MouseButtonRight = true });
}

pub inline fn BeginPopupContextVoidExt(str_id: ?[*:0]const u8, popup_flags: PopupFlags) bool {
    return raw.igBeginPopupContextVoid(str_id, popup_flags.toInt());
}
pub inline fn BeginPopupContextVoid() bool {
    return @This().BeginPopupContextVoidExt(null, .{ .MouseButtonRight = true });
}

pub inline fn BeginPopupContextWindowExt(str_id: ?[*:0]const u8, popup_flags: PopupFlags) bool {
    return raw.igBeginPopupContextWindow(str_id, popup_flags.toInt());
}
pub inline fn BeginPopupContextWindow() bool {
    return @This().BeginPopupContextWindowExt(null, .{ .MouseButtonRight = true });
}

pub inline fn BeginPopupModalExt(name: ?[*:0]const u8, p_open: ?*bool, flags: WindowFlags) bool {
    return raw.igBeginPopupModal(name, p_open, flags.toInt());
}
pub inline fn BeginPopupModal(name: ?[*:0]const u8) bool {
    return @This().BeginPopupModalExt(name, null, .{});
}

pub inline fn BeginTabBarExt(str_id: ?[*:0]const u8, flags: TabBarFlags) bool {
    return raw.igBeginTabBar(str_id, flags.toInt());
}
pub inline fn BeginTabBar(str_id: ?[*:0]const u8) bool {
    return @This().BeginTabBarExt(str_id, .{});
}

pub inline fn BeginTabItemExt(label: ?[*:0]const u8, p_open: ?*bool, flags: TabItemFlags) bool {
    return raw.igBeginTabItem(label, p_open, flags.toInt());
}
pub inline fn BeginTabItem(label: ?[*:0]const u8) bool {
    return @This().BeginTabItemExt(label, null, .{});
}

pub inline fn BeginTableExt(str_id: ?[*:0]const u8, column: i32, flags: TableFlags, outer_size: Vec2, inner_width: f32) bool {
    return raw.igBeginTable(str_id, column, flags.toInt(), &outer_size, inner_width);
}
pub inline fn BeginTable(str_id: ?[*:0]const u8, column: i32) bool {
    return @This().BeginTableExt(str_id, column, .{}, .{.x=0.0,.y=0.0}, 0.0);
}

/// BeginTooltip() void
pub const BeginTooltip = raw.igBeginTooltip;

/// Bullet() void
pub const Bullet = raw.igBullet;

/// BulletText(fmt: ?[*:0]const u8, ...: ...) void
pub const BulletText = raw.igBulletText;

pub inline fn ButtonExt(label: ?[*:0]const u8, size: Vec2) bool {
    return raw.igButton(label, &size);
}
pub inline fn Button(label: ?[*:0]const u8) bool {
    return @This().ButtonExt(label, .{.x=0,.y=0});
}

/// CalcItemWidth() f32
pub const CalcItemWidth = raw.igCalcItemWidth;

pub inline fn CalcTextSizeExt(text: ?[*]const u8, text_end: ?[*]const u8, hide_text_after_double_hash: bool, wrap_width: f32) Vec2 {
    var out: Vec2 = undefined;
    raw.igCalcTextSize(&out, text, text_end, hide_text_after_double_hash, wrap_width);
    return out;
}
pub inline fn CalcTextSize(text: ?[*]const u8) Vec2 {
    return @This().CalcTextSizeExt(text, null, false, -1.0);
}

/// Checkbox(label: ?[*:0]const u8, v: *bool) bool
pub const Checkbox = raw.igCheckbox;

/// CheckboxFlags_IntPtr(label: ?[*:0]const u8, flags: *i32, flags_value: i32) bool
pub const CheckboxFlags_IntPtr = raw.igCheckboxFlags_IntPtr;

/// CheckboxFlags_UintPtr(label: ?[*:0]const u8, flags: *u32, flags_value: u32) bool
pub const CheckboxFlags_UintPtr = raw.igCheckboxFlags_UintPtr;

/// CloseCurrentPopup() void
pub const CloseCurrentPopup = raw.igCloseCurrentPopup;

pub inline fn CollapsingHeader_TreeNodeFlagsExt(label: ?[*:0]const u8, flags: TreeNodeFlags) bool {
    return raw.igCollapsingHeader_TreeNodeFlags(label, flags.toInt());
}
pub inline fn CollapsingHeader_TreeNodeFlags(label: ?[*:0]const u8) bool {
    return @This().CollapsingHeader_TreeNodeFlagsExt(label, .{});
}

pub inline fn CollapsingHeader_BoolPtrExt(label: ?[*:0]const u8, p_visible: ?*bool, flags: TreeNodeFlags) bool {
    return raw.igCollapsingHeader_BoolPtr(label, p_visible, flags.toInt());
}
pub inline fn CollapsingHeader_BoolPtr(label: ?[*:0]const u8, p_visible: ?*bool) bool {
    return @This().CollapsingHeader_BoolPtrExt(label, p_visible, .{});
}

pub inline fn ColorButtonExt(desc_id: ?[*:0]const u8, col: Vec4, flags: ColorEditFlags, size: Vec2) bool {
    return raw.igColorButton(desc_id, &col, flags.toInt(), &size);
}
pub inline fn ColorButton(desc_id: ?[*:0]const u8, col: Vec4) bool {
    return @This().ColorButtonExt(desc_id, col, .{}, .{.x=0,.y=0});
}

pub inline fn ColorConvertFloat4ToU32(in: Vec4) u32 {
    return raw.igColorConvertFloat4ToU32(&in);
}

/// ColorConvertHSVtoRGB(h: f32, s: f32, v: f32, out_r: *f32, out_g: *f32, out_b: *f32) void
pub const ColorConvertHSVtoRGB = raw.igColorConvertHSVtoRGB;

/// ColorConvertRGBtoHSV(r: f32, g: f32, b: f32, out_h: *f32, out_s: *f32, out_v: *f32) void
pub const ColorConvertRGBtoHSV = raw.igColorConvertRGBtoHSV;

pub inline fn ColorConvertU32ToFloat4(in: u32) Vec4 {
    var out: Vec4 = undefined;
    raw.igColorConvertU32ToFloat4(&out, in);
    return out;
}

pub inline fn ColorEdit3Ext(label: ?[*:0]const u8, col: *[3]f32, flags: ColorEditFlags) bool {
    return raw.igColorEdit3(label, col, flags.toInt());
}
pub inline fn ColorEdit3(label: ?[*:0]const u8, col: *[3]f32) bool {
    return @This().ColorEdit3Ext(label, col, .{});
}

pub inline fn ColorEdit4Ext(label: ?[*:0]const u8, col: *[4]f32, flags: ColorEditFlags) bool {
    return raw.igColorEdit4(label, col, flags.toInt());
}
pub inline fn ColorEdit4(label: ?[*:0]const u8, col: *[4]f32) bool {
    return @This().ColorEdit4Ext(label, col, .{});
}

pub inline fn ColorPicker3Ext(label: ?[*:0]const u8, col: *[3]f32, flags: ColorEditFlags) bool {
    return raw.igColorPicker3(label, col, flags.toInt());
}
pub inline fn ColorPicker3(label: ?[*:0]const u8, col: *[3]f32) bool {
    return @This().ColorPicker3Ext(label, col, .{});
}

pub inline fn ColorPicker4Ext(label: ?[*:0]const u8, col: *[4]f32, flags: ColorEditFlags, ref_col: ?*const[4]f32) bool {
    return raw.igColorPicker4(label, col, flags.toInt(), ref_col);
}
pub inline fn ColorPicker4(label: ?[*:0]const u8, col: *[4]f32) bool {
    return @This().ColorPicker4Ext(label, col, .{}, null);
}

/// ColumnsExt(count: i32, id: ?[*:0]const u8, border: bool) void
pub const ColumnsExt = raw.igColumns;
pub inline fn Columns() void {
    return @This().ColumnsExt(1, null, true);
}

/// Combo_Str_arrExt(label: ?[*:0]const u8, current_item: ?*i32, items: [*]const[*:0]const u8, items_count: i32, popup_max_height_in_items: i32) bool
pub const Combo_Str_arrExt = raw.igCombo_Str_arr;
pub inline fn Combo_Str_arr(label: ?[*:0]const u8, current_item: ?*i32, items: [*]const[*:0]const u8, items_count: i32) bool {
    return @This().Combo_Str_arrExt(label, current_item, items, items_count, -1);
}

/// Combo_StrExt(label: ?[*:0]const u8, current_item: ?*i32, items_separated_by_zeros: ?[*]const u8, popup_max_height_in_items: i32) bool
pub const Combo_StrExt = raw.igCombo_Str;
pub inline fn Combo_Str(label: ?[*:0]const u8, current_item: ?*i32, items_separated_by_zeros: ?[*]const u8) bool {
    return @This().Combo_StrExt(label, current_item, items_separated_by_zeros, -1);
}

/// Combo_FnBoolPtrExt(label: ?[*:0]const u8, current_item: ?*i32, items_getter: ?*const fn (data: ?*anyopaque, idx: i32, out_text: *?[*:0]const u8) callconv(.C) bool, data: ?*anyopaque, items_count: i32, popup_max_height_in_items: i32) bool
pub const Combo_FnBoolPtrExt = raw.igCombo_FnBoolPtr;
pub inline fn Combo_FnBoolPtr(label: ?[*:0]const u8, current_item: ?*i32, items_getter: ?*const fn (data: ?*anyopaque, idx: i32, out_text: *?[*:0]const u8) callconv(.C) bool, data: ?*anyopaque, items_count: i32) bool {
    return @This().Combo_FnBoolPtrExt(label, current_item, items_getter, data, items_count, -1);
}

/// CreateContextExt(shared_font_atlas: ?*FontAtlas) ?*Context
pub const CreateContextExt = raw.igCreateContext;
pub inline fn CreateContext() ?*Context {
    return @This().CreateContextExt(null);
}

/// DebugCheckVersionAndDataLayout(version_str: ?[*:0]const u8, sz_io: usize, sz_style: usize, sz_vec2: usize, sz_vec4: usize, sz_drawvert: usize, sz_drawidx: usize) bool
pub const DebugCheckVersionAndDataLayout = raw.igDebugCheckVersionAndDataLayout;

/// DebugTextEncoding(text: ?[*]const u8) void
pub const DebugTextEncoding = raw.igDebugTextEncoding;

/// DestroyContextExt(ctx: ?*Context) void
pub const DestroyContextExt = raw.igDestroyContext;
pub inline fn DestroyContext() void {
    return @This().DestroyContextExt(null);
}

pub inline fn DragFloatExt(label: ?[*:0]const u8, v: *f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igDragFloat(label, v, v_speed, v_min, v_max, format, flags.toInt());
}
pub inline fn DragFloat(label: ?[*:0]const u8, v: *f32) bool {
    return @This().DragFloatExt(label, v, 1.0, 0.0, 0.0, "%.3f", .{});
}

pub inline fn DragFloat2Ext(label: ?[*:0]const u8, v: *[2]f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igDragFloat2(label, v, v_speed, v_min, v_max, format, flags.toInt());
}
pub inline fn DragFloat2(label: ?[*:0]const u8, v: *[2]f32) bool {
    return @This().DragFloat2Ext(label, v, 1.0, 0.0, 0.0, "%.3f", .{});
}

pub inline fn DragFloat3Ext(label: ?[*:0]const u8, v: *[3]f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igDragFloat3(label, v, v_speed, v_min, v_max, format, flags.toInt());
}
pub inline fn DragFloat3(label: ?[*:0]const u8, v: *[3]f32) bool {
    return @This().DragFloat3Ext(label, v, 1.0, 0.0, 0.0, "%.3f", .{});
}

pub inline fn DragFloat4Ext(label: ?[*:0]const u8, v: *[4]f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igDragFloat4(label, v, v_speed, v_min, v_max, format, flags.toInt());
}
pub inline fn DragFloat4(label: ?[*:0]const u8, v: *[4]f32) bool {
    return @This().DragFloat4Ext(label, v, 1.0, 0.0, 0.0, "%.3f", .{});
}

pub inline fn DragFloatRange2Ext(label: ?[*:0]const u8, v_current_min: *f32, v_current_max: *f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, format_max: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igDragFloatRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, flags.toInt());
}
pub inline fn DragFloatRange2(label: ?[*:0]const u8, v_current_min: *f32, v_current_max: *f32) bool {
    return @This().DragFloatRange2Ext(label, v_current_min, v_current_max, 1.0, 0.0, 0.0, "%.3f", null, .{});
}

pub inline fn DragIntExt(label: ?[*:0]const u8, v: *i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igDragInt(label, v, v_speed, v_min, v_max, format, flags.toInt());
}
pub inline fn DragInt(label: ?[*:0]const u8, v: *i32) bool {
    return @This().DragIntExt(label, v, 1.0, 0, 0, "%d", .{});
}

pub inline fn DragInt2Ext(label: ?[*:0]const u8, v: *[2]i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igDragInt2(label, v, v_speed, v_min, v_max, format, flags.toInt());
}
pub inline fn DragInt2(label: ?[*:0]const u8, v: *[2]i32) bool {
    return @This().DragInt2Ext(label, v, 1.0, 0, 0, "%d", .{});
}

pub inline fn DragInt3Ext(label: ?[*:0]const u8, v: *[3]i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igDragInt3(label, v, v_speed, v_min, v_max, format, flags.toInt());
}
pub inline fn DragInt3(label: ?[*:0]const u8, v: *[3]i32) bool {
    return @This().DragInt3Ext(label, v, 1.0, 0, 0, "%d", .{});
}

pub inline fn DragInt4Ext(label: ?[*:0]const u8, v: *[4]i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igDragInt4(label, v, v_speed, v_min, v_max, format, flags.toInt());
}
pub inline fn DragInt4(label: ?[*:0]const u8, v: *[4]i32) bool {
    return @This().DragInt4Ext(label, v, 1.0, 0, 0, "%d", .{});
}

pub inline fn DragIntRange2Ext(label: ?[*:0]const u8, v_current_min: *i32, v_current_max: *i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8, format_max: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igDragIntRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, flags.toInt());
}
pub inline fn DragIntRange2(label: ?[*:0]const u8, v_current_min: *i32, v_current_max: *i32) bool {
    return @This().DragIntRange2Ext(label, v_current_min, v_current_max, 1.0, 0, 0, "%d", null, .{});
}

pub inline fn DragScalarExt(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, v_speed: f32, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igDragScalar(label, data_type, p_data, v_speed, p_min, p_max, format, flags.toInt());
}
pub inline fn DragScalar(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque) bool {
    return @This().DragScalarExt(label, data_type, p_data, 1.0, null, null, null, .{});
}

pub inline fn DragScalarNExt(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, components: i32, v_speed: f32, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igDragScalarN(label, data_type, p_data, components, v_speed, p_min, p_max, format, flags.toInt());
}
pub inline fn DragScalarN(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, components: i32) bool {
    return @This().DragScalarNExt(label, data_type, p_data, components, 1.0, null, null, null, .{});
}

pub inline fn Dummy(size: Vec2) void {
    return raw.igDummy(&size);
}

/// End() void
pub const End = raw.igEnd;

/// EndChild() void
pub const EndChild = raw.igEndChild;

/// EndChildFrame() void
pub const EndChildFrame = raw.igEndChildFrame;

/// EndCombo() void
pub const EndCombo = raw.igEndCombo;

/// EndDisabled() void
pub const EndDisabled = raw.igEndDisabled;

/// EndDragDropSource() void
pub const EndDragDropSource = raw.igEndDragDropSource;

/// EndDragDropTarget() void
pub const EndDragDropTarget = raw.igEndDragDropTarget;

/// EndFrame() void
pub const EndFrame = raw.igEndFrame;

/// EndGroup() void
pub const EndGroup = raw.igEndGroup;

/// EndListBox() void
pub const EndListBox = raw.igEndListBox;

/// EndMainMenuBar() void
pub const EndMainMenuBar = raw.igEndMainMenuBar;

/// EndMenu() void
pub const EndMenu = raw.igEndMenu;

/// EndMenuBar() void
pub const EndMenuBar = raw.igEndMenuBar;

/// EndPopup() void
pub const EndPopup = raw.igEndPopup;

/// EndTabBar() void
pub const EndTabBar = raw.igEndTabBar;

/// EndTabItem() void
pub const EndTabItem = raw.igEndTabItem;

/// EndTable() void
pub const EndTable = raw.igEndTable;

/// EndTooltip() void
pub const EndTooltip = raw.igEndTooltip;

/// GetAllocatorFunctions(p_alloc_func: ?*MemAllocFunc, p_free_func: ?*MemFreeFunc, p_user_data: ?*?*anyopaque) void
pub const GetAllocatorFunctions = raw.igGetAllocatorFunctions;

/// GetBackgroundDrawList() ?*DrawList
pub const GetBackgroundDrawList = raw.igGetBackgroundDrawList;

/// GetClipboardText() ?[*:0]const u8
pub const GetClipboardText = raw.igGetClipboardText;

/// GetColorU32_ColExt(idx: Col, alpha_mul: f32) u32
pub const GetColorU32_ColExt = raw.igGetColorU32_Col;
pub inline fn GetColorU32_Col(idx: Col) u32 {
    return @This().GetColorU32_ColExt(idx, 1.0);
}

pub inline fn GetColorU32_Vec4(col: Vec4) u32 {
    return raw.igGetColorU32_Vec4(&col);
}

/// GetColorU32_U32(col: u32) u32
pub const GetColorU32_U32 = raw.igGetColorU32_U32;

/// GetColumnIndex() i32
pub const GetColumnIndex = raw.igGetColumnIndex;

/// GetColumnOffsetExt(column_index: i32) f32
pub const GetColumnOffsetExt = raw.igGetColumnOffset;
pub inline fn GetColumnOffset() f32 {
    return @This().GetColumnOffsetExt(-1);
}

/// GetColumnWidthExt(column_index: i32) f32
pub const GetColumnWidthExt = raw.igGetColumnWidth;
pub inline fn GetColumnWidth() f32 {
    return @This().GetColumnWidthExt(-1);
}

/// GetColumnsCount() i32
pub const GetColumnsCount = raw.igGetColumnsCount;

pub inline fn GetContentRegionAvail() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetContentRegionAvail(&out);
    return out;
}

pub inline fn GetContentRegionMax() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetContentRegionMax(&out);
    return out;
}

/// GetCurrentContext() ?*Context
pub const GetCurrentContext = raw.igGetCurrentContext;

pub inline fn GetCursorPos() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetCursorPos(&out);
    return out;
}

/// GetCursorPosX() f32
pub const GetCursorPosX = raw.igGetCursorPosX;

/// GetCursorPosY() f32
pub const GetCursorPosY = raw.igGetCursorPosY;

pub inline fn GetCursorScreenPos() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetCursorScreenPos(&out);
    return out;
}

pub inline fn GetCursorStartPos() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetCursorStartPos(&out);
    return out;
}

/// GetDragDropPayload() ?*const Payload
pub const GetDragDropPayload = raw.igGetDragDropPayload;

/// GetDrawData() *DrawData
pub const GetDrawData = raw.igGetDrawData;

/// GetDrawListSharedData() ?*DrawListSharedData
pub const GetDrawListSharedData = raw.igGetDrawListSharedData;

/// GetFont() ?*Font
pub const GetFont = raw.igGetFont;

/// GetFontSize() f32
pub const GetFontSize = raw.igGetFontSize;

pub inline fn GetFontTexUvWhitePixel() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetFontTexUvWhitePixel(&out);
    return out;
}

/// GetForegroundDrawList() ?*DrawList
pub const GetForegroundDrawList = raw.igGetForegroundDrawList;

/// GetFrameCount() i32
pub const GetFrameCount = raw.igGetFrameCount;

/// GetFrameHeight() f32
pub const GetFrameHeight = raw.igGetFrameHeight;

/// GetFrameHeightWithSpacing() f32
pub const GetFrameHeightWithSpacing = raw.igGetFrameHeightWithSpacing;

/// GetID_Str(str_id: ?[*:0]const u8) ID
pub const GetID_Str = raw.igGetID_Str;

/// GetID_StrStr(str_id_begin: ?[*]const u8, str_id_end: ?[*]const u8) ID
pub const GetID_StrStr = raw.igGetID_StrStr;

/// GetID_Ptr(ptr_id: ?*const anyopaque) ID
pub const GetID_Ptr = raw.igGetID_Ptr;

/// GetIO() *IO
pub const GetIO = raw.igGetIO;

pub inline fn GetItemRectMax() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetItemRectMax(&out);
    return out;
}

pub inline fn GetItemRectMin() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetItemRectMin(&out);
    return out;
}

pub inline fn GetItemRectSize() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetItemRectSize(&out);
    return out;
}

/// GetKeyIndex(key: Key) i32
pub const GetKeyIndex = raw.igGetKeyIndex;

/// GetKeyName(key: Key) ?[*:0]const u8
pub const GetKeyName = raw.igGetKeyName;

/// GetKeyPressedAmount(key: Key, repeat_delay: f32, rate: f32) i32
pub const GetKeyPressedAmount = raw.igGetKeyPressedAmount;

/// GetMainViewport() ?*Viewport
pub const GetMainViewport = raw.igGetMainViewport;

/// GetMouseClickedCount(button: MouseButton) i32
pub const GetMouseClickedCount = raw.igGetMouseClickedCount;

/// GetMouseCursor() MouseCursor
pub const GetMouseCursor = raw.igGetMouseCursor;

pub inline fn GetMouseDragDeltaExt(button: MouseButton, lock_threshold: f32) Vec2 {
    var out: Vec2 = undefined;
    raw.igGetMouseDragDelta(&out, button, lock_threshold);
    return out;
}
pub inline fn GetMouseDragDelta() Vec2 {
    return @This().GetMouseDragDeltaExt(.Left, -1.0);
}

pub inline fn GetMousePos() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetMousePos(&out);
    return out;
}

pub inline fn GetMousePosOnOpeningCurrentPopup() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetMousePosOnOpeningCurrentPopup(&out);
    return out;
}

/// GetScrollMaxX() f32
pub const GetScrollMaxX = raw.igGetScrollMaxX;

/// GetScrollMaxY() f32
pub const GetScrollMaxY = raw.igGetScrollMaxY;

/// GetScrollX() f32
pub const GetScrollX = raw.igGetScrollX;

/// GetScrollY() f32
pub const GetScrollY = raw.igGetScrollY;

/// GetStateStorage() ?*Storage
pub const GetStateStorage = raw.igGetStateStorage;

/// GetStyle() ?*Style
pub const GetStyle = raw.igGetStyle;

/// GetStyleColorName(idx: Col) ?[*:0]const u8
pub const GetStyleColorName = raw.igGetStyleColorName;

/// GetStyleColorVec4(idx: Col) ?*const Vec4
pub const GetStyleColorVec4 = raw.igGetStyleColorVec4;

/// GetTextLineHeight() f32
pub const GetTextLineHeight = raw.igGetTextLineHeight;

/// GetTextLineHeightWithSpacing() f32
pub const GetTextLineHeightWithSpacing = raw.igGetTextLineHeightWithSpacing;

/// GetTime() f64
pub const GetTime = raw.igGetTime;

/// GetTreeNodeToLabelSpacing() f32
pub const GetTreeNodeToLabelSpacing = raw.igGetTreeNodeToLabelSpacing;

/// GetVersion() ?[*:0]const u8
pub const GetVersion = raw.igGetVersion;

pub inline fn GetWindowContentRegionMax() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetWindowContentRegionMax(&out);
    return out;
}

pub inline fn GetWindowContentRegionMin() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetWindowContentRegionMin(&out);
    return out;
}

/// GetWindowDrawList() ?*DrawList
pub const GetWindowDrawList = raw.igGetWindowDrawList;

/// GetWindowHeight() f32
pub const GetWindowHeight = raw.igGetWindowHeight;

pub inline fn GetWindowPos() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetWindowPos(&out);
    return out;
}

pub inline fn GetWindowSize() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetWindowSize(&out);
    return out;
}

/// GetWindowWidth() f32
pub const GetWindowWidth = raw.igGetWindowWidth;

pub inline fn ImageExt(user_texture_id: TextureID, size: Vec2, uv0: Vec2, uv1: Vec2, tint_col: Vec4, border_col: Vec4) void {
    return raw.igImage(user_texture_id, &size, &uv0, &uv1, &tint_col, &border_col);
}
pub inline fn Image(user_texture_id: TextureID, size: Vec2) void {
    return @This().ImageExt(user_texture_id, size, .{.x=0,.y=0}, .{.x=1,.y=1}, .{.x=1,.y=1,.z=1,.w=1}, .{.x=0,.y=0,.z=0,.w=0});
}

pub inline fn ImageButtonExt(user_texture_id: TextureID, size: Vec2, uv0: Vec2, uv1: Vec2, frame_padding: i32, bg_col: Vec4, tint_col: Vec4) bool {
    return raw.igImageButton(user_texture_id, &size, &uv0, &uv1, frame_padding, &bg_col, &tint_col);
}
pub inline fn ImageButton(user_texture_id: TextureID, size: Vec2) bool {
    return @This().ImageButtonExt(user_texture_id, size, .{.x=0,.y=0}, .{.x=1,.y=1}, -1, .{.x=0,.y=0,.z=0,.w=0}, .{.x=1,.y=1,.z=1,.w=1});
}

/// IndentExt(indent_w: f32) void
pub const IndentExt = raw.igIndent;
pub inline fn Indent() void {
    return @This().IndentExt(0.0);
}

pub inline fn InputDoubleExt(label: ?[*:0]const u8, v: *f64, step: f64, step_fast: f64, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputDouble(label, v, step, step_fast, format, flags.toInt());
}
pub inline fn InputDouble(label: ?[*:0]const u8, v: *f64) bool {
    return @This().InputDoubleExt(label, v, 0.0, 0.0, "%.6f", .{});
}

pub inline fn InputFloatExt(label: ?[*:0]const u8, v: *f32, step: f32, step_fast: f32, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputFloat(label, v, step, step_fast, format, flags.toInt());
}
pub inline fn InputFloat(label: ?[*:0]const u8, v: *f32) bool {
    return @This().InputFloatExt(label, v, 0.0, 0.0, "%.3f", .{});
}

pub inline fn InputFloat2Ext(label: ?[*:0]const u8, v: *[2]f32, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputFloat2(label, v, format, flags.toInt());
}
pub inline fn InputFloat2(label: ?[*:0]const u8, v: *[2]f32) bool {
    return @This().InputFloat2Ext(label, v, "%.3f", .{});
}

pub inline fn InputFloat3Ext(label: ?[*:0]const u8, v: *[3]f32, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputFloat3(label, v, format, flags.toInt());
}
pub inline fn InputFloat3(label: ?[*:0]const u8, v: *[3]f32) bool {
    return @This().InputFloat3Ext(label, v, "%.3f", .{});
}

pub inline fn InputFloat4Ext(label: ?[*:0]const u8, v: *[4]f32, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputFloat4(label, v, format, flags.toInt());
}
pub inline fn InputFloat4(label: ?[*:0]const u8, v: *[4]f32) bool {
    return @This().InputFloat4Ext(label, v, "%.3f", .{});
}

pub inline fn InputIntExt(label: ?[*:0]const u8, v: *i32, step: i32, step_fast: i32, flags: InputTextFlags) bool {
    return raw.igInputInt(label, v, step, step_fast, flags.toInt());
}
pub inline fn InputInt(label: ?[*:0]const u8, v: *i32) bool {
    return @This().InputIntExt(label, v, 1, 100, .{});
}

pub inline fn InputInt2Ext(label: ?[*:0]const u8, v: *[2]i32, flags: InputTextFlags) bool {
    return raw.igInputInt2(label, v, flags.toInt());
}
pub inline fn InputInt2(label: ?[*:0]const u8, v: *[2]i32) bool {
    return @This().InputInt2Ext(label, v, .{});
}

pub inline fn InputInt3Ext(label: ?[*:0]const u8, v: *[3]i32, flags: InputTextFlags) bool {
    return raw.igInputInt3(label, v, flags.toInt());
}
pub inline fn InputInt3(label: ?[*:0]const u8, v: *[3]i32) bool {
    return @This().InputInt3Ext(label, v, .{});
}

pub inline fn InputInt4Ext(label: ?[*:0]const u8, v: *[4]i32, flags: InputTextFlags) bool {
    return raw.igInputInt4(label, v, flags.toInt());
}
pub inline fn InputInt4(label: ?[*:0]const u8, v: *[4]i32) bool {
    return @This().InputInt4Ext(label, v, .{});
}

pub inline fn InputScalarExt(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, p_step: ?*const anyopaque, p_step_fast: ?*const anyopaque, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputScalar(label, data_type, p_data, p_step, p_step_fast, format, flags.toInt());
}
pub inline fn InputScalar(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque) bool {
    return @This().InputScalarExt(label, data_type, p_data, null, null, null, .{});
}

pub inline fn InputScalarNExt(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, components: i32, p_step: ?*const anyopaque, p_step_fast: ?*const anyopaque, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputScalarN(label, data_type, p_data, components, p_step, p_step_fast, format, flags.toInt());
}
pub inline fn InputScalarN(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, components: i32) bool {
    return @This().InputScalarNExt(label, data_type, p_data, components, null, null, null, .{});
}

pub inline fn InputTextExt(label: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize, flags: InputTextFlags, callback: InputTextCallback, user_data: ?*anyopaque) bool {
    return raw.igInputText(label, buf, buf_size, flags.toInt(), callback, user_data);
}
pub inline fn InputText(label: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize) bool {
    return @This().InputTextExt(label, buf, buf_size, .{}, null, null);
}

pub inline fn InputTextMultilineExt(label: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize, size: Vec2, flags: InputTextFlags, callback: InputTextCallback, user_data: ?*anyopaque) bool {
    return raw.igInputTextMultiline(label, buf, buf_size, &size, flags.toInt(), callback, user_data);
}
pub inline fn InputTextMultiline(label: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize) bool {
    return @This().InputTextMultilineExt(label, buf, buf_size, .{.x=0,.y=0}, .{}, null, null);
}

pub inline fn InputTextWithHintExt(label: ?[*:0]const u8, hint: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize, flags: InputTextFlags, callback: InputTextCallback, user_data: ?*anyopaque) bool {
    return raw.igInputTextWithHint(label, hint, buf, buf_size, flags.toInt(), callback, user_data);
}
pub inline fn InputTextWithHint(label: ?[*:0]const u8, hint: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize) bool {
    return @This().InputTextWithHintExt(label, hint, buf, buf_size, .{}, null, null);
}

pub inline fn InvisibleButtonExt(str_id: ?[*:0]const u8, size: Vec2, flags: ButtonFlags) bool {
    return raw.igInvisibleButton(str_id, &size, flags.toInt());
}
pub inline fn InvisibleButton(str_id: ?[*:0]const u8, size: Vec2) bool {
    return @This().InvisibleButtonExt(str_id, size, .{});
}

/// IsAnyItemActive() bool
pub const IsAnyItemActive = raw.igIsAnyItemActive;

/// IsAnyItemFocused() bool
pub const IsAnyItemFocused = raw.igIsAnyItemFocused;

/// IsAnyItemHovered() bool
pub const IsAnyItemHovered = raw.igIsAnyItemHovered;

/// IsAnyMouseDown() bool
pub const IsAnyMouseDown = raw.igIsAnyMouseDown;

/// IsItemActivated() bool
pub const IsItemActivated = raw.igIsItemActivated;

/// IsItemActive() bool
pub const IsItemActive = raw.igIsItemActive;

/// IsItemClickedExt(mouse_button: MouseButton) bool
pub const IsItemClickedExt = raw.igIsItemClicked;
pub inline fn IsItemClicked() bool {
    return @This().IsItemClickedExt(.Left);
}

/// IsItemDeactivated() bool
pub const IsItemDeactivated = raw.igIsItemDeactivated;

/// IsItemDeactivatedAfterEdit() bool
pub const IsItemDeactivatedAfterEdit = raw.igIsItemDeactivatedAfterEdit;

/// IsItemEdited() bool
pub const IsItemEdited = raw.igIsItemEdited;

/// IsItemFocused() bool
pub const IsItemFocused = raw.igIsItemFocused;

pub inline fn IsItemHoveredExt(flags: HoveredFlags) bool {
    return raw.igIsItemHovered(flags.toInt());
}
pub inline fn IsItemHovered() bool {
    return @This().IsItemHoveredExt(.{});
}

/// IsItemToggledOpen() bool
pub const IsItemToggledOpen = raw.igIsItemToggledOpen;

/// IsItemVisible() bool
pub const IsItemVisible = raw.igIsItemVisible;

/// IsKeyDown(key: Key) bool
pub const IsKeyDown = raw.igIsKeyDown;

/// IsKeyPressedExt(key: Key, repeat: bool) bool
pub const IsKeyPressedExt = raw.igIsKeyPressed;
pub inline fn IsKeyPressed(key: Key) bool {
    return @This().IsKeyPressedExt(key, true);
}

/// IsKeyReleased(key: Key) bool
pub const IsKeyReleased = raw.igIsKeyReleased;

/// IsMouseClickedExt(button: MouseButton, repeat: bool) bool
pub const IsMouseClickedExt = raw.igIsMouseClicked;
pub inline fn IsMouseClicked(button: MouseButton) bool {
    return @This().IsMouseClickedExt(button, false);
}

/// IsMouseDoubleClicked(button: MouseButton) bool
pub const IsMouseDoubleClicked = raw.igIsMouseDoubleClicked;

/// IsMouseDown(button: MouseButton) bool
pub const IsMouseDown = raw.igIsMouseDown;

/// IsMouseDraggingExt(button: MouseButton, lock_threshold: f32) bool
pub const IsMouseDraggingExt = raw.igIsMouseDragging;
pub inline fn IsMouseDragging(button: MouseButton) bool {
    return @This().IsMouseDraggingExt(button, -1.0);
}

pub inline fn IsMouseHoveringRectExt(r_min: Vec2, r_max: Vec2, clip: bool) bool {
    return raw.igIsMouseHoveringRect(&r_min, &r_max, clip);
}
pub inline fn IsMouseHoveringRect(r_min: Vec2, r_max: Vec2) bool {
    return @This().IsMouseHoveringRectExt(r_min, r_max, true);
}

/// IsMousePosValidExt(mouse_pos: ?*const Vec2) bool
pub const IsMousePosValidExt = raw.igIsMousePosValid;
pub inline fn IsMousePosValid() bool {
    return @This().IsMousePosValidExt(null);
}

/// IsMouseReleased(button: MouseButton) bool
pub const IsMouseReleased = raw.igIsMouseReleased;

pub inline fn IsPopupOpenExt(str_id: ?[*:0]const u8, flags: PopupFlags) bool {
    return raw.igIsPopupOpen(str_id, flags.toInt());
}
pub inline fn IsPopupOpen(str_id: ?[*:0]const u8) bool {
    return @This().IsPopupOpenExt(str_id, .{});
}

pub inline fn IsRectVisible_Nil(size: Vec2) bool {
    return raw.igIsRectVisible_Nil(&size);
}

pub inline fn IsRectVisible_Vec2(rect_min: Vec2, rect_max: Vec2) bool {
    return raw.igIsRectVisible_Vec2(&rect_min, &rect_max);
}

/// IsWindowAppearing() bool
pub const IsWindowAppearing = raw.igIsWindowAppearing;

/// IsWindowCollapsed() bool
pub const IsWindowCollapsed = raw.igIsWindowCollapsed;

pub inline fn IsWindowFocusedExt(flags: FocusedFlags) bool {
    return raw.igIsWindowFocused(flags.toInt());
}
pub inline fn IsWindowFocused() bool {
    return @This().IsWindowFocusedExt(.{});
}

pub inline fn IsWindowHoveredExt(flags: HoveredFlags) bool {
    return raw.igIsWindowHovered(flags.toInt());
}
pub inline fn IsWindowHovered() bool {
    return @This().IsWindowHoveredExt(.{});
}

/// LabelText(label: ?[*:0]const u8, fmt: ?[*:0]const u8, ...: ...) void
pub const LabelText = raw.igLabelText;

/// ListBox_Str_arrExt(label: ?[*:0]const u8, current_item: ?*i32, items: [*]const[*:0]const u8, items_count: i32, height_in_items: i32) bool
pub const ListBox_Str_arrExt = raw.igListBox_Str_arr;
pub inline fn ListBox_Str_arr(label: ?[*:0]const u8, current_item: ?*i32, items: [*]const[*:0]const u8, items_count: i32) bool {
    return @This().ListBox_Str_arrExt(label, current_item, items, items_count, -1);
}

/// ListBox_FnBoolPtrExt(label: ?[*:0]const u8, current_item: ?*i32, items_getter: ?*const fn (data: ?*anyopaque, idx: i32, out_text: *?[*:0]const u8) callconv(.C) bool, data: ?*anyopaque, items_count: i32, height_in_items: i32) bool
pub const ListBox_FnBoolPtrExt = raw.igListBox_FnBoolPtr;
pub inline fn ListBox_FnBoolPtr(label: ?[*:0]const u8, current_item: ?*i32, items_getter: ?*const fn (data: ?*anyopaque, idx: i32, out_text: *?[*:0]const u8) callconv(.C) bool, data: ?*anyopaque, items_count: i32) bool {
    return @This().ListBox_FnBoolPtrExt(label, current_item, items_getter, data, items_count, -1);
}

/// LoadIniSettingsFromDisk(ini_filename: ?[*:0]const u8) void
pub const LoadIniSettingsFromDisk = raw.igLoadIniSettingsFromDisk;

/// LoadIniSettingsFromMemoryExt(ini_data: ?[*]const u8, ini_size: usize) void
pub const LoadIniSettingsFromMemoryExt = raw.igLoadIniSettingsFromMemory;
pub inline fn LoadIniSettingsFromMemory(ini_data: ?[*]const u8) void {
    return @This().LoadIniSettingsFromMemoryExt(ini_data, 0);
}

/// LogButtons() void
pub const LogButtons = raw.igLogButtons;

/// LogFinish() void
pub const LogFinish = raw.igLogFinish;

/// LogText(fmt: ?[*:0]const u8, ...: ...) void
pub const LogText = raw.igLogText;

/// LogToClipboardExt(auto_open_depth: i32) void
pub const LogToClipboardExt = raw.igLogToClipboard;
pub inline fn LogToClipboard() void {
    return @This().LogToClipboardExt(-1);
}

/// LogToFileExt(auto_open_depth: i32, filename: ?[*:0]const u8) void
pub const LogToFileExt = raw.igLogToFile;
pub inline fn LogToFile() void {
    return @This().LogToFileExt(-1, null);
}

/// LogToTTYExt(auto_open_depth: i32) void
pub const LogToTTYExt = raw.igLogToTTY;
pub inline fn LogToTTY() void {
    return @This().LogToTTYExt(-1);
}

/// MemAlloc(size: usize) ?*anyopaque
pub const MemAlloc = raw.igMemAlloc;

/// MemFree(ptr: ?*anyopaque) void
pub const MemFree = raw.igMemFree;

/// MenuItem_BoolExt(label: ?[*:0]const u8, shortcut: ?[*:0]const u8, selected: bool, enabled: bool) bool
pub const MenuItem_BoolExt = raw.igMenuItem_Bool;
pub inline fn MenuItem_Bool(label: ?[*:0]const u8) bool {
    return @This().MenuItem_BoolExt(label, null, false, true);
}

/// MenuItem_BoolPtrExt(label: ?[*:0]const u8, shortcut: ?[*:0]const u8, p_selected: ?*bool, enabled: bool) bool
pub const MenuItem_BoolPtrExt = raw.igMenuItem_BoolPtr;
pub inline fn MenuItem_BoolPtr(label: ?[*:0]const u8, shortcut: ?[*:0]const u8, p_selected: ?*bool) bool {
    return @This().MenuItem_BoolPtrExt(label, shortcut, p_selected, true);
}

/// NewFrame() void
pub const NewFrame = raw.igNewFrame;

/// NewLine() void
pub const NewLine = raw.igNewLine;

/// NextColumn() void
pub const NextColumn = raw.igNextColumn;

pub inline fn OpenPopup_StrExt(str_id: ?[*:0]const u8, popup_flags: PopupFlags) void {
    return raw.igOpenPopup_Str(str_id, popup_flags.toInt());
}
pub inline fn OpenPopup_Str(str_id: ?[*:0]const u8) void {
    return @This().OpenPopup_StrExt(str_id, .{});
}

pub inline fn OpenPopup_IDExt(id: ID, popup_flags: PopupFlags) void {
    return raw.igOpenPopup_ID(id, popup_flags.toInt());
}
pub inline fn OpenPopup_ID(id: ID) void {
    return @This().OpenPopup_IDExt(id, .{});
}

pub inline fn OpenPopupOnItemClickExt(str_id: ?[*:0]const u8, popup_flags: PopupFlags) void {
    return raw.igOpenPopupOnItemClick(str_id, popup_flags.toInt());
}
pub inline fn OpenPopupOnItemClick() void {
    return @This().OpenPopupOnItemClickExt(null, .{ .MouseButtonRight = true });
}

pub inline fn PlotHistogram_FloatPtrExt(label: ?[*:0]const u8, values: *const f32, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2, stride: i32) void {
    return raw.igPlotHistogram_FloatPtr(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, &graph_size, stride);
}
pub inline fn PlotHistogram_FloatPtr(label: ?[*:0]const u8, values: *const f32, values_count: i32) void {
    return @This().PlotHistogram_FloatPtrExt(label, values, values_count, 0, null, FLT_MAX, FLT_MAX, .{.x=0,.y=0}, @sizeOf(f32));
}

pub inline fn PlotHistogram_FnFloatPtrExt(label: ?[*:0]const u8, values_getter: ?*const fn (data: ?*anyopaque, idx: i32) callconv(.C) f32, data: ?*anyopaque, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2) void {
    return raw.igPlotHistogram_FnFloatPtr(label, values_getter, data, values_count, values_offset, overlay_text, scale_min, scale_max, &graph_size);
}
pub inline fn PlotHistogram_FnFloatPtr(label: ?[*:0]const u8, values_getter: ?*const fn (data: ?*anyopaque, idx: i32) callconv(.C) f32, data: ?*anyopaque, values_count: i32) void {
    return @This().PlotHistogram_FnFloatPtrExt(label, values_getter, data, values_count, 0, null, FLT_MAX, FLT_MAX, .{.x=0,.y=0});
}

pub inline fn PlotLines_FloatPtrExt(label: ?[*:0]const u8, values: *const f32, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2, stride: i32) void {
    return raw.igPlotLines_FloatPtr(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, &graph_size, stride);
}
pub inline fn PlotLines_FloatPtr(label: ?[*:0]const u8, values: *const f32, values_count: i32) void {
    return @This().PlotLines_FloatPtrExt(label, values, values_count, 0, null, FLT_MAX, FLT_MAX, .{.x=0,.y=0}, @sizeOf(f32));
}

pub inline fn PlotLines_FnFloatPtrExt(label: ?[*:0]const u8, values_getter: ?*const fn (data: ?*anyopaque, idx: i32) callconv(.C) f32, data: ?*anyopaque, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2) void {
    return raw.igPlotLines_FnFloatPtr(label, values_getter, data, values_count, values_offset, overlay_text, scale_min, scale_max, &graph_size);
}
pub inline fn PlotLines_FnFloatPtr(label: ?[*:0]const u8, values_getter: ?*const fn (data: ?*anyopaque, idx: i32) callconv(.C) f32, data: ?*anyopaque, values_count: i32) void {
    return @This().PlotLines_FnFloatPtrExt(label, values_getter, data, values_count, 0, null, FLT_MAX, FLT_MAX, .{.x=0,.y=0});
}

/// PopAllowKeyboardFocus() void
pub const PopAllowKeyboardFocus = raw.igPopAllowKeyboardFocus;

/// PopButtonRepeat() void
pub const PopButtonRepeat = raw.igPopButtonRepeat;

/// PopClipRect() void
pub const PopClipRect = raw.igPopClipRect;

/// PopFont() void
pub const PopFont = raw.igPopFont;

/// PopID() void
pub const PopID = raw.igPopID;

/// PopItemWidth() void
pub const PopItemWidth = raw.igPopItemWidth;

/// PopStyleColorExt(count: i32) void
pub const PopStyleColorExt = raw.igPopStyleColor;
pub inline fn PopStyleColor() void {
    return @This().PopStyleColorExt(1);
}

/// PopStyleVarExt(count: i32) void
pub const PopStyleVarExt = raw.igPopStyleVar;
pub inline fn PopStyleVar() void {
    return @This().PopStyleVarExt(1);
}

/// PopTextWrapPos() void
pub const PopTextWrapPos = raw.igPopTextWrapPos;

pub inline fn ProgressBarExt(fraction: f32, size_arg: Vec2, overlay: ?[*:0]const u8) void {
    return raw.igProgressBar(fraction, &size_arg, overlay);
}
pub inline fn ProgressBar(fraction: f32) void {
    return @This().ProgressBarExt(fraction, .{.x=-FLT_MIN,.y=0}, null);
}

/// PushAllowKeyboardFocus(allow_keyboard_focus: bool) void
pub const PushAllowKeyboardFocus = raw.igPushAllowKeyboardFocus;

/// PushButtonRepeat(repeat: bool) void
pub const PushButtonRepeat = raw.igPushButtonRepeat;

pub inline fn PushClipRect(clip_rect_min: Vec2, clip_rect_max: Vec2, intersect_with_current_clip_rect: bool) void {
    return raw.igPushClipRect(&clip_rect_min, &clip_rect_max, intersect_with_current_clip_rect);
}

/// PushFont(font: ?*Font) void
pub const PushFont = raw.igPushFont;

/// PushID_Str(str_id: ?[*:0]const u8) void
pub const PushID_Str = raw.igPushID_Str;

/// PushID_StrStr(str_id_begin: ?[*]const u8, str_id_end: ?[*]const u8) void
pub const PushID_StrStr = raw.igPushID_StrStr;

/// PushID_Ptr(ptr_id: ?*const anyopaque) void
pub const PushID_Ptr = raw.igPushID_Ptr;

/// PushID_Int(int_id: i32) void
pub const PushID_Int = raw.igPushID_Int;

/// PushItemWidth(item_width: f32) void
pub const PushItemWidth = raw.igPushItemWidth;

/// PushStyleColor_U32(idx: Col, col: u32) void
pub const PushStyleColor_U32 = raw.igPushStyleColor_U32;

pub inline fn PushStyleColor_Vec4(idx: Col, col: Vec4) void {
    return raw.igPushStyleColor_Vec4(idx, &col);
}

/// PushStyleVar_Float(idx: StyleVar, val: f32) void
pub const PushStyleVar_Float = raw.igPushStyleVar_Float;

pub inline fn PushStyleVar_Vec2(idx: StyleVar, val: Vec2) void {
    return raw.igPushStyleVar_Vec2(idx, &val);
}

/// PushTextWrapPosExt(wrap_local_pos_x: f32) void
pub const PushTextWrapPosExt = raw.igPushTextWrapPos;
pub inline fn PushTextWrapPos() void {
    return @This().PushTextWrapPosExt(0.0);
}

/// RadioButton_Bool(label: ?[*:0]const u8, active: bool) bool
pub const RadioButton_Bool = raw.igRadioButton_Bool;

/// RadioButton_IntPtr(label: ?[*:0]const u8, v: *i32, v_button: i32) bool
pub const RadioButton_IntPtr = raw.igRadioButton_IntPtr;

/// Render() void
pub const Render = raw.igRender;

/// ResetMouseDragDeltaExt(button: MouseButton) void
pub const ResetMouseDragDeltaExt = raw.igResetMouseDragDelta;
pub inline fn ResetMouseDragDelta() void {
    return @This().ResetMouseDragDeltaExt(.Left);
}

/// SameLineExt(offset_from_start_x: f32, spacing: f32) void
pub const SameLineExt = raw.igSameLine;
pub inline fn SameLine() void {
    return @This().SameLineExt(0.0, -1.0);
}

/// SaveIniSettingsToDisk(ini_filename: ?[*:0]const u8) void
pub const SaveIniSettingsToDisk = raw.igSaveIniSettingsToDisk;

/// SaveIniSettingsToMemoryExt(out_ini_size: ?*usize) ?[*:0]const u8
pub const SaveIniSettingsToMemoryExt = raw.igSaveIniSettingsToMemory;
pub inline fn SaveIniSettingsToMemory() ?[*:0]const u8 {
    return @This().SaveIniSettingsToMemoryExt(null);
}

pub inline fn Selectable_BoolExt(label: ?[*:0]const u8, selected: bool, flags: SelectableFlags, size: Vec2) bool {
    return raw.igSelectable_Bool(label, selected, flags.toInt(), &size);
}
pub inline fn Selectable_Bool(label: ?[*:0]const u8) bool {
    return @This().Selectable_BoolExt(label, false, .{}, .{.x=0,.y=0});
}

pub inline fn Selectable_BoolPtrExt(label: ?[*:0]const u8, p_selected: ?*bool, flags: SelectableFlags, size: Vec2) bool {
    return raw.igSelectable_BoolPtr(label, p_selected, flags.toInt(), &size);
}
pub inline fn Selectable_BoolPtr(label: ?[*:0]const u8, p_selected: ?*bool) bool {
    return @This().Selectable_BoolPtrExt(label, p_selected, .{}, .{.x=0,.y=0});
}

/// Separator() void
pub const Separator = raw.igSeparator;

/// SetAllocatorFunctionsExt(alloc_func: MemAllocFunc, free_func: MemFreeFunc, user_data: ?*anyopaque) void
pub const SetAllocatorFunctionsExt = raw.igSetAllocatorFunctions;
pub inline fn SetAllocatorFunctions(alloc_func: MemAllocFunc, free_func: MemFreeFunc) void {
    return @This().SetAllocatorFunctionsExt(alloc_func, free_func, null);
}

/// SetClipboardText(text: ?[*:0]const u8) void
pub const SetClipboardText = raw.igSetClipboardText;

pub inline fn SetColorEditOptions(flags: ColorEditFlags) void {
    return raw.igSetColorEditOptions(flags.toInt());
}

/// SetColumnOffset(column_index: i32, offset_x: f32) void
pub const SetColumnOffset = raw.igSetColumnOffset;

/// SetColumnWidth(column_index: i32, width: f32) void
pub const SetColumnWidth = raw.igSetColumnWidth;

/// SetCurrentContext(ctx: ?*Context) void
pub const SetCurrentContext = raw.igSetCurrentContext;

pub inline fn SetCursorPos(local_pos: Vec2) void {
    return raw.igSetCursorPos(&local_pos);
}

/// SetCursorPosX(local_x: f32) void
pub const SetCursorPosX = raw.igSetCursorPosX;

/// SetCursorPosY(local_y: f32) void
pub const SetCursorPosY = raw.igSetCursorPosY;

pub inline fn SetCursorScreenPos(pos: Vec2) void {
    return raw.igSetCursorScreenPos(&pos);
}

pub inline fn SetDragDropPayloadExt(kind: ?[*:0]const u8, data: ?*const anyopaque, sz: usize, cond: CondFlags) bool {
    return raw.igSetDragDropPayload(kind, data, sz, cond.toInt());
}
pub inline fn SetDragDropPayload(kind: ?[*:0]const u8, data: ?*const anyopaque, sz: usize) bool {
    return @This().SetDragDropPayloadExt(kind, data, sz, .{});
}

/// SetItemAllowOverlap() void
pub const SetItemAllowOverlap = raw.igSetItemAllowOverlap;

/// SetItemDefaultFocus() void
pub const SetItemDefaultFocus = raw.igSetItemDefaultFocus;

/// SetKeyboardFocusHereExt(offset: i32) void
pub const SetKeyboardFocusHereExt = raw.igSetKeyboardFocusHere;
pub inline fn SetKeyboardFocusHere() void {
    return @This().SetKeyboardFocusHereExt(0);
}

/// SetMouseCursor(cursor_type: MouseCursor) void
pub const SetMouseCursor = raw.igSetMouseCursor;

/// SetNextFrameWantCaptureKeyboard(want_capture_keyboard: bool) void
pub const SetNextFrameWantCaptureKeyboard = raw.igSetNextFrameWantCaptureKeyboard;

/// SetNextFrameWantCaptureMouse(want_capture_mouse: bool) void
pub const SetNextFrameWantCaptureMouse = raw.igSetNextFrameWantCaptureMouse;

pub inline fn SetNextItemOpenExt(is_open: bool, cond: CondFlags) void {
    return raw.igSetNextItemOpen(is_open, cond.toInt());
}
pub inline fn SetNextItemOpen(is_open: bool) void {
    return @This().SetNextItemOpenExt(is_open, .{});
}

/// SetNextItemWidth(item_width: f32) void
pub const SetNextItemWidth = raw.igSetNextItemWidth;

/// SetNextWindowBgAlpha(alpha: f32) void
pub const SetNextWindowBgAlpha = raw.igSetNextWindowBgAlpha;

pub inline fn SetNextWindowCollapsedExt(collapsed: bool, cond: CondFlags) void {
    return raw.igSetNextWindowCollapsed(collapsed, cond.toInt());
}
pub inline fn SetNextWindowCollapsed(collapsed: bool) void {
    return @This().SetNextWindowCollapsedExt(collapsed, .{});
}

pub inline fn SetNextWindowContentSize(size: Vec2) void {
    return raw.igSetNextWindowContentSize(&size);
}

/// SetNextWindowFocus() void
pub const SetNextWindowFocus = raw.igSetNextWindowFocus;

pub inline fn SetNextWindowPosExt(pos: Vec2, cond: CondFlags, pivot: Vec2) void {
    return raw.igSetNextWindowPos(&pos, cond.toInt(), &pivot);
}
pub inline fn SetNextWindowPos(pos: Vec2) void {
    return @This().SetNextWindowPosExt(pos, .{}, .{.x=0,.y=0});
}

pub inline fn SetNextWindowSizeExt(size: Vec2, cond: CondFlags) void {
    return raw.igSetNextWindowSize(&size, cond.toInt());
}
pub inline fn SetNextWindowSize(size: Vec2) void {
    return @This().SetNextWindowSizeExt(size, .{});
}

pub inline fn SetNextWindowSizeConstraintsExt(size_min: Vec2, size_max: Vec2, custom_callback: SizeCallback, custom_callback_data: ?*anyopaque) void {
    return raw.igSetNextWindowSizeConstraints(&size_min, &size_max, custom_callback, custom_callback_data);
}
pub inline fn SetNextWindowSizeConstraints(size_min: Vec2, size_max: Vec2) void {
    return @This().SetNextWindowSizeConstraintsExt(size_min, size_max, null, null);
}

/// SetScrollFromPosXExt(local_x: f32, center_x_ratio: f32) void
pub const SetScrollFromPosXExt = raw.igSetScrollFromPosX;
pub inline fn SetScrollFromPosX(local_x: f32) void {
    return @This().SetScrollFromPosXExt(local_x, 0.5);
}

/// SetScrollFromPosYExt(local_y: f32, center_y_ratio: f32) void
pub const SetScrollFromPosYExt = raw.igSetScrollFromPosY;
pub inline fn SetScrollFromPosY(local_y: f32) void {
    return @This().SetScrollFromPosYExt(local_y, 0.5);
}

/// SetScrollHereXExt(center_x_ratio: f32) void
pub const SetScrollHereXExt = raw.igSetScrollHereX;
pub inline fn SetScrollHereX() void {
    return @This().SetScrollHereXExt(0.5);
}

/// SetScrollHereYExt(center_y_ratio: f32) void
pub const SetScrollHereYExt = raw.igSetScrollHereY;
pub inline fn SetScrollHereY() void {
    return @This().SetScrollHereYExt(0.5);
}

/// SetScrollX(scroll_x: f32) void
pub const SetScrollX = raw.igSetScrollX;

/// SetScrollY(scroll_y: f32) void
pub const SetScrollY = raw.igSetScrollY;

/// SetStateStorage(storage: ?*Storage) void
pub const SetStateStorage = raw.igSetStateStorage;

/// SetTabItemClosed(tab_or_docked_window_label: ?[*:0]const u8) void
pub const SetTabItemClosed = raw.igSetTabItemClosed;

/// SetTooltip(fmt: ?[*:0]const u8, ...: ...) void
pub const SetTooltip = raw.igSetTooltip;

pub inline fn SetWindowCollapsed_BoolExt(collapsed: bool, cond: CondFlags) void {
    return raw.igSetWindowCollapsed_Bool(collapsed, cond.toInt());
}
pub inline fn SetWindowCollapsed_Bool(collapsed: bool) void {
    return @This().SetWindowCollapsed_BoolExt(collapsed, .{});
}

pub inline fn SetWindowCollapsed_StrExt(name: ?[*:0]const u8, collapsed: bool, cond: CondFlags) void {
    return raw.igSetWindowCollapsed_Str(name, collapsed, cond.toInt());
}
pub inline fn SetWindowCollapsed_Str(name: ?[*:0]const u8, collapsed: bool) void {
    return @This().SetWindowCollapsed_StrExt(name, collapsed, .{});
}

/// SetWindowFocus_Nil() void
pub const SetWindowFocus_Nil = raw.igSetWindowFocus_Nil;

/// SetWindowFocus_Str(name: ?[*:0]const u8) void
pub const SetWindowFocus_Str = raw.igSetWindowFocus_Str;

/// SetWindowFontScale(scale: f32) void
pub const SetWindowFontScale = raw.igSetWindowFontScale;

pub inline fn SetWindowPos_Vec2Ext(pos: Vec2, cond: CondFlags) void {
    return raw.igSetWindowPos_Vec2(&pos, cond.toInt());
}
pub inline fn SetWindowPos_Vec2(pos: Vec2) void {
    return @This().SetWindowPos_Vec2Ext(pos, .{});
}

pub inline fn SetWindowPos_StrExt(name: ?[*:0]const u8, pos: Vec2, cond: CondFlags) void {
    return raw.igSetWindowPos_Str(name, &pos, cond.toInt());
}
pub inline fn SetWindowPos_Str(name: ?[*:0]const u8, pos: Vec2) void {
    return @This().SetWindowPos_StrExt(name, pos, .{});
}

pub inline fn SetWindowSize_Vec2Ext(size: Vec2, cond: CondFlags) void {
    return raw.igSetWindowSize_Vec2(&size, cond.toInt());
}
pub inline fn SetWindowSize_Vec2(size: Vec2) void {
    return @This().SetWindowSize_Vec2Ext(size, .{});
}

pub inline fn SetWindowSize_StrExt(name: ?[*:0]const u8, size: Vec2, cond: CondFlags) void {
    return raw.igSetWindowSize_Str(name, &size, cond.toInt());
}
pub inline fn SetWindowSize_Str(name: ?[*:0]const u8, size: Vec2) void {
    return @This().SetWindowSize_StrExt(name, size, .{});
}

/// ShowAboutWindowExt(p_open: ?*bool) void
pub const ShowAboutWindowExt = raw.igShowAboutWindow;
pub inline fn ShowAboutWindow() void {
    return @This().ShowAboutWindowExt(null);
}

/// ShowDebugLogWindowExt(p_open: ?*bool) void
pub const ShowDebugLogWindowExt = raw.igShowDebugLogWindow;
pub inline fn ShowDebugLogWindow() void {
    return @This().ShowDebugLogWindowExt(null);
}

/// ShowDemoWindowExt(p_open: ?*bool) void
pub const ShowDemoWindowExt = raw.igShowDemoWindow;
pub inline fn ShowDemoWindow() void {
    return @This().ShowDemoWindowExt(null);
}

/// ShowFontSelector(label: ?[*:0]const u8) void
pub const ShowFontSelector = raw.igShowFontSelector;

/// ShowMetricsWindowExt(p_open: ?*bool) void
pub const ShowMetricsWindowExt = raw.igShowMetricsWindow;
pub inline fn ShowMetricsWindow() void {
    return @This().ShowMetricsWindowExt(null);
}

/// ShowStackToolWindowExt(p_open: ?*bool) void
pub const ShowStackToolWindowExt = raw.igShowStackToolWindow;
pub inline fn ShowStackToolWindow() void {
    return @This().ShowStackToolWindowExt(null);
}

/// ShowStyleEditorExt(ref: ?*Style) void
pub const ShowStyleEditorExt = raw.igShowStyleEditor;
pub inline fn ShowStyleEditor() void {
    return @This().ShowStyleEditorExt(null);
}

/// ShowStyleSelector(label: ?[*:0]const u8) bool
pub const ShowStyleSelector = raw.igShowStyleSelector;

/// ShowUserGuide() void
pub const ShowUserGuide = raw.igShowUserGuide;

pub inline fn SliderAngleExt(label: ?[*:0]const u8, v_rad: *f32, v_degrees_min: f32, v_degrees_max: f32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igSliderAngle(label, v_rad, v_degrees_min, v_degrees_max, format, flags.toInt());
}
pub inline fn SliderAngle(label: ?[*:0]const u8, v_rad: *f32) bool {
    return @This().SliderAngleExt(label, v_rad, -360.0, 360.0, "%.0f deg", .{});
}

pub inline fn SliderFloatExt(label: ?[*:0]const u8, v: *f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igSliderFloat(label, v, v_min, v_max, format, flags.toInt());
}
pub inline fn SliderFloat(label: ?[*:0]const u8, v: *f32, v_min: f32, v_max: f32) bool {
    return @This().SliderFloatExt(label, v, v_min, v_max, "%.3f", .{});
}

pub inline fn SliderFloat2Ext(label: ?[*:0]const u8, v: *[2]f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igSliderFloat2(label, v, v_min, v_max, format, flags.toInt());
}
pub inline fn SliderFloat2(label: ?[*:0]const u8, v: *[2]f32, v_min: f32, v_max: f32) bool {
    return @This().SliderFloat2Ext(label, v, v_min, v_max, "%.3f", .{});
}

pub inline fn SliderFloat3Ext(label: ?[*:0]const u8, v: *[3]f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igSliderFloat3(label, v, v_min, v_max, format, flags.toInt());
}
pub inline fn SliderFloat3(label: ?[*:0]const u8, v: *[3]f32, v_min: f32, v_max: f32) bool {
    return @This().SliderFloat3Ext(label, v, v_min, v_max, "%.3f", .{});
}

pub inline fn SliderFloat4Ext(label: ?[*:0]const u8, v: *[4]f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igSliderFloat4(label, v, v_min, v_max, format, flags.toInt());
}
pub inline fn SliderFloat4(label: ?[*:0]const u8, v: *[4]f32, v_min: f32, v_max: f32) bool {
    return @This().SliderFloat4Ext(label, v, v_min, v_max, "%.3f", .{});
}

pub inline fn SliderIntExt(label: ?[*:0]const u8, v: *i32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igSliderInt(label, v, v_min, v_max, format, flags.toInt());
}
pub inline fn SliderInt(label: ?[*:0]const u8, v: *i32, v_min: i32, v_max: i32) bool {
    return @This().SliderIntExt(label, v, v_min, v_max, "%d", .{});
}

pub inline fn SliderInt2Ext(label: ?[*:0]const u8, v: *[2]i32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igSliderInt2(label, v, v_min, v_max, format, flags.toInt());
}
pub inline fn SliderInt2(label: ?[*:0]const u8, v: *[2]i32, v_min: i32, v_max: i32) bool {
    return @This().SliderInt2Ext(label, v, v_min, v_max, "%d", .{});
}

pub inline fn SliderInt3Ext(label: ?[*:0]const u8, v: *[3]i32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igSliderInt3(label, v, v_min, v_max, format, flags.toInt());
}
pub inline fn SliderInt3(label: ?[*:0]const u8, v: *[3]i32, v_min: i32, v_max: i32) bool {
    return @This().SliderInt3Ext(label, v, v_min, v_max, "%d", .{});
}

pub inline fn SliderInt4Ext(label: ?[*:0]const u8, v: *[4]i32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igSliderInt4(label, v, v_min, v_max, format, flags.toInt());
}
pub inline fn SliderInt4(label: ?[*:0]const u8, v: *[4]i32, v_min: i32, v_max: i32) bool {
    return @This().SliderInt4Ext(label, v, v_min, v_max, "%d", .{});
}

pub inline fn SliderScalarExt(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igSliderScalar(label, data_type, p_data, p_min, p_max, format, flags.toInt());
}
pub inline fn SliderScalar(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, p_min: ?*const anyopaque, p_max: ?*const anyopaque) bool {
    return @This().SliderScalarExt(label, data_type, p_data, p_min, p_max, null, .{});
}

pub inline fn SliderScalarNExt(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, components: i32, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igSliderScalarN(label, data_type, p_data, components, p_min, p_max, format, flags.toInt());
}
pub inline fn SliderScalarN(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, components: i32, p_min: ?*const anyopaque, p_max: ?*const anyopaque) bool {
    return @This().SliderScalarNExt(label, data_type, p_data, components, p_min, p_max, null, .{});
}

/// SmallButton(label: ?[*:0]const u8) bool
pub const SmallButton = raw.igSmallButton;

/// Spacing() void
pub const Spacing = raw.igSpacing;

/// StyleColorsClassicExt(dst: ?*Style) void
pub const StyleColorsClassicExt = raw.igStyleColorsClassic;
pub inline fn StyleColorsClassic() void {
    return @This().StyleColorsClassicExt(null);
}

/// StyleColorsDarkExt(dst: ?*Style) void
pub const StyleColorsDarkExt = raw.igStyleColorsDark;
pub inline fn StyleColorsDark() void {
    return @This().StyleColorsDarkExt(null);
}

/// StyleColorsLightExt(dst: ?*Style) void
pub const StyleColorsLightExt = raw.igStyleColorsLight;
pub inline fn StyleColorsLight() void {
    return @This().StyleColorsLightExt(null);
}

pub inline fn TabItemButtonExt(label: ?[*:0]const u8, flags: TabItemFlags) bool {
    return raw.igTabItemButton(label, flags.toInt());
}
pub inline fn TabItemButton(label: ?[*:0]const u8) bool {
    return @This().TabItemButtonExt(label, .{});
}

/// TableGetColumnCount() i32
pub const TableGetColumnCount = raw.igTableGetColumnCount;

pub inline fn TableGetColumnFlagsExt(column_n: i32) TableColumnFlags {
    const _retflags = raw.igTableGetColumnFlags(column_n);
    return TableColumnFlags.fromInt(_retflags);
}
pub inline fn TableGetColumnFlags() TableColumnFlags {
    return @This().TableGetColumnFlagsExt(-1);
}

/// TableGetColumnIndex() i32
pub const TableGetColumnIndex = raw.igTableGetColumnIndex;

/// TableGetColumnNameExt(column_n: i32) ?[*:0]const u8
pub const TableGetColumnNameExt = raw.igTableGetColumnName;
pub inline fn TableGetColumnName() ?[*:0]const u8 {
    return @This().TableGetColumnNameExt(-1);
}

/// TableGetRowIndex() i32
pub const TableGetRowIndex = raw.igTableGetRowIndex;

/// TableGetSortSpecs() ?*TableSortSpecs
pub const TableGetSortSpecs = raw.igTableGetSortSpecs;

/// TableHeader(label: ?[*:0]const u8) void
pub const TableHeader = raw.igTableHeader;

/// TableHeadersRow() void
pub const TableHeadersRow = raw.igTableHeadersRow;

/// TableNextColumn() bool
pub const TableNextColumn = raw.igTableNextColumn;

pub inline fn TableNextRowExt(row_flags: TableRowFlags, min_row_height: f32) void {
    return raw.igTableNextRow(row_flags.toInt(), min_row_height);
}
pub inline fn TableNextRow() void {
    return @This().TableNextRowExt(.{}, 0.0);
}

/// TableSetBgColorExt(target: TableBgTarget, color: u32, column_n: i32) void
pub const TableSetBgColorExt = raw.igTableSetBgColor;
pub inline fn TableSetBgColor(target: TableBgTarget, color: u32) void {
    return @This().TableSetBgColorExt(target, color, -1);
}

/// TableSetColumnEnabled(column_n: i32, v: bool) void
pub const TableSetColumnEnabled = raw.igTableSetColumnEnabled;

/// TableSetColumnIndex(column_n: i32) bool
pub const TableSetColumnIndex = raw.igTableSetColumnIndex;

pub inline fn TableSetupColumnExt(label: ?[*:0]const u8, flags: TableColumnFlags, init_width_or_weight: f32, user_id: ID) void {
    return raw.igTableSetupColumn(label, flags.toInt(), init_width_or_weight, user_id);
}
pub inline fn TableSetupColumn(label: ?[*:0]const u8) void {
    return @This().TableSetupColumnExt(label, .{}, 0.0, 0);
}

/// TableSetupScrollFreeze(cols: i32, rows: i32) void
pub const TableSetupScrollFreeze = raw.igTableSetupScrollFreeze;

/// Text(fmt: ?[*:0]const u8, ...: ...) void
pub const Text = raw.igText;

/// TextColored(col: Vec4, fmt: ?[*:0]const u8, ...: ...) void
pub const TextColored = raw.igTextColored;

/// TextDisabled(fmt: ?[*:0]const u8, ...: ...) void
pub const TextDisabled = raw.igTextDisabled;

/// TextUnformattedExt(text: ?[*]const u8, text_end: ?[*]const u8) void
pub const TextUnformattedExt = raw.igTextUnformatted;
pub inline fn TextUnformatted(text: ?[*]const u8) void {
    return @This().TextUnformattedExt(text, null);
}

/// TextWrapped(fmt: ?[*:0]const u8, ...: ...) void
pub const TextWrapped = raw.igTextWrapped;

/// TreeNode_Str(label: ?[*:0]const u8) bool
pub const TreeNode_Str = raw.igTreeNode_Str;

/// TreeNode_StrStr(str_id: ?[*:0]const u8, fmt: ?[*:0]const u8, ...: ...) bool
pub const TreeNode_StrStr = raw.igTreeNode_StrStr;

/// TreeNode_Ptr(ptr_id: ?*const anyopaque, fmt: ?[*:0]const u8, ...: ...) bool
pub const TreeNode_Ptr = raw.igTreeNode_Ptr;

pub inline fn TreeNodeEx_StrExt(label: ?[*:0]const u8, flags: TreeNodeFlags) bool {
    return raw.igTreeNodeEx_Str(label, flags.toInt());
}
pub inline fn TreeNodeEx_Str(label: ?[*:0]const u8) bool {
    return @This().TreeNodeEx_StrExt(label, .{});
}

/// TreeNodeEx_StrStr(str_id: ?[*:0]const u8, flags: TreeNodeFlags, fmt: ?[*:0]const u8, ...: ...) bool
pub const TreeNodeEx_StrStr = raw.igTreeNodeEx_StrStr;

/// TreeNodeEx_Ptr(ptr_id: ?*const anyopaque, flags: TreeNodeFlags, fmt: ?[*:0]const u8, ...: ...) bool
pub const TreeNodeEx_Ptr = raw.igTreeNodeEx_Ptr;

/// TreePop() void
pub const TreePop = raw.igTreePop;

/// TreePush_Str(str_id: ?[*:0]const u8) void
pub const TreePush_Str = raw.igTreePush_Str;

/// TreePush_PtrExt(ptr_id: ?*const anyopaque) void
pub const TreePush_PtrExt = raw.igTreePush_Ptr;
pub inline fn TreePush_Ptr() void {
    return @This().TreePush_PtrExt(null);
}

/// UnindentExt(indent_w: f32) void
pub const UnindentExt = raw.igUnindent;
pub inline fn Unindent() void {
    return @This().UnindentExt(0.0);
}

pub inline fn VSliderFloatExt(label: ?[*:0]const u8, size: Vec2, v: *f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igVSliderFloat(label, &size, v, v_min, v_max, format, flags.toInt());
}
pub inline fn VSliderFloat(label: ?[*:0]const u8, size: Vec2, v: *f32, v_min: f32, v_max: f32) bool {
    return @This().VSliderFloatExt(label, size, v, v_min, v_max, "%.3f", .{});
}

pub inline fn VSliderIntExt(label: ?[*:0]const u8, size: Vec2, v: *i32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igVSliderInt(label, &size, v, v_min, v_max, format, flags.toInt());
}
pub inline fn VSliderInt(label: ?[*:0]const u8, size: Vec2, v: *i32, v_min: i32, v_max: i32) bool {
    return @This().VSliderIntExt(label, size, v, v_min, v_max, "%d", .{});
}

pub inline fn VSliderScalarExt(label: ?[*:0]const u8, size: Vec2, data_type: DataType, p_data: ?*anyopaque, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: ?[*:0]const u8, flags: SliderFlags) bool {
    return raw.igVSliderScalar(label, &size, data_type, p_data, p_min, p_max, format, flags.toInt());
}
pub inline fn VSliderScalar(label: ?[*:0]const u8, size: Vec2, data_type: DataType, p_data: ?*anyopaque, p_min: ?*const anyopaque, p_max: ?*const anyopaque) bool {
    return @This().VSliderScalarExt(label, size, data_type, p_data, p_min, p_max, null, .{});
}

/// Value_Bool(prefix: ?[*:0]const u8, b: bool) void
pub const Value_Bool = raw.igValue_Bool;

/// Value_Int(prefix: ?[*:0]const u8, v: i32) void
pub const Value_Int = raw.igValue_Int;

/// Value_Uint(prefix: ?[*:0]const u8, v: u32) void
pub const Value_Uint = raw.igValue_Uint;

/// Value_FloatExt(prefix: ?[*:0]const u8, v: f32, float_format: ?[*:0]const u8) void
pub const Value_FloatExt = raw.igValue_Float;
pub inline fn Value_Float(prefix: ?[*:0]const u8, v: f32) void {
    return @This().Value_FloatExt(prefix, v, null);
}

pub const raw = struct {
    pub extern fn ImColor_HSV(pOut: *Color, h: f32, s: f32, v: f32, a: f32) callconv(.C) void;
    pub extern fn ImColor_ImColor_Nil(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImColor_ImColor_Float(self: ?*anyopaque, r: f32, g: f32, b: f32, a: f32) callconv(.C) void;
    pub extern fn ImColor_ImColor_Vec4(self: ?*anyopaque, col: *const Vec4) callconv(.C) void;
    pub extern fn ImColor_ImColor_Int(self: ?*anyopaque, r: i32, g: i32, b: i32, a: i32) callconv(.C) void;
    pub extern fn ImColor_ImColor_U32(self: ?*anyopaque, rgba: u32) callconv(.C) void;
    pub extern fn ImColor_SetHSV(self: *Color, h: f32, s: f32, v: f32, a: f32) callconv(.C) void;
    pub extern fn ImColor_destroy(self: *Color) callconv(.C) void;
    pub extern fn ImDrawCmd_GetTexID(self: *const DrawCmd) callconv(.C) TextureID;
    pub extern fn ImDrawCmd_ImDrawCmd(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImDrawCmd_destroy(self: *DrawCmd) callconv(.C) void;
    pub extern fn ImDrawData_Clear(self: *DrawData) callconv(.C) void;
    pub extern fn ImDrawData_DeIndexAllBuffers(self: *DrawData) callconv(.C) void;
    pub extern fn ImDrawData_ImDrawData(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImDrawData_ScaleClipRects(self: *DrawData, fb_scale: *const Vec2) callconv(.C) void;
    pub extern fn ImDrawData_destroy(self: *DrawData) callconv(.C) void;
    pub extern fn ImDrawListSplitter_Clear(self: *DrawListSplitter) callconv(.C) void;
    pub extern fn ImDrawListSplitter_ClearFreeMemory(self: *DrawListSplitter) callconv(.C) void;
    pub extern fn ImDrawListSplitter_ImDrawListSplitter(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImDrawListSplitter_Merge(self: *DrawListSplitter, draw_list: ?*DrawList) callconv(.C) void;
    pub extern fn ImDrawListSplitter_SetCurrentChannel(self: *DrawListSplitter, draw_list: ?*DrawList, channel_idx: i32) callconv(.C) void;
    pub extern fn ImDrawListSplitter_Split(self: *DrawListSplitter, draw_list: ?*DrawList, count: i32) callconv(.C) void;
    pub extern fn ImDrawListSplitter_destroy(self: *DrawListSplitter) callconv(.C) void;
    pub extern fn ImDrawList_AddBezierCubic(self: *DrawList, p1: *const Vec2, p2: *const Vec2, p3: *const Vec2, p4: *const Vec2, col: u32, thickness: f32, num_segments: i32) callconv(.C) void;
    pub extern fn ImDrawList_AddBezierQuadratic(self: *DrawList, p1: *const Vec2, p2: *const Vec2, p3: *const Vec2, col: u32, thickness: f32, num_segments: i32) callconv(.C) void;
    pub extern fn ImDrawList_AddCallback(self: *DrawList, callback: DrawCallback, callback_data: ?*anyopaque) callconv(.C) void;
    pub extern fn ImDrawList_AddCircle(self: *DrawList, center: *const Vec2, radius: f32, col: u32, num_segments: i32, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddCircleFilled(self: *DrawList, center: *const Vec2, radius: f32, col: u32, num_segments: i32) callconv(.C) void;
    pub extern fn ImDrawList_AddConvexPolyFilled(self: *DrawList, points: ?[*]const Vec2, num_points: i32, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_AddDrawCmd(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_AddImage(self: *DrawList, user_texture_id: TextureID, p_min: *const Vec2, p_max: *const Vec2, uv_min: *const Vec2, uv_max: *const Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_AddImageQuad(self: *DrawList, user_texture_id: TextureID, p1: *const Vec2, p2: *const Vec2, p3: *const Vec2, p4: *const Vec2, uv1: *const Vec2, uv2: *const Vec2, uv3: *const Vec2, uv4: *const Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_AddImageRounded(self: *DrawList, user_texture_id: TextureID, p_min: *const Vec2, p_max: *const Vec2, uv_min: *const Vec2, uv_max: *const Vec2, col: u32, rounding: f32, flags: DrawFlagsInt) callconv(.C) void;
    pub extern fn ImDrawList_AddLine(self: *DrawList, p1: *const Vec2, p2: *const Vec2, col: u32, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddNgon(self: *DrawList, center: *const Vec2, radius: f32, col: u32, num_segments: i32, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddNgonFilled(self: *DrawList, center: *const Vec2, radius: f32, col: u32, num_segments: i32) callconv(.C) void;
    pub extern fn ImDrawList_AddPolyline(self: *DrawList, points: ?[*]const Vec2, num_points: i32, col: u32, flags: DrawFlagsInt, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddQuad(self: *DrawList, p1: *const Vec2, p2: *const Vec2, p3: *const Vec2, p4: *const Vec2, col: u32, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddQuadFilled(self: *DrawList, p1: *const Vec2, p2: *const Vec2, p3: *const Vec2, p4: *const Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_AddRect(self: *DrawList, p_min: *const Vec2, p_max: *const Vec2, col: u32, rounding: f32, flags: DrawFlagsInt, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddRectFilled(self: *DrawList, p_min: *const Vec2, p_max: *const Vec2, col: u32, rounding: f32, flags: DrawFlagsInt) callconv(.C) void;
    pub extern fn ImDrawList_AddRectFilledMultiColor(self: *DrawList, p_min: *const Vec2, p_max: *const Vec2, col_upr_left: u32, col_upr_right: u32, col_bot_right: u32, col_bot_left: u32) callconv(.C) void;
    pub extern fn ImDrawList_AddText_Vec2(self: *DrawList, pos: *const Vec2, col: u32, text_begin: ?[*]const u8, text_end: ?[*]const u8) callconv(.C) void;
    pub extern fn ImDrawList_AddText_FontPtr(self: *DrawList, font: ?*const Font, font_size: f32, pos: *const Vec2, col: u32, text_begin: ?[*]const u8, text_end: ?[*]const u8, wrap_width: f32, cpu_fine_clip_rect: ?*const Vec4) callconv(.C) void;
    pub extern fn ImDrawList_AddTriangle(self: *DrawList, p1: *const Vec2, p2: *const Vec2, p3: *const Vec2, col: u32, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddTriangleFilled(self: *DrawList, p1: *const Vec2, p2: *const Vec2, p3: *const Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_ChannelsMerge(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_ChannelsSetCurrent(self: *DrawList, n: i32) callconv(.C) void;
    pub extern fn ImDrawList_ChannelsSplit(self: *DrawList, count: i32) callconv(.C) void;
    pub extern fn ImDrawList_CloneOutput(self: *const DrawList) callconv(.C) ?*DrawList;
    pub extern fn ImDrawList_GetClipRectMax(pOut: *Vec2, self: *const DrawList) callconv(.C) void;
    pub extern fn ImDrawList_GetClipRectMin(pOut: *Vec2, self: *const DrawList) callconv(.C) void;
    pub extern fn ImDrawList_ImDrawList(self: ?*anyopaque, shared_data: ?*const DrawListSharedData) callconv(.C) void;
    pub extern fn ImDrawList_PathArcTo(self: *DrawList, center: *const Vec2, radius: f32, a_min: f32, a_max: f32, num_segments: i32) callconv(.C) void;
    pub extern fn ImDrawList_PathArcToFast(self: *DrawList, center: *const Vec2, radius: f32, a_min_of_12: i32, a_max_of_12: i32) callconv(.C) void;
    pub extern fn ImDrawList_PathBezierCubicCurveTo(self: *DrawList, p2: *const Vec2, p3: *const Vec2, p4: *const Vec2, num_segments: i32) callconv(.C) void;
    pub extern fn ImDrawList_PathBezierQuadraticCurveTo(self: *DrawList, p2: *const Vec2, p3: *const Vec2, num_segments: i32) callconv(.C) void;
    pub extern fn ImDrawList_PathClear(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_PathFillConvex(self: *DrawList, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_PathLineTo(self: *DrawList, pos: *const Vec2) callconv(.C) void;
    pub extern fn ImDrawList_PathLineToMergeDuplicate(self: *DrawList, pos: *const Vec2) callconv(.C) void;
    pub extern fn ImDrawList_PathRect(self: *DrawList, rect_min: *const Vec2, rect_max: *const Vec2, rounding: f32, flags: DrawFlagsInt) callconv(.C) void;
    pub extern fn ImDrawList_PathStroke(self: *DrawList, col: u32, flags: DrawFlagsInt, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_PopClipRect(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_PopTextureID(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_PrimQuadUV(self: *DrawList, a: *const Vec2, b: *const Vec2, c: *const Vec2, d: *const Vec2, uv_a: *const Vec2, uv_b: *const Vec2, uv_c: *const Vec2, uv_d: *const Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_PrimRect(self: *DrawList, a: *const Vec2, b: *const Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_PrimRectUV(self: *DrawList, a: *const Vec2, b: *const Vec2, uv_a: *const Vec2, uv_b: *const Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_PrimReserve(self: *DrawList, idx_count: i32, vtx_count: i32) callconv(.C) void;
    pub extern fn ImDrawList_PrimUnreserve(self: *DrawList, idx_count: i32, vtx_count: i32) callconv(.C) void;
    pub extern fn ImDrawList_PrimVtx(self: *DrawList, pos: *const Vec2, uv: *const Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_PrimWriteIdx(self: *DrawList, idx: DrawIdx) callconv(.C) void;
    pub extern fn ImDrawList_PrimWriteVtx(self: *DrawList, pos: *const Vec2, uv: *const Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_PushClipRect(self: *DrawList, clip_rect_min: *const Vec2, clip_rect_max: *const Vec2, intersect_with_current_clip_rect: bool) callconv(.C) void;
    pub extern fn ImDrawList_PushClipRectFullScreen(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_PushTextureID(self: *DrawList, texture_id: TextureID) callconv(.C) void;
    pub extern fn ImDrawList__CalcCircleAutoSegmentCount(self: *const DrawList, radius: f32) callconv(.C) i32;
    pub extern fn ImDrawList__ClearFreeMemory(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList__OnChangedClipRect(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList__OnChangedTextureID(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList__OnChangedVtxOffset(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList__PathArcToFastEx(self: *DrawList, center: *const Vec2, radius: f32, a_min_sample: i32, a_max_sample: i32, a_step: i32) callconv(.C) void;
    pub extern fn ImDrawList__PathArcToN(self: *DrawList, center: *const Vec2, radius: f32, a_min: f32, a_max: f32, num_segments: i32) callconv(.C) void;
    pub extern fn ImDrawList__PopUnusedDrawCmd(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList__ResetForNewFrame(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList__TryMergeDrawCmds(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_destroy(self: *DrawList) callconv(.C) void;
    pub extern fn ImFontAtlasCustomRect_ImFontAtlasCustomRect(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImFontAtlasCustomRect_IsPacked(self: *const FontAtlasCustomRect) callconv(.C) bool;
    pub extern fn ImFontAtlasCustomRect_destroy(self: *FontAtlasCustomRect) callconv(.C) void;
    pub extern fn ImFontAtlas_AddCustomRectFontGlyph(self: *FontAtlas, font: ?*Font, id: Wchar, width: i32, height: i32, advance_x: f32, offset: *const Vec2) callconv(.C) i32;
    pub extern fn ImFontAtlas_AddCustomRectRegular(self: *FontAtlas, width: i32, height: i32) callconv(.C) i32;
    pub extern fn ImFontAtlas_AddFont(self: *FontAtlas, font_cfg: ?*const FontConfig) callconv(.C) ?*Font;
    pub extern fn ImFontAtlas_AddFontDefault(self: *FontAtlas, font_cfg: ?*const FontConfig) callconv(.C) ?*Font;
    pub extern fn ImFontAtlas_AddFontFromFileTTF(self: *FontAtlas, filename: ?[*:0]const u8, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) callconv(.C) ?*Font;
    pub extern fn ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(self: *FontAtlas, compressed_font_data_base85: ?[*]const u8, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) callconv(.C) ?*Font;
    pub extern fn ImFontAtlas_AddFontFromMemoryCompressedTTF(self: *FontAtlas, compressed_font_data: ?*const anyopaque, compressed_font_size: i32, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) callconv(.C) ?*Font;
    pub extern fn ImFontAtlas_AddFontFromMemoryTTF(self: *FontAtlas, font_data: ?*anyopaque, font_size: i32, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) callconv(.C) ?*Font;
    pub extern fn ImFontAtlas_Build(self: *FontAtlas) callconv(.C) bool;
    pub extern fn ImFontAtlas_CalcCustomRectUV(self: *const FontAtlas, rect: ?*const FontAtlasCustomRect, out_uv_min: ?*Vec2, out_uv_max: ?*Vec2) callconv(.C) void;
    pub extern fn ImFontAtlas_Clear(self: *FontAtlas) callconv(.C) void;
    pub extern fn ImFontAtlas_ClearFonts(self: *FontAtlas) callconv(.C) void;
    pub extern fn ImFontAtlas_ClearInputData(self: *FontAtlas) callconv(.C) void;
    pub extern fn ImFontAtlas_ClearTexData(self: *FontAtlas) callconv(.C) void;
    pub extern fn ImFontAtlas_GetCustomRectByIndex(self: *FontAtlas, index: i32) callconv(.C) ?*FontAtlasCustomRect;
    pub extern fn ImFontAtlas_GetGlyphRangesChineseFull(self: *FontAtlas) callconv(.C) ?*const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon(self: *FontAtlas) callconv(.C) ?*const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesCyrillic(self: *FontAtlas) callconv(.C) ?*const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesDefault(self: *FontAtlas) callconv(.C) ?*const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesJapanese(self: *FontAtlas) callconv(.C) ?*const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesKorean(self: *FontAtlas) callconv(.C) ?*const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesThai(self: *FontAtlas) callconv(.C) ?*const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesVietnamese(self: *FontAtlas) callconv(.C) ?*const Wchar;
    pub extern fn ImFontAtlas_GetMouseCursorTexData(self: *FontAtlas, cursor: MouseCursor, out_offset: ?*Vec2, out_size: ?*Vec2, out_uv_border: *[2]Vec2, out_uv_fill: *[2]Vec2) callconv(.C) bool;
    pub extern fn ImFontAtlas_GetTexDataAsAlpha8(self: *FontAtlas, out_pixels: *?[*]u8, out_width: *i32, out_height: *i32, out_bytes_per_pixel: ?*i32) callconv(.C) void;
    pub extern fn ImFontAtlas_GetTexDataAsRGBA32(self: *FontAtlas, out_pixels: *?[*]u8, out_width: *i32, out_height: *i32, out_bytes_per_pixel: ?*i32) callconv(.C) void;
    pub extern fn ImFontAtlas_ImFontAtlas(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImFontAtlas_IsBuilt(self: *const FontAtlas) callconv(.C) bool;
    pub extern fn ImFontAtlas_SetTexID(self: *FontAtlas, id: TextureID) callconv(.C) void;
    pub extern fn ImFontAtlas_destroy(self: *FontAtlas) callconv(.C) void;
    pub extern fn ImFontConfig_ImFontConfig(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImFontConfig_destroy(self: *FontConfig) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_AddChar(self: *FontGlyphRangesBuilder, c: Wchar) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_AddRanges(self: *FontGlyphRangesBuilder, ranges: ?[*:0]const Wchar) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_AddText(self: *FontGlyphRangesBuilder, text: ?[*]const u8, text_end: ?[*]const u8) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_BuildRanges(self: *FontGlyphRangesBuilder, out_ranges: *Vector(Wchar)) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_Clear(self: *FontGlyphRangesBuilder) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_GetBit(self: *const FontGlyphRangesBuilder, n: usize) callconv(.C) bool;
    pub extern fn ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_SetBit(self: *FontGlyphRangesBuilder, n: usize) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_destroy(self: *FontGlyphRangesBuilder) callconv(.C) void;
    pub extern fn ImFont_AddGlyph(self: *Font, src_cfg: ?*const FontConfig, c: Wchar, x0: f32, y0: f32, x1: f32, y1: f32, u0: f32, v0: f32, u1: f32, v1: f32, advance_x: f32) callconv(.C) void;
    pub extern fn ImFont_AddRemapChar(self: *Font, dst: Wchar, src: Wchar, overwrite_dst: bool) callconv(.C) void;
    pub extern fn ImFont_BuildLookupTable(self: *Font) callconv(.C) void;
    pub extern fn ImFont_CalcTextSizeA(pOut: *Vec2, self: *const Font, size: f32, max_width: f32, wrap_width: f32, text_begin: ?[*]const u8, text_end: ?[*]const u8, remaining: ?*?[*:0]const u8) callconv(.C) void;
    pub extern fn ImFont_CalcWordWrapPositionA(self: *const Font, scale: f32, text: ?[*]const u8, text_end: ?[*]const u8, wrap_width: f32) callconv(.C) ?[*]const u8;
    pub extern fn ImFont_ClearOutputData(self: *Font) callconv(.C) void;
    pub extern fn ImFont_FindGlyph(self: *const Font, c: Wchar) callconv(.C) ?*const FontGlyph;
    pub extern fn ImFont_FindGlyphNoFallback(self: *const Font, c: Wchar) callconv(.C) ?*const FontGlyph;
    pub extern fn ImFont_GetCharAdvance(self: *const Font, c: Wchar) callconv(.C) f32;
    pub extern fn ImFont_GetDebugName(self: *const Font) callconv(.C) ?[*:0]const u8;
    pub extern fn ImFont_GrowIndex(self: *Font, new_size: i32) callconv(.C) void;
    pub extern fn ImFont_ImFont(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImFont_IsGlyphRangeUnused(self: *Font, c_begin: u32, c_last: u32) callconv(.C) bool;
    pub extern fn ImFont_IsLoaded(self: *const Font) callconv(.C) bool;
    pub extern fn ImFont_RenderChar(self: *const Font, draw_list: ?*DrawList, size: f32, pos: *const Vec2, col: u32, c: Wchar) callconv(.C) void;
    pub extern fn ImFont_RenderText(self: *const Font, draw_list: ?*DrawList, size: f32, pos: *const Vec2, col: u32, clip_rect: *const Vec4, text_begin: ?[*]const u8, text_end: ?[*]const u8, wrap_width: f32, cpu_fine_clip: bool) callconv(.C) void;
    pub extern fn ImFont_SetGlyphVisible(self: *Font, c: Wchar, visible: bool) callconv(.C) void;
    pub extern fn ImFont_destroy(self: *Font) callconv(.C) void;
    pub extern fn ImGuiIO_AddFocusEvent(self: *IO, focused: bool) callconv(.C) void;
    pub extern fn ImGuiIO_AddInputCharacter(self: *IO, c: u32) callconv(.C) void;
    pub extern fn ImGuiIO_AddInputCharacterUTF16(self: *IO, c: Wchar16) callconv(.C) void;
    pub extern fn ImGuiIO_AddInputCharactersUTF8(self: *IO, str: ?[*:0]const u8) callconv(.C) void;
    pub extern fn ImGuiIO_AddKeyAnalogEvent(self: *IO, key: Key, down: bool, v: f32) callconv(.C) void;
    pub extern fn ImGuiIO_AddKeyEvent(self: *IO, key: Key, down: bool) callconv(.C) void;
    pub extern fn ImGuiIO_AddMouseButtonEvent(self: *IO, button: i32, down: bool) callconv(.C) void;
    pub extern fn ImGuiIO_AddMousePosEvent(self: *IO, x: f32, y: f32) callconv(.C) void;
    pub extern fn ImGuiIO_AddMouseWheelEvent(self: *IO, wh_x: f32, wh_y: f32) callconv(.C) void;
    pub extern fn ImGuiIO_ClearInputCharacters(self: *IO) callconv(.C) void;
    pub extern fn ImGuiIO_ClearInputKeys(self: *IO) callconv(.C) void;
    pub extern fn ImGuiIO_ImGuiIO(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiIO_SetAppAcceptingEvents(self: *IO, accepting_events: bool) callconv(.C) void;
    pub extern fn ImGuiIO_SetKeyEventNativeData(self: *IO, key: Key, native_keycode: i32, native_scancode: i32, native_legacy_index: i32) callconv(.C) void;
    pub extern fn ImGuiIO_destroy(self: *IO) callconv(.C) void;
    pub extern fn ImGuiInputTextCallbackData_ClearSelection(self: *InputTextCallbackData) callconv(.C) void;
    pub extern fn ImGuiInputTextCallbackData_DeleteChars(self: *InputTextCallbackData, pos: i32, bytes_count: i32) callconv(.C) void;
    pub extern fn ImGuiInputTextCallbackData_HasSelection(self: *const InputTextCallbackData) callconv(.C) bool;
    pub extern fn ImGuiInputTextCallbackData_ImGuiInputTextCallbackData(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiInputTextCallbackData_InsertChars(self: *InputTextCallbackData, pos: i32, text: ?[*]const u8, text_end: ?[*]const u8) callconv(.C) void;
    pub extern fn ImGuiInputTextCallbackData_SelectAll(self: *InputTextCallbackData) callconv(.C) void;
    pub extern fn ImGuiInputTextCallbackData_destroy(self: *InputTextCallbackData) callconv(.C) void;
    pub extern fn ImGuiListClipper_Begin(self: *ListClipper, items_count: i32, items_height: f32) callconv(.C) void;
    pub extern fn ImGuiListClipper_End(self: *ListClipper) callconv(.C) void;
    pub extern fn ImGuiListClipper_ForceDisplayRangeByIndices(self: *ListClipper, item_min: i32, item_max: i32) callconv(.C) void;
    pub extern fn ImGuiListClipper_ImGuiListClipper(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiListClipper_Step(self: *ListClipper) callconv(.C) bool;
    pub extern fn ImGuiListClipper_destroy(self: *ListClipper) callconv(.C) void;
    pub extern fn ImGuiOnceUponAFrame_ImGuiOnceUponAFrame(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiOnceUponAFrame_destroy(self: *OnceUponAFrame) callconv(.C) void;
    pub extern fn ImGuiPayload_Clear(self: *Payload) callconv(.C) void;
    pub extern fn ImGuiPayload_ImGuiPayload(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiPayload_IsDataType(self: *const Payload, kind: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn ImGuiPayload_IsDelivery(self: *const Payload) callconv(.C) bool;
    pub extern fn ImGuiPayload_IsPreview(self: *const Payload) callconv(.C) bool;
    pub extern fn ImGuiPayload_destroy(self: *Payload) callconv(.C) void;
    pub extern fn ImGuiPlatformImeData_ImGuiPlatformImeData(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiPlatformImeData_destroy(self: *PlatformImeData) callconv(.C) void;
    pub extern fn ImGuiStoragePair_ImGuiStoragePair_Int(self: ?*anyopaque, _key: ID, _val_i: i32) callconv(.C) void;
    pub extern fn ImGuiStoragePair_ImGuiStoragePair_Float(self: ?*anyopaque, _key: ID, _val_f: f32) callconv(.C) void;
    pub extern fn ImGuiStoragePair_ImGuiStoragePair_Ptr(self: ?*anyopaque, _key: ID, _val_p: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiStoragePair_destroy(self: *StoragePair) callconv(.C) void;
    pub extern fn ImGuiStorage_BuildSortByKey(self: *Storage) callconv(.C) void;
    pub extern fn ImGuiStorage_Clear(self: *Storage) callconv(.C) void;
    pub extern fn ImGuiStorage_GetBool(self: *const Storage, key: ID, default_val: bool) callconv(.C) bool;
    pub extern fn ImGuiStorage_GetBoolRef(self: *Storage, key: ID, default_val: bool) callconv(.C) ?*bool;
    pub extern fn ImGuiStorage_GetFloat(self: *const Storage, key: ID, default_val: f32) callconv(.C) f32;
    pub extern fn ImGuiStorage_GetFloatRef(self: *Storage, key: ID, default_val: f32) callconv(.C) ?*f32;
    pub extern fn ImGuiStorage_GetInt(self: *const Storage, key: ID, default_val: i32) callconv(.C) i32;
    pub extern fn ImGuiStorage_GetIntRef(self: *Storage, key: ID, default_val: i32) callconv(.C) ?*i32;
    pub extern fn ImGuiStorage_GetVoidPtr(self: *const Storage, key: ID) callconv(.C) ?*anyopaque;
    pub extern fn ImGuiStorage_GetVoidPtrRef(self: *Storage, key: ID, default_val: ?*anyopaque) callconv(.C) ?*?*anyopaque;
    pub extern fn ImGuiStorage_SetAllInt(self: *Storage, val: i32) callconv(.C) void;
    pub extern fn ImGuiStorage_SetBool(self: *Storage, key: ID, val: bool) callconv(.C) void;
    pub extern fn ImGuiStorage_SetFloat(self: *Storage, key: ID, val: f32) callconv(.C) void;
    pub extern fn ImGuiStorage_SetInt(self: *Storage, key: ID, val: i32) callconv(.C) void;
    pub extern fn ImGuiStorage_SetVoidPtr(self: *Storage, key: ID, val: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiStyle_ImGuiStyle(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiStyle_ScaleAllSizes(self: *Style, scale_factor: f32) callconv(.C) void;
    pub extern fn ImGuiStyle_destroy(self: *Style) callconv(.C) void;
    pub extern fn ImGuiTableColumnSortSpecs_ImGuiTableColumnSortSpecs(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiTableColumnSortSpecs_destroy(self: *TableColumnSortSpecs) callconv(.C) void;
    pub extern fn ImGuiTableSortSpecs_ImGuiTableSortSpecs(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiTableSortSpecs_destroy(self: *TableSortSpecs) callconv(.C) void;
    pub extern fn ImGuiTextBuffer_ImGuiTextBuffer(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiTextBuffer_append(self: *TextBuffer, str: ?[*]const u8, str_end: ?[*]const u8) callconv(.C) void;
    pub extern fn ImGuiTextBuffer_appendf(self: *TextBuffer, fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn ImGuiTextBuffer_begin(self: *const TextBuffer) callconv(.C) [*]const u8;
    pub extern fn ImGuiTextBuffer_c_str(self: *const TextBuffer) callconv(.C) [*:0]const u8;
    pub extern fn ImGuiTextBuffer_clear(self: *TextBuffer) callconv(.C) void;
    pub extern fn ImGuiTextBuffer_destroy(self: *TextBuffer) callconv(.C) void;
    pub extern fn ImGuiTextBuffer_empty(self: *const TextBuffer) callconv(.C) bool;
    pub extern fn ImGuiTextBuffer_end(self: *const TextBuffer) callconv(.C) [*]const u8;
    pub extern fn ImGuiTextBuffer_reserve(self: *TextBuffer, capacity: i32) callconv(.C) void;
    pub extern fn ImGuiTextBuffer_size(self: *const TextBuffer) callconv(.C) i32;
    pub extern fn ImGuiTextFilter_Build(self: *TextFilter) callconv(.C) void;
    pub extern fn ImGuiTextFilter_Clear(self: *TextFilter) callconv(.C) void;
    pub extern fn ImGuiTextFilter_Draw(self: *TextFilter, label: ?[*:0]const u8, width: f32) callconv(.C) bool;
    pub extern fn ImGuiTextFilter_ImGuiTextFilter(self: ?*anyopaque, default_filter: ?[*:0]const u8) callconv(.C) void;
    pub extern fn ImGuiTextFilter_IsActive(self: *const TextFilter) callconv(.C) bool;
    pub extern fn ImGuiTextFilter_PassFilter(self: *const TextFilter, text: ?[*]const u8, text_end: ?[*]const u8) callconv(.C) bool;
    pub extern fn ImGuiTextFilter_destroy(self: *TextFilter) callconv(.C) void;
    pub extern fn ImGuiTextRange_ImGuiTextRange_Nil(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiTextRange_ImGuiTextRange_Str(self: ?*anyopaque, _b: ?[*]const u8, _e: ?[*]const u8) callconv(.C) void;
    pub extern fn ImGuiTextRange_destroy(self: *TextRange) callconv(.C) void;
    pub extern fn ImGuiTextRange_empty(self: *const TextRange) callconv(.C) bool;
    pub extern fn ImGuiTextRange_split(self: *const TextRange, separator: u8, out: ?*Vector(TextRange)) callconv(.C) void;
    pub extern fn ImGuiViewport_GetCenter(pOut: *Vec2, self: *const Viewport) callconv(.C) void;
    pub extern fn ImGuiViewport_GetWorkCenter(pOut: *Vec2, self: *const Viewport) callconv(.C) void;
    pub extern fn ImGuiViewport_ImGuiViewport(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImGuiViewport_destroy(self: *Viewport) callconv(.C) void;
    pub extern fn ImVec2_ImVec2_Nil(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImVec2_ImVec2_Float(self: ?*anyopaque, _x: f32, _y: f32) callconv(.C) void;
    pub extern fn ImVec2_destroy(self: *Vec2) callconv(.C) void;
    pub extern fn ImVec4_ImVec4_Nil(self: ?*anyopaque) callconv(.C) void;
    pub extern fn ImVec4_ImVec4_Float(self: ?*anyopaque, _x: f32, _y: f32, _z: f32, _w: f32) callconv(.C) void;
    pub extern fn ImVec4_destroy(self: *Vec4) callconv(.C) void;
    pub extern fn igAcceptDragDropPayload(kind: ?[*:0]const u8, flags: DragDropFlagsInt) callconv(.C) ?*const Payload;
    pub extern fn igAlignTextToFramePadding() callconv(.C) void;
    pub extern fn igArrowButton(str_id: ?[*:0]const u8, dir: Dir) callconv(.C) bool;
    pub extern fn igBegin(name: ?[*:0]const u8, p_open: ?*bool, flags: WindowFlagsInt) callconv(.C) bool;
    pub extern fn igBeginChild_Str(str_id: ?[*:0]const u8, size: *const Vec2, border: bool, flags: WindowFlagsInt) callconv(.C) bool;
    pub extern fn igBeginChild_ID(id: ID, size: *const Vec2, border: bool, flags: WindowFlagsInt) callconv(.C) bool;
    pub extern fn igBeginChildFrame(id: ID, size: *const Vec2, flags: WindowFlagsInt) callconv(.C) bool;
    pub extern fn igBeginCombo(label: ?[*:0]const u8, preview_value: ?[*:0]const u8, flags: ComboFlagsInt) callconv(.C) bool;
    pub extern fn igBeginDisabled(disabled: bool) callconv(.C) void;
    pub extern fn igBeginDragDropSource(flags: DragDropFlagsInt) callconv(.C) bool;
    pub extern fn igBeginDragDropTarget() callconv(.C) bool;
    pub extern fn igBeginGroup() callconv(.C) void;
    pub extern fn igBeginListBox(label: ?[*:0]const u8, size: *const Vec2) callconv(.C) bool;
    pub extern fn igBeginMainMenuBar() callconv(.C) bool;
    pub extern fn igBeginMenu(label: ?[*:0]const u8, enabled: bool) callconv(.C) bool;
    pub extern fn igBeginMenuBar() callconv(.C) bool;
    pub extern fn igBeginPopup(str_id: ?[*:0]const u8, flags: WindowFlagsInt) callconv(.C) bool;
    pub extern fn igBeginPopupContextItem(str_id: ?[*:0]const u8, popup_flags: PopupFlagsInt) callconv(.C) bool;
    pub extern fn igBeginPopupContextVoid(str_id: ?[*:0]const u8, popup_flags: PopupFlagsInt) callconv(.C) bool;
    pub extern fn igBeginPopupContextWindow(str_id: ?[*:0]const u8, popup_flags: PopupFlagsInt) callconv(.C) bool;
    pub extern fn igBeginPopupModal(name: ?[*:0]const u8, p_open: ?*bool, flags: WindowFlagsInt) callconv(.C) bool;
    pub extern fn igBeginTabBar(str_id: ?[*:0]const u8, flags: TabBarFlagsInt) callconv(.C) bool;
    pub extern fn igBeginTabItem(label: ?[*:0]const u8, p_open: ?*bool, flags: TabItemFlagsInt) callconv(.C) bool;
    pub extern fn igBeginTable(str_id: ?[*:0]const u8, column: i32, flags: TableFlagsInt, outer_size: *const Vec2, inner_width: f32) callconv(.C) bool;
    pub extern fn igBeginTooltip() callconv(.C) void;
    pub extern fn igBullet() callconv(.C) void;
    pub extern fn igBulletText(fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igButton(label: ?[*:0]const u8, size: *const Vec2) callconv(.C) bool;
    pub extern fn igCalcItemWidth() callconv(.C) f32;
    pub extern fn igCalcTextSize(pOut: *Vec2, text: ?[*]const u8, text_end: ?[*]const u8, hide_text_after_double_hash: bool, wrap_width: f32) callconv(.C) void;
    pub extern fn igCheckbox(label: ?[*:0]const u8, v: *bool) callconv(.C) bool;
    pub extern fn igCheckboxFlags_IntPtr(label: ?[*:0]const u8, flags: *i32, flags_value: i32) callconv(.C) bool;
    pub extern fn igCheckboxFlags_UintPtr(label: ?[*:0]const u8, flags: *u32, flags_value: u32) callconv(.C) bool;
    pub extern fn igCloseCurrentPopup() callconv(.C) void;
    pub extern fn igCollapsingHeader_TreeNodeFlags(label: ?[*:0]const u8, flags: TreeNodeFlagsInt) callconv(.C) bool;
    pub extern fn igCollapsingHeader_BoolPtr(label: ?[*:0]const u8, p_visible: ?*bool, flags: TreeNodeFlagsInt) callconv(.C) bool;
    pub extern fn igColorButton(desc_id: ?[*:0]const u8, col: *const Vec4, flags: ColorEditFlagsInt, size: *const Vec2) callconv(.C) bool;
    pub extern fn igColorConvertFloat4ToU32(in: *const Vec4) callconv(.C) u32;
    pub extern fn igColorConvertHSVtoRGB(h: f32, s: f32, v: f32, out_r: *f32, out_g: *f32, out_b: *f32) callconv(.C) void;
    pub extern fn igColorConvertRGBtoHSV(r: f32, g: f32, b: f32, out_h: *f32, out_s: *f32, out_v: *f32) callconv(.C) void;
    pub extern fn igColorConvertU32ToFloat4(pOut: *Vec4, in: u32) callconv(.C) void;
    pub extern fn igColorEdit3(label: ?[*:0]const u8, col: *[3]f32, flags: ColorEditFlagsInt) callconv(.C) bool;
    pub extern fn igColorEdit4(label: ?[*:0]const u8, col: *[4]f32, flags: ColorEditFlagsInt) callconv(.C) bool;
    pub extern fn igColorPicker3(label: ?[*:0]const u8, col: *[3]f32, flags: ColorEditFlagsInt) callconv(.C) bool;
    pub extern fn igColorPicker4(label: ?[*:0]const u8, col: *[4]f32, flags: ColorEditFlagsInt, ref_col: ?*const[4]f32) callconv(.C) bool;
    pub extern fn igColumns(count: i32, id: ?[*:0]const u8, border: bool) callconv(.C) void;
    pub extern fn igCombo_Str_arr(label: ?[*:0]const u8, current_item: ?*i32, items: [*]const[*:0]const u8, items_count: i32, popup_max_height_in_items: i32) callconv(.C) bool;
    pub extern fn igCombo_Str(label: ?[*:0]const u8, current_item: ?*i32, items_separated_by_zeros: ?[*]const u8, popup_max_height_in_items: i32) callconv(.C) bool;
    pub extern fn igCombo_FnBoolPtr(label: ?[*:0]const u8, current_item: ?*i32, items_getter: ?*const fn (data: ?*anyopaque, idx: i32, out_text: *?[*:0]const u8) callconv(.C) bool, data: ?*anyopaque, items_count: i32, popup_max_height_in_items: i32) callconv(.C) bool;
    pub extern fn igCreateContext(shared_font_atlas: ?*FontAtlas) callconv(.C) ?*Context;
    pub extern fn igDebugCheckVersionAndDataLayout(version_str: ?[*:0]const u8, sz_io: usize, sz_style: usize, sz_vec2: usize, sz_vec4: usize, sz_drawvert: usize, sz_drawidx: usize) callconv(.C) bool;
    pub extern fn igDebugTextEncoding(text: ?[*]const u8) callconv(.C) void;
    pub extern fn igDestroyContext(ctx: ?*Context) callconv(.C) void;
    pub extern fn igDragFloat(label: ?[*:0]const u8, v: *f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igDragFloat2(label: ?[*:0]const u8, v: *[2]f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igDragFloat3(label: ?[*:0]const u8, v: *[3]f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igDragFloat4(label: ?[*:0]const u8, v: *[4]f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igDragFloatRange2(label: ?[*:0]const u8, v_current_min: *f32, v_current_max: *f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, format_max: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igDragInt(label: ?[*:0]const u8, v: *i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igDragInt2(label: ?[*:0]const u8, v: *[2]i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igDragInt3(label: ?[*:0]const u8, v: *[3]i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igDragInt4(label: ?[*:0]const u8, v: *[4]i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igDragIntRange2(label: ?[*:0]const u8, v_current_min: *i32, v_current_max: *i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8, format_max: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igDragScalar(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, v_speed: f32, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igDragScalarN(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, components: i32, v_speed: f32, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igDummy(size: *const Vec2) callconv(.C) void;
    pub extern fn igEnd() callconv(.C) void;
    pub extern fn igEndChild() callconv(.C) void;
    pub extern fn igEndChildFrame() callconv(.C) void;
    pub extern fn igEndCombo() callconv(.C) void;
    pub extern fn igEndDisabled() callconv(.C) void;
    pub extern fn igEndDragDropSource() callconv(.C) void;
    pub extern fn igEndDragDropTarget() callconv(.C) void;
    pub extern fn igEndFrame() callconv(.C) void;
    pub extern fn igEndGroup() callconv(.C) void;
    pub extern fn igEndListBox() callconv(.C) void;
    pub extern fn igEndMainMenuBar() callconv(.C) void;
    pub extern fn igEndMenu() callconv(.C) void;
    pub extern fn igEndMenuBar() callconv(.C) void;
    pub extern fn igEndPopup() callconv(.C) void;
    pub extern fn igEndTabBar() callconv(.C) void;
    pub extern fn igEndTabItem() callconv(.C) void;
    pub extern fn igEndTable() callconv(.C) void;
    pub extern fn igEndTooltip() callconv(.C) void;
    pub extern fn igGetAllocatorFunctions(p_alloc_func: ?*MemAllocFunc, p_free_func: ?*MemFreeFunc, p_user_data: ?*?*anyopaque) callconv(.C) void;
    pub extern fn igGetBackgroundDrawList() callconv(.C) ?*DrawList;
    pub extern fn igGetClipboardText() callconv(.C) ?[*:0]const u8;
    pub extern fn igGetColorU32_Col(idx: Col, alpha_mul: f32) callconv(.C) u32;
    pub extern fn igGetColorU32_Vec4(col: *const Vec4) callconv(.C) u32;
    pub extern fn igGetColorU32_U32(col: u32) callconv(.C) u32;
    pub extern fn igGetColumnIndex() callconv(.C) i32;
    pub extern fn igGetColumnOffset(column_index: i32) callconv(.C) f32;
    pub extern fn igGetColumnWidth(column_index: i32) callconv(.C) f32;
    pub extern fn igGetColumnsCount() callconv(.C) i32;
    pub extern fn igGetContentRegionAvail(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetContentRegionMax(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetCurrentContext() callconv(.C) ?*Context;
    pub extern fn igGetCursorPos(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetCursorPosX() callconv(.C) f32;
    pub extern fn igGetCursorPosY() callconv(.C) f32;
    pub extern fn igGetCursorScreenPos(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetCursorStartPos(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetDragDropPayload() callconv(.C) ?*const Payload;
    pub extern fn igGetDrawData() callconv(.C) *DrawData;
    pub extern fn igGetDrawListSharedData() callconv(.C) ?*DrawListSharedData;
    pub extern fn igGetFont() callconv(.C) ?*Font;
    pub extern fn igGetFontSize() callconv(.C) f32;
    pub extern fn igGetFontTexUvWhitePixel(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetForegroundDrawList() callconv(.C) ?*DrawList;
    pub extern fn igGetFrameCount() callconv(.C) i32;
    pub extern fn igGetFrameHeight() callconv(.C) f32;
    pub extern fn igGetFrameHeightWithSpacing() callconv(.C) f32;
    pub extern fn igGetID_Str(str_id: ?[*:0]const u8) callconv(.C) ID;
    pub extern fn igGetID_StrStr(str_id_begin: ?[*]const u8, str_id_end: ?[*]const u8) callconv(.C) ID;
    pub extern fn igGetID_Ptr(ptr_id: ?*const anyopaque) callconv(.C) ID;
    pub extern fn igGetIO() callconv(.C) *IO;
    pub extern fn igGetItemRectMax(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetItemRectMin(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetItemRectSize(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetKeyIndex(key: Key) callconv(.C) i32;
    pub extern fn igGetKeyName(key: Key) callconv(.C) ?[*:0]const u8;
    pub extern fn igGetKeyPressedAmount(key: Key, repeat_delay: f32, rate: f32) callconv(.C) i32;
    pub extern fn igGetMainViewport() callconv(.C) ?*Viewport;
    pub extern fn igGetMouseClickedCount(button: MouseButton) callconv(.C) i32;
    pub extern fn igGetMouseCursor() callconv(.C) MouseCursor;
    pub extern fn igGetMouseDragDelta(pOut: *Vec2, button: MouseButton, lock_threshold: f32) callconv(.C) void;
    pub extern fn igGetMousePos(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetMousePosOnOpeningCurrentPopup(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetScrollMaxX() callconv(.C) f32;
    pub extern fn igGetScrollMaxY() callconv(.C) f32;
    pub extern fn igGetScrollX() callconv(.C) f32;
    pub extern fn igGetScrollY() callconv(.C) f32;
    pub extern fn igGetStateStorage() callconv(.C) ?*Storage;
    pub extern fn igGetStyle() callconv(.C) ?*Style;
    pub extern fn igGetStyleColorName(idx: Col) callconv(.C) ?[*:0]const u8;
    pub extern fn igGetStyleColorVec4(idx: Col) callconv(.C) ?*const Vec4;
    pub extern fn igGetTextLineHeight() callconv(.C) f32;
    pub extern fn igGetTextLineHeightWithSpacing() callconv(.C) f32;
    pub extern fn igGetTime() callconv(.C) f64;
    pub extern fn igGetTreeNodeToLabelSpacing() callconv(.C) f32;
    pub extern fn igGetVersion() callconv(.C) ?[*:0]const u8;
    pub extern fn igGetWindowContentRegionMax(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetWindowContentRegionMin(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetWindowDrawList() callconv(.C) ?*DrawList;
    pub extern fn igGetWindowHeight() callconv(.C) f32;
    pub extern fn igGetWindowPos(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetWindowSize(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetWindowWidth() callconv(.C) f32;
    pub extern fn igImage(user_texture_id: TextureID, size: *const Vec2, uv0: *const Vec2, uv1: *const Vec2, tint_col: *const Vec4, border_col: *const Vec4) callconv(.C) void;
    pub extern fn igImageButton(user_texture_id: TextureID, size: *const Vec2, uv0: *const Vec2, uv1: *const Vec2, frame_padding: i32, bg_col: *const Vec4, tint_col: *const Vec4) callconv(.C) bool;
    pub extern fn igIndent(indent_w: f32) callconv(.C) void;
    pub extern fn igInputDouble(label: ?[*:0]const u8, v: *f64, step: f64, step_fast: f64, format: ?[*:0]const u8, flags: InputTextFlagsInt) callconv(.C) bool;
    pub extern fn igInputFloat(label: ?[*:0]const u8, v: *f32, step: f32, step_fast: f32, format: ?[*:0]const u8, flags: InputTextFlagsInt) callconv(.C) bool;
    pub extern fn igInputFloat2(label: ?[*:0]const u8, v: *[2]f32, format: ?[*:0]const u8, flags: InputTextFlagsInt) callconv(.C) bool;
    pub extern fn igInputFloat3(label: ?[*:0]const u8, v: *[3]f32, format: ?[*:0]const u8, flags: InputTextFlagsInt) callconv(.C) bool;
    pub extern fn igInputFloat4(label: ?[*:0]const u8, v: *[4]f32, format: ?[*:0]const u8, flags: InputTextFlagsInt) callconv(.C) bool;
    pub extern fn igInputInt(label: ?[*:0]const u8, v: *i32, step: i32, step_fast: i32, flags: InputTextFlagsInt) callconv(.C) bool;
    pub extern fn igInputInt2(label: ?[*:0]const u8, v: *[2]i32, flags: InputTextFlagsInt) callconv(.C) bool;
    pub extern fn igInputInt3(label: ?[*:0]const u8, v: *[3]i32, flags: InputTextFlagsInt) callconv(.C) bool;
    pub extern fn igInputInt4(label: ?[*:0]const u8, v: *[4]i32, flags: InputTextFlagsInt) callconv(.C) bool;
    pub extern fn igInputScalar(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, p_step: ?*const anyopaque, p_step_fast: ?*const anyopaque, format: ?[*:0]const u8, flags: InputTextFlagsInt) callconv(.C) bool;
    pub extern fn igInputScalarN(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, components: i32, p_step: ?*const anyopaque, p_step_fast: ?*const anyopaque, format: ?[*:0]const u8, flags: InputTextFlagsInt) callconv(.C) bool;
    pub extern fn igInputText(label: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize, flags: InputTextFlagsInt, callback: InputTextCallback, user_data: ?*anyopaque) callconv(.C) bool;
    pub extern fn igInputTextMultiline(label: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize, size: *const Vec2, flags: InputTextFlagsInt, callback: InputTextCallback, user_data: ?*anyopaque) callconv(.C) bool;
    pub extern fn igInputTextWithHint(label: ?[*:0]const u8, hint: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize, flags: InputTextFlagsInt, callback: InputTextCallback, user_data: ?*anyopaque) callconv(.C) bool;
    pub extern fn igInvisibleButton(str_id: ?[*:0]const u8, size: *const Vec2, flags: ButtonFlagsInt) callconv(.C) bool;
    pub extern fn igIsAnyItemActive() callconv(.C) bool;
    pub extern fn igIsAnyItemFocused() callconv(.C) bool;
    pub extern fn igIsAnyItemHovered() callconv(.C) bool;
    pub extern fn igIsAnyMouseDown() callconv(.C) bool;
    pub extern fn igIsItemActivated() callconv(.C) bool;
    pub extern fn igIsItemActive() callconv(.C) bool;
    pub extern fn igIsItemClicked(mouse_button: MouseButton) callconv(.C) bool;
    pub extern fn igIsItemDeactivated() callconv(.C) bool;
    pub extern fn igIsItemDeactivatedAfterEdit() callconv(.C) bool;
    pub extern fn igIsItemEdited() callconv(.C) bool;
    pub extern fn igIsItemFocused() callconv(.C) bool;
    pub extern fn igIsItemHovered(flags: HoveredFlagsInt) callconv(.C) bool;
    pub extern fn igIsItemToggledOpen() callconv(.C) bool;
    pub extern fn igIsItemVisible() callconv(.C) bool;
    pub extern fn igIsKeyDown(key: Key) callconv(.C) bool;
    pub extern fn igIsKeyPressed(key: Key, repeat: bool) callconv(.C) bool;
    pub extern fn igIsKeyReleased(key: Key) callconv(.C) bool;
    pub extern fn igIsMouseClicked(button: MouseButton, repeat: bool) callconv(.C) bool;
    pub extern fn igIsMouseDoubleClicked(button: MouseButton) callconv(.C) bool;
    pub extern fn igIsMouseDown(button: MouseButton) callconv(.C) bool;
    pub extern fn igIsMouseDragging(button: MouseButton, lock_threshold: f32) callconv(.C) bool;
    pub extern fn igIsMouseHoveringRect(r_min: *const Vec2, r_max: *const Vec2, clip: bool) callconv(.C) bool;
    pub extern fn igIsMousePosValid(mouse_pos: ?*const Vec2) callconv(.C) bool;
    pub extern fn igIsMouseReleased(button: MouseButton) callconv(.C) bool;
    pub extern fn igIsPopupOpen(str_id: ?[*:0]const u8, flags: PopupFlagsInt) callconv(.C) bool;
    pub extern fn igIsRectVisible_Nil(size: *const Vec2) callconv(.C) bool;
    pub extern fn igIsRectVisible_Vec2(rect_min: *const Vec2, rect_max: *const Vec2) callconv(.C) bool;
    pub extern fn igIsWindowAppearing() callconv(.C) bool;
    pub extern fn igIsWindowCollapsed() callconv(.C) bool;
    pub extern fn igIsWindowFocused(flags: FocusedFlagsInt) callconv(.C) bool;
    pub extern fn igIsWindowHovered(flags: HoveredFlagsInt) callconv(.C) bool;
    pub extern fn igLabelText(label: ?[*:0]const u8, fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igListBox_Str_arr(label: ?[*:0]const u8, current_item: ?*i32, items: [*]const[*:0]const u8, items_count: i32, height_in_items: i32) callconv(.C) bool;
    pub extern fn igListBox_FnBoolPtr(label: ?[*:0]const u8, current_item: ?*i32, items_getter: ?*const fn (data: ?*anyopaque, idx: i32, out_text: *?[*:0]const u8) callconv(.C) bool, data: ?*anyopaque, items_count: i32, height_in_items: i32) callconv(.C) bool;
    pub extern fn igLoadIniSettingsFromDisk(ini_filename: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igLoadIniSettingsFromMemory(ini_data: ?[*]const u8, ini_size: usize) callconv(.C) void;
    pub extern fn igLogButtons() callconv(.C) void;
    pub extern fn igLogFinish() callconv(.C) void;
    pub extern fn igLogText(fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igLogToClipboard(auto_open_depth: i32) callconv(.C) void;
    pub extern fn igLogToFile(auto_open_depth: i32, filename: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igLogToTTY(auto_open_depth: i32) callconv(.C) void;
    pub extern fn igMemAlloc(size: usize) callconv(.C) ?*anyopaque;
    pub extern fn igMemFree(ptr: ?*anyopaque) callconv(.C) void;
    pub extern fn igMenuItem_Bool(label: ?[*:0]const u8, shortcut: ?[*:0]const u8, selected: bool, enabled: bool) callconv(.C) bool;
    pub extern fn igMenuItem_BoolPtr(label: ?[*:0]const u8, shortcut: ?[*:0]const u8, p_selected: ?*bool, enabled: bool) callconv(.C) bool;
    pub extern fn igNewFrame() callconv(.C) void;
    pub extern fn igNewLine() callconv(.C) void;
    pub extern fn igNextColumn() callconv(.C) void;
    pub extern fn igOpenPopup_Str(str_id: ?[*:0]const u8, popup_flags: PopupFlagsInt) callconv(.C) void;
    pub extern fn igOpenPopup_ID(id: ID, popup_flags: PopupFlagsInt) callconv(.C) void;
    pub extern fn igOpenPopupOnItemClick(str_id: ?[*:0]const u8, popup_flags: PopupFlagsInt) callconv(.C) void;
    pub extern fn igPlotHistogram_FloatPtr(label: ?[*:0]const u8, values: *const f32, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: *const Vec2, stride: i32) callconv(.C) void;
    pub extern fn igPlotHistogram_FnFloatPtr(label: ?[*:0]const u8, values_getter: ?*const fn (data: ?*anyopaque, idx: i32) callconv(.C) f32, data: ?*anyopaque, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: *const Vec2) callconv(.C) void;
    pub extern fn igPlotLines_FloatPtr(label: ?[*:0]const u8, values: *const f32, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: *const Vec2, stride: i32) callconv(.C) void;
    pub extern fn igPlotLines_FnFloatPtr(label: ?[*:0]const u8, values_getter: ?*const fn (data: ?*anyopaque, idx: i32) callconv(.C) f32, data: ?*anyopaque, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: *const Vec2) callconv(.C) void;
    pub extern fn igPopAllowKeyboardFocus() callconv(.C) void;
    pub extern fn igPopButtonRepeat() callconv(.C) void;
    pub extern fn igPopClipRect() callconv(.C) void;
    pub extern fn igPopFont() callconv(.C) void;
    pub extern fn igPopID() callconv(.C) void;
    pub extern fn igPopItemWidth() callconv(.C) void;
    pub extern fn igPopStyleColor(count: i32) callconv(.C) void;
    pub extern fn igPopStyleVar(count: i32) callconv(.C) void;
    pub extern fn igPopTextWrapPos() callconv(.C) void;
    pub extern fn igProgressBar(fraction: f32, size_arg: *const Vec2, overlay: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igPushAllowKeyboardFocus(allow_keyboard_focus: bool) callconv(.C) void;
    pub extern fn igPushButtonRepeat(repeat: bool) callconv(.C) void;
    pub extern fn igPushClipRect(clip_rect_min: *const Vec2, clip_rect_max: *const Vec2, intersect_with_current_clip_rect: bool) callconv(.C) void;
    pub extern fn igPushFont(font: ?*Font) callconv(.C) void;
    pub extern fn igPushID_Str(str_id: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igPushID_StrStr(str_id_begin: ?[*]const u8, str_id_end: ?[*]const u8) callconv(.C) void;
    pub extern fn igPushID_Ptr(ptr_id: ?*const anyopaque) callconv(.C) void;
    pub extern fn igPushID_Int(int_id: i32) callconv(.C) void;
    pub extern fn igPushItemWidth(item_width: f32) callconv(.C) void;
    pub extern fn igPushStyleColor_U32(idx: Col, col: u32) callconv(.C) void;
    pub extern fn igPushStyleColor_Vec4(idx: Col, col: *const Vec4) callconv(.C) void;
    pub extern fn igPushStyleVar_Float(idx: StyleVar, val: f32) callconv(.C) void;
    pub extern fn igPushStyleVar_Vec2(idx: StyleVar, val: *const Vec2) callconv(.C) void;
    pub extern fn igPushTextWrapPos(wrap_local_pos_x: f32) callconv(.C) void;
    pub extern fn igRadioButton_Bool(label: ?[*:0]const u8, active: bool) callconv(.C) bool;
    pub extern fn igRadioButton_IntPtr(label: ?[*:0]const u8, v: *i32, v_button: i32) callconv(.C) bool;
    pub extern fn igRender() callconv(.C) void;
    pub extern fn igResetMouseDragDelta(button: MouseButton) callconv(.C) void;
    pub extern fn igSameLine(offset_from_start_x: f32, spacing: f32) callconv(.C) void;
    pub extern fn igSaveIniSettingsToDisk(ini_filename: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igSaveIniSettingsToMemory(out_ini_size: ?*usize) callconv(.C) ?[*:0]const u8;
    pub extern fn igSelectable_Bool(label: ?[*:0]const u8, selected: bool, flags: SelectableFlagsInt, size: *const Vec2) callconv(.C) bool;
    pub extern fn igSelectable_BoolPtr(label: ?[*:0]const u8, p_selected: ?*bool, flags: SelectableFlagsInt, size: *const Vec2) callconv(.C) bool;
    pub extern fn igSeparator() callconv(.C) void;
    pub extern fn igSetAllocatorFunctions(alloc_func: MemAllocFunc, free_func: MemFreeFunc, user_data: ?*anyopaque) callconv(.C) void;
    pub extern fn igSetClipboardText(text: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igSetColorEditOptions(flags: ColorEditFlagsInt) callconv(.C) void;
    pub extern fn igSetColumnOffset(column_index: i32, offset_x: f32) callconv(.C) void;
    pub extern fn igSetColumnWidth(column_index: i32, width: f32) callconv(.C) void;
    pub extern fn igSetCurrentContext(ctx: ?*Context) callconv(.C) void;
    pub extern fn igSetCursorPos(local_pos: *const Vec2) callconv(.C) void;
    pub extern fn igSetCursorPosX(local_x: f32) callconv(.C) void;
    pub extern fn igSetCursorPosY(local_y: f32) callconv(.C) void;
    pub extern fn igSetCursorScreenPos(pos: *const Vec2) callconv(.C) void;
    pub extern fn igSetDragDropPayload(kind: ?[*:0]const u8, data: ?*const anyopaque, sz: usize, cond: CondFlagsInt) callconv(.C) bool;
    pub extern fn igSetItemAllowOverlap() callconv(.C) void;
    pub extern fn igSetItemDefaultFocus() callconv(.C) void;
    pub extern fn igSetKeyboardFocusHere(offset: i32) callconv(.C) void;
    pub extern fn igSetMouseCursor(cursor_type: MouseCursor) callconv(.C) void;
    pub extern fn igSetNextFrameWantCaptureKeyboard(want_capture_keyboard: bool) callconv(.C) void;
    pub extern fn igSetNextFrameWantCaptureMouse(want_capture_mouse: bool) callconv(.C) void;
    pub extern fn igSetNextItemOpen(is_open: bool, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetNextItemWidth(item_width: f32) callconv(.C) void;
    pub extern fn igSetNextWindowBgAlpha(alpha: f32) callconv(.C) void;
    pub extern fn igSetNextWindowCollapsed(collapsed: bool, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetNextWindowContentSize(size: *const Vec2) callconv(.C) void;
    pub extern fn igSetNextWindowFocus() callconv(.C) void;
    pub extern fn igSetNextWindowPos(pos: *const Vec2, cond: CondFlagsInt, pivot: *const Vec2) callconv(.C) void;
    pub extern fn igSetNextWindowSize(size: *const Vec2, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetNextWindowSizeConstraints(size_min: *const Vec2, size_max: *const Vec2, custom_callback: SizeCallback, custom_callback_data: ?*anyopaque) callconv(.C) void;
    pub extern fn igSetScrollFromPosX(local_x: f32, center_x_ratio: f32) callconv(.C) void;
    pub extern fn igSetScrollFromPosY(local_y: f32, center_y_ratio: f32) callconv(.C) void;
    pub extern fn igSetScrollHereX(center_x_ratio: f32) callconv(.C) void;
    pub extern fn igSetScrollHereY(center_y_ratio: f32) callconv(.C) void;
    pub extern fn igSetScrollX(scroll_x: f32) callconv(.C) void;
    pub extern fn igSetScrollY(scroll_y: f32) callconv(.C) void;
    pub extern fn igSetStateStorage(storage: ?*Storage) callconv(.C) void;
    pub extern fn igSetTabItemClosed(tab_or_docked_window_label: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igSetTooltip(fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igSetWindowCollapsed_Bool(collapsed: bool, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetWindowCollapsed_Str(name: ?[*:0]const u8, collapsed: bool, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetWindowFocus_Nil() callconv(.C) void;
    pub extern fn igSetWindowFocus_Str(name: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igSetWindowFontScale(scale: f32) callconv(.C) void;
    pub extern fn igSetWindowPos_Vec2(pos: *const Vec2, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetWindowPos_Str(name: ?[*:0]const u8, pos: *const Vec2, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetWindowSize_Vec2(size: *const Vec2, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetWindowSize_Str(name: ?[*:0]const u8, size: *const Vec2, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igShowAboutWindow(p_open: ?*bool) callconv(.C) void;
    pub extern fn igShowDebugLogWindow(p_open: ?*bool) callconv(.C) void;
    pub extern fn igShowDemoWindow(p_open: ?*bool) callconv(.C) void;
    pub extern fn igShowFontSelector(label: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igShowMetricsWindow(p_open: ?*bool) callconv(.C) void;
    pub extern fn igShowStackToolWindow(p_open: ?*bool) callconv(.C) void;
    pub extern fn igShowStyleEditor(ref: ?*Style) callconv(.C) void;
    pub extern fn igShowStyleSelector(label: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igShowUserGuide() callconv(.C) void;
    pub extern fn igSliderAngle(label: ?[*:0]const u8, v_rad: *f32, v_degrees_min: f32, v_degrees_max: f32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igSliderFloat(label: ?[*:0]const u8, v: *f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igSliderFloat2(label: ?[*:0]const u8, v: *[2]f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igSliderFloat3(label: ?[*:0]const u8, v: *[3]f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igSliderFloat4(label: ?[*:0]const u8, v: *[4]f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igSliderInt(label: ?[*:0]const u8, v: *i32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igSliderInt2(label: ?[*:0]const u8, v: *[2]i32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igSliderInt3(label: ?[*:0]const u8, v: *[3]i32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igSliderInt4(label: ?[*:0]const u8, v: *[4]i32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igSliderScalar(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igSliderScalarN(label: ?[*:0]const u8, data_type: DataType, p_data: ?*anyopaque, components: i32, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igSmallButton(label: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igSpacing() callconv(.C) void;
    pub extern fn igStyleColorsClassic(dst: ?*Style) callconv(.C) void;
    pub extern fn igStyleColorsDark(dst: ?*Style) callconv(.C) void;
    pub extern fn igStyleColorsLight(dst: ?*Style) callconv(.C) void;
    pub extern fn igTabItemButton(label: ?[*:0]const u8, flags: TabItemFlagsInt) callconv(.C) bool;
    pub extern fn igTableGetColumnCount() callconv(.C) i32;
    pub extern fn igTableGetColumnFlags(column_n: i32) callconv(.C) TableColumnFlagsInt;
    pub extern fn igTableGetColumnIndex() callconv(.C) i32;
    pub extern fn igTableGetColumnName(column_n: i32) callconv(.C) ?[*:0]const u8;
    pub extern fn igTableGetRowIndex() callconv(.C) i32;
    pub extern fn igTableGetSortSpecs() callconv(.C) ?*TableSortSpecs;
    pub extern fn igTableHeader(label: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igTableHeadersRow() callconv(.C) void;
    pub extern fn igTableNextColumn() callconv(.C) bool;
    pub extern fn igTableNextRow(row_flags: TableRowFlagsInt, min_row_height: f32) callconv(.C) void;
    pub extern fn igTableSetBgColor(target: TableBgTarget, color: u32, column_n: i32) callconv(.C) void;
    pub extern fn igTableSetColumnEnabled(column_n: i32, v: bool) callconv(.C) void;
    pub extern fn igTableSetColumnIndex(column_n: i32) callconv(.C) bool;
    pub extern fn igTableSetupColumn(label: ?[*:0]const u8, flags: TableColumnFlagsInt, init_width_or_weight: f32, user_id: ID) callconv(.C) void;
    pub extern fn igTableSetupScrollFreeze(cols: i32, rows: i32) callconv(.C) void;
    pub extern fn igText(fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igTextColored(col: *const Vec4, fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igTextDisabled(fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igTextUnformatted(text: ?[*]const u8, text_end: ?[*]const u8) callconv(.C) void;
    pub extern fn igTextWrapped(fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igTreeNode_Str(label: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igTreeNode_StrStr(str_id: ?[*:0]const u8, fmt: ?[*:0]const u8, ...) callconv(.C) bool;
    pub extern fn igTreeNode_Ptr(ptr_id: ?*const anyopaque, fmt: ?[*:0]const u8, ...) callconv(.C) bool;
    pub extern fn igTreeNodeEx_Str(label: ?[*:0]const u8, flags: TreeNodeFlagsInt) callconv(.C) bool;
    pub extern fn igTreeNodeEx_StrStr(str_id: ?[*:0]const u8, flags: TreeNodeFlagsInt, fmt: ?[*:0]const u8, ...) callconv(.C) bool;
    pub extern fn igTreeNodeEx_Ptr(ptr_id: ?*const anyopaque, flags: TreeNodeFlagsInt, fmt: ?[*:0]const u8, ...) callconv(.C) bool;
    pub extern fn igTreePop() callconv(.C) void;
    pub extern fn igTreePush_Str(str_id: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igTreePush_Ptr(ptr_id: ?*const anyopaque) callconv(.C) void;
    pub extern fn igUnindent(indent_w: f32) callconv(.C) void;
    pub extern fn igVSliderFloat(label: ?[*:0]const u8, size: *const Vec2, v: *f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igVSliderInt(label: ?[*:0]const u8, size: *const Vec2, v: *i32, v_min: i32, v_max: i32, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igVSliderScalar(label: ?[*:0]const u8, size: *const Vec2, data_type: DataType, p_data: ?*anyopaque, p_min: ?*const anyopaque, p_max: ?*const anyopaque, format: ?[*:0]const u8, flags: SliderFlagsInt) callconv(.C) bool;
    pub extern fn igValue_Bool(prefix: ?[*:0]const u8, b: bool) callconv(.C) void;
    pub extern fn igValue_Int(prefix: ?[*:0]const u8, v: i32) callconv(.C) void;
    pub extern fn igValue_Uint(prefix: ?[*:0]const u8, v: u32) callconv(.C) void;
    pub extern fn igValue_Float(prefix: ?[*:0]const u8, v: f32, float_format: ?[*:0]const u8) callconv(.C) void;
};
