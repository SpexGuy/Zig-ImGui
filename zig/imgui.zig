const assert = @import("std").debug.assert;

pub const DrawListSharedData = @OpaqueType();
pub const Context = @OpaqueType();
pub const DrawCallback = ?fn (parent_list: ?*const DrawList, cmd: ?*const DrawCmd) callconv(.C) void;
pub const DrawIdx = u16;
pub const ID = u32;
pub const InputTextCallback = ?fn (data: ?*InputTextCallbackData) callconv(.C) i32;
pub const SizeCallback = ?fn (data: ?*SizeCallbackData) callconv(.C) void;
pub const TextureID = ?*c_void;
pub const Wchar = u16;

pub const DrawCallback_ResetRenderState = @intToPtr(DrawCallback, ~@as(usize, 0));
pub const VERSION = "1.75";
pub fn CHECKVERSION() void {
    if (@import("builtin").mode != .ReleaseFast) {
        @import("std").debug.assert(raw.igDebugCheckVersionAndDataLayout(VERSION, @sizeOf(IO), @sizeOf(Style), @sizeOf(Vec2), @sizeOf(Vec4), @sizeOf(DrawVert), @sizeOf(DrawIdx)));
    }
}

pub const FLT_MAX = @import("std").math.f32_max;
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
    };
}

pub const DrawCornerFlagsInt = FlagsInt;
pub const DrawCornerFlags = packed struct {
    TopLeft: bool = false,
    TopRight: bool = false,
    BotLeft: bool = false,
    BotRight: bool = false,
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

    const Self = @This();
    pub const None = Self{};
    pub const Top = Self{ .TopLeft=true, .TopRight=true };
    pub const Bot = Self{ .BotLeft=true, .BotRight=true };
    pub const Left = Self{ .TopLeft=true, .BotLeft=true };
    pub const Right = Self{ .TopRight=true, .BotRight=true };
    pub const All = Self{ .TopLeft=true, .TopRight=true, .BotLeft=true, .BotRight=true };

    pub usingnamespace FlagsMixin(Self);
};

pub const DrawListFlagsInt = FlagsInt;
pub const DrawListFlags = packed struct {
    AntiAliasedLines: bool = false,
    AntiAliasedFill: bool = false,
    AllowVtxOffset: bool = false,
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

    const Self = @This();
    pub const None = Self{};

    pub usingnamespace FlagsMixin(Self);
};

pub const FontAtlasFlagsInt = FlagsInt;
pub const FontAtlasFlags = packed struct {
    NoPowerOfTwoHeight: bool = false,
    NoMouseCursors: bool = false,
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

    const Self = @This();
    pub const None = Self{};

    pub usingnamespace FlagsMixin(Self);
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

    const Self = @This();
    pub const None = Self{};

    pub usingnamespace FlagsMixin(Self);
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
    __reserved_bit_10: bool = false,
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

    const Self = @This();
    pub const None = Self{};
    pub const _OptionsDefault = Self{ .DisplayRGB=true, .Uint8=true, .PickerHueBar=true, .InputRGB=true };
    pub const _DisplayMask = Self{ .DisplayRGB=true, .DisplayHSV=true, .DisplayHex=true };
    pub const _DataTypeMask = Self{ .Uint8=true, .Float=true };
    pub const _PickerMask = Self{ .PickerHueBar=true, .PickerHueWheel=true };
    pub const _InputMask = Self{ .InputRGB=true, .InputHSV=true };

    pub usingnamespace FlagsMixin(Self);
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

    const Self = @This();
    pub const None = Self{};
    pub const HeightMask_ = Self{ .HeightSmall=true, .HeightRegular=true, .HeightLarge=true, .HeightLargest=true };

    pub usingnamespace FlagsMixin(Self);
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

    const Self = @This();
    pub const None = Self{};

    pub usingnamespace FlagsMixin(Self);
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

    const Self = @This();
    pub const None = Self{};
    pub const AcceptPeekOnly = Self{ .AcceptBeforeDelivery=true, .AcceptNoDrawDefaultRect=true };

    pub usingnamespace FlagsMixin(Self);
};

pub const FocusedFlagsInt = FlagsInt;
pub const FocusedFlags = packed struct {
    ChildWindows: bool = false,
    RootWindow: bool = false,
    AnyWindow: bool = false,
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

    const Self = @This();
    pub const None = Self{};
    pub const RootAndChildWindows = Self{ .ChildWindows=true, .RootWindow=true };

    pub usingnamespace FlagsMixin(Self);
};

pub const HoveredFlagsInt = FlagsInt;
pub const HoveredFlags = packed struct {
    ChildWindows: bool = false,
    RootWindow: bool = false,
    AnyWindow: bool = false,
    AllowWhenBlockedByPopup: bool = false,
    __reserved_bit_04: bool = false,
    AllowWhenBlockedByActiveItem: bool = false,
    AllowWhenOverlapped: bool = false,
    AllowWhenDisabled: bool = false,
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

    const Self = @This();
    pub const None = Self{};
    pub const RectOnly = Self{ .AllowWhenBlockedByPopup=true, .AllowWhenBlockedByActiveItem=true, .AllowWhenOverlapped=true };
    pub const RootAndChildWindows = Self{ .ChildWindows=true, .RootWindow=true };

    pub usingnamespace FlagsMixin(Self);
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
    AlwaysInsertMode: bool = false,
    ReadOnly: bool = false,
    Password: bool = false,
    NoUndoRedo: bool = false,
    CharsScientific: bool = false,
    CallbackResize: bool = false,
    __reserved_bit_19: bool = false,
    Multiline: bool = false,
    NoMarkEdited: bool = false,
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

    const Self = @This();
    pub const None = Self{};

    pub usingnamespace FlagsMixin(Self);
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

    const Self = @This();
    pub const None = Self{};

    pub usingnamespace FlagsMixin(Self);
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

    const Self = @This();
    pub const None = Self{};
    pub const FittingPolicyMask_ = Self{ .FittingPolicyResizeDown=true, .FittingPolicyScroll=true };
    pub const FittingPolicyDefault_ = Self{ .FittingPolicyResizeDown=true };

    pub usingnamespace FlagsMixin(Self);
};

pub const TabItemFlagsInt = FlagsInt;
pub const TabItemFlags = packed struct {
    UnsavedDocument: bool = false,
    SetSelected: bool = false,
    NoCloseWithMiddleMouseButton: bool = false,
    NoPushId: bool = false,
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

    const Self = @This();
    pub const None = Self{};

    pub usingnamespace FlagsMixin(Self);
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

    const Self = @This();
    pub const None = Self{};
    pub const CollapsingHeader = Self{ .Framed=true, .NoTreePushOnOpen=true, .NoAutoOpenOnLog=true };

    pub usingnamespace FlagsMixin(Self);
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

    const Self = @This();
    pub const None = Self{};
    pub const NoNav = Self{ .NoNavInputs=true, .NoNavFocus=true };
    pub const NoDecoration = Self{ .NoTitleBar=true, .NoResize=true, .NoScrollbar=true, .NoCollapse=true };
    pub const NoInputs = Self{ .NoMouseInputs=true, .NoNavInputs=true, .NoNavFocus=true };

    pub usingnamespace FlagsMixin(Self);
};

pub const Col = extern enum {
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
    TextSelectedBg = 42,
    DragDropTarget = 43,
    NavHighlight = 44,
    NavWindowingHighlight = 45,
    NavWindowingDimBg = 46,
    ModalWindowDimBg = 47,
    pub const COUNT = 48;
};

pub const DataType = extern enum {
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
    pub const COUNT = 10;
};

pub const Dir = extern enum {
    None = -1,
    Left = 0,
    Right = 1,
    Up = 2,
    Down = 3,
    pub const COUNT = 4;
};

pub const Key = extern enum {
    Tab = 0,
    LeftArrow = 1,
    RightArrow = 2,
    UpArrow = 3,
    DownArrow = 4,
    PageUp = 5,
    PageDown = 6,
    Home = 7,
    End = 8,
    Insert = 9,
    Delete = 10,
    Backspace = 11,
    Space = 12,
    Enter = 13,
    Escape = 14,
    KeyPadEnter = 15,
    A = 16,
    C = 17,
    V = 18,
    X = 19,
    Y = 20,
    Z = 21,
    pub const COUNT = 22;
};

pub const MouseButton = extern enum {
    Left = 0,
    Right = 1,
    Middle = 2,
    pub const COUNT = 5;
};

pub const MouseCursor = extern enum {
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
    pub const COUNT = 9;
};

pub const NavInput = extern enum {
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
    KeyMenu_ = 16,
    KeyLeft_ = 17,
    KeyRight_ = 18,
    KeyUp_ = 19,
    KeyDown_ = 20,
    pub const COUNT = 21;

    pub const Self = @This();
    pub const InternalStart_ = Self.KeyMenu_;
};

pub const StyleVar = extern enum {
    Alpha = 0,
    WindowPadding = 1,
    WindowRounding = 2,
    WindowBorderSize = 3,
    WindowMinSize = 4,
    WindowTitleAlign = 5,
    ChildRounding = 6,
    ChildBorderSize = 7,
    PopupRounding = 8,
    PopupBorderSize = 9,
    FramePadding = 10,
    FrameRounding = 11,
    FrameBorderSize = 12,
    ItemSpacing = 13,
    ItemInnerSpacing = 14,
    IndentSpacing = 15,
    ScrollbarSize = 16,
    ScrollbarRounding = 17,
    GrabMinSize = 18,
    GrabRounding = 19,
    TabRounding = 20,
    ButtonTextAlign = 21,
    SelectableTextAlign = 22,
    pub const COUNT = 23;
};

pub const Color = extern struct {
    Value: Vec4,

    pub inline fn HSVExt(self: *Color, h: f32, s: f32, v: f32, a: f32) Color {
        var out: Color = undefined;
        raw.ImColor_HSV_nonUDT(&out, self, h, s, v, a);
        return out;
    }
    pub inline fn HSV(self: *Color, h: f32, s: f32, v: f32) Color {
        return HSVExt(self, h, s, v, 1.0);
    }

    /// init(self: *Color) void
    pub const init = raw.ImColor_ImColor;

    /// initIntExt(self: *Color, r: i32, g: i32, b: i32, a: i32) void
    pub const initIntExt = raw.ImColor_ImColorInt;
    pub inline fn initInt(self: *Color, r: i32, g: i32, b: i32) void {
        return initIntExt(self, r, g, b, 255);
    }

    /// initU32(self: *Color, rgba: u32) void
    pub const initU32 = raw.ImColor_ImColorU32;

    /// initFloatExt(self: *Color, r: f32, g: f32, b: f32, a: f32) void
    pub const initFloatExt = raw.ImColor_ImColorFloat;
    pub inline fn initFloat(self: *Color, r: f32, g: f32, b: f32) void {
        return initFloatExt(self, r, g, b, 1.0);
    }

    /// initVec4(self: *Color, col: Vec4) void
    pub const initVec4 = raw.ImColor_ImColorVec4;

    /// SetHSVExt(self: *Color, h: f32, s: f32, v: f32, a: f32) void
    pub const SetHSVExt = raw.ImColor_SetHSV;
    pub inline fn SetHSV(self: *Color, h: f32, s: f32, v: f32) void {
        return SetHSVExt(self, h, s, v, 1.0);
    }

    /// deinit(self: *Color) void
    pub const deinit = raw.ImColor_destroy;
};

pub const DrawChannel = extern struct {
    _CmdBuffer: Vector(DrawCmd),
    _IdxBuffer: Vector(DrawIdx),
};

pub const DrawCmd = extern struct {
    ElemCount: u32,
    ClipRect: Vec4,
    TextureId: TextureID,
    VtxOffset: u32,
    IdxOffset: u32,
    UserCallback: DrawCallback,
    UserCallbackData: ?*c_void,

    /// init(self: *DrawCmd) void
    pub const init = raw.ImDrawCmd_ImDrawCmd;

    /// deinit(self: *DrawCmd) void
    pub const deinit = raw.ImDrawCmd_destroy;
};

pub const DrawData = extern struct {
    Valid: bool,
    CmdLists: ?[*]*DrawList,
    CmdListsCount: i32,
    TotalIdxCount: i32,
    TotalVtxCount: i32,
    DisplayPos: Vec2,
    DisplaySize: Vec2,
    FramebufferScale: Vec2,

    /// Clear(self: *DrawData) void
    pub const Clear = raw.ImDrawData_Clear;

    /// DeIndexAllBuffers(self: *DrawData) void
    pub const DeIndexAllBuffers = raw.ImDrawData_DeIndexAllBuffers;

    /// init(self: *DrawData) void
    pub const init = raw.ImDrawData_ImDrawData;

    /// ScaleClipRects(self: *DrawData, fb_scale: Vec2) void
    pub const ScaleClipRects = raw.ImDrawData_ScaleClipRects;

    /// deinit(self: *DrawData) void
    pub const deinit = raw.ImDrawData_destroy;
};

pub const DrawList = extern struct {
    CmdBuffer: Vector(DrawCmd),
    IdxBuffer: Vector(DrawIdx),
    VtxBuffer: Vector(DrawVert),
    Flags: DrawListFlags align(4),
    _Data: ?*const DrawListSharedData,
    _OwnerName: ?[*:0]const u8,
    _VtxCurrentOffset: u32,
    _VtxCurrentIdx: u32,
    _VtxWritePtr: ?[*]DrawVert,
    _IdxWritePtr: ?[*]DrawIdx,
    _ClipRectStack: Vector(Vec4),
    _TextureIdStack: Vector(TextureID),
    _Path: Vector(Vec2),
    _Splitter: DrawListSplitter,

    /// AddBezierCurveExt(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32, thickness: f32, num_segments: i32) void
    pub const AddBezierCurveExt = raw.ImDrawList_AddBezierCurve;
    pub inline fn AddBezierCurve(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32, thickness: f32) void {
        return AddBezierCurveExt(self, p1, p2, p3, p4, col, thickness, 0);
    }

    /// AddCallback(self: *DrawList, callback: DrawCallback, callback_data: ?*c_void) void
    pub const AddCallback = raw.ImDrawList_AddCallback;

    /// AddCircleExt(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32, thickness: f32) void
    pub const AddCircleExt = raw.ImDrawList_AddCircle;
    pub inline fn AddCircle(self: *DrawList, center: Vec2, radius: f32, col: u32) void {
        return AddCircleExt(self, center, radius, col, 12, 1.0);
    }

    /// AddCircleFilledExt(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32) void
    pub const AddCircleFilledExt = raw.ImDrawList_AddCircleFilled;
    pub inline fn AddCircleFilled(self: *DrawList, center: Vec2, radius: f32, col: u32) void {
        return AddCircleFilledExt(self, center, radius, col, 12);
    }

    /// AddConvexPolyFilled(self: *DrawList, points: ?[*]const Vec2, num_points: i32, col: u32) void
    pub const AddConvexPolyFilled = raw.ImDrawList_AddConvexPolyFilled;

    /// AddDrawCmd(self: *DrawList) void
    pub const AddDrawCmd = raw.ImDrawList_AddDrawCmd;

    /// AddImageExt(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2, uv_min: Vec2, uv_max: Vec2, col: u32) void
    pub const AddImageExt = raw.ImDrawList_AddImage;
    pub inline fn AddImage(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2) void {
        return AddImageExt(self, user_texture_id, p_min, p_max, .{.x=0,.y=0}, .{.x=1,.y=1}, 0xFFFFFFFF);
    }

    /// AddImageQuadExt(self: *DrawList, user_texture_id: TextureID, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, uv1: Vec2, uv2: Vec2, uv3: Vec2, uv4: Vec2, col: u32) void
    pub const AddImageQuadExt = raw.ImDrawList_AddImageQuad;
    pub inline fn AddImageQuad(self: *DrawList, user_texture_id: TextureID, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2) void {
        return AddImageQuadExt(self, user_texture_id, p1, p2, p3, p4, .{.x=0,.y=0}, .{.x=1,.y=0}, .{.x=1,.y=1}, .{.x=0,.y=1}, 0xFFFFFFFF);
    }

    pub inline fn AddImageRoundedExt(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2, uv_min: Vec2, uv_max: Vec2, col: u32, rounding: f32, rounding_corners: DrawCornerFlags) void {
        return raw.ImDrawList_AddImageRounded(self, user_texture_id, p_min, p_max, uv_min, uv_max, col, rounding, rounding_corners.toInt());
    }
    pub inline fn AddImageRounded(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2, uv_min: Vec2, uv_max: Vec2, col: u32, rounding: f32) void {
        return AddImageRoundedExt(self, user_texture_id, p_min, p_max, uv_min, uv_max, col, rounding, DrawCornerFlags.All);
    }

    /// AddLineExt(self: *DrawList, p1: Vec2, p2: Vec2, col: u32, thickness: f32) void
    pub const AddLineExt = raw.ImDrawList_AddLine;
    pub inline fn AddLine(self: *DrawList, p1: Vec2, p2: Vec2, col: u32) void {
        return AddLineExt(self, p1, p2, col, 1.0);
    }

    /// AddNgonExt(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32, thickness: f32) void
    pub const AddNgonExt = raw.ImDrawList_AddNgon;
    pub inline fn AddNgon(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32) void {
        return AddNgonExt(self, center, radius, col, num_segments, 1.0);
    }

    /// AddNgonFilled(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32) void
    pub const AddNgonFilled = raw.ImDrawList_AddNgonFilled;

    /// AddPolyline(self: *DrawList, points: ?[*]const Vec2, num_points: i32, col: u32, closed: bool, thickness: f32) void
    pub const AddPolyline = raw.ImDrawList_AddPolyline;

    /// AddQuadExt(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32, thickness: f32) void
    pub const AddQuadExt = raw.ImDrawList_AddQuad;
    pub inline fn AddQuad(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32) void {
        return AddQuadExt(self, p1, p2, p3, p4, col, 1.0);
    }

    /// AddQuadFilled(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32) void
    pub const AddQuadFilled = raw.ImDrawList_AddQuadFilled;

    pub inline fn AddRectExt(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32, rounding: f32, rounding_corners: DrawCornerFlags, thickness: f32) void {
        return raw.ImDrawList_AddRect(self, p_min, p_max, col, rounding, rounding_corners.toInt(), thickness);
    }
    pub inline fn AddRect(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32) void {
        return AddRectExt(self, p_min, p_max, col, 0.0, DrawCornerFlags.All, 1.0);
    }

    pub inline fn AddRectFilledExt(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32, rounding: f32, rounding_corners: DrawCornerFlags) void {
        return raw.ImDrawList_AddRectFilled(self, p_min, p_max, col, rounding, rounding_corners.toInt());
    }
    pub inline fn AddRectFilled(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32) void {
        return AddRectFilledExt(self, p_min, p_max, col, 0.0, DrawCornerFlags.All);
    }

    /// AddRectFilledMultiColor(self: *DrawList, p_min: Vec2, p_max: Vec2, col_upr_left: u32, col_upr_right: u32, col_bot_right: u32, col_bot_left: u32) void
    pub const AddRectFilledMultiColor = raw.ImDrawList_AddRectFilledMultiColor;

    /// AddTextVec2Ext(self: *DrawList, pos: Vec2, col: u32, text_begin: ?[*]const u8, text_end: ?[*]const u8) void
    pub const AddTextVec2Ext = raw.ImDrawList_AddTextVec2;
    pub inline fn AddTextVec2(self: *DrawList, pos: Vec2, col: u32, text_begin: ?[*]const u8) void {
        return AddTextVec2Ext(self, pos, col, text_begin, null);
    }

    /// AddTextFontPtrExt(self: *DrawList, font: ?*const Font, font_size: f32, pos: Vec2, col: u32, text_begin: ?[*]const u8, text_end: ?[*]const u8, wrap_width: f32, cpu_fine_clip_rect: ?*const Vec4) void
    pub const AddTextFontPtrExt = raw.ImDrawList_AddTextFontPtr;
    pub inline fn AddTextFontPtr(self: *DrawList, font: ?*const Font, font_size: f32, pos: Vec2, col: u32, text_begin: ?[*]const u8) void {
        return AddTextFontPtrExt(self, font, font_size, pos, col, text_begin, null, 0.0, null);
    }

    /// AddTriangleExt(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32, thickness: f32) void
    pub const AddTriangleExt = raw.ImDrawList_AddTriangle;
    pub inline fn AddTriangle(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32) void {
        return AddTriangleExt(self, p1, p2, p3, col, 1.0);
    }

    /// AddTriangleFilled(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32) void
    pub const AddTriangleFilled = raw.ImDrawList_AddTriangleFilled;

    /// ChannelsMerge(self: *DrawList) void
    pub const ChannelsMerge = raw.ImDrawList_ChannelsMerge;

    /// ChannelsSetCurrent(self: *DrawList, n: i32) void
    pub const ChannelsSetCurrent = raw.ImDrawList_ChannelsSetCurrent;

    /// ChannelsSplit(self: *DrawList, count: i32) void
    pub const ChannelsSplit = raw.ImDrawList_ChannelsSplit;

    /// Clear(self: *DrawList) void
    pub const Clear = raw.ImDrawList_Clear;

    /// ClearFreeMemory(self: *DrawList) void
    pub const ClearFreeMemory = raw.ImDrawList_ClearFreeMemory;

    /// CloneOutput(self: *const DrawList) ?*DrawList
    pub const CloneOutput = raw.ImDrawList_CloneOutput;

    pub inline fn GetClipRectMax(self: *const DrawList) Vec2 {
        var out: Vec2 = undefined;
        raw.ImDrawList_GetClipRectMax_nonUDT(&out, self);
        return out;
    }

    pub inline fn GetClipRectMin(self: *const DrawList) Vec2 {
        var out: Vec2 = undefined;
        raw.ImDrawList_GetClipRectMin_nonUDT(&out, self);
        return out;
    }

    /// init(self: *DrawList, shared_data: ?*const DrawListSharedData) void
    pub const init = raw.ImDrawList_ImDrawList;

    /// PathArcToExt(self: *DrawList, center: Vec2, radius: f32, a_min: f32, a_max: f32, num_segments: i32) void
    pub const PathArcToExt = raw.ImDrawList_PathArcTo;
    pub inline fn PathArcTo(self: *DrawList, center: Vec2, radius: f32, a_min: f32, a_max: f32) void {
        return PathArcToExt(self, center, radius, a_min, a_max, 10);
    }

    /// PathArcToFast(self: *DrawList, center: Vec2, radius: f32, a_min_of_12: i32, a_max_of_12: i32) void
    pub const PathArcToFast = raw.ImDrawList_PathArcToFast;

    /// PathBezierCurveToExt(self: *DrawList, p2: Vec2, p3: Vec2, p4: Vec2, num_segments: i32) void
    pub const PathBezierCurveToExt = raw.ImDrawList_PathBezierCurveTo;
    pub inline fn PathBezierCurveTo(self: *DrawList, p2: Vec2, p3: Vec2, p4: Vec2) void {
        return PathBezierCurveToExt(self, p2, p3, p4, 0);
    }

    /// PathClear(self: *DrawList) void
    pub const PathClear = raw.ImDrawList_PathClear;

    /// PathFillConvex(self: *DrawList, col: u32) void
    pub const PathFillConvex = raw.ImDrawList_PathFillConvex;

    /// PathLineTo(self: *DrawList, pos: Vec2) void
    pub const PathLineTo = raw.ImDrawList_PathLineTo;

    /// PathLineToMergeDuplicate(self: *DrawList, pos: Vec2) void
    pub const PathLineToMergeDuplicate = raw.ImDrawList_PathLineToMergeDuplicate;

    pub inline fn PathRectExt(self: *DrawList, rect_min: Vec2, rect_max: Vec2, rounding: f32, rounding_corners: DrawCornerFlags) void {
        return raw.ImDrawList_PathRect(self, rect_min, rect_max, rounding, rounding_corners.toInt());
    }
    pub inline fn PathRect(self: *DrawList, rect_min: Vec2, rect_max: Vec2) void {
        return PathRectExt(self, rect_min, rect_max, 0.0, DrawCornerFlags.All);
    }

    /// PathStrokeExt(self: *DrawList, col: u32, closed: bool, thickness: f32) void
    pub const PathStrokeExt = raw.ImDrawList_PathStroke;
    pub inline fn PathStroke(self: *DrawList, col: u32, closed: bool) void {
        return PathStrokeExt(self, col, closed, 1.0);
    }

    /// PopClipRect(self: *DrawList) void
    pub const PopClipRect = raw.ImDrawList_PopClipRect;

    /// PopTextureID(self: *DrawList) void
    pub const PopTextureID = raw.ImDrawList_PopTextureID;

    /// PrimQuadUV(self: *DrawList, a: Vec2, b: Vec2, c: Vec2, d: Vec2, uv_a: Vec2, uv_b: Vec2, uv_c: Vec2, uv_d: Vec2, col: u32) void
    pub const PrimQuadUV = raw.ImDrawList_PrimQuadUV;

    /// PrimRect(self: *DrawList, a: Vec2, b: Vec2, col: u32) void
    pub const PrimRect = raw.ImDrawList_PrimRect;

    /// PrimRectUV(self: *DrawList, a: Vec2, b: Vec2, uv_a: Vec2, uv_b: Vec2, col: u32) void
    pub const PrimRectUV = raw.ImDrawList_PrimRectUV;

    /// PrimReserve(self: *DrawList, idx_count: i32, vtx_count: i32) void
    pub const PrimReserve = raw.ImDrawList_PrimReserve;

    /// PrimUnreserve(self: *DrawList, idx_count: i32, vtx_count: i32) void
    pub const PrimUnreserve = raw.ImDrawList_PrimUnreserve;

    /// PrimVtx(self: *DrawList, pos: Vec2, uv: Vec2, col: u32) void
    pub const PrimVtx = raw.ImDrawList_PrimVtx;

    /// PrimWriteIdx(self: *DrawList, idx: DrawIdx) void
    pub const PrimWriteIdx = raw.ImDrawList_PrimWriteIdx;

    /// PrimWriteVtx(self: *DrawList, pos: Vec2, uv: Vec2, col: u32) void
    pub const PrimWriteVtx = raw.ImDrawList_PrimWriteVtx;

    /// PushClipRectExt(self: *DrawList, clip_rect_min: Vec2, clip_rect_max: Vec2, intersect_with_current_clip_rect: bool) void
    pub const PushClipRectExt = raw.ImDrawList_PushClipRect;
    pub inline fn PushClipRect(self: *DrawList, clip_rect_min: Vec2, clip_rect_max: Vec2) void {
        return PushClipRectExt(self, clip_rect_min, clip_rect_max, false);
    }

    /// PushClipRectFullScreen(self: *DrawList) void
    pub const PushClipRectFullScreen = raw.ImDrawList_PushClipRectFullScreen;

    /// PushTextureID(self: *DrawList, texture_id: TextureID) void
    pub const PushTextureID = raw.ImDrawList_PushTextureID;

    /// UpdateClipRect(self: *DrawList) void
    pub const UpdateClipRect = raw.ImDrawList_UpdateClipRect;

    /// UpdateTextureID(self: *DrawList) void
    pub const UpdateTextureID = raw.ImDrawList_UpdateTextureID;

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

    /// init(self: *DrawListSplitter) void
    pub const init = raw.ImDrawListSplitter_ImDrawListSplitter;

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
    DisplayOffset: Vec2,
    ContainerAtlas: ?*FontAtlas,
    ConfigData: ?*const FontConfig,
    ConfigDataCount: i16,
    FallbackChar: Wchar,
    EllipsisChar: Wchar,
    DirtyLookupTables: bool,
    Scale: f32,
    Ascent: f32,
    Descent: f32,
    MetricsTotalSurface: i32,

    /// AddGlyph(self: *Font, c: Wchar, x0: f32, y0: f32, x1: f32, y1: f32, u0: f32, v0: f32, u1: f32, v1: f32, advance_x: f32) void
    pub const AddGlyph = raw.ImFont_AddGlyph;

    /// AddRemapCharExt(self: *Font, dst: Wchar, src: Wchar, overwrite_dst: bool) void
    pub const AddRemapCharExt = raw.ImFont_AddRemapChar;
    pub inline fn AddRemapChar(self: *Font, dst: Wchar, src: Wchar) void {
        return AddRemapCharExt(self, dst, src, true);
    }

    /// BuildLookupTable(self: *Font) void
    pub const BuildLookupTable = raw.ImFont_BuildLookupTable;

    pub inline fn CalcTextSizeAExt(self: *const Font, size: f32, max_width: f32, wrap_width: f32, text_begin: ?[*]const u8, text_end: ?[*]const u8, remaining: ?*?[*:0]const u8) Vec2 {
        var out: Vec2 = undefined;
        raw.ImFont_CalcTextSizeA_nonUDT(&out, self, size, max_width, wrap_width, text_begin, text_end, remaining);
        return out;
    }
    pub inline fn CalcTextSizeA(self: *const Font, size: f32, max_width: f32, wrap_width: f32, text_begin: ?[*]const u8) Vec2 {
        return CalcTextSizeAExt(self, size, max_width, wrap_width, text_begin, null, null);
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

    /// init(self: *Font) void
    pub const init = raw.ImFont_ImFont;

    /// IsLoaded(self: *const Font) bool
    pub const IsLoaded = raw.ImFont_IsLoaded;

    /// RenderChar(self: *const Font, draw_list: ?*DrawList, size: f32, pos: Vec2, col: u32, c: Wchar) void
    pub const RenderChar = raw.ImFont_RenderChar;

    /// RenderTextExt(self: *const Font, draw_list: ?*DrawList, size: f32, pos: Vec2, col: u32, clip_rect: Vec4, text_begin: ?[*]const u8, text_end: ?[*]const u8, wrap_width: f32, cpu_fine_clip: bool) void
    pub const RenderTextExt = raw.ImFont_RenderText;
    pub inline fn RenderText(self: *const Font, draw_list: ?*DrawList, size: f32, pos: Vec2, col: u32, clip_rect: Vec4, text_begin: ?[*]const u8, text_end: ?[*]const u8) void {
        return RenderTextExt(self, draw_list, size, pos, col, clip_rect, text_begin, text_end, 0.0, false);
    }

    /// SetFallbackChar(self: *Font, c: Wchar) void
    pub const SetFallbackChar = raw.ImFont_SetFallbackChar;

    /// deinit(self: *Font) void
    pub const deinit = raw.ImFont_destroy;
};

pub const FontAtlas = extern struct {
    Locked: bool,
    Flags: FontAtlasFlags align(4),
    TexID: TextureID,
    TexDesiredWidth: i32,
    TexGlyphPadding: i32,
    TexPixelsAlpha8: ?[*]u8,
    TexPixelsRGBA32: ?[*]u32,
    TexWidth: i32,
    TexHeight: i32,
    TexUvScale: Vec2,
    TexUvWhitePixel: Vec2,
    Fonts: Vector(*Font),
    CustomRects: Vector(FontAtlasCustomRect),
    ConfigData: Vector(FontConfig),
    CustomRectIds: [1]i32,

    /// AddCustomRectFontGlyphExt(self: *FontAtlas, font: ?*Font, id: Wchar, width: i32, height: i32, advance_x: f32, offset: Vec2) i32
    pub const AddCustomRectFontGlyphExt = raw.ImFontAtlas_AddCustomRectFontGlyph;
    pub inline fn AddCustomRectFontGlyph(self: *FontAtlas, font: ?*Font, id: Wchar, width: i32, height: i32, advance_x: f32) i32 {
        return AddCustomRectFontGlyphExt(self, font, id, width, height, advance_x, .{.x=0,.y=0});
    }

    /// AddCustomRectRegular(self: *FontAtlas, id: u32, width: i32, height: i32) i32
    pub const AddCustomRectRegular = raw.ImFontAtlas_AddCustomRectRegular;

    /// AddFont(self: *FontAtlas, font_cfg: ?*const FontConfig) ?*Font
    pub const AddFont = raw.ImFontAtlas_AddFont;

    /// AddFontDefaultExt(self: *FontAtlas, font_cfg: ?*const FontConfig) ?*Font
    pub const AddFontDefaultExt = raw.ImFontAtlas_AddFontDefault;
    pub inline fn AddFontDefault(self: *FontAtlas) ?*Font {
        return AddFontDefaultExt(self, null);
    }

    /// AddFontFromFileTTFExt(self: *FontAtlas, filename: ?[*:0]const u8, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) ?*Font
    pub const AddFontFromFileTTFExt = raw.ImFontAtlas_AddFontFromFileTTF;
    pub inline fn AddFontFromFileTTF(self: *FontAtlas, filename: ?[*:0]const u8, size_pixels: f32) ?*Font {
        return AddFontFromFileTTFExt(self, filename, size_pixels, null, null);
    }

    /// AddFontFromMemoryCompressedBase85TTFExt(self: *FontAtlas, compressed_font_data_base85: ?[*]const u8, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) ?*Font
    pub const AddFontFromMemoryCompressedBase85TTFExt = raw.ImFontAtlas_AddFontFromMemoryCompressedBase85TTF;
    pub inline fn AddFontFromMemoryCompressedBase85TTF(self: *FontAtlas, compressed_font_data_base85: ?[*]const u8, size_pixels: f32) ?*Font {
        return AddFontFromMemoryCompressedBase85TTFExt(self, compressed_font_data_base85, size_pixels, null, null);
    }

    /// AddFontFromMemoryCompressedTTFExt(self: *FontAtlas, compressed_font_data: ?*const c_void, compressed_font_size: i32, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) ?*Font
    pub const AddFontFromMemoryCompressedTTFExt = raw.ImFontAtlas_AddFontFromMemoryCompressedTTF;
    pub inline fn AddFontFromMemoryCompressedTTF(self: *FontAtlas, compressed_font_data: ?*const c_void, compressed_font_size: i32, size_pixels: f32) ?*Font {
        return AddFontFromMemoryCompressedTTFExt(self, compressed_font_data, compressed_font_size, size_pixels, null, null);
    }

    /// AddFontFromMemoryTTFExt(self: *FontAtlas, font_data: ?*c_void, font_size: i32, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) ?*Font
    pub const AddFontFromMemoryTTFExt = raw.ImFontAtlas_AddFontFromMemoryTTF;
    pub inline fn AddFontFromMemoryTTF(self: *FontAtlas, font_data: ?*c_void, font_size: i32, size_pixels: f32) ?*Font {
        return AddFontFromMemoryTTFExt(self, font_data, font_size, size_pixels, null, null);
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

    /// GetCustomRectByIndex(self: *const FontAtlas, index: i32) ?*const FontAtlasCustomRect
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
        return GetTexDataAsAlpha8Ext(self, out_pixels, out_width, out_height, null);
    }

    /// GetTexDataAsRGBA32Ext(self: *FontAtlas, out_pixels: *?[*]u8, out_width: *i32, out_height: *i32, out_bytes_per_pixel: ?*i32) void
    pub const GetTexDataAsRGBA32Ext = raw.ImFontAtlas_GetTexDataAsRGBA32;
    pub inline fn GetTexDataAsRGBA32(self: *FontAtlas, out_pixels: *?[*]u8, out_width: *i32, out_height: *i32) void {
        return GetTexDataAsRGBA32Ext(self, out_pixels, out_width, out_height, null);
    }

    /// init(self: *FontAtlas) void
    pub const init = raw.ImFontAtlas_ImFontAtlas;

    /// IsBuilt(self: *const FontAtlas) bool
    pub const IsBuilt = raw.ImFontAtlas_IsBuilt;

    /// SetTexID(self: *FontAtlas, id: TextureID) void
    pub const SetTexID = raw.ImFontAtlas_SetTexID;

    /// deinit(self: *FontAtlas) void
    pub const deinit = raw.ImFontAtlas_destroy;
};

pub const FontAtlasCustomRect = extern struct {
    ID: u32,
    Width: u16,
    Height: u16,
    X: u16,
    Y: u16,
    GlyphAdvanceX: f32,
    GlyphOffset: Vec2,
    Font: ?*Font,

    /// init(self: *FontAtlasCustomRect) void
    pub const init = raw.ImFontAtlasCustomRect_ImFontAtlasCustomRect;

    /// IsPacked(self: *const FontAtlasCustomRect) bool
    pub const IsPacked = raw.ImFontAtlasCustomRect_IsPacked;

    /// deinit(self: *FontAtlasCustomRect) void
    pub const deinit = raw.ImFontAtlasCustomRect_destroy;
};

pub const FontConfig = extern struct {
    FontData: ?*c_void,
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
    RasterizerFlags: u32,
    RasterizerMultiply: f32,
    EllipsisChar: Wchar,
    Name: [40]u8,
    DstFont: ?*Font,

    /// init(self: *FontConfig) void
    pub const init = raw.ImFontConfig_ImFontConfig;

    /// deinit(self: *FontConfig) void
    pub const deinit = raw.ImFontConfig_destroy;
};

pub const FontGlyph = extern struct {
    Codepoint: Wchar,
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
        return AddTextExt(self, text, null);
    }

    /// BuildRanges(self: *FontGlyphRangesBuilder, out_ranges: *Vector(Wchar)) void
    pub const BuildRanges = raw.ImFontGlyphRangesBuilder_BuildRanges;

    /// Clear(self: *FontGlyphRangesBuilder) void
    pub const Clear = raw.ImFontGlyphRangesBuilder_Clear;

    /// GetBit(self: *const FontGlyphRangesBuilder, n: i32) bool
    pub const GetBit = raw.ImFontGlyphRangesBuilder_GetBit;

    /// init(self: *FontGlyphRangesBuilder) void
    pub const init = raw.ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder;

    /// SetBit(self: *FontGlyphRangesBuilder, n: i32) void
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
    KeyMap: [Key.COUNT]i32,
    KeyRepeatDelay: f32,
    KeyRepeatRate: f32,
    UserData: ?*c_void,
    Fonts: ?*FontAtlas,
    FontGlobalScale: f32,
    FontAllowUserScaling: bool,
    FontDefault: ?*Font,
    DisplayFramebufferScale: Vec2,
    MouseDrawCursor: bool,
    ConfigMacOSXBehaviors: bool,
    ConfigInputTextCursorBlink: bool,
    ConfigWindowsResizeFromEdges: bool,
    ConfigWindowsMoveFromTitleBarOnly: bool,
    ConfigWindowsMemoryCompactTimer: f32,
    BackendPlatformName: ?[*:0]const u8,
    BackendRendererName: ?[*:0]const u8,
    BackendPlatformUserData: ?*c_void,
    BackendRendererUserData: ?*c_void,
    BackendLanguageUserData: ?*c_void,
    GetClipboardTextFn: ?fn (user_data: ?*c_void) callconv(.C) ?[*:0]const u8,
    SetClipboardTextFn: ?fn (user_data: ?*c_void, text: ?[*:0]const u8) callconv(.C) void,
    ClipboardUserData: ?*c_void,
    ImeSetInputScreenPosFn: ?fn (x: i32, y: i32) callconv(.C) void,
    ImeWindowHandle: ?*c_void,
    RenderDrawListsFnUnused: ?*c_void,
    MousePos: Vec2,
    MouseDown: [5]bool,
    MouseWheel: f32,
    MouseWheelH: f32,
    KeyCtrl: bool,
    KeyShift: bool,
    KeyAlt: bool,
    KeySuper: bool,
    KeysDown: [512]bool,
    NavInputs: [NavInput.COUNT]f32,
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
    MousePosPrev: Vec2,
    MouseClickedPos: [5]Vec2,
    MouseClickedTime: [5]f64,
    MouseClicked: [5]bool,
    MouseDoubleClicked: [5]bool,
    MouseReleased: [5]bool,
    MouseDownOwned: [5]bool,
    MouseDownWasDoubleClick: [5]bool,
    MouseDownDuration: [5]f32,
    MouseDownDurationPrev: [5]f32,
    MouseDragMaxDistanceAbs: [5]Vec2,
    MouseDragMaxDistanceSqr: [5]f32,
    KeysDownDuration: [512]f32,
    KeysDownDurationPrev: [512]f32,
    NavInputsDownDuration: [NavInput.COUNT]f32,
    NavInputsDownDurationPrev: [NavInput.COUNT]f32,
    InputQueueCharacters: Vector(Wchar),

    /// AddInputCharacter(self: *IO, c: u32) void
    pub const AddInputCharacter = raw.ImGuiIO_AddInputCharacter;

    /// AddInputCharactersUTF8(self: *IO, str: ?[*:0]const u8) void
    pub const AddInputCharactersUTF8 = raw.ImGuiIO_AddInputCharactersUTF8;

    /// ClearInputCharacters(self: *IO) void
    pub const ClearInputCharacters = raw.ImGuiIO_ClearInputCharacters;

    /// init(self: *IO) void
    pub const init = raw.ImGuiIO_ImGuiIO;

    /// deinit(self: *IO) void
    pub const deinit = raw.ImGuiIO_destroy;
};

pub const InputTextCallbackData = extern struct {
    EventFlag: InputTextFlags align(4),
    Flags: InputTextFlags align(4),
    UserData: ?*c_void,
    EventChar: Wchar,
    EventKey: Key,
    Buf: ?[*]u8,
    BufTextLen: i32,
    BufSize: i32,
    BufDirty: bool,
    CursorPos: i32,
    SelectionStart: i32,
    SelectionEnd: i32,

    /// DeleteChars(self: *InputTextCallbackData, pos: i32, bytes_count: i32) void
    pub const DeleteChars = raw.ImGuiInputTextCallbackData_DeleteChars;

    /// HasSelection(self: *const InputTextCallbackData) bool
    pub const HasSelection = raw.ImGuiInputTextCallbackData_HasSelection;

    /// init(self: *InputTextCallbackData) void
    pub const init = raw.ImGuiInputTextCallbackData_ImGuiInputTextCallbackData;

    /// InsertCharsExt(self: *InputTextCallbackData, pos: i32, text: ?[*]const u8, text_end: ?[*]const u8) void
    pub const InsertCharsExt = raw.ImGuiInputTextCallbackData_InsertChars;
    pub inline fn InsertChars(self: *InputTextCallbackData, pos: i32, text: ?[*]const u8) void {
        return InsertCharsExt(self, pos, text, null);
    }

    /// deinit(self: *InputTextCallbackData) void
    pub const deinit = raw.ImGuiInputTextCallbackData_destroy;
};

pub const ListClipper = extern struct {
    DisplayStart: i32,
    DisplayEnd: i32,
    ItemsCount: i32,
    StepNo: i32,
    ItemsHeight: f32,
    StartPosY: f32,

    /// BeginExt(self: *ListClipper, items_count: i32, items_height: f32) void
    pub const BeginExt = raw.ImGuiListClipper_Begin;
    pub inline fn Begin(self: *ListClipper, items_count: i32) void {
        return BeginExt(self, items_count, -1.0);
    }

    /// End(self: *ListClipper) void
    pub const End = raw.ImGuiListClipper_End;

    /// initExt(self: *ListClipper, items_count: i32, items_height: f32) void
    pub const initExt = raw.ImGuiListClipper_ImGuiListClipper;
    pub inline fn init(self: *ListClipper) void {
        return initExt(self, -1, -1.0);
    }

    /// Step(self: *ListClipper) bool
    pub const Step = raw.ImGuiListClipper_Step;

    /// deinit(self: *ListClipper) void
    pub const deinit = raw.ImGuiListClipper_destroy;
};

pub const OnceUponAFrame = extern struct {
    RefFrame: i32,

    /// init(self: *OnceUponAFrame) void
    pub const init = raw.ImGuiOnceUponAFrame_ImGuiOnceUponAFrame;

    /// deinit(self: *OnceUponAFrame) void
    pub const deinit = raw.ImGuiOnceUponAFrame_destroy;
};

pub const Payload = extern struct {
    Data: ?*c_void,
    DataSize: i32,
    SourceId: ID,
    SourceParentId: ID,
    DataFrameCount: i32,
    DataType: [32+1]u8,
    Preview: bool,
    Delivery: bool,

    /// Clear(self: *Payload) void
    pub const Clear = raw.ImGuiPayload_Clear;

    /// init(self: *Payload) void
    pub const init = raw.ImGuiPayload_ImGuiPayload;

    /// IsDataType(self: *const Payload, kind: ?[*:0]const u8) bool
    pub const IsDataType = raw.ImGuiPayload_IsDataType;

    /// IsDelivery(self: *const Payload) bool
    pub const IsDelivery = raw.ImGuiPayload_IsDelivery;

    /// IsPreview(self: *const Payload) bool
    pub const IsPreview = raw.ImGuiPayload_IsPreview;

    /// deinit(self: *Payload) void
    pub const deinit = raw.ImGuiPayload_destroy;
};

pub const SizeCallbackData = extern struct {
    UserData: ?*c_void,
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
        return GetBoolExt(self, key, false);
    }

    /// GetBoolRefExt(self: *Storage, key: ID, default_val: bool) ?*bool
    pub const GetBoolRefExt = raw.ImGuiStorage_GetBoolRef;
    pub inline fn GetBoolRef(self: *Storage, key: ID) ?*bool {
        return GetBoolRefExt(self, key, false);
    }

    /// GetFloatExt(self: *const Storage, key: ID, default_val: f32) f32
    pub const GetFloatExt = raw.ImGuiStorage_GetFloat;
    pub inline fn GetFloat(self: *const Storage, key: ID) f32 {
        return GetFloatExt(self, key, 0.0);
    }

    /// GetFloatRefExt(self: *Storage, key: ID, default_val: f32) ?*f32
    pub const GetFloatRefExt = raw.ImGuiStorage_GetFloatRef;
    pub inline fn GetFloatRef(self: *Storage, key: ID) ?*f32 {
        return GetFloatRefExt(self, key, 0.0);
    }

    /// GetIntExt(self: *const Storage, key: ID, default_val: i32) i32
    pub const GetIntExt = raw.ImGuiStorage_GetInt;
    pub inline fn GetInt(self: *const Storage, key: ID) i32 {
        return GetIntExt(self, key, 0);
    }

    /// GetIntRefExt(self: *Storage, key: ID, default_val: i32) ?*i32
    pub const GetIntRefExt = raw.ImGuiStorage_GetIntRef;
    pub inline fn GetIntRef(self: *Storage, key: ID) ?*i32 {
        return GetIntRefExt(self, key, 0);
    }

    /// GetVoidPtr(self: *const Storage, key: ID) ?*c_void
    pub const GetVoidPtr = raw.ImGuiStorage_GetVoidPtr;

    /// GetVoidPtrRefExt(self: *Storage, key: ID, default_val: ?*c_void) ?*?*c_void
    pub const GetVoidPtrRefExt = raw.ImGuiStorage_GetVoidPtrRef;
    pub inline fn GetVoidPtrRef(self: *Storage, key: ID) ?*?*c_void {
        return GetVoidPtrRefExt(self, key, null);
    }

    /// SetAllInt(self: *Storage, val: i32) void
    pub const SetAllInt = raw.ImGuiStorage_SetAllInt;

    /// SetBool(self: *Storage, key: ID, val: bool) void
    pub const SetBool = raw.ImGuiStorage_SetBool;

    /// SetFloat(self: *Storage, key: ID, val: f32) void
    pub const SetFloat = raw.ImGuiStorage_SetFloat;

    /// SetInt(self: *Storage, key: ID, val: i32) void
    pub const SetInt = raw.ImGuiStorage_SetInt;

    /// SetVoidPtr(self: *Storage, key: ID, val: ?*c_void) void
    pub const SetVoidPtr = raw.ImGuiStorage_SetVoidPtr;
};

pub const StoragePair = extern struct {
    key: ID,
    value: extern union { val_i: i32, val_f: f32, val_p: ?*c_void },

    /// initInt(self: *StoragePair, _key: ID, _val_i: i32) void
    pub const initInt = raw.ImGuiStoragePair_ImGuiStoragePairInt;

    /// initFloat(self: *StoragePair, _key: ID, _val_f: f32) void
    pub const initFloat = raw.ImGuiStoragePair_ImGuiStoragePairFloat;

    /// initPtr(self: *StoragePair, _key: ID, _val_p: ?*c_void) void
    pub const initPtr = raw.ImGuiStoragePair_ImGuiStoragePairPtr;

    /// deinit(self: *StoragePair) void
    pub const deinit = raw.ImGuiStoragePair_destroy;
};

pub const Style = extern struct {
    Alpha: f32,
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
    TouchExtraPadding: Vec2,
    IndentSpacing: f32,
    ColumnsMinSpacing: f32,
    ScrollbarSize: f32,
    ScrollbarRounding: f32,
    GrabMinSize: f32,
    GrabRounding: f32,
    TabRounding: f32,
    TabBorderSize: f32,
    ColorButtonPosition: Dir,
    ButtonTextAlign: Vec2,
    SelectableTextAlign: Vec2,
    DisplayWindowPadding: Vec2,
    DisplaySafeAreaPadding: Vec2,
    MouseCursorScale: f32,
    AntiAliasedLines: bool,
    AntiAliasedFill: bool,
    CurveTessellationTol: f32,
    CircleSegmentMaxError: f32,
    Colors: [Col.COUNT]Vec4,

    /// init(self: *Style) void
    pub const init = raw.ImGuiStyle_ImGuiStyle;

    /// ScaleAllSizes(self: *Style, scale_factor: f32) void
    pub const ScaleAllSizes = raw.ImGuiStyle_ScaleAllSizes;

    /// deinit(self: *Style) void
    pub const deinit = raw.ImGuiStyle_destroy;
};

pub const TextBuffer = extern struct {
    Buf: Vector(u8),

    /// init(self: *TextBuffer) void
    pub const init = raw.ImGuiTextBuffer_ImGuiTextBuffer;

    /// appendExt(self: *TextBuffer, str: ?[*]const u8, str_end: ?[*]const u8) void
    pub const appendExt = raw.ImGuiTextBuffer_append;
    pub inline fn append(self: *TextBuffer, str: ?[*]const u8) void {
        return appendExt(self, str, null);
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
        return DrawExt(self, "Filter(inc,-exc)", 0.0);
    }

    /// initExt(self: *TextFilter, default_filter: ?[*:0]const u8) void
    pub const initExt = raw.ImGuiTextFilter_ImGuiTextFilter;
    pub inline fn init(self: *TextFilter) void {
        return initExt(self, "");
    }

    /// IsActive(self: *const TextFilter) bool
    pub const IsActive = raw.ImGuiTextFilter_IsActive;

    /// PassFilterExt(self: *const TextFilter, text: ?[*]const u8, text_end: ?[*]const u8) bool
    pub const PassFilterExt = raw.ImGuiTextFilter_PassFilter;
    pub inline fn PassFilter(self: *const TextFilter, text: ?[*]const u8) bool {
        return PassFilterExt(self, text, null);
    }

    /// deinit(self: *TextFilter) void
    pub const deinit = raw.ImGuiTextFilter_destroy;
};

pub const TextRange = extern struct {
    b: ?[*]const u8,
    e: ?[*]const u8,

    /// init(self: *TextRange) void
    pub const init = raw.ImGuiTextRange_ImGuiTextRange;

    /// initStr(self: *TextRange, _b: ?[*]const u8, _e: ?[*]const u8) void
    pub const initStr = raw.ImGuiTextRange_ImGuiTextRangeStr;

    /// deinit(self: *TextRange) void
    pub const deinit = raw.ImGuiTextRange_destroy;

    /// empty(self: *const TextRange) bool
    pub const empty = raw.ImGuiTextRange_empty;

    /// split(self: *const TextRange, separator: u8, out: ?*Vector(TextRange)) void
    pub const split = raw.ImGuiTextRange_split;
};

pub const Vec2 = extern struct {
    x: f32,
    y: f32,

    /// init(self: *Vec2) void
    pub const init = raw.ImVec2_ImVec2;

    /// initFloat(self: *Vec2, _x: f32, _y: f32) void
    pub const initFloat = raw.ImVec2_ImVec2Float;

    /// deinit(self: *Vec2) void
    pub const deinit = raw.ImVec2_destroy;
};

pub const Vec4 = extern struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,

    /// init(self: *Vec4) void
    pub const init = raw.ImVec4_ImVec4;

    /// initFloat(self: *Vec4, _x: f32, _y: f32, _z: f32, _w: f32) void
    pub const initFloat = raw.ImVec4_ImVec4Float;

    /// deinit(self: *Vec4) void
    pub const deinit = raw.ImVec4_destroy;
};

const FTABLE_ImVector_ImDrawChannel = struct {
    /// init(self: *Vector(DrawChannel)) void
    pub const init = raw.ImVector_ImDrawChannel_ImVector_ImDrawChannel;
    /// initVector(self: *Vector(DrawChannel), src: Vector(DrawChannel)) void
    pub const initVector = raw.ImVector_ImDrawChannel_ImVector_ImDrawChannelVector;
    /// _grow_capacity(self: *const Vector(DrawChannel), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImDrawChannel__grow_capacity;
    /// back(self: *Vector(DrawChannel)) *DrawChannel
    pub const back = raw.ImVector_ImDrawChannel_back;
    /// back_const(self: *const Vector(DrawChannel)) *const DrawChannel
    pub const back_const = raw.ImVector_ImDrawChannel_back_const;
    /// begin(self: *Vector(DrawChannel)) [*]DrawChannel
    pub const begin = raw.ImVector_ImDrawChannel_begin;
    /// begin_const(self: *const Vector(DrawChannel)) [*]const DrawChannel
    pub const begin_const = raw.ImVector_ImDrawChannel_begin_const;
    /// capacity(self: *const Vector(DrawChannel)) i32
    pub const capacity = raw.ImVector_ImDrawChannel_capacity;
    /// clear(self: *Vector(DrawChannel)) void
    pub const clear = raw.ImVector_ImDrawChannel_clear;
    /// deinit(self: *Vector(DrawChannel)) void
    pub const deinit = raw.ImVector_ImDrawChannel_destroy;
    /// empty(self: *const Vector(DrawChannel)) bool
    pub const empty = raw.ImVector_ImDrawChannel_empty;
    /// end(self: *Vector(DrawChannel)) [*]DrawChannel
    pub const end = raw.ImVector_ImDrawChannel_end;
    /// end_const(self: *const Vector(DrawChannel)) [*]const DrawChannel
    pub const end_const = raw.ImVector_ImDrawChannel_end_const;
    /// erase(self: *Vector(DrawChannel), it: [*]const DrawChannel) [*]DrawChannel
    pub const erase = raw.ImVector_ImDrawChannel_erase;
    /// eraseTPtr(self: *Vector(DrawChannel), it: [*]const DrawChannel, it_last: [*]const DrawChannel) [*]DrawChannel
    pub const eraseTPtr = raw.ImVector_ImDrawChannel_eraseTPtr;
    /// erase_unsorted(self: *Vector(DrawChannel), it: [*]const DrawChannel) [*]DrawChannel
    pub const erase_unsorted = raw.ImVector_ImDrawChannel_erase_unsorted;
    /// front(self: *Vector(DrawChannel)) *DrawChannel
    pub const front = raw.ImVector_ImDrawChannel_front;
    /// front_const(self: *const Vector(DrawChannel)) *const DrawChannel
    pub const front_const = raw.ImVector_ImDrawChannel_front_const;
    /// index_from_ptr(self: *const Vector(DrawChannel), it: [*]const DrawChannel) i32
    pub const index_from_ptr = raw.ImVector_ImDrawChannel_index_from_ptr;
    /// insert(self: *Vector(DrawChannel), it: [*]const DrawChannel, v: DrawChannel) [*]DrawChannel
    pub const insert = raw.ImVector_ImDrawChannel_insert;
    /// pop_back(self: *Vector(DrawChannel)) void
    pub const pop_back = raw.ImVector_ImDrawChannel_pop_back;
    /// push_back(self: *Vector(DrawChannel), v: DrawChannel) void
    pub const push_back = raw.ImVector_ImDrawChannel_push_back;
    /// push_front(self: *Vector(DrawChannel), v: DrawChannel) void
    pub const push_front = raw.ImVector_ImDrawChannel_push_front;
    /// reserve(self: *Vector(DrawChannel), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImDrawChannel_reserve;
    /// resize(self: *Vector(DrawChannel), new_size: i32) void
    pub const resize = raw.ImVector_ImDrawChannel_resize;
    /// resizeT(self: *Vector(DrawChannel), new_size: i32, v: DrawChannel) void
    pub const resizeT = raw.ImVector_ImDrawChannel_resizeT;
    /// shrink(self: *Vector(DrawChannel), new_size: i32) void
    pub const shrink = raw.ImVector_ImDrawChannel_shrink;
    /// size(self: *const Vector(DrawChannel)) i32
    pub const size = raw.ImVector_ImDrawChannel_size;
    /// size_in_bytes(self: *const Vector(DrawChannel)) i32
    pub const size_in_bytes = raw.ImVector_ImDrawChannel_size_in_bytes;
    /// swap(self: *Vector(DrawChannel), rhs: *Vector(DrawChannel)) void
    pub const swap = raw.ImVector_ImDrawChannel_swap;
};

const FTABLE_ImVector_ImDrawCmd = struct {
    /// init(self: *Vector(DrawCmd)) void
    pub const init = raw.ImVector_ImDrawCmd_ImVector_ImDrawCmd;
    /// initVector(self: *Vector(DrawCmd), src: Vector(DrawCmd)) void
    pub const initVector = raw.ImVector_ImDrawCmd_ImVector_ImDrawCmdVector;
    /// _grow_capacity(self: *const Vector(DrawCmd), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImDrawCmd__grow_capacity;
    /// back(self: *Vector(DrawCmd)) *DrawCmd
    pub const back = raw.ImVector_ImDrawCmd_back;
    /// back_const(self: *const Vector(DrawCmd)) *const DrawCmd
    pub const back_const = raw.ImVector_ImDrawCmd_back_const;
    /// begin(self: *Vector(DrawCmd)) [*]DrawCmd
    pub const begin = raw.ImVector_ImDrawCmd_begin;
    /// begin_const(self: *const Vector(DrawCmd)) [*]const DrawCmd
    pub const begin_const = raw.ImVector_ImDrawCmd_begin_const;
    /// capacity(self: *const Vector(DrawCmd)) i32
    pub const capacity = raw.ImVector_ImDrawCmd_capacity;
    /// clear(self: *Vector(DrawCmd)) void
    pub const clear = raw.ImVector_ImDrawCmd_clear;
    /// deinit(self: *Vector(DrawCmd)) void
    pub const deinit = raw.ImVector_ImDrawCmd_destroy;
    /// empty(self: *const Vector(DrawCmd)) bool
    pub const empty = raw.ImVector_ImDrawCmd_empty;
    /// end(self: *Vector(DrawCmd)) [*]DrawCmd
    pub const end = raw.ImVector_ImDrawCmd_end;
    /// end_const(self: *const Vector(DrawCmd)) [*]const DrawCmd
    pub const end_const = raw.ImVector_ImDrawCmd_end_const;
    /// erase(self: *Vector(DrawCmd), it: [*]const DrawCmd) [*]DrawCmd
    pub const erase = raw.ImVector_ImDrawCmd_erase;
    /// eraseTPtr(self: *Vector(DrawCmd), it: [*]const DrawCmd, it_last: [*]const DrawCmd) [*]DrawCmd
    pub const eraseTPtr = raw.ImVector_ImDrawCmd_eraseTPtr;
    /// erase_unsorted(self: *Vector(DrawCmd), it: [*]const DrawCmd) [*]DrawCmd
    pub const erase_unsorted = raw.ImVector_ImDrawCmd_erase_unsorted;
    /// front(self: *Vector(DrawCmd)) *DrawCmd
    pub const front = raw.ImVector_ImDrawCmd_front;
    /// front_const(self: *const Vector(DrawCmd)) *const DrawCmd
    pub const front_const = raw.ImVector_ImDrawCmd_front_const;
    /// index_from_ptr(self: *const Vector(DrawCmd), it: [*]const DrawCmd) i32
    pub const index_from_ptr = raw.ImVector_ImDrawCmd_index_from_ptr;
    /// insert(self: *Vector(DrawCmd), it: [*]const DrawCmd, v: DrawCmd) [*]DrawCmd
    pub const insert = raw.ImVector_ImDrawCmd_insert;
    /// pop_back(self: *Vector(DrawCmd)) void
    pub const pop_back = raw.ImVector_ImDrawCmd_pop_back;
    /// push_back(self: *Vector(DrawCmd), v: DrawCmd) void
    pub const push_back = raw.ImVector_ImDrawCmd_push_back;
    /// push_front(self: *Vector(DrawCmd), v: DrawCmd) void
    pub const push_front = raw.ImVector_ImDrawCmd_push_front;
    /// reserve(self: *Vector(DrawCmd), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImDrawCmd_reserve;
    /// resize(self: *Vector(DrawCmd), new_size: i32) void
    pub const resize = raw.ImVector_ImDrawCmd_resize;
    /// resizeT(self: *Vector(DrawCmd), new_size: i32, v: DrawCmd) void
    pub const resizeT = raw.ImVector_ImDrawCmd_resizeT;
    /// shrink(self: *Vector(DrawCmd), new_size: i32) void
    pub const shrink = raw.ImVector_ImDrawCmd_shrink;
    /// size(self: *const Vector(DrawCmd)) i32
    pub const size = raw.ImVector_ImDrawCmd_size;
    /// size_in_bytes(self: *const Vector(DrawCmd)) i32
    pub const size_in_bytes = raw.ImVector_ImDrawCmd_size_in_bytes;
    /// swap(self: *Vector(DrawCmd), rhs: *Vector(DrawCmd)) void
    pub const swap = raw.ImVector_ImDrawCmd_swap;
};

const FTABLE_ImVector_ImDrawIdx = struct {
    /// init(self: *Vector(DrawIdx)) void
    pub const init = raw.ImVector_ImDrawIdx_ImVector_ImDrawIdx;
    /// initVector(self: *Vector(DrawIdx), src: Vector(DrawIdx)) void
    pub const initVector = raw.ImVector_ImDrawIdx_ImVector_ImDrawIdxVector;
    /// _grow_capacity(self: *const Vector(DrawIdx), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImDrawIdx__grow_capacity;
    /// back(self: *Vector(DrawIdx)) *DrawIdx
    pub const back = raw.ImVector_ImDrawIdx_back;
    /// back_const(self: *const Vector(DrawIdx)) *const DrawIdx
    pub const back_const = raw.ImVector_ImDrawIdx_back_const;
    /// begin(self: *Vector(DrawIdx)) [*]DrawIdx
    pub const begin = raw.ImVector_ImDrawIdx_begin;
    /// begin_const(self: *const Vector(DrawIdx)) [*]const DrawIdx
    pub const begin_const = raw.ImVector_ImDrawIdx_begin_const;
    /// capacity(self: *const Vector(DrawIdx)) i32
    pub const capacity = raw.ImVector_ImDrawIdx_capacity;
    /// clear(self: *Vector(DrawIdx)) void
    pub const clear = raw.ImVector_ImDrawIdx_clear;
    /// contains(self: *const Vector(DrawIdx), v: DrawIdx) bool
    pub const contains = raw.ImVector_ImDrawIdx_contains;
    /// deinit(self: *Vector(DrawIdx)) void
    pub const deinit = raw.ImVector_ImDrawIdx_destroy;
    /// empty(self: *const Vector(DrawIdx)) bool
    pub const empty = raw.ImVector_ImDrawIdx_empty;
    /// end(self: *Vector(DrawIdx)) [*]DrawIdx
    pub const end = raw.ImVector_ImDrawIdx_end;
    /// end_const(self: *const Vector(DrawIdx)) [*]const DrawIdx
    pub const end_const = raw.ImVector_ImDrawIdx_end_const;
    /// erase(self: *Vector(DrawIdx), it: [*]const DrawIdx) [*]DrawIdx
    pub const erase = raw.ImVector_ImDrawIdx_erase;
    /// eraseTPtr(self: *Vector(DrawIdx), it: [*]const DrawIdx, it_last: [*]const DrawIdx) [*]DrawIdx
    pub const eraseTPtr = raw.ImVector_ImDrawIdx_eraseTPtr;
    /// erase_unsorted(self: *Vector(DrawIdx), it: [*]const DrawIdx) [*]DrawIdx
    pub const erase_unsorted = raw.ImVector_ImDrawIdx_erase_unsorted;
    /// find(self: *Vector(DrawIdx), v: DrawIdx) [*]DrawIdx
    pub const find = raw.ImVector_ImDrawIdx_find;
    /// find_const(self: *const Vector(DrawIdx), v: DrawIdx) [*]const DrawIdx
    pub const find_const = raw.ImVector_ImDrawIdx_find_const;
    /// find_erase(self: *Vector(DrawIdx), v: DrawIdx) bool
    pub const find_erase = raw.ImVector_ImDrawIdx_find_erase;
    /// find_erase_unsorted(self: *Vector(DrawIdx), v: DrawIdx) bool
    pub const find_erase_unsorted = raw.ImVector_ImDrawIdx_find_erase_unsorted;
    /// front(self: *Vector(DrawIdx)) *DrawIdx
    pub const front = raw.ImVector_ImDrawIdx_front;
    /// front_const(self: *const Vector(DrawIdx)) *const DrawIdx
    pub const front_const = raw.ImVector_ImDrawIdx_front_const;
    /// index_from_ptr(self: *const Vector(DrawIdx), it: [*]const DrawIdx) i32
    pub const index_from_ptr = raw.ImVector_ImDrawIdx_index_from_ptr;
    /// insert(self: *Vector(DrawIdx), it: [*]const DrawIdx, v: DrawIdx) [*]DrawIdx
    pub const insert = raw.ImVector_ImDrawIdx_insert;
    /// pop_back(self: *Vector(DrawIdx)) void
    pub const pop_back = raw.ImVector_ImDrawIdx_pop_back;
    /// push_back(self: *Vector(DrawIdx), v: DrawIdx) void
    pub const push_back = raw.ImVector_ImDrawIdx_push_back;
    /// push_front(self: *Vector(DrawIdx), v: DrawIdx) void
    pub const push_front = raw.ImVector_ImDrawIdx_push_front;
    /// reserve(self: *Vector(DrawIdx), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImDrawIdx_reserve;
    /// resize(self: *Vector(DrawIdx), new_size: i32) void
    pub const resize = raw.ImVector_ImDrawIdx_resize;
    /// resizeT(self: *Vector(DrawIdx), new_size: i32, v: DrawIdx) void
    pub const resizeT = raw.ImVector_ImDrawIdx_resizeT;
    /// shrink(self: *Vector(DrawIdx), new_size: i32) void
    pub const shrink = raw.ImVector_ImDrawIdx_shrink;
    /// size(self: *const Vector(DrawIdx)) i32
    pub const size = raw.ImVector_ImDrawIdx_size;
    /// size_in_bytes(self: *const Vector(DrawIdx)) i32
    pub const size_in_bytes = raw.ImVector_ImDrawIdx_size_in_bytes;
    /// swap(self: *Vector(DrawIdx), rhs: *Vector(DrawIdx)) void
    pub const swap = raw.ImVector_ImDrawIdx_swap;
};

const FTABLE_ImVector_ImDrawVert = struct {
    /// init(self: *Vector(DrawVert)) void
    pub const init = raw.ImVector_ImDrawVert_ImVector_ImDrawVert;
    /// initVector(self: *Vector(DrawVert), src: Vector(DrawVert)) void
    pub const initVector = raw.ImVector_ImDrawVert_ImVector_ImDrawVertVector;
    /// _grow_capacity(self: *const Vector(DrawVert), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImDrawVert__grow_capacity;
    /// back(self: *Vector(DrawVert)) *DrawVert
    pub const back = raw.ImVector_ImDrawVert_back;
    /// back_const(self: *const Vector(DrawVert)) *const DrawVert
    pub const back_const = raw.ImVector_ImDrawVert_back_const;
    /// begin(self: *Vector(DrawVert)) [*]DrawVert
    pub const begin = raw.ImVector_ImDrawVert_begin;
    /// begin_const(self: *const Vector(DrawVert)) [*]const DrawVert
    pub const begin_const = raw.ImVector_ImDrawVert_begin_const;
    /// capacity(self: *const Vector(DrawVert)) i32
    pub const capacity = raw.ImVector_ImDrawVert_capacity;
    /// clear(self: *Vector(DrawVert)) void
    pub const clear = raw.ImVector_ImDrawVert_clear;
    /// deinit(self: *Vector(DrawVert)) void
    pub const deinit = raw.ImVector_ImDrawVert_destroy;
    /// empty(self: *const Vector(DrawVert)) bool
    pub const empty = raw.ImVector_ImDrawVert_empty;
    /// end(self: *Vector(DrawVert)) [*]DrawVert
    pub const end = raw.ImVector_ImDrawVert_end;
    /// end_const(self: *const Vector(DrawVert)) [*]const DrawVert
    pub const end_const = raw.ImVector_ImDrawVert_end_const;
    /// erase(self: *Vector(DrawVert), it: [*]const DrawVert) [*]DrawVert
    pub const erase = raw.ImVector_ImDrawVert_erase;
    /// eraseTPtr(self: *Vector(DrawVert), it: [*]const DrawVert, it_last: [*]const DrawVert) [*]DrawVert
    pub const eraseTPtr = raw.ImVector_ImDrawVert_eraseTPtr;
    /// erase_unsorted(self: *Vector(DrawVert), it: [*]const DrawVert) [*]DrawVert
    pub const erase_unsorted = raw.ImVector_ImDrawVert_erase_unsorted;
    /// front(self: *Vector(DrawVert)) *DrawVert
    pub const front = raw.ImVector_ImDrawVert_front;
    /// front_const(self: *const Vector(DrawVert)) *const DrawVert
    pub const front_const = raw.ImVector_ImDrawVert_front_const;
    /// index_from_ptr(self: *const Vector(DrawVert), it: [*]const DrawVert) i32
    pub const index_from_ptr = raw.ImVector_ImDrawVert_index_from_ptr;
    /// insert(self: *Vector(DrawVert), it: [*]const DrawVert, v: DrawVert) [*]DrawVert
    pub const insert = raw.ImVector_ImDrawVert_insert;
    /// pop_back(self: *Vector(DrawVert)) void
    pub const pop_back = raw.ImVector_ImDrawVert_pop_back;
    /// push_back(self: *Vector(DrawVert), v: DrawVert) void
    pub const push_back = raw.ImVector_ImDrawVert_push_back;
    /// push_front(self: *Vector(DrawVert), v: DrawVert) void
    pub const push_front = raw.ImVector_ImDrawVert_push_front;
    /// reserve(self: *Vector(DrawVert), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImDrawVert_reserve;
    /// resize(self: *Vector(DrawVert), new_size: i32) void
    pub const resize = raw.ImVector_ImDrawVert_resize;
    /// resizeT(self: *Vector(DrawVert), new_size: i32, v: DrawVert) void
    pub const resizeT = raw.ImVector_ImDrawVert_resizeT;
    /// shrink(self: *Vector(DrawVert), new_size: i32) void
    pub const shrink = raw.ImVector_ImDrawVert_shrink;
    /// size(self: *const Vector(DrawVert)) i32
    pub const size = raw.ImVector_ImDrawVert_size;
    /// size_in_bytes(self: *const Vector(DrawVert)) i32
    pub const size_in_bytes = raw.ImVector_ImDrawVert_size_in_bytes;
    /// swap(self: *Vector(DrawVert), rhs: *Vector(DrawVert)) void
    pub const swap = raw.ImVector_ImDrawVert_swap;
};

const FTABLE_ImVector_ImFontPtr = struct {
    /// init(self: *Vector(*Font)) void
    pub const init = raw.ImVector_ImFontPtr_ImVector_ImFontPtr;
    /// initVector(self: *Vector(*Font), src: Vector(*Font)) void
    pub const initVector = raw.ImVector_ImFontPtr_ImVector_ImFontPtrVector;
    /// _grow_capacity(self: *const Vector(*Font), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImFontPtr__grow_capacity;
    /// back(self: *Vector(*Font)) **Font
    pub const back = raw.ImVector_ImFontPtr_back;
    /// back_const(self: *const Vector(*Font)) *const *Font
    pub const back_const = raw.ImVector_ImFontPtr_back_const;
    /// begin(self: *Vector(*Font)) [*]*Font
    pub const begin = raw.ImVector_ImFontPtr_begin;
    /// begin_const(self: *const Vector(*Font)) [*]const *Font
    pub const begin_const = raw.ImVector_ImFontPtr_begin_const;
    /// capacity(self: *const Vector(*Font)) i32
    pub const capacity = raw.ImVector_ImFontPtr_capacity;
    /// clear(self: *Vector(*Font)) void
    pub const clear = raw.ImVector_ImFontPtr_clear;
    /// contains(self: *const Vector(*Font), v: *Font) bool
    pub const contains = raw.ImVector_ImFontPtr_contains;
    /// deinit(self: *Vector(*Font)) void
    pub const deinit = raw.ImVector_ImFontPtr_destroy;
    /// empty(self: *const Vector(*Font)) bool
    pub const empty = raw.ImVector_ImFontPtr_empty;
    /// end(self: *Vector(*Font)) [*]*Font
    pub const end = raw.ImVector_ImFontPtr_end;
    /// end_const(self: *const Vector(*Font)) [*]const *Font
    pub const end_const = raw.ImVector_ImFontPtr_end_const;
    /// erase(self: *Vector(*Font), it: [*]const *Font) [*]*Font
    pub const erase = raw.ImVector_ImFontPtr_erase;
    /// eraseTPtr(self: *Vector(*Font), it: [*]const *Font, it_last: [*]const *Font) [*]*Font
    pub const eraseTPtr = raw.ImVector_ImFontPtr_eraseTPtr;
    /// erase_unsorted(self: *Vector(*Font), it: [*]const *Font) [*]*Font
    pub const erase_unsorted = raw.ImVector_ImFontPtr_erase_unsorted;
    /// find(self: *Vector(*Font), v: *Font) [*]*Font
    pub const find = raw.ImVector_ImFontPtr_find;
    /// find_const(self: *const Vector(*Font), v: *Font) [*]const *Font
    pub const find_const = raw.ImVector_ImFontPtr_find_const;
    /// find_erase(self: *Vector(*Font), v: *Font) bool
    pub const find_erase = raw.ImVector_ImFontPtr_find_erase;
    /// find_erase_unsorted(self: *Vector(*Font), v: *Font) bool
    pub const find_erase_unsorted = raw.ImVector_ImFontPtr_find_erase_unsorted;
    /// front(self: *Vector(*Font)) **Font
    pub const front = raw.ImVector_ImFontPtr_front;
    /// front_const(self: *const Vector(*Font)) *const *Font
    pub const front_const = raw.ImVector_ImFontPtr_front_const;
    /// index_from_ptr(self: *const Vector(*Font), it: [*]const *Font) i32
    pub const index_from_ptr = raw.ImVector_ImFontPtr_index_from_ptr;
    /// insert(self: *Vector(*Font), it: [*]const *Font, v: *Font) [*]*Font
    pub const insert = raw.ImVector_ImFontPtr_insert;
    /// pop_back(self: *Vector(*Font)) void
    pub const pop_back = raw.ImVector_ImFontPtr_pop_back;
    /// push_back(self: *Vector(*Font), v: *Font) void
    pub const push_back = raw.ImVector_ImFontPtr_push_back;
    /// push_front(self: *Vector(*Font), v: *Font) void
    pub const push_front = raw.ImVector_ImFontPtr_push_front;
    /// reserve(self: *Vector(*Font), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImFontPtr_reserve;
    /// resize(self: *Vector(*Font), new_size: i32) void
    pub const resize = raw.ImVector_ImFontPtr_resize;
    /// resizeT(self: *Vector(*Font), new_size: i32, v: *Font) void
    pub const resizeT = raw.ImVector_ImFontPtr_resizeT;
    /// shrink(self: *Vector(*Font), new_size: i32) void
    pub const shrink = raw.ImVector_ImFontPtr_shrink;
    /// size(self: *const Vector(*Font)) i32
    pub const size = raw.ImVector_ImFontPtr_size;
    /// size_in_bytes(self: *const Vector(*Font)) i32
    pub const size_in_bytes = raw.ImVector_ImFontPtr_size_in_bytes;
    /// swap(self: *Vector(*Font), rhs: *Vector(*Font)) void
    pub const swap = raw.ImVector_ImFontPtr_swap;
};

const FTABLE_ImVector_ImFontAtlasCustomRect = struct {
    /// init(self: *Vector(FontAtlasCustomRect)) void
    pub const init = raw.ImVector_ImFontAtlasCustomRect_ImVector_ImFontAtlasCustomRect;
    /// initVector(self: *Vector(FontAtlasCustomRect), src: Vector(FontAtlasCustomRect)) void
    pub const initVector = raw.ImVector_ImFontAtlasCustomRect_ImVector_ImFontAtlasCustomRectVector;
    /// _grow_capacity(self: *const Vector(FontAtlasCustomRect), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImFontAtlasCustomRect__grow_capacity;
    /// back(self: *Vector(FontAtlasCustomRect)) *FontAtlasCustomRect
    pub const back = raw.ImVector_ImFontAtlasCustomRect_back;
    /// back_const(self: *const Vector(FontAtlasCustomRect)) *const FontAtlasCustomRect
    pub const back_const = raw.ImVector_ImFontAtlasCustomRect_back_const;
    /// begin(self: *Vector(FontAtlasCustomRect)) [*]FontAtlasCustomRect
    pub const begin = raw.ImVector_ImFontAtlasCustomRect_begin;
    /// begin_const(self: *const Vector(FontAtlasCustomRect)) [*]const FontAtlasCustomRect
    pub const begin_const = raw.ImVector_ImFontAtlasCustomRect_begin_const;
    /// capacity(self: *const Vector(FontAtlasCustomRect)) i32
    pub const capacity = raw.ImVector_ImFontAtlasCustomRect_capacity;
    /// clear(self: *Vector(FontAtlasCustomRect)) void
    pub const clear = raw.ImVector_ImFontAtlasCustomRect_clear;
    /// deinit(self: *Vector(FontAtlasCustomRect)) void
    pub const deinit = raw.ImVector_ImFontAtlasCustomRect_destroy;
    /// empty(self: *const Vector(FontAtlasCustomRect)) bool
    pub const empty = raw.ImVector_ImFontAtlasCustomRect_empty;
    /// end(self: *Vector(FontAtlasCustomRect)) [*]FontAtlasCustomRect
    pub const end = raw.ImVector_ImFontAtlasCustomRect_end;
    /// end_const(self: *const Vector(FontAtlasCustomRect)) [*]const FontAtlasCustomRect
    pub const end_const = raw.ImVector_ImFontAtlasCustomRect_end_const;
    /// erase(self: *Vector(FontAtlasCustomRect), it: [*]const FontAtlasCustomRect) [*]FontAtlasCustomRect
    pub const erase = raw.ImVector_ImFontAtlasCustomRect_erase;
    /// eraseTPtr(self: *Vector(FontAtlasCustomRect), it: [*]const FontAtlasCustomRect, it_last: [*]const FontAtlasCustomRect) [*]FontAtlasCustomRect
    pub const eraseTPtr = raw.ImVector_ImFontAtlasCustomRect_eraseTPtr;
    /// erase_unsorted(self: *Vector(FontAtlasCustomRect), it: [*]const FontAtlasCustomRect) [*]FontAtlasCustomRect
    pub const erase_unsorted = raw.ImVector_ImFontAtlasCustomRect_erase_unsorted;
    /// front(self: *Vector(FontAtlasCustomRect)) *FontAtlasCustomRect
    pub const front = raw.ImVector_ImFontAtlasCustomRect_front;
    /// front_const(self: *const Vector(FontAtlasCustomRect)) *const FontAtlasCustomRect
    pub const front_const = raw.ImVector_ImFontAtlasCustomRect_front_const;
    /// index_from_ptr(self: *const Vector(FontAtlasCustomRect), it: [*]const FontAtlasCustomRect) i32
    pub const index_from_ptr = raw.ImVector_ImFontAtlasCustomRect_index_from_ptr;
    /// insert(self: *Vector(FontAtlasCustomRect), it: [*]const FontAtlasCustomRect, v: FontAtlasCustomRect) [*]FontAtlasCustomRect
    pub const insert = raw.ImVector_ImFontAtlasCustomRect_insert;
    /// pop_back(self: *Vector(FontAtlasCustomRect)) void
    pub const pop_back = raw.ImVector_ImFontAtlasCustomRect_pop_back;
    /// push_back(self: *Vector(FontAtlasCustomRect), v: FontAtlasCustomRect) void
    pub const push_back = raw.ImVector_ImFontAtlasCustomRect_push_back;
    /// push_front(self: *Vector(FontAtlasCustomRect), v: FontAtlasCustomRect) void
    pub const push_front = raw.ImVector_ImFontAtlasCustomRect_push_front;
    /// reserve(self: *Vector(FontAtlasCustomRect), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImFontAtlasCustomRect_reserve;
    /// resize(self: *Vector(FontAtlasCustomRect), new_size: i32) void
    pub const resize = raw.ImVector_ImFontAtlasCustomRect_resize;
    /// resizeT(self: *Vector(FontAtlasCustomRect), new_size: i32, v: FontAtlasCustomRect) void
    pub const resizeT = raw.ImVector_ImFontAtlasCustomRect_resizeT;
    /// shrink(self: *Vector(FontAtlasCustomRect), new_size: i32) void
    pub const shrink = raw.ImVector_ImFontAtlasCustomRect_shrink;
    /// size(self: *const Vector(FontAtlasCustomRect)) i32
    pub const size = raw.ImVector_ImFontAtlasCustomRect_size;
    /// size_in_bytes(self: *const Vector(FontAtlasCustomRect)) i32
    pub const size_in_bytes = raw.ImVector_ImFontAtlasCustomRect_size_in_bytes;
    /// swap(self: *Vector(FontAtlasCustomRect), rhs: *Vector(FontAtlasCustomRect)) void
    pub const swap = raw.ImVector_ImFontAtlasCustomRect_swap;
};

const FTABLE_ImVector_ImFontConfig = struct {
    /// init(self: *Vector(FontConfig)) void
    pub const init = raw.ImVector_ImFontConfig_ImVector_ImFontConfig;
    /// initVector(self: *Vector(FontConfig), src: Vector(FontConfig)) void
    pub const initVector = raw.ImVector_ImFontConfig_ImVector_ImFontConfigVector;
    /// _grow_capacity(self: *const Vector(FontConfig), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImFontConfig__grow_capacity;
    /// back(self: *Vector(FontConfig)) *FontConfig
    pub const back = raw.ImVector_ImFontConfig_back;
    /// back_const(self: *const Vector(FontConfig)) *const FontConfig
    pub const back_const = raw.ImVector_ImFontConfig_back_const;
    /// begin(self: *Vector(FontConfig)) [*]FontConfig
    pub const begin = raw.ImVector_ImFontConfig_begin;
    /// begin_const(self: *const Vector(FontConfig)) [*]const FontConfig
    pub const begin_const = raw.ImVector_ImFontConfig_begin_const;
    /// capacity(self: *const Vector(FontConfig)) i32
    pub const capacity = raw.ImVector_ImFontConfig_capacity;
    /// clear(self: *Vector(FontConfig)) void
    pub const clear = raw.ImVector_ImFontConfig_clear;
    /// deinit(self: *Vector(FontConfig)) void
    pub const deinit = raw.ImVector_ImFontConfig_destroy;
    /// empty(self: *const Vector(FontConfig)) bool
    pub const empty = raw.ImVector_ImFontConfig_empty;
    /// end(self: *Vector(FontConfig)) [*]FontConfig
    pub const end = raw.ImVector_ImFontConfig_end;
    /// end_const(self: *const Vector(FontConfig)) [*]const FontConfig
    pub const end_const = raw.ImVector_ImFontConfig_end_const;
    /// erase(self: *Vector(FontConfig), it: [*]const FontConfig) [*]FontConfig
    pub const erase = raw.ImVector_ImFontConfig_erase;
    /// eraseTPtr(self: *Vector(FontConfig), it: [*]const FontConfig, it_last: [*]const FontConfig) [*]FontConfig
    pub const eraseTPtr = raw.ImVector_ImFontConfig_eraseTPtr;
    /// erase_unsorted(self: *Vector(FontConfig), it: [*]const FontConfig) [*]FontConfig
    pub const erase_unsorted = raw.ImVector_ImFontConfig_erase_unsorted;
    /// front(self: *Vector(FontConfig)) *FontConfig
    pub const front = raw.ImVector_ImFontConfig_front;
    /// front_const(self: *const Vector(FontConfig)) *const FontConfig
    pub const front_const = raw.ImVector_ImFontConfig_front_const;
    /// index_from_ptr(self: *const Vector(FontConfig), it: [*]const FontConfig) i32
    pub const index_from_ptr = raw.ImVector_ImFontConfig_index_from_ptr;
    /// insert(self: *Vector(FontConfig), it: [*]const FontConfig, v: FontConfig) [*]FontConfig
    pub const insert = raw.ImVector_ImFontConfig_insert;
    /// pop_back(self: *Vector(FontConfig)) void
    pub const pop_back = raw.ImVector_ImFontConfig_pop_back;
    /// push_back(self: *Vector(FontConfig), v: FontConfig) void
    pub const push_back = raw.ImVector_ImFontConfig_push_back;
    /// push_front(self: *Vector(FontConfig), v: FontConfig) void
    pub const push_front = raw.ImVector_ImFontConfig_push_front;
    /// reserve(self: *Vector(FontConfig), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImFontConfig_reserve;
    /// resize(self: *Vector(FontConfig), new_size: i32) void
    pub const resize = raw.ImVector_ImFontConfig_resize;
    /// resizeT(self: *Vector(FontConfig), new_size: i32, v: FontConfig) void
    pub const resizeT = raw.ImVector_ImFontConfig_resizeT;
    /// shrink(self: *Vector(FontConfig), new_size: i32) void
    pub const shrink = raw.ImVector_ImFontConfig_shrink;
    /// size(self: *const Vector(FontConfig)) i32
    pub const size = raw.ImVector_ImFontConfig_size;
    /// size_in_bytes(self: *const Vector(FontConfig)) i32
    pub const size_in_bytes = raw.ImVector_ImFontConfig_size_in_bytes;
    /// swap(self: *Vector(FontConfig), rhs: *Vector(FontConfig)) void
    pub const swap = raw.ImVector_ImFontConfig_swap;
};

const FTABLE_ImVector_ImFontGlyph = struct {
    /// init(self: *Vector(FontGlyph)) void
    pub const init = raw.ImVector_ImFontGlyph_ImVector_ImFontGlyph;
    /// initVector(self: *Vector(FontGlyph), src: Vector(FontGlyph)) void
    pub const initVector = raw.ImVector_ImFontGlyph_ImVector_ImFontGlyphVector;
    /// _grow_capacity(self: *const Vector(FontGlyph), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImFontGlyph__grow_capacity;
    /// back(self: *Vector(FontGlyph)) *FontGlyph
    pub const back = raw.ImVector_ImFontGlyph_back;
    /// back_const(self: *const Vector(FontGlyph)) *const FontGlyph
    pub const back_const = raw.ImVector_ImFontGlyph_back_const;
    /// begin(self: *Vector(FontGlyph)) [*]FontGlyph
    pub const begin = raw.ImVector_ImFontGlyph_begin;
    /// begin_const(self: *const Vector(FontGlyph)) [*]const FontGlyph
    pub const begin_const = raw.ImVector_ImFontGlyph_begin_const;
    /// capacity(self: *const Vector(FontGlyph)) i32
    pub const capacity = raw.ImVector_ImFontGlyph_capacity;
    /// clear(self: *Vector(FontGlyph)) void
    pub const clear = raw.ImVector_ImFontGlyph_clear;
    /// deinit(self: *Vector(FontGlyph)) void
    pub const deinit = raw.ImVector_ImFontGlyph_destroy;
    /// empty(self: *const Vector(FontGlyph)) bool
    pub const empty = raw.ImVector_ImFontGlyph_empty;
    /// end(self: *Vector(FontGlyph)) [*]FontGlyph
    pub const end = raw.ImVector_ImFontGlyph_end;
    /// end_const(self: *const Vector(FontGlyph)) [*]const FontGlyph
    pub const end_const = raw.ImVector_ImFontGlyph_end_const;
    /// erase(self: *Vector(FontGlyph), it: [*]const FontGlyph) [*]FontGlyph
    pub const erase = raw.ImVector_ImFontGlyph_erase;
    /// eraseTPtr(self: *Vector(FontGlyph), it: [*]const FontGlyph, it_last: [*]const FontGlyph) [*]FontGlyph
    pub const eraseTPtr = raw.ImVector_ImFontGlyph_eraseTPtr;
    /// erase_unsorted(self: *Vector(FontGlyph), it: [*]const FontGlyph) [*]FontGlyph
    pub const erase_unsorted = raw.ImVector_ImFontGlyph_erase_unsorted;
    /// front(self: *Vector(FontGlyph)) *FontGlyph
    pub const front = raw.ImVector_ImFontGlyph_front;
    /// front_const(self: *const Vector(FontGlyph)) *const FontGlyph
    pub const front_const = raw.ImVector_ImFontGlyph_front_const;
    /// index_from_ptr(self: *const Vector(FontGlyph), it: [*]const FontGlyph) i32
    pub const index_from_ptr = raw.ImVector_ImFontGlyph_index_from_ptr;
    /// insert(self: *Vector(FontGlyph), it: [*]const FontGlyph, v: FontGlyph) [*]FontGlyph
    pub const insert = raw.ImVector_ImFontGlyph_insert;
    /// pop_back(self: *Vector(FontGlyph)) void
    pub const pop_back = raw.ImVector_ImFontGlyph_pop_back;
    /// push_back(self: *Vector(FontGlyph), v: FontGlyph) void
    pub const push_back = raw.ImVector_ImFontGlyph_push_back;
    /// push_front(self: *Vector(FontGlyph), v: FontGlyph) void
    pub const push_front = raw.ImVector_ImFontGlyph_push_front;
    /// reserve(self: *Vector(FontGlyph), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImFontGlyph_reserve;
    /// resize(self: *Vector(FontGlyph), new_size: i32) void
    pub const resize = raw.ImVector_ImFontGlyph_resize;
    /// resizeT(self: *Vector(FontGlyph), new_size: i32, v: FontGlyph) void
    pub const resizeT = raw.ImVector_ImFontGlyph_resizeT;
    /// shrink(self: *Vector(FontGlyph), new_size: i32) void
    pub const shrink = raw.ImVector_ImFontGlyph_shrink;
    /// size(self: *const Vector(FontGlyph)) i32
    pub const size = raw.ImVector_ImFontGlyph_size;
    /// size_in_bytes(self: *const Vector(FontGlyph)) i32
    pub const size_in_bytes = raw.ImVector_ImFontGlyph_size_in_bytes;
    /// swap(self: *Vector(FontGlyph), rhs: *Vector(FontGlyph)) void
    pub const swap = raw.ImVector_ImFontGlyph_swap;
};

const FTABLE_ImVector_ImGuiStoragePair = struct {
    /// init(self: *Vector(StoragePair)) void
    pub const init = raw.ImVector_ImGuiStoragePair_ImVector_ImGuiStoragePair;
    /// initVector(self: *Vector(StoragePair), src: Vector(StoragePair)) void
    pub const initVector = raw.ImVector_ImGuiStoragePair_ImVector_ImGuiStoragePairVector;
    /// _grow_capacity(self: *const Vector(StoragePair), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImGuiStoragePair__grow_capacity;
    /// back(self: *Vector(StoragePair)) *StoragePair
    pub const back = raw.ImVector_ImGuiStoragePair_back;
    /// back_const(self: *const Vector(StoragePair)) *const StoragePair
    pub const back_const = raw.ImVector_ImGuiStoragePair_back_const;
    /// begin(self: *Vector(StoragePair)) [*]StoragePair
    pub const begin = raw.ImVector_ImGuiStoragePair_begin;
    /// begin_const(self: *const Vector(StoragePair)) [*]const StoragePair
    pub const begin_const = raw.ImVector_ImGuiStoragePair_begin_const;
    /// capacity(self: *const Vector(StoragePair)) i32
    pub const capacity = raw.ImVector_ImGuiStoragePair_capacity;
    /// clear(self: *Vector(StoragePair)) void
    pub const clear = raw.ImVector_ImGuiStoragePair_clear;
    /// deinit(self: *Vector(StoragePair)) void
    pub const deinit = raw.ImVector_ImGuiStoragePair_destroy;
    /// empty(self: *const Vector(StoragePair)) bool
    pub const empty = raw.ImVector_ImGuiStoragePair_empty;
    /// end(self: *Vector(StoragePair)) [*]StoragePair
    pub const end = raw.ImVector_ImGuiStoragePair_end;
    /// end_const(self: *const Vector(StoragePair)) [*]const StoragePair
    pub const end_const = raw.ImVector_ImGuiStoragePair_end_const;
    /// erase(self: *Vector(StoragePair), it: [*]const StoragePair) [*]StoragePair
    pub const erase = raw.ImVector_ImGuiStoragePair_erase;
    /// eraseTPtr(self: *Vector(StoragePair), it: [*]const StoragePair, it_last: [*]const StoragePair) [*]StoragePair
    pub const eraseTPtr = raw.ImVector_ImGuiStoragePair_eraseTPtr;
    /// erase_unsorted(self: *Vector(StoragePair), it: [*]const StoragePair) [*]StoragePair
    pub const erase_unsorted = raw.ImVector_ImGuiStoragePair_erase_unsorted;
    /// front(self: *Vector(StoragePair)) *StoragePair
    pub const front = raw.ImVector_ImGuiStoragePair_front;
    /// front_const(self: *const Vector(StoragePair)) *const StoragePair
    pub const front_const = raw.ImVector_ImGuiStoragePair_front_const;
    /// index_from_ptr(self: *const Vector(StoragePair), it: [*]const StoragePair) i32
    pub const index_from_ptr = raw.ImVector_ImGuiStoragePair_index_from_ptr;
    /// insert(self: *Vector(StoragePair), it: [*]const StoragePair, v: StoragePair) [*]StoragePair
    pub const insert = raw.ImVector_ImGuiStoragePair_insert;
    /// pop_back(self: *Vector(StoragePair)) void
    pub const pop_back = raw.ImVector_ImGuiStoragePair_pop_back;
    /// push_back(self: *Vector(StoragePair), v: StoragePair) void
    pub const push_back = raw.ImVector_ImGuiStoragePair_push_back;
    /// push_front(self: *Vector(StoragePair), v: StoragePair) void
    pub const push_front = raw.ImVector_ImGuiStoragePair_push_front;
    /// reserve(self: *Vector(StoragePair), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImGuiStoragePair_reserve;
    /// resize(self: *Vector(StoragePair), new_size: i32) void
    pub const resize = raw.ImVector_ImGuiStoragePair_resize;
    /// resizeT(self: *Vector(StoragePair), new_size: i32, v: StoragePair) void
    pub const resizeT = raw.ImVector_ImGuiStoragePair_resizeT;
    /// shrink(self: *Vector(StoragePair), new_size: i32) void
    pub const shrink = raw.ImVector_ImGuiStoragePair_shrink;
    /// size(self: *const Vector(StoragePair)) i32
    pub const size = raw.ImVector_ImGuiStoragePair_size;
    /// size_in_bytes(self: *const Vector(StoragePair)) i32
    pub const size_in_bytes = raw.ImVector_ImGuiStoragePair_size_in_bytes;
    /// swap(self: *Vector(StoragePair), rhs: *Vector(StoragePair)) void
    pub const swap = raw.ImVector_ImGuiStoragePair_swap;
};

const FTABLE_ImVector_ImGuiTextRange = struct {
    /// init(self: *Vector(TextRange)) void
    pub const init = raw.ImVector_ImGuiTextRange_ImVector_ImGuiTextRange;
    /// initVector(self: *Vector(TextRange), src: Vector(TextRange)) void
    pub const initVector = raw.ImVector_ImGuiTextRange_ImVector_ImGuiTextRangeVector;
    /// _grow_capacity(self: *const Vector(TextRange), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImGuiTextRange__grow_capacity;
    /// back(self: *Vector(TextRange)) *TextRange
    pub const back = raw.ImVector_ImGuiTextRange_back;
    /// back_const(self: *const Vector(TextRange)) *const TextRange
    pub const back_const = raw.ImVector_ImGuiTextRange_back_const;
    /// begin(self: *Vector(TextRange)) [*]TextRange
    pub const begin = raw.ImVector_ImGuiTextRange_begin;
    /// begin_const(self: *const Vector(TextRange)) [*]const TextRange
    pub const begin_const = raw.ImVector_ImGuiTextRange_begin_const;
    /// capacity(self: *const Vector(TextRange)) i32
    pub const capacity = raw.ImVector_ImGuiTextRange_capacity;
    /// clear(self: *Vector(TextRange)) void
    pub const clear = raw.ImVector_ImGuiTextRange_clear;
    /// deinit(self: *Vector(TextRange)) void
    pub const deinit = raw.ImVector_ImGuiTextRange_destroy;
    /// empty(self: *const Vector(TextRange)) bool
    pub const empty = raw.ImVector_ImGuiTextRange_empty;
    /// end(self: *Vector(TextRange)) [*]TextRange
    pub const end = raw.ImVector_ImGuiTextRange_end;
    /// end_const(self: *const Vector(TextRange)) [*]const TextRange
    pub const end_const = raw.ImVector_ImGuiTextRange_end_const;
    /// erase(self: *Vector(TextRange), it: [*]const TextRange) [*]TextRange
    pub const erase = raw.ImVector_ImGuiTextRange_erase;
    /// eraseTPtr(self: *Vector(TextRange), it: [*]const TextRange, it_last: [*]const TextRange) [*]TextRange
    pub const eraseTPtr = raw.ImVector_ImGuiTextRange_eraseTPtr;
    /// erase_unsorted(self: *Vector(TextRange), it: [*]const TextRange) [*]TextRange
    pub const erase_unsorted = raw.ImVector_ImGuiTextRange_erase_unsorted;
    /// front(self: *Vector(TextRange)) *TextRange
    pub const front = raw.ImVector_ImGuiTextRange_front;
    /// front_const(self: *const Vector(TextRange)) *const TextRange
    pub const front_const = raw.ImVector_ImGuiTextRange_front_const;
    /// index_from_ptr(self: *const Vector(TextRange), it: [*]const TextRange) i32
    pub const index_from_ptr = raw.ImVector_ImGuiTextRange_index_from_ptr;
    /// insert(self: *Vector(TextRange), it: [*]const TextRange, v: TextRange) [*]TextRange
    pub const insert = raw.ImVector_ImGuiTextRange_insert;
    /// pop_back(self: *Vector(TextRange)) void
    pub const pop_back = raw.ImVector_ImGuiTextRange_pop_back;
    /// push_back(self: *Vector(TextRange), v: TextRange) void
    pub const push_back = raw.ImVector_ImGuiTextRange_push_back;
    /// push_front(self: *Vector(TextRange), v: TextRange) void
    pub const push_front = raw.ImVector_ImGuiTextRange_push_front;
    /// reserve(self: *Vector(TextRange), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImGuiTextRange_reserve;
    /// resize(self: *Vector(TextRange), new_size: i32) void
    pub const resize = raw.ImVector_ImGuiTextRange_resize;
    /// resizeT(self: *Vector(TextRange), new_size: i32, v: TextRange) void
    pub const resizeT = raw.ImVector_ImGuiTextRange_resizeT;
    /// shrink(self: *Vector(TextRange), new_size: i32) void
    pub const shrink = raw.ImVector_ImGuiTextRange_shrink;
    /// size(self: *const Vector(TextRange)) i32
    pub const size = raw.ImVector_ImGuiTextRange_size;
    /// size_in_bytes(self: *const Vector(TextRange)) i32
    pub const size_in_bytes = raw.ImVector_ImGuiTextRange_size_in_bytes;
    /// swap(self: *Vector(TextRange), rhs: *Vector(TextRange)) void
    pub const swap = raw.ImVector_ImGuiTextRange_swap;
};

const FTABLE_ImVector_ImTextureID = struct {
    /// init(self: *Vector(TextureID)) void
    pub const init = raw.ImVector_ImTextureID_ImVector_ImTextureID;
    /// initVector(self: *Vector(TextureID), src: Vector(TextureID)) void
    pub const initVector = raw.ImVector_ImTextureID_ImVector_ImTextureIDVector;
    /// _grow_capacity(self: *const Vector(TextureID), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImTextureID__grow_capacity;
    /// back(self: *Vector(TextureID)) *TextureID
    pub const back = raw.ImVector_ImTextureID_back;
    /// back_const(self: *const Vector(TextureID)) *const TextureID
    pub const back_const = raw.ImVector_ImTextureID_back_const;
    /// begin(self: *Vector(TextureID)) [*]TextureID
    pub const begin = raw.ImVector_ImTextureID_begin;
    /// begin_const(self: *const Vector(TextureID)) [*]const TextureID
    pub const begin_const = raw.ImVector_ImTextureID_begin_const;
    /// capacity(self: *const Vector(TextureID)) i32
    pub const capacity = raw.ImVector_ImTextureID_capacity;
    /// clear(self: *Vector(TextureID)) void
    pub const clear = raw.ImVector_ImTextureID_clear;
    /// contains(self: *const Vector(TextureID), v: TextureID) bool
    pub const contains = raw.ImVector_ImTextureID_contains;
    /// deinit(self: *Vector(TextureID)) void
    pub const deinit = raw.ImVector_ImTextureID_destroy;
    /// empty(self: *const Vector(TextureID)) bool
    pub const empty = raw.ImVector_ImTextureID_empty;
    /// end(self: *Vector(TextureID)) [*]TextureID
    pub const end = raw.ImVector_ImTextureID_end;
    /// end_const(self: *const Vector(TextureID)) [*]const TextureID
    pub const end_const = raw.ImVector_ImTextureID_end_const;
    /// erase(self: *Vector(TextureID), it: [*]const TextureID) [*]TextureID
    pub const erase = raw.ImVector_ImTextureID_erase;
    /// eraseTPtr(self: *Vector(TextureID), it: [*]const TextureID, it_last: [*]const TextureID) [*]TextureID
    pub const eraseTPtr = raw.ImVector_ImTextureID_eraseTPtr;
    /// erase_unsorted(self: *Vector(TextureID), it: [*]const TextureID) [*]TextureID
    pub const erase_unsorted = raw.ImVector_ImTextureID_erase_unsorted;
    /// find(self: *Vector(TextureID), v: TextureID) [*]TextureID
    pub const find = raw.ImVector_ImTextureID_find;
    /// find_const(self: *const Vector(TextureID), v: TextureID) [*]const TextureID
    pub const find_const = raw.ImVector_ImTextureID_find_const;
    /// find_erase(self: *Vector(TextureID), v: TextureID) bool
    pub const find_erase = raw.ImVector_ImTextureID_find_erase;
    /// find_erase_unsorted(self: *Vector(TextureID), v: TextureID) bool
    pub const find_erase_unsorted = raw.ImVector_ImTextureID_find_erase_unsorted;
    /// front(self: *Vector(TextureID)) *TextureID
    pub const front = raw.ImVector_ImTextureID_front;
    /// front_const(self: *const Vector(TextureID)) *const TextureID
    pub const front_const = raw.ImVector_ImTextureID_front_const;
    /// index_from_ptr(self: *const Vector(TextureID), it: [*]const TextureID) i32
    pub const index_from_ptr = raw.ImVector_ImTextureID_index_from_ptr;
    /// insert(self: *Vector(TextureID), it: [*]const TextureID, v: TextureID) [*]TextureID
    pub const insert = raw.ImVector_ImTextureID_insert;
    /// pop_back(self: *Vector(TextureID)) void
    pub const pop_back = raw.ImVector_ImTextureID_pop_back;
    /// push_back(self: *Vector(TextureID), v: TextureID) void
    pub const push_back = raw.ImVector_ImTextureID_push_back;
    /// push_front(self: *Vector(TextureID), v: TextureID) void
    pub const push_front = raw.ImVector_ImTextureID_push_front;
    /// reserve(self: *Vector(TextureID), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImTextureID_reserve;
    /// resize(self: *Vector(TextureID), new_size: i32) void
    pub const resize = raw.ImVector_ImTextureID_resize;
    /// resizeT(self: *Vector(TextureID), new_size: i32, v: TextureID) void
    pub const resizeT = raw.ImVector_ImTextureID_resizeT;
    /// shrink(self: *Vector(TextureID), new_size: i32) void
    pub const shrink = raw.ImVector_ImTextureID_shrink;
    /// size(self: *const Vector(TextureID)) i32
    pub const size = raw.ImVector_ImTextureID_size;
    /// size_in_bytes(self: *const Vector(TextureID)) i32
    pub const size_in_bytes = raw.ImVector_ImTextureID_size_in_bytes;
    /// swap(self: *Vector(TextureID), rhs: *Vector(TextureID)) void
    pub const swap = raw.ImVector_ImTextureID_swap;
};

const FTABLE_ImVector_ImU32 = struct {
    /// init(self: *Vector(u32)) void
    pub const init = raw.ImVector_ImU32_ImVector_ImU32;
    /// initVector(self: *Vector(u32), src: Vector(u32)) void
    pub const initVector = raw.ImVector_ImU32_ImVector_ImU32Vector;
    /// _grow_capacity(self: *const Vector(u32), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImU32__grow_capacity;
    /// back(self: *Vector(u32)) *u32
    pub const back = raw.ImVector_ImU32_back;
    /// back_const(self: *const Vector(u32)) *const u32
    pub const back_const = raw.ImVector_ImU32_back_const;
    /// begin(self: *Vector(u32)) [*]u32
    pub const begin = raw.ImVector_ImU32_begin;
    /// begin_const(self: *const Vector(u32)) [*]const u32
    pub const begin_const = raw.ImVector_ImU32_begin_const;
    /// capacity(self: *const Vector(u32)) i32
    pub const capacity = raw.ImVector_ImU32_capacity;
    /// clear(self: *Vector(u32)) void
    pub const clear = raw.ImVector_ImU32_clear;
    /// contains(self: *const Vector(u32), v: u32) bool
    pub const contains = raw.ImVector_ImU32_contains;
    /// deinit(self: *Vector(u32)) void
    pub const deinit = raw.ImVector_ImU32_destroy;
    /// empty(self: *const Vector(u32)) bool
    pub const empty = raw.ImVector_ImU32_empty;
    /// end(self: *Vector(u32)) [*]u32
    pub const end = raw.ImVector_ImU32_end;
    /// end_const(self: *const Vector(u32)) [*]const u32
    pub const end_const = raw.ImVector_ImU32_end_const;
    /// erase(self: *Vector(u32), it: [*]const u32) [*]u32
    pub const erase = raw.ImVector_ImU32_erase;
    /// eraseTPtr(self: *Vector(u32), it: [*]const u32, it_last: [*]const u32) [*]u32
    pub const eraseTPtr = raw.ImVector_ImU32_eraseTPtr;
    /// erase_unsorted(self: *Vector(u32), it: [*]const u32) [*]u32
    pub const erase_unsorted = raw.ImVector_ImU32_erase_unsorted;
    /// find(self: *Vector(u32), v: u32) [*]u32
    pub const find = raw.ImVector_ImU32_find;
    /// find_const(self: *const Vector(u32), v: u32) [*]const u32
    pub const find_const = raw.ImVector_ImU32_find_const;
    /// find_erase(self: *Vector(u32), v: u32) bool
    pub const find_erase = raw.ImVector_ImU32_find_erase;
    /// find_erase_unsorted(self: *Vector(u32), v: u32) bool
    pub const find_erase_unsorted = raw.ImVector_ImU32_find_erase_unsorted;
    /// front(self: *Vector(u32)) *u32
    pub const front = raw.ImVector_ImU32_front;
    /// front_const(self: *const Vector(u32)) *const u32
    pub const front_const = raw.ImVector_ImU32_front_const;
    /// index_from_ptr(self: *const Vector(u32), it: [*]const u32) i32
    pub const index_from_ptr = raw.ImVector_ImU32_index_from_ptr;
    /// insert(self: *Vector(u32), it: [*]const u32, v: u32) [*]u32
    pub const insert = raw.ImVector_ImU32_insert;
    /// pop_back(self: *Vector(u32)) void
    pub const pop_back = raw.ImVector_ImU32_pop_back;
    /// push_back(self: *Vector(u32), v: u32) void
    pub const push_back = raw.ImVector_ImU32_push_back;
    /// push_front(self: *Vector(u32), v: u32) void
    pub const push_front = raw.ImVector_ImU32_push_front;
    /// reserve(self: *Vector(u32), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImU32_reserve;
    /// resize(self: *Vector(u32), new_size: i32) void
    pub const resize = raw.ImVector_ImU32_resize;
    /// resizeT(self: *Vector(u32), new_size: i32, v: u32) void
    pub const resizeT = raw.ImVector_ImU32_resizeT;
    /// shrink(self: *Vector(u32), new_size: i32) void
    pub const shrink = raw.ImVector_ImU32_shrink;
    /// size(self: *const Vector(u32)) i32
    pub const size = raw.ImVector_ImU32_size;
    /// size_in_bytes(self: *const Vector(u32)) i32
    pub const size_in_bytes = raw.ImVector_ImU32_size_in_bytes;
    /// swap(self: *Vector(u32), rhs: *Vector(u32)) void
    pub const swap = raw.ImVector_ImU32_swap;
};

const FTABLE_ImVector_ImVec2 = struct {
    /// init(self: *Vector(Vec2)) void
    pub const init = raw.ImVector_ImVec2_ImVector_ImVec2;
    /// initVector(self: *Vector(Vec2), src: Vector(Vec2)) void
    pub const initVector = raw.ImVector_ImVec2_ImVector_ImVec2Vector;
    /// _grow_capacity(self: *const Vector(Vec2), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImVec2__grow_capacity;
    /// back(self: *Vector(Vec2)) *Vec2
    pub const back = raw.ImVector_ImVec2_back;
    /// back_const(self: *const Vector(Vec2)) *const Vec2
    pub const back_const = raw.ImVector_ImVec2_back_const;
    /// begin(self: *Vector(Vec2)) [*]Vec2
    pub const begin = raw.ImVector_ImVec2_begin;
    /// begin_const(self: *const Vector(Vec2)) [*]const Vec2
    pub const begin_const = raw.ImVector_ImVec2_begin_const;
    /// capacity(self: *const Vector(Vec2)) i32
    pub const capacity = raw.ImVector_ImVec2_capacity;
    /// clear(self: *Vector(Vec2)) void
    pub const clear = raw.ImVector_ImVec2_clear;
    /// deinit(self: *Vector(Vec2)) void
    pub const deinit = raw.ImVector_ImVec2_destroy;
    /// empty(self: *const Vector(Vec2)) bool
    pub const empty = raw.ImVector_ImVec2_empty;
    /// end(self: *Vector(Vec2)) [*]Vec2
    pub const end = raw.ImVector_ImVec2_end;
    /// end_const(self: *const Vector(Vec2)) [*]const Vec2
    pub const end_const = raw.ImVector_ImVec2_end_const;
    /// erase(self: *Vector(Vec2), it: [*]const Vec2) [*]Vec2
    pub const erase = raw.ImVector_ImVec2_erase;
    /// eraseTPtr(self: *Vector(Vec2), it: [*]const Vec2, it_last: [*]const Vec2) [*]Vec2
    pub const eraseTPtr = raw.ImVector_ImVec2_eraseTPtr;
    /// erase_unsorted(self: *Vector(Vec2), it: [*]const Vec2) [*]Vec2
    pub const erase_unsorted = raw.ImVector_ImVec2_erase_unsorted;
    /// front(self: *Vector(Vec2)) *Vec2
    pub const front = raw.ImVector_ImVec2_front;
    /// front_const(self: *const Vector(Vec2)) *const Vec2
    pub const front_const = raw.ImVector_ImVec2_front_const;
    /// index_from_ptr(self: *const Vector(Vec2), it: [*]const Vec2) i32
    pub const index_from_ptr = raw.ImVector_ImVec2_index_from_ptr;
    /// insert(self: *Vector(Vec2), it: [*]const Vec2, v: Vec2) [*]Vec2
    pub const insert = raw.ImVector_ImVec2_insert;
    /// pop_back(self: *Vector(Vec2)) void
    pub const pop_back = raw.ImVector_ImVec2_pop_back;
    /// push_back(self: *Vector(Vec2), v: Vec2) void
    pub const push_back = raw.ImVector_ImVec2_push_back;
    /// push_front(self: *Vector(Vec2), v: Vec2) void
    pub const push_front = raw.ImVector_ImVec2_push_front;
    /// reserve(self: *Vector(Vec2), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImVec2_reserve;
    /// resize(self: *Vector(Vec2), new_size: i32) void
    pub const resize = raw.ImVector_ImVec2_resize;
    /// resizeT(self: *Vector(Vec2), new_size: i32, v: Vec2) void
    pub const resizeT = raw.ImVector_ImVec2_resizeT;
    /// shrink(self: *Vector(Vec2), new_size: i32) void
    pub const shrink = raw.ImVector_ImVec2_shrink;
    /// size(self: *const Vector(Vec2)) i32
    pub const size = raw.ImVector_ImVec2_size;
    /// size_in_bytes(self: *const Vector(Vec2)) i32
    pub const size_in_bytes = raw.ImVector_ImVec2_size_in_bytes;
    /// swap(self: *Vector(Vec2), rhs: *Vector(Vec2)) void
    pub const swap = raw.ImVector_ImVec2_swap;
};

const FTABLE_ImVector_ImVec4 = struct {
    /// init(self: *Vector(Vec4)) void
    pub const init = raw.ImVector_ImVec4_ImVector_ImVec4;
    /// initVector(self: *Vector(Vec4), src: Vector(Vec4)) void
    pub const initVector = raw.ImVector_ImVec4_ImVector_ImVec4Vector;
    /// _grow_capacity(self: *const Vector(Vec4), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImVec4__grow_capacity;
    /// back(self: *Vector(Vec4)) *Vec4
    pub const back = raw.ImVector_ImVec4_back;
    /// back_const(self: *const Vector(Vec4)) *const Vec4
    pub const back_const = raw.ImVector_ImVec4_back_const;
    /// begin(self: *Vector(Vec4)) [*]Vec4
    pub const begin = raw.ImVector_ImVec4_begin;
    /// begin_const(self: *const Vector(Vec4)) [*]const Vec4
    pub const begin_const = raw.ImVector_ImVec4_begin_const;
    /// capacity(self: *const Vector(Vec4)) i32
    pub const capacity = raw.ImVector_ImVec4_capacity;
    /// clear(self: *Vector(Vec4)) void
    pub const clear = raw.ImVector_ImVec4_clear;
    /// deinit(self: *Vector(Vec4)) void
    pub const deinit = raw.ImVector_ImVec4_destroy;
    /// empty(self: *const Vector(Vec4)) bool
    pub const empty = raw.ImVector_ImVec4_empty;
    /// end(self: *Vector(Vec4)) [*]Vec4
    pub const end = raw.ImVector_ImVec4_end;
    /// end_const(self: *const Vector(Vec4)) [*]const Vec4
    pub const end_const = raw.ImVector_ImVec4_end_const;
    /// erase(self: *Vector(Vec4), it: [*]const Vec4) [*]Vec4
    pub const erase = raw.ImVector_ImVec4_erase;
    /// eraseTPtr(self: *Vector(Vec4), it: [*]const Vec4, it_last: [*]const Vec4) [*]Vec4
    pub const eraseTPtr = raw.ImVector_ImVec4_eraseTPtr;
    /// erase_unsorted(self: *Vector(Vec4), it: [*]const Vec4) [*]Vec4
    pub const erase_unsorted = raw.ImVector_ImVec4_erase_unsorted;
    /// front(self: *Vector(Vec4)) *Vec4
    pub const front = raw.ImVector_ImVec4_front;
    /// front_const(self: *const Vector(Vec4)) *const Vec4
    pub const front_const = raw.ImVector_ImVec4_front_const;
    /// index_from_ptr(self: *const Vector(Vec4), it: [*]const Vec4) i32
    pub const index_from_ptr = raw.ImVector_ImVec4_index_from_ptr;
    /// insert(self: *Vector(Vec4), it: [*]const Vec4, v: Vec4) [*]Vec4
    pub const insert = raw.ImVector_ImVec4_insert;
    /// pop_back(self: *Vector(Vec4)) void
    pub const pop_back = raw.ImVector_ImVec4_pop_back;
    /// push_back(self: *Vector(Vec4), v: Vec4) void
    pub const push_back = raw.ImVector_ImVec4_push_back;
    /// push_front(self: *Vector(Vec4), v: Vec4) void
    pub const push_front = raw.ImVector_ImVec4_push_front;
    /// reserve(self: *Vector(Vec4), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImVec4_reserve;
    /// resize(self: *Vector(Vec4), new_size: i32) void
    pub const resize = raw.ImVector_ImVec4_resize;
    /// resizeT(self: *Vector(Vec4), new_size: i32, v: Vec4) void
    pub const resizeT = raw.ImVector_ImVec4_resizeT;
    /// shrink(self: *Vector(Vec4), new_size: i32) void
    pub const shrink = raw.ImVector_ImVec4_shrink;
    /// size(self: *const Vector(Vec4)) i32
    pub const size = raw.ImVector_ImVec4_size;
    /// size_in_bytes(self: *const Vector(Vec4)) i32
    pub const size_in_bytes = raw.ImVector_ImVec4_size_in_bytes;
    /// swap(self: *Vector(Vec4), rhs: *Vector(Vec4)) void
    pub const swap = raw.ImVector_ImVec4_swap;
};

const FTABLE_ImVector_ImWchar = struct {
    /// init(self: *Vector(Wchar)) void
    pub const init = raw.ImVector_ImWchar_ImVector_ImWchar;
    /// initVector(self: *Vector(Wchar), src: Vector(Wchar)) void
    pub const initVector = raw.ImVector_ImWchar_ImVector_ImWcharVector;
    /// _grow_capacity(self: *const Vector(Wchar), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_ImWchar__grow_capacity;
    /// back(self: *Vector(Wchar)) *Wchar
    pub const back = raw.ImVector_ImWchar_back;
    /// back_const(self: *const Vector(Wchar)) *const Wchar
    pub const back_const = raw.ImVector_ImWchar_back_const;
    /// begin(self: *Vector(Wchar)) [*]Wchar
    pub const begin = raw.ImVector_ImWchar_begin;
    /// begin_const(self: *const Vector(Wchar)) [*]const Wchar
    pub const begin_const = raw.ImVector_ImWchar_begin_const;
    /// capacity(self: *const Vector(Wchar)) i32
    pub const capacity = raw.ImVector_ImWchar_capacity;
    /// clear(self: *Vector(Wchar)) void
    pub const clear = raw.ImVector_ImWchar_clear;
    /// contains(self: *const Vector(Wchar), v: Wchar) bool
    pub const contains = raw.ImVector_ImWchar_contains;
    /// deinit(self: *Vector(Wchar)) void
    pub const deinit = raw.ImVector_ImWchar_destroy;
    /// empty(self: *const Vector(Wchar)) bool
    pub const empty = raw.ImVector_ImWchar_empty;
    /// end(self: *Vector(Wchar)) [*]Wchar
    pub const end = raw.ImVector_ImWchar_end;
    /// end_const(self: *const Vector(Wchar)) [*]const Wchar
    pub const end_const = raw.ImVector_ImWchar_end_const;
    /// erase(self: *Vector(Wchar), it: [*]const Wchar) [*]Wchar
    pub const erase = raw.ImVector_ImWchar_erase;
    /// eraseTPtr(self: *Vector(Wchar), it: [*]const Wchar, it_last: [*]const Wchar) [*]Wchar
    pub const eraseTPtr = raw.ImVector_ImWchar_eraseTPtr;
    /// erase_unsorted(self: *Vector(Wchar), it: [*]const Wchar) [*]Wchar
    pub const erase_unsorted = raw.ImVector_ImWchar_erase_unsorted;
    /// find(self: *Vector(Wchar), v: Wchar) [*]Wchar
    pub const find = raw.ImVector_ImWchar_find;
    /// find_const(self: *const Vector(Wchar), v: Wchar) [*]const Wchar
    pub const find_const = raw.ImVector_ImWchar_find_const;
    /// find_erase(self: *Vector(Wchar), v: Wchar) bool
    pub const find_erase = raw.ImVector_ImWchar_find_erase;
    /// find_erase_unsorted(self: *Vector(Wchar), v: Wchar) bool
    pub const find_erase_unsorted = raw.ImVector_ImWchar_find_erase_unsorted;
    /// front(self: *Vector(Wchar)) *Wchar
    pub const front = raw.ImVector_ImWchar_front;
    /// front_const(self: *const Vector(Wchar)) *const Wchar
    pub const front_const = raw.ImVector_ImWchar_front_const;
    /// index_from_ptr(self: *const Vector(Wchar), it: [*]const Wchar) i32
    pub const index_from_ptr = raw.ImVector_ImWchar_index_from_ptr;
    /// insert(self: *Vector(Wchar), it: [*]const Wchar, v: Wchar) [*]Wchar
    pub const insert = raw.ImVector_ImWchar_insert;
    /// pop_back(self: *Vector(Wchar)) void
    pub const pop_back = raw.ImVector_ImWchar_pop_back;
    /// push_back(self: *Vector(Wchar), v: Wchar) void
    pub const push_back = raw.ImVector_ImWchar_push_back;
    /// push_front(self: *Vector(Wchar), v: Wchar) void
    pub const push_front = raw.ImVector_ImWchar_push_front;
    /// reserve(self: *Vector(Wchar), new_capacity: i32) void
    pub const reserve = raw.ImVector_ImWchar_reserve;
    /// resize(self: *Vector(Wchar), new_size: i32) void
    pub const resize = raw.ImVector_ImWchar_resize;
    /// resizeT(self: *Vector(Wchar), new_size: i32, v: Wchar) void
    pub const resizeT = raw.ImVector_ImWchar_resizeT;
    /// shrink(self: *Vector(Wchar), new_size: i32) void
    pub const shrink = raw.ImVector_ImWchar_shrink;
    /// size(self: *const Vector(Wchar)) i32
    pub const size = raw.ImVector_ImWchar_size;
    /// size_in_bytes(self: *const Vector(Wchar)) i32
    pub const size_in_bytes = raw.ImVector_ImWchar_size_in_bytes;
    /// swap(self: *Vector(Wchar), rhs: *Vector(Wchar)) void
    pub const swap = raw.ImVector_ImWchar_swap;
};

const FTABLE_ImVector_char = struct {
    /// init(self: *Vector(u8)) void
    pub const init = raw.ImVector_char_ImVector_char;
    /// initVector(self: *Vector(u8), src: Vector(u8)) void
    pub const initVector = raw.ImVector_char_ImVector_charVector;
    /// _grow_capacity(self: *const Vector(u8), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_char__grow_capacity;
    /// back(self: *Vector(u8)) *u8
    pub const back = raw.ImVector_char_back;
    /// back_const(self: *const Vector(u8)) *const u8
    pub const back_const = raw.ImVector_char_back_const;
    /// begin(self: *Vector(u8)) [*]u8
    pub const begin = raw.ImVector_char_begin;
    /// begin_const(self: *const Vector(u8)) [*]const u8
    pub const begin_const = raw.ImVector_char_begin_const;
    /// capacity(self: *const Vector(u8)) i32
    pub const capacity = raw.ImVector_char_capacity;
    /// clear(self: *Vector(u8)) void
    pub const clear = raw.ImVector_char_clear;
    /// contains(self: *const Vector(u8), v: u8) bool
    pub const contains = raw.ImVector_char_contains;
    /// deinit(self: *Vector(u8)) void
    pub const deinit = raw.ImVector_char_destroy;
    /// empty(self: *const Vector(u8)) bool
    pub const empty = raw.ImVector_char_empty;
    /// end(self: *Vector(u8)) [*]u8
    pub const end = raw.ImVector_char_end;
    /// end_const(self: *const Vector(u8)) [*]const u8
    pub const end_const = raw.ImVector_char_end_const;
    /// erase(self: *Vector(u8), it: [*]const u8) [*]u8
    pub const erase = raw.ImVector_char_erase;
    /// eraseTPtr(self: *Vector(u8), it: [*]const u8, it_last: [*]const u8) [*]u8
    pub const eraseTPtr = raw.ImVector_char_eraseTPtr;
    /// erase_unsorted(self: *Vector(u8), it: [*]const u8) [*]u8
    pub const erase_unsorted = raw.ImVector_char_erase_unsorted;
    /// find(self: *Vector(u8), v: u8) [*]u8
    pub const find = raw.ImVector_char_find;
    /// find_const(self: *const Vector(u8), v: u8) [*]const u8
    pub const find_const = raw.ImVector_char_find_const;
    /// find_erase(self: *Vector(u8), v: u8) bool
    pub const find_erase = raw.ImVector_char_find_erase;
    /// find_erase_unsorted(self: *Vector(u8), v: u8) bool
    pub const find_erase_unsorted = raw.ImVector_char_find_erase_unsorted;
    /// front(self: *Vector(u8)) *u8
    pub const front = raw.ImVector_char_front;
    /// front_const(self: *const Vector(u8)) *const u8
    pub const front_const = raw.ImVector_char_front_const;
    /// index_from_ptr(self: *const Vector(u8), it: [*]const u8) i32
    pub const index_from_ptr = raw.ImVector_char_index_from_ptr;
    /// insert(self: *Vector(u8), it: [*]const u8, v: u8) [*]u8
    pub const insert = raw.ImVector_char_insert;
    /// pop_back(self: *Vector(u8)) void
    pub const pop_back = raw.ImVector_char_pop_back;
    /// push_back(self: *Vector(u8), v: u8) void
    pub const push_back = raw.ImVector_char_push_back;
    /// push_front(self: *Vector(u8), v: u8) void
    pub const push_front = raw.ImVector_char_push_front;
    /// reserve(self: *Vector(u8), new_capacity: i32) void
    pub const reserve = raw.ImVector_char_reserve;
    /// resize(self: *Vector(u8), new_size: i32) void
    pub const resize = raw.ImVector_char_resize;
    /// resizeT(self: *Vector(u8), new_size: i32, v: u8) void
    pub const resizeT = raw.ImVector_char_resizeT;
    /// shrink(self: *Vector(u8), new_size: i32) void
    pub const shrink = raw.ImVector_char_shrink;
    /// size(self: *const Vector(u8)) i32
    pub const size = raw.ImVector_char_size;
    /// size_in_bytes(self: *const Vector(u8)) i32
    pub const size_in_bytes = raw.ImVector_char_size_in_bytes;
    /// swap(self: *Vector(u8), rhs: *Vector(u8)) void
    pub const swap = raw.ImVector_char_swap;
};

const FTABLE_ImVector_float = struct {
    /// init(self: *Vector(f32)) void
    pub const init = raw.ImVector_float_ImVector_float;
    /// initVector(self: *Vector(f32), src: Vector(f32)) void
    pub const initVector = raw.ImVector_float_ImVector_floatVector;
    /// _grow_capacity(self: *const Vector(f32), sz: i32) i32
    pub const _grow_capacity = raw.ImVector_float__grow_capacity;
    /// back(self: *Vector(f32)) *f32
    pub const back = raw.ImVector_float_back;
    /// back_const(self: *const Vector(f32)) *const f32
    pub const back_const = raw.ImVector_float_back_const;
    /// begin(self: *Vector(f32)) [*]f32
    pub const begin = raw.ImVector_float_begin;
    /// begin_const(self: *const Vector(f32)) [*]const f32
    pub const begin_const = raw.ImVector_float_begin_const;
    /// capacity(self: *const Vector(f32)) i32
    pub const capacity = raw.ImVector_float_capacity;
    /// clear(self: *Vector(f32)) void
    pub const clear = raw.ImVector_float_clear;
    /// contains(self: *const Vector(f32), v: f32) bool
    pub const contains = raw.ImVector_float_contains;
    /// deinit(self: *Vector(f32)) void
    pub const deinit = raw.ImVector_float_destroy;
    /// empty(self: *const Vector(f32)) bool
    pub const empty = raw.ImVector_float_empty;
    /// end(self: *Vector(f32)) [*]f32
    pub const end = raw.ImVector_float_end;
    /// end_const(self: *const Vector(f32)) [*]const f32
    pub const end_const = raw.ImVector_float_end_const;
    /// erase(self: *Vector(f32), it: [*]const f32) [*]f32
    pub const erase = raw.ImVector_float_erase;
    /// eraseTPtr(self: *Vector(f32), it: [*]const f32, it_last: [*]const f32) [*]f32
    pub const eraseTPtr = raw.ImVector_float_eraseTPtr;
    /// erase_unsorted(self: *Vector(f32), it: [*]const f32) [*]f32
    pub const erase_unsorted = raw.ImVector_float_erase_unsorted;
    /// find(self: *Vector(f32), v: f32) [*]f32
    pub const find = raw.ImVector_float_find;
    /// find_const(self: *const Vector(f32), v: f32) [*]const f32
    pub const find_const = raw.ImVector_float_find_const;
    /// find_erase(self: *Vector(f32), v: f32) bool
    pub const find_erase = raw.ImVector_float_find_erase;
    /// find_erase_unsorted(self: *Vector(f32), v: f32) bool
    pub const find_erase_unsorted = raw.ImVector_float_find_erase_unsorted;
    /// front(self: *Vector(f32)) *f32
    pub const front = raw.ImVector_float_front;
    /// front_const(self: *const Vector(f32)) *const f32
    pub const front_const = raw.ImVector_float_front_const;
    /// index_from_ptr(self: *const Vector(f32), it: [*]const f32) i32
    pub const index_from_ptr = raw.ImVector_float_index_from_ptr;
    /// insert(self: *Vector(f32), it: [*]const f32, v: f32) [*]f32
    pub const insert = raw.ImVector_float_insert;
    /// pop_back(self: *Vector(f32)) void
    pub const pop_back = raw.ImVector_float_pop_back;
    /// push_back(self: *Vector(f32), v: f32) void
    pub const push_back = raw.ImVector_float_push_back;
    /// push_front(self: *Vector(f32), v: f32) void
    pub const push_front = raw.ImVector_float_push_front;
    /// reserve(self: *Vector(f32), new_capacity: i32) void
    pub const reserve = raw.ImVector_float_reserve;
    /// resize(self: *Vector(f32), new_size: i32) void
    pub const resize = raw.ImVector_float_resize;
    /// resizeT(self: *Vector(f32), new_size: i32, v: f32) void
    pub const resizeT = raw.ImVector_float_resizeT;
    /// shrink(self: *Vector(f32), new_size: i32) void
    pub const shrink = raw.ImVector_float_shrink;
    /// size(self: *const Vector(f32)) i32
    pub const size = raw.ImVector_float_size;
    /// size_in_bytes(self: *const Vector(f32)) i32
    pub const size_in_bytes = raw.ImVector_float_size_in_bytes;
    /// swap(self: *Vector(f32), rhs: *Vector(f32)) void
    pub const swap = raw.ImVector_float_swap;
};

fn getFTABLE_ImVector(comptime T: type) type {
    if (T == DrawChannel) return FTABLE_ImVector_ImDrawChannel;
    if (T == DrawCmd) return FTABLE_ImVector_ImDrawCmd;
    if (T == DrawIdx) return FTABLE_ImVector_ImDrawIdx;
    if (T == DrawVert) return FTABLE_ImVector_ImDrawVert;
    if (T == *Font) return FTABLE_ImVector_ImFontPtr;
    if (T == FontAtlasCustomRect) return FTABLE_ImVector_ImFontAtlasCustomRect;
    if (T == FontConfig) return FTABLE_ImVector_ImFontConfig;
    if (T == FontGlyph) return FTABLE_ImVector_ImFontGlyph;
    if (T == StoragePair) return FTABLE_ImVector_ImGuiStoragePair;
    if (T == TextRange) return FTABLE_ImVector_ImGuiTextRange;
    if (T == TextureID) return FTABLE_ImVector_ImTextureID;
    if (T == u32) return FTABLE_ImVector_ImU32;
    if (T == Vec2) return FTABLE_ImVector_ImVec2;
    if (T == Vec4) return FTABLE_ImVector_ImVec4;
    if (T == Wchar) return FTABLE_ImVector_ImWchar;
    if (T == u8) return FTABLE_ImVector_char;
    if (T == f32) return FTABLE_ImVector_float;
    @compileError("Invalid Vector type");
}

pub fn Vector(comptime T: type) type {
    return extern struct {
        len: i32,
        capacity: i32,
        items: [*]T,

        pub usingnamespace getFTABLE_ImVector(T);
    };
}


pub inline fn AcceptDragDropPayloadExt(kind: ?[*:0]const u8, flags: DragDropFlags) ?*const Payload {
    return raw.igAcceptDragDropPayload(kind, flags.toInt());
}
pub inline fn AcceptDragDropPayload(kind: ?[*:0]const u8) ?*const Payload {
    return AcceptDragDropPayloadExt(kind, .{});
}

/// AlignTextToFramePadding() void
pub const AlignTextToFramePadding = raw.igAlignTextToFramePadding;

/// ArrowButton(str_id: ?[*:0]const u8, dir: Dir) bool
pub const ArrowButton = raw.igArrowButton;

pub inline fn BeginExt(name: ?[*:0]const u8, p_open: ?*bool, flags: WindowFlags) bool {
    return raw.igBegin(name, p_open, flags.toInt());
}
pub inline fn Begin(name: ?[*:0]const u8) bool {
    return BeginExt(name, null, .{});
}

pub inline fn BeginChildStrExt(str_id: ?[*:0]const u8, size: Vec2, border: bool, flags: WindowFlags) bool {
    return raw.igBeginChildStr(str_id, size, border, flags.toInt());
}
pub inline fn BeginChildStr(str_id: ?[*:0]const u8) bool {
    return BeginChildStrExt(str_id, .{.x=0,.y=0}, false, .{});
}

pub inline fn BeginChildIDExt(id: ID, size: Vec2, border: bool, flags: WindowFlags) bool {
    return raw.igBeginChildID(id, size, border, flags.toInt());
}
pub inline fn BeginChildID(id: ID) bool {
    return BeginChildIDExt(id, .{.x=0,.y=0}, false, .{});
}

pub inline fn BeginChildFrameExt(id: ID, size: Vec2, flags: WindowFlags) bool {
    return raw.igBeginChildFrame(id, size, flags.toInt());
}
pub inline fn BeginChildFrame(id: ID, size: Vec2) bool {
    return BeginChildFrameExt(id, size, .{});
}

pub inline fn BeginComboExt(label: ?[*:0]const u8, preview_value: ?[*:0]const u8, flags: ComboFlags) bool {
    return raw.igBeginCombo(label, preview_value, flags.toInt());
}
pub inline fn BeginCombo(label: ?[*:0]const u8, preview_value: ?[*:0]const u8) bool {
    return BeginComboExt(label, preview_value, .{});
}

pub inline fn BeginDragDropSourceExt(flags: DragDropFlags) bool {
    return raw.igBeginDragDropSource(flags.toInt());
}
pub inline fn BeginDragDropSource() bool {
    return BeginDragDropSourceExt(.{});
}

/// BeginDragDropTarget() bool
pub const BeginDragDropTarget = raw.igBeginDragDropTarget;

/// BeginGroup() void
pub const BeginGroup = raw.igBeginGroup;

/// BeginMainMenuBar() bool
pub const BeginMainMenuBar = raw.igBeginMainMenuBar;

/// BeginMenuExt(label: ?[*:0]const u8, enabled: bool) bool
pub const BeginMenuExt = raw.igBeginMenu;
pub inline fn BeginMenu(label: ?[*:0]const u8) bool {
    return BeginMenuExt(label, true);
}

/// BeginMenuBar() bool
pub const BeginMenuBar = raw.igBeginMenuBar;

pub inline fn BeginPopupExt(str_id: ?[*:0]const u8, flags: WindowFlags) bool {
    return raw.igBeginPopup(str_id, flags.toInt());
}
pub inline fn BeginPopup(str_id: ?[*:0]const u8) bool {
    return BeginPopupExt(str_id, .{});
}

/// BeginPopupContextItemExt(str_id: ?[*:0]const u8, mouse_button: MouseButton) bool
pub const BeginPopupContextItemExt = raw.igBeginPopupContextItem;
pub inline fn BeginPopupContextItem() bool {
    return BeginPopupContextItemExt(null, .Right);
}

/// BeginPopupContextVoidExt(str_id: ?[*:0]const u8, mouse_button: MouseButton) bool
pub const BeginPopupContextVoidExt = raw.igBeginPopupContextVoid;
pub inline fn BeginPopupContextVoid() bool {
    return BeginPopupContextVoidExt(null, .Right);
}

/// BeginPopupContextWindowExt(str_id: ?[*:0]const u8, mouse_button: MouseButton, also_over_items: bool) bool
pub const BeginPopupContextWindowExt = raw.igBeginPopupContextWindow;
pub inline fn BeginPopupContextWindow() bool {
    return BeginPopupContextWindowExt(null, .Right, true);
}

pub inline fn BeginPopupModalExt(name: ?[*:0]const u8, p_open: ?*bool, flags: WindowFlags) bool {
    return raw.igBeginPopupModal(name, p_open, flags.toInt());
}
pub inline fn BeginPopupModal(name: ?[*:0]const u8) bool {
    return BeginPopupModalExt(name, null, .{});
}

pub inline fn BeginTabBarExt(str_id: ?[*:0]const u8, flags: TabBarFlags) bool {
    return raw.igBeginTabBar(str_id, flags.toInt());
}
pub inline fn BeginTabBar(str_id: ?[*:0]const u8) bool {
    return BeginTabBarExt(str_id, .{});
}

pub inline fn BeginTabItemExt(label: ?[*:0]const u8, p_open: ?*bool, flags: TabItemFlags) bool {
    return raw.igBeginTabItem(label, p_open, flags.toInt());
}
pub inline fn BeginTabItem(label: ?[*:0]const u8) bool {
    return BeginTabItemExt(label, null, .{});
}

/// BeginTooltip() void
pub const BeginTooltip = raw.igBeginTooltip;

/// Bullet() void
pub const Bullet = raw.igBullet;

/// BulletText(fmt: ?[*:0]const u8, ...: ...) void
pub const BulletText = raw.igBulletText;

/// ButtonExt(label: ?[*:0]const u8, size: Vec2) bool
pub const ButtonExt = raw.igButton;
pub inline fn Button(label: ?[*:0]const u8) bool {
    return ButtonExt(label, .{.x=0,.y=0});
}

/// CalcItemWidth() f32
pub const CalcItemWidth = raw.igCalcItemWidth;

/// CalcListClipping(items_count: i32, items_height: f32, out_items_display_start: *i32, out_items_display_end: *i32) void
pub const CalcListClipping = raw.igCalcListClipping;

pub inline fn CalcTextSizeExt(text: ?[*]const u8, text_end: ?[*]const u8, hide_text_after_double_hash: bool, wrap_width: f32) Vec2 {
    var out: Vec2 = undefined;
    raw.igCalcTextSize_nonUDT(&out, text, text_end, hide_text_after_double_hash, wrap_width);
    return out;
}
pub inline fn CalcTextSize(text: ?[*]const u8) Vec2 {
    return CalcTextSizeExt(text, null, false, -1.0);
}

/// CaptureKeyboardFromAppExt(want_capture_keyboard_value: bool) void
pub const CaptureKeyboardFromAppExt = raw.igCaptureKeyboardFromApp;
pub inline fn CaptureKeyboardFromApp() void {
    return CaptureKeyboardFromAppExt(true);
}

/// CaptureMouseFromAppExt(want_capture_mouse_value: bool) void
pub const CaptureMouseFromAppExt = raw.igCaptureMouseFromApp;
pub inline fn CaptureMouseFromApp() void {
    return CaptureMouseFromAppExt(true);
}

/// Checkbox(label: ?[*:0]const u8, v: *bool) bool
pub const Checkbox = raw.igCheckbox;

/// CheckboxFlags(label: ?[*:0]const u8, flags: ?*u32, flags_value: u32) bool
pub const CheckboxFlags = raw.igCheckboxFlags;

/// CloseCurrentPopup() void
pub const CloseCurrentPopup = raw.igCloseCurrentPopup;

pub inline fn CollapsingHeaderExt(label: ?[*:0]const u8, flags: TreeNodeFlags) bool {
    return raw.igCollapsingHeader(label, flags.toInt());
}
pub inline fn CollapsingHeader(label: ?[*:0]const u8) bool {
    return CollapsingHeaderExt(label, .{});
}

pub inline fn CollapsingHeaderBoolPtrExt(label: ?[*:0]const u8, p_open: ?*bool, flags: TreeNodeFlags) bool {
    return raw.igCollapsingHeaderBoolPtr(label, p_open, flags.toInt());
}
pub inline fn CollapsingHeaderBoolPtr(label: ?[*:0]const u8, p_open: ?*bool) bool {
    return CollapsingHeaderBoolPtrExt(label, p_open, .{});
}

pub inline fn ColorButtonExt(desc_id: ?[*:0]const u8, col: Vec4, flags: ColorEditFlags, size: Vec2) bool {
    return raw.igColorButton(desc_id, col, flags.toInt(), size);
}
pub inline fn ColorButton(desc_id: ?[*:0]const u8, col: Vec4) bool {
    return ColorButtonExt(desc_id, col, .{}, .{.x=0,.y=0});
}

/// ColorConvertFloat4ToU32(in: Vec4) u32
pub const ColorConvertFloat4ToU32 = raw.igColorConvertFloat4ToU32;

/// ColorConvertHSVtoRGB(h: f32, s: f32, v: f32, out_r: *f32, out_g: *f32, out_b: *f32) void
pub const ColorConvertHSVtoRGB = raw.igColorConvertHSVtoRGB;

/// ColorConvertRGBtoHSV(r: f32, g: f32, b: f32, out_h: *f32, out_s: *f32, out_v: *f32) void
pub const ColorConvertRGBtoHSV = raw.igColorConvertRGBtoHSV;

pub inline fn ColorConvertU32ToFloat4(in: u32) Vec4 {
    var out: Vec4 = undefined;
    raw.igColorConvertU32ToFloat4_nonUDT(&out, in);
    return out;
}

pub inline fn ColorEdit3Ext(label: ?[*:0]const u8, col: *[3]f32, flags: ColorEditFlags) bool {
    return raw.igColorEdit3(label, col, flags.toInt());
}
pub inline fn ColorEdit3(label: ?[*:0]const u8, col: *[3]f32) bool {
    return ColorEdit3Ext(label, col, .{});
}

pub inline fn ColorEdit4Ext(label: ?[*:0]const u8, col: *[4]f32, flags: ColorEditFlags) bool {
    return raw.igColorEdit4(label, col, flags.toInt());
}
pub inline fn ColorEdit4(label: ?[*:0]const u8, col: *[4]f32) bool {
    return ColorEdit4Ext(label, col, .{});
}

pub inline fn ColorPicker3Ext(label: ?[*:0]const u8, col: *[3]f32, flags: ColorEditFlags) bool {
    return raw.igColorPicker3(label, col, flags.toInt());
}
pub inline fn ColorPicker3(label: ?[*:0]const u8, col: *[3]f32) bool {
    return ColorPicker3Ext(label, col, .{});
}

pub inline fn ColorPicker4Ext(label: ?[*:0]const u8, col: *[4]f32, flags: ColorEditFlags, ref_col: ?*const[4]f32) bool {
    return raw.igColorPicker4(label, col, flags.toInt(), ref_col);
}
pub inline fn ColorPicker4(label: ?[*:0]const u8, col: *[4]f32) bool {
    return ColorPicker4Ext(label, col, .{}, null);
}

/// ColumnsExt(count: i32, id: ?[*:0]const u8, border: bool) void
pub const ColumnsExt = raw.igColumns;
pub inline fn Columns() void {
    return ColumnsExt(1, null, true);
}

/// ComboExt(label: ?[*:0]const u8, current_item: ?*i32, items: [*]const[*:0]const u8, items_count: i32, popup_max_height_in_items: i32) bool
pub const ComboExt = raw.igCombo;
pub inline fn Combo(label: ?[*:0]const u8, current_item: ?*i32, items: [*]const[*:0]const u8, items_count: i32) bool {
    return ComboExt(label, current_item, items, items_count, -1);
}

/// ComboStrExt(label: ?[*:0]const u8, current_item: ?*i32, items_separated_by_zeros: ?[*]const u8, popup_max_height_in_items: i32) bool
pub const ComboStrExt = raw.igComboStr;
pub inline fn ComboStr(label: ?[*:0]const u8, current_item: ?*i32, items_separated_by_zeros: ?[*]const u8) bool {
    return ComboStrExt(label, current_item, items_separated_by_zeros, -1);
}

/// ComboFnPtrExt(label: ?[*:0]const u8, current_item: ?*i32, items_getter: ?fn (data: ?*c_void, idx: i32, out_text: *?[*:0]const u8) callconv(.C) bool, data: ?*c_void, items_count: i32, popup_max_height_in_items: i32) bool
pub const ComboFnPtrExt = raw.igComboFnPtr;
pub inline fn ComboFnPtr(label: ?[*:0]const u8, current_item: ?*i32, items_getter: ?fn (data: ?*c_void, idx: i32, out_text: *?[*:0]const u8) callconv(.C) bool, data: ?*c_void, items_count: i32) bool {
    return ComboFnPtrExt(label, current_item, items_getter, data, items_count, -1);
}

/// CreateContextExt(shared_font_atlas: ?*FontAtlas) ?*Context
pub const CreateContextExt = raw.igCreateContext;
pub inline fn CreateContext() ?*Context {
    return CreateContextExt(null);
}

/// DebugCheckVersionAndDataLayout(version_str: ?[*:0]const u8, sz_io: usize, sz_style: usize, sz_vec2: usize, sz_vec4: usize, sz_drawvert: usize, sz_drawidx: usize) bool
pub const DebugCheckVersionAndDataLayout = raw.igDebugCheckVersionAndDataLayout;

/// DestroyContextExt(ctx: ?*Context) void
pub const DestroyContextExt = raw.igDestroyContext;
pub inline fn DestroyContext() void {
    return DestroyContextExt(null);
}

/// DragFloatExt(label: ?[*:0]const u8, v: *f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) bool
pub const DragFloatExt = raw.igDragFloat;
pub inline fn DragFloat(label: ?[*:0]const u8, v: *f32) bool {
    return DragFloatExt(label, v, 1.0, 0.0, 0.0, "%.3f", 1.0);
}

/// DragFloat2Ext(label: ?[*:0]const u8, v: *[2]f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) bool
pub const DragFloat2Ext = raw.igDragFloat2;
pub inline fn DragFloat2(label: ?[*:0]const u8, v: *[2]f32) bool {
    return DragFloat2Ext(label, v, 1.0, 0.0, 0.0, "%.3f", 1.0);
}

/// DragFloat3Ext(label: ?[*:0]const u8, v: *[3]f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) bool
pub const DragFloat3Ext = raw.igDragFloat3;
pub inline fn DragFloat3(label: ?[*:0]const u8, v: *[3]f32) bool {
    return DragFloat3Ext(label, v, 1.0, 0.0, 0.0, "%.3f", 1.0);
}

/// DragFloat4Ext(label: ?[*:0]const u8, v: *[4]f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) bool
pub const DragFloat4Ext = raw.igDragFloat4;
pub inline fn DragFloat4(label: ?[*:0]const u8, v: *[4]f32) bool {
    return DragFloat4Ext(label, v, 1.0, 0.0, 0.0, "%.3f", 1.0);
}

/// DragFloatRange2Ext(label: ?[*:0]const u8, v_current_min: *f32, v_current_max: *f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, format_max: ?[*:0]const u8, power: f32) bool
pub const DragFloatRange2Ext = raw.igDragFloatRange2;
pub inline fn DragFloatRange2(label: ?[*:0]const u8, v_current_min: *f32, v_current_max: *f32) bool {
    return DragFloatRange2Ext(label, v_current_min, v_current_max, 1.0, 0.0, 0.0, "%.3f", null, 1.0);
}

/// DragIntExt(label: ?[*:0]const u8, v: *i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8) bool
pub const DragIntExt = raw.igDragInt;
pub inline fn DragInt(label: ?[*:0]const u8, v: *i32) bool {
    return DragIntExt(label, v, 1.0, 0, 0, "%d");
}

/// DragInt2Ext(label: ?[*:0]const u8, v: *[2]i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8) bool
pub const DragInt2Ext = raw.igDragInt2;
pub inline fn DragInt2(label: ?[*:0]const u8, v: *[2]i32) bool {
    return DragInt2Ext(label, v, 1.0, 0, 0, "%d");
}

/// DragInt3Ext(label: ?[*:0]const u8, v: *[3]i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8) bool
pub const DragInt3Ext = raw.igDragInt3;
pub inline fn DragInt3(label: ?[*:0]const u8, v: *[3]i32) bool {
    return DragInt3Ext(label, v, 1.0, 0, 0, "%d");
}

/// DragInt4Ext(label: ?[*:0]const u8, v: *[4]i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8) bool
pub const DragInt4Ext = raw.igDragInt4;
pub inline fn DragInt4(label: ?[*:0]const u8, v: *[4]i32) bool {
    return DragInt4Ext(label, v, 1.0, 0, 0, "%d");
}

/// DragIntRange2Ext(label: ?[*:0]const u8, v_current_min: *i32, v_current_max: *i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8, format_max: ?[*:0]const u8) bool
pub const DragIntRange2Ext = raw.igDragIntRange2;
pub inline fn DragIntRange2(label: ?[*:0]const u8, v_current_min: *i32, v_current_max: *i32) bool {
    return DragIntRange2Ext(label, v_current_min, v_current_max, 1.0, 0, 0, "%d", null);
}

/// DragScalarExt(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, v_speed: f32, p_min: ?*const c_void, p_max: ?*const c_void, format: ?[*:0]const u8, power: f32) bool
pub const DragScalarExt = raw.igDragScalar;
pub inline fn DragScalar(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, v_speed: f32) bool {
    return DragScalarExt(label, data_type, p_data, v_speed, null, null, null, 1.0);
}

/// DragScalarNExt(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, components: i32, v_speed: f32, p_min: ?*const c_void, p_max: ?*const c_void, format: ?[*:0]const u8, power: f32) bool
pub const DragScalarNExt = raw.igDragScalarN;
pub inline fn DragScalarN(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, components: i32, v_speed: f32) bool {
    return DragScalarNExt(label, data_type, p_data, components, v_speed, null, null, null, 1.0);
}

/// Dummy(size: Vec2) void
pub const Dummy = raw.igDummy;

/// End() void
pub const End = raw.igEnd;

/// EndChild() void
pub const EndChild = raw.igEndChild;

/// EndChildFrame() void
pub const EndChildFrame = raw.igEndChildFrame;

/// EndCombo() void
pub const EndCombo = raw.igEndCombo;

/// EndDragDropSource() void
pub const EndDragDropSource = raw.igEndDragDropSource;

/// EndDragDropTarget() void
pub const EndDragDropTarget = raw.igEndDragDropTarget;

/// EndFrame() void
pub const EndFrame = raw.igEndFrame;

/// EndGroup() void
pub const EndGroup = raw.igEndGroup;

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

/// EndTooltip() void
pub const EndTooltip = raw.igEndTooltip;

/// GetBackgroundDrawList() ?*DrawList
pub const GetBackgroundDrawList = raw.igGetBackgroundDrawList;

/// GetClipboardText() ?[*:0]const u8
pub const GetClipboardText = raw.igGetClipboardText;

/// GetColorU32Ext(idx: Col, alpha_mul: f32) u32
pub const GetColorU32Ext = raw.igGetColorU32;
pub inline fn GetColorU32(idx: Col) u32 {
    return GetColorU32Ext(idx, 1.0);
}

/// GetColorU32Vec4(col: Vec4) u32
pub const GetColorU32Vec4 = raw.igGetColorU32Vec4;

/// GetColorU32U32(col: u32) u32
pub const GetColorU32U32 = raw.igGetColorU32U32;

/// GetColumnIndex() i32
pub const GetColumnIndex = raw.igGetColumnIndex;

/// GetColumnOffsetExt(column_index: i32) f32
pub const GetColumnOffsetExt = raw.igGetColumnOffset;
pub inline fn GetColumnOffset() f32 {
    return GetColumnOffsetExt(-1);
}

/// GetColumnWidthExt(column_index: i32) f32
pub const GetColumnWidthExt = raw.igGetColumnWidth;
pub inline fn GetColumnWidth() f32 {
    return GetColumnWidthExt(-1);
}

/// GetColumnsCount() i32
pub const GetColumnsCount = raw.igGetColumnsCount;

pub inline fn GetContentRegionAvail() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetContentRegionAvail_nonUDT(&out);
    return out;
}

pub inline fn GetContentRegionMax() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetContentRegionMax_nonUDT(&out);
    return out;
}

/// GetCurrentContext() ?*Context
pub const GetCurrentContext = raw.igGetCurrentContext;

pub inline fn GetCursorPos() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetCursorPos_nonUDT(&out);
    return out;
}

/// GetCursorPosX() f32
pub const GetCursorPosX = raw.igGetCursorPosX;

/// GetCursorPosY() f32
pub const GetCursorPosY = raw.igGetCursorPosY;

pub inline fn GetCursorScreenPos() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetCursorScreenPos_nonUDT(&out);
    return out;
}

pub inline fn GetCursorStartPos() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetCursorStartPos_nonUDT(&out);
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
    raw.igGetFontTexUvWhitePixel_nonUDT(&out);
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

/// GetIDStr(str_id: ?[*:0]const u8) ID
pub const GetIDStr = raw.igGetIDStr;

/// GetIDRange(str_id_begin: ?[*]const u8, str_id_end: ?[*]const u8) ID
pub const GetIDRange = raw.igGetIDRange;

/// GetIDPtr(ptr_id: ?*const c_void) ID
pub const GetIDPtr = raw.igGetIDPtr;

/// GetIO() *IO
pub const GetIO = raw.igGetIO;

pub inline fn GetItemRectMax() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetItemRectMax_nonUDT(&out);
    return out;
}

pub inline fn GetItemRectMin() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetItemRectMin_nonUDT(&out);
    return out;
}

pub inline fn GetItemRectSize() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetItemRectSize_nonUDT(&out);
    return out;
}

/// GetKeyIndex(imgui_key: Key) i32
pub const GetKeyIndex = raw.igGetKeyIndex;

/// GetKeyPressedAmount(key_index: i32, repeat_delay: f32, rate: f32) i32
pub const GetKeyPressedAmount = raw.igGetKeyPressedAmount;

/// GetMouseCursor() MouseCursor
pub const GetMouseCursor = raw.igGetMouseCursor;

pub inline fn GetMouseDragDeltaExt(button: MouseButton, lock_threshold: f32) Vec2 {
    var out: Vec2 = undefined;
    raw.igGetMouseDragDelta_nonUDT(&out, button, lock_threshold);
    return out;
}
pub inline fn GetMouseDragDelta() Vec2 {
    return GetMouseDragDeltaExt(.Left, -1.0);
}

pub inline fn GetMousePos() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetMousePos_nonUDT(&out);
    return out;
}

pub inline fn GetMousePosOnOpeningCurrentPopup() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetMousePosOnOpeningCurrentPopup_nonUDT(&out);
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
    raw.igGetWindowContentRegionMax_nonUDT(&out);
    return out;
}

pub inline fn GetWindowContentRegionMin() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetWindowContentRegionMin_nonUDT(&out);
    return out;
}

/// GetWindowContentRegionWidth() f32
pub const GetWindowContentRegionWidth = raw.igGetWindowContentRegionWidth;

/// GetWindowDrawList() ?*DrawList
pub const GetWindowDrawList = raw.igGetWindowDrawList;

/// GetWindowHeight() f32
pub const GetWindowHeight = raw.igGetWindowHeight;

pub inline fn GetWindowPos() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetWindowPos_nonUDT(&out);
    return out;
}

pub inline fn GetWindowSize() Vec2 {
    var out: Vec2 = undefined;
    raw.igGetWindowSize_nonUDT(&out);
    return out;
}

/// GetWindowWidth() f32
pub const GetWindowWidth = raw.igGetWindowWidth;

/// ImageExt(user_texture_id: TextureID, size: Vec2, uv0: Vec2, uv1: Vec2, tint_col: Vec4, border_col: Vec4) void
pub const ImageExt = raw.igImage;
pub inline fn Image(user_texture_id: TextureID, size: Vec2) void {
    return ImageExt(user_texture_id, size, .{.x=0,.y=0}, .{.x=1,.y=1}, .{.x=1,.y=1,.z=1,.w=1}, .{.x=0,.y=0,.z=0,.w=0});
}

/// ImageButtonExt(user_texture_id: TextureID, size: Vec2, uv0: Vec2, uv1: Vec2, frame_padding: i32, bg_col: Vec4, tint_col: Vec4) bool
pub const ImageButtonExt = raw.igImageButton;
pub inline fn ImageButton(user_texture_id: TextureID, size: Vec2) bool {
    return ImageButtonExt(user_texture_id, size, .{.x=0,.y=0}, .{.x=1,.y=1}, -1, .{.x=0,.y=0,.z=0,.w=0}, .{.x=1,.y=1,.z=1,.w=1});
}

/// IndentExt(indent_w: f32) void
pub const IndentExt = raw.igIndent;
pub inline fn Indent() void {
    return IndentExt(0.0);
}

pub inline fn InputDoubleExt(label: ?[*:0]const u8, v: *f64, step: f64, step_fast: f64, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputDouble(label, v, step, step_fast, format, flags.toInt());
}
pub inline fn InputDouble(label: ?[*:0]const u8, v: *f64) bool {
    return InputDoubleExt(label, v, 0.0, 0.0, "%.6f", .{});
}

pub inline fn InputFloatExt(label: ?[*:0]const u8, v: *f32, step: f32, step_fast: f32, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputFloat(label, v, step, step_fast, format, flags.toInt());
}
pub inline fn InputFloat(label: ?[*:0]const u8, v: *f32) bool {
    return InputFloatExt(label, v, 0.0, 0.0, "%.3f", .{});
}

pub inline fn InputFloat2Ext(label: ?[*:0]const u8, v: *[2]f32, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputFloat2(label, v, format, flags.toInt());
}
pub inline fn InputFloat2(label: ?[*:0]const u8, v: *[2]f32) bool {
    return InputFloat2Ext(label, v, "%.3f", .{});
}

pub inline fn InputFloat3Ext(label: ?[*:0]const u8, v: *[3]f32, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputFloat3(label, v, format, flags.toInt());
}
pub inline fn InputFloat3(label: ?[*:0]const u8, v: *[3]f32) bool {
    return InputFloat3Ext(label, v, "%.3f", .{});
}

pub inline fn InputFloat4Ext(label: ?[*:0]const u8, v: *[4]f32, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputFloat4(label, v, format, flags.toInt());
}
pub inline fn InputFloat4(label: ?[*:0]const u8, v: *[4]f32) bool {
    return InputFloat4Ext(label, v, "%.3f", .{});
}

pub inline fn InputIntExt(label: ?[*:0]const u8, v: *i32, step: i32, step_fast: i32, flags: InputTextFlags) bool {
    return raw.igInputInt(label, v, step, step_fast, flags.toInt());
}
pub inline fn InputInt(label: ?[*:0]const u8, v: *i32) bool {
    return InputIntExt(label, v, 1, 100, .{});
}

pub inline fn InputInt2Ext(label: ?[*:0]const u8, v: *[2]i32, flags: InputTextFlags) bool {
    return raw.igInputInt2(label, v, flags.toInt());
}
pub inline fn InputInt2(label: ?[*:0]const u8, v: *[2]i32) bool {
    return InputInt2Ext(label, v, .{});
}

pub inline fn InputInt3Ext(label: ?[*:0]const u8, v: *[3]i32, flags: InputTextFlags) bool {
    return raw.igInputInt3(label, v, flags.toInt());
}
pub inline fn InputInt3(label: ?[*:0]const u8, v: *[3]i32) bool {
    return InputInt3Ext(label, v, .{});
}

pub inline fn InputInt4Ext(label: ?[*:0]const u8, v: *[4]i32, flags: InputTextFlags) bool {
    return raw.igInputInt4(label, v, flags.toInt());
}
pub inline fn InputInt4(label: ?[*:0]const u8, v: *[4]i32) bool {
    return InputInt4Ext(label, v, .{});
}

pub inline fn InputScalarExt(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, p_step: ?*const c_void, p_step_fast: ?*const c_void, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputScalar(label, data_type, p_data, p_step, p_step_fast, format, flags.toInt());
}
pub inline fn InputScalar(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void) bool {
    return InputScalarExt(label, data_type, p_data, null, null, null, .{});
}

pub inline fn InputScalarNExt(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, components: i32, p_step: ?*const c_void, p_step_fast: ?*const c_void, format: ?[*:0]const u8, flags: InputTextFlags) bool {
    return raw.igInputScalarN(label, data_type, p_data, components, p_step, p_step_fast, format, flags.toInt());
}
pub inline fn InputScalarN(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, components: i32) bool {
    return InputScalarNExt(label, data_type, p_data, components, null, null, null, .{});
}

pub inline fn InputTextExt(label: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize, flags: InputTextFlags, callback: InputTextCallback, user_data: ?*c_void) bool {
    return raw.igInputText(label, buf, buf_size, flags.toInt(), callback, user_data);
}
pub inline fn InputText(label: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize) bool {
    return InputTextExt(label, buf, buf_size, .{}, null, null);
}

pub inline fn InputTextMultilineExt(label: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize, size: Vec2, flags: InputTextFlags, callback: InputTextCallback, user_data: ?*c_void) bool {
    return raw.igInputTextMultiline(label, buf, buf_size, size, flags.toInt(), callback, user_data);
}
pub inline fn InputTextMultiline(label: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize) bool {
    return InputTextMultilineExt(label, buf, buf_size, .{.x=0,.y=0}, .{}, null, null);
}

pub inline fn InputTextWithHintExt(label: ?[*:0]const u8, hint: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize, flags: InputTextFlags, callback: InputTextCallback, user_data: ?*c_void) bool {
    return raw.igInputTextWithHint(label, hint, buf, buf_size, flags.toInt(), callback, user_data);
}
pub inline fn InputTextWithHint(label: ?[*:0]const u8, hint: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize) bool {
    return InputTextWithHintExt(label, hint, buf, buf_size, .{}, null, null);
}

/// InvisibleButton(str_id: ?[*:0]const u8, size: Vec2) bool
pub const InvisibleButton = raw.igInvisibleButton;

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
    return IsItemClickedExt(.Left);
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
    return IsItemHoveredExt(.{});
}

/// IsItemToggledOpen() bool
pub const IsItemToggledOpen = raw.igIsItemToggledOpen;

/// IsItemVisible() bool
pub const IsItemVisible = raw.igIsItemVisible;

/// IsKeyDown(user_key_index: i32) bool
pub const IsKeyDown = raw.igIsKeyDown;

/// IsKeyPressedExt(user_key_index: i32, repeat: bool) bool
pub const IsKeyPressedExt = raw.igIsKeyPressed;
pub inline fn IsKeyPressed(user_key_index: i32) bool {
    return IsKeyPressedExt(user_key_index, true);
}

/// IsKeyReleased(user_key_index: i32) bool
pub const IsKeyReleased = raw.igIsKeyReleased;

/// IsMouseClickedExt(button: MouseButton, repeat: bool) bool
pub const IsMouseClickedExt = raw.igIsMouseClicked;
pub inline fn IsMouseClicked(button: MouseButton) bool {
    return IsMouseClickedExt(button, false);
}

/// IsMouseDoubleClicked(button: MouseButton) bool
pub const IsMouseDoubleClicked = raw.igIsMouseDoubleClicked;

/// IsMouseDown(button: MouseButton) bool
pub const IsMouseDown = raw.igIsMouseDown;

/// IsMouseDraggingExt(button: MouseButton, lock_threshold: f32) bool
pub const IsMouseDraggingExt = raw.igIsMouseDragging;
pub inline fn IsMouseDragging(button: MouseButton) bool {
    return IsMouseDraggingExt(button, -1.0);
}

/// IsMouseHoveringRectExt(r_min: Vec2, r_max: Vec2, clip: bool) bool
pub const IsMouseHoveringRectExt = raw.igIsMouseHoveringRect;
pub inline fn IsMouseHoveringRect(r_min: Vec2, r_max: Vec2) bool {
    return IsMouseHoveringRectExt(r_min, r_max, true);
}

/// IsMousePosValidExt(mouse_pos: ?*const Vec2) bool
pub const IsMousePosValidExt = raw.igIsMousePosValid;
pub inline fn IsMousePosValid() bool {
    return IsMousePosValidExt(null);
}

/// IsMouseReleased(button: MouseButton) bool
pub const IsMouseReleased = raw.igIsMouseReleased;

/// IsPopupOpen(str_id: ?[*:0]const u8) bool
pub const IsPopupOpen = raw.igIsPopupOpen;

/// IsRectVisible(size: Vec2) bool
pub const IsRectVisible = raw.igIsRectVisible;

/// IsRectVisibleVec2(rect_min: Vec2, rect_max: Vec2) bool
pub const IsRectVisibleVec2 = raw.igIsRectVisibleVec2;

/// IsWindowAppearing() bool
pub const IsWindowAppearing = raw.igIsWindowAppearing;

/// IsWindowCollapsed() bool
pub const IsWindowCollapsed = raw.igIsWindowCollapsed;

pub inline fn IsWindowFocusedExt(flags: FocusedFlags) bool {
    return raw.igIsWindowFocused(flags.toInt());
}
pub inline fn IsWindowFocused() bool {
    return IsWindowFocusedExt(.{});
}

pub inline fn IsWindowHoveredExt(flags: HoveredFlags) bool {
    return raw.igIsWindowHovered(flags.toInt());
}
pub inline fn IsWindowHovered() bool {
    return IsWindowHoveredExt(.{});
}

/// LabelText(label: ?[*:0]const u8, fmt: ?[*:0]const u8, ...: ...) void
pub const LabelText = raw.igLabelText;

/// ListBoxStr_arrExt(label: ?[*:0]const u8, current_item: ?*i32, items: [*]const[*:0]const u8, items_count: i32, height_in_items: i32) bool
pub const ListBoxStr_arrExt = raw.igListBoxStr_arr;
pub inline fn ListBoxStr_arr(label: ?[*:0]const u8, current_item: ?*i32, items: [*]const[*:0]const u8, items_count: i32) bool {
    return ListBoxStr_arrExt(label, current_item, items, items_count, -1);
}

/// ListBoxFnPtrExt(label: ?[*:0]const u8, current_item: ?*i32, items_getter: ?fn (data: ?*c_void, idx: i32, out_text: *?[*:0]const u8) callconv(.C) bool, data: ?*c_void, items_count: i32, height_in_items: i32) bool
pub const ListBoxFnPtrExt = raw.igListBoxFnPtr;
pub inline fn ListBoxFnPtr(label: ?[*:0]const u8, current_item: ?*i32, items_getter: ?fn (data: ?*c_void, idx: i32, out_text: *?[*:0]const u8) callconv(.C) bool, data: ?*c_void, items_count: i32) bool {
    return ListBoxFnPtrExt(label, current_item, items_getter, data, items_count, -1);
}

/// ListBoxFooter() void
pub const ListBoxFooter = raw.igListBoxFooter;

/// ListBoxHeaderVec2Ext(label: ?[*:0]const u8, size: Vec2) bool
pub const ListBoxHeaderVec2Ext = raw.igListBoxHeaderVec2;
pub inline fn ListBoxHeaderVec2(label: ?[*:0]const u8) bool {
    return ListBoxHeaderVec2Ext(label, .{.x=0,.y=0});
}

/// ListBoxHeaderIntExt(label: ?[*:0]const u8, items_count: i32, height_in_items: i32) bool
pub const ListBoxHeaderIntExt = raw.igListBoxHeaderInt;
pub inline fn ListBoxHeaderInt(label: ?[*:0]const u8, items_count: i32) bool {
    return ListBoxHeaderIntExt(label, items_count, -1);
}

/// LoadIniSettingsFromDisk(ini_filename: ?[*:0]const u8) void
pub const LoadIniSettingsFromDisk = raw.igLoadIniSettingsFromDisk;

/// LoadIniSettingsFromMemoryExt(ini_data: ?[*]const u8, ini_size: usize) void
pub const LoadIniSettingsFromMemoryExt = raw.igLoadIniSettingsFromMemory;
pub inline fn LoadIniSettingsFromMemory(ini_data: ?[*]const u8) void {
    return LoadIniSettingsFromMemoryExt(ini_data, 0);
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
    return LogToClipboardExt(-1);
}

/// LogToFileExt(auto_open_depth: i32, filename: ?[*:0]const u8) void
pub const LogToFileExt = raw.igLogToFile;
pub inline fn LogToFile() void {
    return LogToFileExt(-1, null);
}

/// LogToTTYExt(auto_open_depth: i32) void
pub const LogToTTYExt = raw.igLogToTTY;
pub inline fn LogToTTY() void {
    return LogToTTYExt(-1);
}

/// MemAlloc(size: usize) ?*c_void
pub const MemAlloc = raw.igMemAlloc;

/// MemFree(ptr: ?*c_void) void
pub const MemFree = raw.igMemFree;

/// MenuItemBoolExt(label: ?[*:0]const u8, shortcut: ?[*:0]const u8, selected: bool, enabled: bool) bool
pub const MenuItemBoolExt = raw.igMenuItemBool;
pub inline fn MenuItemBool(label: ?[*:0]const u8) bool {
    return MenuItemBoolExt(label, null, false, true);
}

/// MenuItemBoolPtrExt(label: ?[*:0]const u8, shortcut: ?[*:0]const u8, p_selected: ?*bool, enabled: bool) bool
pub const MenuItemBoolPtrExt = raw.igMenuItemBoolPtr;
pub inline fn MenuItemBoolPtr(label: ?[*:0]const u8, shortcut: ?[*:0]const u8, p_selected: ?*bool) bool {
    return MenuItemBoolPtrExt(label, shortcut, p_selected, true);
}

/// NewFrame() void
pub const NewFrame = raw.igNewFrame;

/// NewLine() void
pub const NewLine = raw.igNewLine;

/// NextColumn() void
pub const NextColumn = raw.igNextColumn;

/// OpenPopup(str_id: ?[*:0]const u8) void
pub const OpenPopup = raw.igOpenPopup;

/// OpenPopupOnItemClickExt(str_id: ?[*:0]const u8, mouse_button: MouseButton) bool
pub const OpenPopupOnItemClickExt = raw.igOpenPopupOnItemClick;
pub inline fn OpenPopupOnItemClick() bool {
    return OpenPopupOnItemClickExt(null, .Right);
}

/// PlotHistogramFloatPtrExt(label: ?[*:0]const u8, values: *const f32, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2, stride: i32) void
pub const PlotHistogramFloatPtrExt = raw.igPlotHistogramFloatPtr;
pub inline fn PlotHistogramFloatPtr(label: ?[*:0]const u8, values: *const f32, values_count: i32) void {
    return PlotHistogramFloatPtrExt(label, values, values_count, 0, null, FLT_MAX, FLT_MAX, .{.x=0,.y=0}, @sizeOf(f32));
}

/// PlotHistogramFnPtrExt(label: ?[*:0]const u8, values_getter: ?fn (data: ?*c_void, idx: i32) callconv(.C) f32, data: ?*c_void, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2) void
pub const PlotHistogramFnPtrExt = raw.igPlotHistogramFnPtr;
pub inline fn PlotHistogramFnPtr(label: ?[*:0]const u8, values_getter: ?fn (data: ?*c_void, idx: i32) callconv(.C) f32, data: ?*c_void, values_count: i32) void {
    return PlotHistogramFnPtrExt(label, values_getter, data, values_count, 0, null, FLT_MAX, FLT_MAX, .{.x=0,.y=0});
}

/// PlotLinesExt(label: ?[*:0]const u8, values: *const f32, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2, stride: i32) void
pub const PlotLinesExt = raw.igPlotLines;
pub inline fn PlotLines(label: ?[*:0]const u8, values: *const f32, values_count: i32) void {
    return PlotLinesExt(label, values, values_count, 0, null, FLT_MAX, FLT_MAX, .{.x=0,.y=0}, @sizeOf(f32));
}

/// PlotLinesFnPtrExt(label: ?[*:0]const u8, values_getter: ?fn (data: ?*c_void, idx: i32) callconv(.C) f32, data: ?*c_void, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2) void
pub const PlotLinesFnPtrExt = raw.igPlotLinesFnPtr;
pub inline fn PlotLinesFnPtr(label: ?[*:0]const u8, values_getter: ?fn (data: ?*c_void, idx: i32) callconv(.C) f32, data: ?*c_void, values_count: i32) void {
    return PlotLinesFnPtrExt(label, values_getter, data, values_count, 0, null, FLT_MAX, FLT_MAX, .{.x=0,.y=0});
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
    return PopStyleColorExt(1);
}

/// PopStyleVarExt(count: i32) void
pub const PopStyleVarExt = raw.igPopStyleVar;
pub inline fn PopStyleVar() void {
    return PopStyleVarExt(1);
}

/// PopTextWrapPos() void
pub const PopTextWrapPos = raw.igPopTextWrapPos;

/// ProgressBarExt(fraction: f32, size_arg: Vec2, overlay: ?[*:0]const u8) void
pub const ProgressBarExt = raw.igProgressBar;
pub inline fn ProgressBar(fraction: f32) void {
    return ProgressBarExt(fraction, .{.x=-1,.y=0}, null);
}

/// PushAllowKeyboardFocus(allow_keyboard_focus: bool) void
pub const PushAllowKeyboardFocus = raw.igPushAllowKeyboardFocus;

/// PushButtonRepeat(repeat: bool) void
pub const PushButtonRepeat = raw.igPushButtonRepeat;

/// PushClipRect(clip_rect_min: Vec2, clip_rect_max: Vec2, intersect_with_current_clip_rect: bool) void
pub const PushClipRect = raw.igPushClipRect;

/// PushFont(font: ?*Font) void
pub const PushFont = raw.igPushFont;

/// PushIDStr(str_id: ?[*:0]const u8) void
pub const PushIDStr = raw.igPushIDStr;

/// PushIDRange(str_id_begin: ?[*]const u8, str_id_end: ?[*]const u8) void
pub const PushIDRange = raw.igPushIDRange;

/// PushIDPtr(ptr_id: ?*const c_void) void
pub const PushIDPtr = raw.igPushIDPtr;

/// PushIDInt(int_id: i32) void
pub const PushIDInt = raw.igPushIDInt;

/// PushItemWidth(item_width: f32) void
pub const PushItemWidth = raw.igPushItemWidth;

/// PushStyleColorU32(idx: Col, col: u32) void
pub const PushStyleColorU32 = raw.igPushStyleColorU32;

/// PushStyleColorVec4(idx: Col, col: Vec4) void
pub const PushStyleColorVec4 = raw.igPushStyleColorVec4;

/// PushStyleVarFloat(idx: StyleVar, val: f32) void
pub const PushStyleVarFloat = raw.igPushStyleVarFloat;

/// PushStyleVarVec2(idx: StyleVar, val: Vec2) void
pub const PushStyleVarVec2 = raw.igPushStyleVarVec2;

/// PushTextWrapPosExt(wrap_local_pos_x: f32) void
pub const PushTextWrapPosExt = raw.igPushTextWrapPos;
pub inline fn PushTextWrapPos() void {
    return PushTextWrapPosExt(0.0);
}

/// RadioButtonBool(label: ?[*:0]const u8, active: bool) bool
pub const RadioButtonBool = raw.igRadioButtonBool;

/// RadioButtonIntPtr(label: ?[*:0]const u8, v: *i32, v_button: i32) bool
pub const RadioButtonIntPtr = raw.igRadioButtonIntPtr;

/// Render() void
pub const Render = raw.igRender;

/// ResetMouseDragDeltaExt(button: MouseButton) void
pub const ResetMouseDragDeltaExt = raw.igResetMouseDragDelta;
pub inline fn ResetMouseDragDelta() void {
    return ResetMouseDragDeltaExt(.Left);
}

/// SameLineExt(offset_from_start_x: f32, spacing: f32) void
pub const SameLineExt = raw.igSameLine;
pub inline fn SameLine() void {
    return SameLineExt(0.0, -1.0);
}

/// SaveIniSettingsToDisk(ini_filename: ?[*:0]const u8) void
pub const SaveIniSettingsToDisk = raw.igSaveIniSettingsToDisk;

/// SaveIniSettingsToMemoryExt(out_ini_size: ?*usize) ?[*:0]const u8
pub const SaveIniSettingsToMemoryExt = raw.igSaveIniSettingsToMemory;
pub inline fn SaveIniSettingsToMemory() ?[*:0]const u8 {
    return SaveIniSettingsToMemoryExt(null);
}

pub inline fn SelectableBoolExt(label: ?[*:0]const u8, selected: bool, flags: SelectableFlags, size: Vec2) bool {
    return raw.igSelectableBool(label, selected, flags.toInt(), size);
}
pub inline fn SelectableBool(label: ?[*:0]const u8) bool {
    return SelectableBoolExt(label, false, .{}, .{.x=0,.y=0});
}

pub inline fn SelectableBoolPtrExt(label: ?[*:0]const u8, p_selected: ?*bool, flags: SelectableFlags, size: Vec2) bool {
    return raw.igSelectableBoolPtr(label, p_selected, flags.toInt(), size);
}
pub inline fn SelectableBoolPtr(label: ?[*:0]const u8, p_selected: ?*bool) bool {
    return SelectableBoolPtrExt(label, p_selected, .{}, .{.x=0,.y=0});
}

/// Separator() void
pub const Separator = raw.igSeparator;

/// SetAllocatorFunctionsExt(alloc_func: ?fn (sz: usize, user_data: ?*c_void) callconv(.C) ?*c_void, free_func: ?fn (ptr: ?*c_void, user_data: ?*c_void) callconv(.C) void, user_data: ?*c_void) void
pub const SetAllocatorFunctionsExt = raw.igSetAllocatorFunctions;
pub inline fn SetAllocatorFunctions(alloc_func: ?fn (sz: usize, user_data: ?*c_void) callconv(.C) ?*c_void, free_func: ?fn (ptr: ?*c_void, user_data: ?*c_void) callconv(.C) void) void {
    return SetAllocatorFunctionsExt(alloc_func, free_func, null);
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

/// SetCursorPos(local_pos: Vec2) void
pub const SetCursorPos = raw.igSetCursorPos;

/// SetCursorPosX(local_x: f32) void
pub const SetCursorPosX = raw.igSetCursorPosX;

/// SetCursorPosY(local_y: f32) void
pub const SetCursorPosY = raw.igSetCursorPosY;

/// SetCursorScreenPos(pos: Vec2) void
pub const SetCursorScreenPos = raw.igSetCursorScreenPos;

pub inline fn SetDragDropPayloadExt(kind: ?[*:0]const u8, data: ?*const c_void, sz: usize, cond: CondFlags) bool {
    return raw.igSetDragDropPayload(kind, data, sz, cond.toInt());
}
pub inline fn SetDragDropPayload(kind: ?[*:0]const u8, data: ?*const c_void, sz: usize) bool {
    return SetDragDropPayloadExt(kind, data, sz, .{});
}

/// SetItemAllowOverlap() void
pub const SetItemAllowOverlap = raw.igSetItemAllowOverlap;

/// SetItemDefaultFocus() void
pub const SetItemDefaultFocus = raw.igSetItemDefaultFocus;

/// SetKeyboardFocusHereExt(offset: i32) void
pub const SetKeyboardFocusHereExt = raw.igSetKeyboardFocusHere;
pub inline fn SetKeyboardFocusHere() void {
    return SetKeyboardFocusHereExt(0);
}

/// SetMouseCursor(cursor_type: MouseCursor) void
pub const SetMouseCursor = raw.igSetMouseCursor;

pub inline fn SetNextItemOpenExt(is_open: bool, cond: CondFlags) void {
    return raw.igSetNextItemOpen(is_open, cond.toInt());
}
pub inline fn SetNextItemOpen(is_open: bool) void {
    return SetNextItemOpenExt(is_open, .{});
}

/// SetNextItemWidth(item_width: f32) void
pub const SetNextItemWidth = raw.igSetNextItemWidth;

/// SetNextWindowBgAlpha(alpha: f32) void
pub const SetNextWindowBgAlpha = raw.igSetNextWindowBgAlpha;

pub inline fn SetNextWindowCollapsedExt(collapsed: bool, cond: CondFlags) void {
    return raw.igSetNextWindowCollapsed(collapsed, cond.toInt());
}
pub inline fn SetNextWindowCollapsed(collapsed: bool) void {
    return SetNextWindowCollapsedExt(collapsed, .{});
}

/// SetNextWindowContentSize(size: Vec2) void
pub const SetNextWindowContentSize = raw.igSetNextWindowContentSize;

/// SetNextWindowFocus() void
pub const SetNextWindowFocus = raw.igSetNextWindowFocus;

pub inline fn SetNextWindowPosExt(pos: Vec2, cond: CondFlags, pivot: Vec2) void {
    return raw.igSetNextWindowPos(pos, cond.toInt(), pivot);
}
pub inline fn SetNextWindowPos(pos: Vec2) void {
    return SetNextWindowPosExt(pos, .{}, .{.x=0,.y=0});
}

pub inline fn SetNextWindowSizeExt(size: Vec2, cond: CondFlags) void {
    return raw.igSetNextWindowSize(size, cond.toInt());
}
pub inline fn SetNextWindowSize(size: Vec2) void {
    return SetNextWindowSizeExt(size, .{});
}

/// SetNextWindowSizeConstraintsExt(size_min: Vec2, size_max: Vec2, custom_callback: SizeCallback, custom_callback_data: ?*c_void) void
pub const SetNextWindowSizeConstraintsExt = raw.igSetNextWindowSizeConstraints;
pub inline fn SetNextWindowSizeConstraints(size_min: Vec2, size_max: Vec2) void {
    return SetNextWindowSizeConstraintsExt(size_min, size_max, null, null);
}

/// SetScrollFromPosXExt(local_x: f32, center_x_ratio: f32) void
pub const SetScrollFromPosXExt = raw.igSetScrollFromPosX;
pub inline fn SetScrollFromPosX(local_x: f32) void {
    return SetScrollFromPosXExt(local_x, 0.5);
}

/// SetScrollFromPosYExt(local_y: f32, center_y_ratio: f32) void
pub const SetScrollFromPosYExt = raw.igSetScrollFromPosY;
pub inline fn SetScrollFromPosY(local_y: f32) void {
    return SetScrollFromPosYExt(local_y, 0.5);
}

/// SetScrollHereXExt(center_x_ratio: f32) void
pub const SetScrollHereXExt = raw.igSetScrollHereX;
pub inline fn SetScrollHereX() void {
    return SetScrollHereXExt(0.5);
}

/// SetScrollHereYExt(center_y_ratio: f32) void
pub const SetScrollHereYExt = raw.igSetScrollHereY;
pub inline fn SetScrollHereY() void {
    return SetScrollHereYExt(0.5);
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

pub inline fn SetWindowCollapsedBoolExt(collapsed: bool, cond: CondFlags) void {
    return raw.igSetWindowCollapsedBool(collapsed, cond.toInt());
}
pub inline fn SetWindowCollapsedBool(collapsed: bool) void {
    return SetWindowCollapsedBoolExt(collapsed, .{});
}

pub inline fn SetWindowCollapsedStrExt(name: ?[*:0]const u8, collapsed: bool, cond: CondFlags) void {
    return raw.igSetWindowCollapsedStr(name, collapsed, cond.toInt());
}
pub inline fn SetWindowCollapsedStr(name: ?[*:0]const u8, collapsed: bool) void {
    return SetWindowCollapsedStrExt(name, collapsed, .{});
}

/// SetWindowFocus() void
pub const SetWindowFocus = raw.igSetWindowFocus;

/// SetWindowFocusStr(name: ?[*:0]const u8) void
pub const SetWindowFocusStr = raw.igSetWindowFocusStr;

/// SetWindowFontScale(scale: f32) void
pub const SetWindowFontScale = raw.igSetWindowFontScale;

pub inline fn SetWindowPosVec2Ext(pos: Vec2, cond: CondFlags) void {
    return raw.igSetWindowPosVec2(pos, cond.toInt());
}
pub inline fn SetWindowPosVec2(pos: Vec2) void {
    return SetWindowPosVec2Ext(pos, .{});
}

pub inline fn SetWindowPosStrExt(name: ?[*:0]const u8, pos: Vec2, cond: CondFlags) void {
    return raw.igSetWindowPosStr(name, pos, cond.toInt());
}
pub inline fn SetWindowPosStr(name: ?[*:0]const u8, pos: Vec2) void {
    return SetWindowPosStrExt(name, pos, .{});
}

pub inline fn SetWindowSizeVec2Ext(size: Vec2, cond: CondFlags) void {
    return raw.igSetWindowSizeVec2(size, cond.toInt());
}
pub inline fn SetWindowSizeVec2(size: Vec2) void {
    return SetWindowSizeVec2Ext(size, .{});
}

pub inline fn SetWindowSizeStrExt(name: ?[*:0]const u8, size: Vec2, cond: CondFlags) void {
    return raw.igSetWindowSizeStr(name, size, cond.toInt());
}
pub inline fn SetWindowSizeStr(name: ?[*:0]const u8, size: Vec2) void {
    return SetWindowSizeStrExt(name, size, .{});
}

/// ShowAboutWindowExt(p_open: ?*bool) void
pub const ShowAboutWindowExt = raw.igShowAboutWindow;
pub inline fn ShowAboutWindow() void {
    return ShowAboutWindowExt(null);
}

/// ShowDemoWindowExt(p_open: ?*bool) void
pub const ShowDemoWindowExt = raw.igShowDemoWindow;
pub inline fn ShowDemoWindow() void {
    return ShowDemoWindowExt(null);
}

/// ShowFontSelector(label: ?[*:0]const u8) void
pub const ShowFontSelector = raw.igShowFontSelector;

/// ShowMetricsWindowExt(p_open: ?*bool) void
pub const ShowMetricsWindowExt = raw.igShowMetricsWindow;
pub inline fn ShowMetricsWindow() void {
    return ShowMetricsWindowExt(null);
}

/// ShowStyleEditorExt(ref: ?*Style) void
pub const ShowStyleEditorExt = raw.igShowStyleEditor;
pub inline fn ShowStyleEditor() void {
    return ShowStyleEditorExt(null);
}

/// ShowStyleSelector(label: ?[*:0]const u8) bool
pub const ShowStyleSelector = raw.igShowStyleSelector;

/// ShowUserGuide() void
pub const ShowUserGuide = raw.igShowUserGuide;

/// SliderAngleExt(label: ?[*:0]const u8, v_rad: *f32, v_degrees_min: f32, v_degrees_max: f32, format: ?[*:0]const u8) bool
pub const SliderAngleExt = raw.igSliderAngle;
pub inline fn SliderAngle(label: ?[*:0]const u8, v_rad: *f32) bool {
    return SliderAngleExt(label, v_rad, -360.0, 360.0, "%.0f deg");
}

/// SliderFloatExt(label: ?[*:0]const u8, v: *f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) bool
pub const SliderFloatExt = raw.igSliderFloat;
pub inline fn SliderFloat(label: ?[*:0]const u8, v: *f32, v_min: f32, v_max: f32) bool {
    return SliderFloatExt(label, v, v_min, v_max, "%.3f", 1.0);
}

/// SliderFloat2Ext(label: ?[*:0]const u8, v: *[2]f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) bool
pub const SliderFloat2Ext = raw.igSliderFloat2;
pub inline fn SliderFloat2(label: ?[*:0]const u8, v: *[2]f32, v_min: f32, v_max: f32) bool {
    return SliderFloat2Ext(label, v, v_min, v_max, "%.3f", 1.0);
}

/// SliderFloat3Ext(label: ?[*:0]const u8, v: *[3]f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) bool
pub const SliderFloat3Ext = raw.igSliderFloat3;
pub inline fn SliderFloat3(label: ?[*:0]const u8, v: *[3]f32, v_min: f32, v_max: f32) bool {
    return SliderFloat3Ext(label, v, v_min, v_max, "%.3f", 1.0);
}

/// SliderFloat4Ext(label: ?[*:0]const u8, v: *[4]f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) bool
pub const SliderFloat4Ext = raw.igSliderFloat4;
pub inline fn SliderFloat4(label: ?[*:0]const u8, v: *[4]f32, v_min: f32, v_max: f32) bool {
    return SliderFloat4Ext(label, v, v_min, v_max, "%.3f", 1.0);
}

/// SliderIntExt(label: ?[*:0]const u8, v: *i32, v_min: i32, v_max: i32, format: ?[*:0]const u8) bool
pub const SliderIntExt = raw.igSliderInt;
pub inline fn SliderInt(label: ?[*:0]const u8, v: *i32, v_min: i32, v_max: i32) bool {
    return SliderIntExt(label, v, v_min, v_max, "%d");
}

/// SliderInt2Ext(label: ?[*:0]const u8, v: *[2]i32, v_min: i32, v_max: i32, format: ?[*:0]const u8) bool
pub const SliderInt2Ext = raw.igSliderInt2;
pub inline fn SliderInt2(label: ?[*:0]const u8, v: *[2]i32, v_min: i32, v_max: i32) bool {
    return SliderInt2Ext(label, v, v_min, v_max, "%d");
}

/// SliderInt3Ext(label: ?[*:0]const u8, v: *[3]i32, v_min: i32, v_max: i32, format: ?[*:0]const u8) bool
pub const SliderInt3Ext = raw.igSliderInt3;
pub inline fn SliderInt3(label: ?[*:0]const u8, v: *[3]i32, v_min: i32, v_max: i32) bool {
    return SliderInt3Ext(label, v, v_min, v_max, "%d");
}

/// SliderInt4Ext(label: ?[*:0]const u8, v: *[4]i32, v_min: i32, v_max: i32, format: ?[*:0]const u8) bool
pub const SliderInt4Ext = raw.igSliderInt4;
pub inline fn SliderInt4(label: ?[*:0]const u8, v: *[4]i32, v_min: i32, v_max: i32) bool {
    return SliderInt4Ext(label, v, v_min, v_max, "%d");
}

/// SliderScalarExt(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, p_min: ?*const c_void, p_max: ?*const c_void, format: ?[*:0]const u8, power: f32) bool
pub const SliderScalarExt = raw.igSliderScalar;
pub inline fn SliderScalar(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, p_min: ?*const c_void, p_max: ?*const c_void) bool {
    return SliderScalarExt(label, data_type, p_data, p_min, p_max, null, 1.0);
}

/// SliderScalarNExt(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, components: i32, p_min: ?*const c_void, p_max: ?*const c_void, format: ?[*:0]const u8, power: f32) bool
pub const SliderScalarNExt = raw.igSliderScalarN;
pub inline fn SliderScalarN(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, components: i32, p_min: ?*const c_void, p_max: ?*const c_void) bool {
    return SliderScalarNExt(label, data_type, p_data, components, p_min, p_max, null, 1.0);
}

/// SmallButton(label: ?[*:0]const u8) bool
pub const SmallButton = raw.igSmallButton;

/// Spacing() void
pub const Spacing = raw.igSpacing;

/// StyleColorsClassicExt(dst: ?*Style) void
pub const StyleColorsClassicExt = raw.igStyleColorsClassic;
pub inline fn StyleColorsClassic() void {
    return StyleColorsClassicExt(null);
}

/// StyleColorsDarkExt(dst: ?*Style) void
pub const StyleColorsDarkExt = raw.igStyleColorsDark;
pub inline fn StyleColorsDark() void {
    return StyleColorsDarkExt(null);
}

/// StyleColorsLightExt(dst: ?*Style) void
pub const StyleColorsLightExt = raw.igStyleColorsLight;
pub inline fn StyleColorsLight() void {
    return StyleColorsLightExt(null);
}

/// Text(fmt: ?[*:0]const u8, ...: ...) void
pub const Text = raw.igText;

/// TextColored(col: Vec4, fmt: ?[*:0]const u8, ...: ...) void
pub const TextColored = raw.igTextColored;

/// TextDisabled(fmt: ?[*:0]const u8, ...: ...) void
pub const TextDisabled = raw.igTextDisabled;

/// TextUnformattedExt(text: ?[*]const u8, text_end: ?[*]const u8) void
pub const TextUnformattedExt = raw.igTextUnformatted;
pub inline fn TextUnformatted(text: ?[*]const u8) void {
    return TextUnformattedExt(text, null);
}

/// TextWrapped(fmt: ?[*:0]const u8, ...: ...) void
pub const TextWrapped = raw.igTextWrapped;

/// TreeNodeStr(label: ?[*:0]const u8) bool
pub const TreeNodeStr = raw.igTreeNodeStr;

/// TreeNodeStrStr(str_id: ?[*:0]const u8, fmt: ?[*:0]const u8, ...: ...) bool
pub const TreeNodeStrStr = raw.igTreeNodeStrStr;

/// TreeNodePtr(ptr_id: ?*const c_void, fmt: ?[*:0]const u8, ...: ...) bool
pub const TreeNodePtr = raw.igTreeNodePtr;

pub inline fn TreeNodeExStrExt(label: ?[*:0]const u8, flags: TreeNodeFlags) bool {
    return raw.igTreeNodeExStr(label, flags.toInt());
}
pub inline fn TreeNodeExStr(label: ?[*:0]const u8) bool {
    return TreeNodeExStrExt(label, .{});
}

/// TreeNodeExStrStr(str_id: ?[*:0]const u8, flags: TreeNodeFlags, fmt: ?[*:0]const u8, ...: ...) bool
pub const TreeNodeExStrStr = raw.igTreeNodeExStrStr;

/// TreeNodeExPtr(ptr_id: ?*const c_void, flags: TreeNodeFlags, fmt: ?[*:0]const u8, ...: ...) bool
pub const TreeNodeExPtr = raw.igTreeNodeExPtr;

/// TreePop() void
pub const TreePop = raw.igTreePop;

/// TreePushStr(str_id: ?[*:0]const u8) void
pub const TreePushStr = raw.igTreePushStr;

/// TreePushPtrExt(ptr_id: ?*const c_void) void
pub const TreePushPtrExt = raw.igTreePushPtr;
pub inline fn TreePushPtr() void {
    return TreePushPtrExt(null);
}

/// UnindentExt(indent_w: f32) void
pub const UnindentExt = raw.igUnindent;
pub inline fn Unindent() void {
    return UnindentExt(0.0);
}

/// VSliderFloatExt(label: ?[*:0]const u8, size: Vec2, v: *f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) bool
pub const VSliderFloatExt = raw.igVSliderFloat;
pub inline fn VSliderFloat(label: ?[*:0]const u8, size: Vec2, v: *f32, v_min: f32, v_max: f32) bool {
    return VSliderFloatExt(label, size, v, v_min, v_max, "%.3f", 1.0);
}

/// VSliderIntExt(label: ?[*:0]const u8, size: Vec2, v: *i32, v_min: i32, v_max: i32, format: ?[*:0]const u8) bool
pub const VSliderIntExt = raw.igVSliderInt;
pub inline fn VSliderInt(label: ?[*:0]const u8, size: Vec2, v: *i32, v_min: i32, v_max: i32) bool {
    return VSliderIntExt(label, size, v, v_min, v_max, "%d");
}

/// VSliderScalarExt(label: ?[*:0]const u8, size: Vec2, data_type: DataType, p_data: ?*c_void, p_min: ?*const c_void, p_max: ?*const c_void, format: ?[*:0]const u8, power: f32) bool
pub const VSliderScalarExt = raw.igVSliderScalar;
pub inline fn VSliderScalar(label: ?[*:0]const u8, size: Vec2, data_type: DataType, p_data: ?*c_void, p_min: ?*const c_void, p_max: ?*const c_void) bool {
    return VSliderScalarExt(label, size, data_type, p_data, p_min, p_max, null, 1.0);
}

/// ValueBool(prefix: ?[*:0]const u8, b: bool) void
pub const ValueBool = raw.igValueBool;

/// ValueInt(prefix: ?[*:0]const u8, v: i32) void
pub const ValueInt = raw.igValueInt;

/// ValueUint(prefix: ?[*:0]const u8, v: u32) void
pub const ValueUint = raw.igValueUint;

/// ValueFloatExt(prefix: ?[*:0]const u8, v: f32, float_format: ?[*:0]const u8) void
pub const ValueFloatExt = raw.igValueFloat;
pub inline fn ValueFloat(prefix: ?[*:0]const u8, v: f32) void {
    return ValueFloatExt(prefix, v, null);
}

pub const raw = struct {
    pub extern fn ImColor_HSV_nonUDT(pOut: *Color, self: *Color, h: f32, s: f32, v: f32, a: f32) callconv(.C) void;
    pub extern fn ImColor_ImColor(self: *Color) callconv(.C) void;
    pub extern fn ImColor_ImColorInt(self: *Color, r: i32, g: i32, b: i32, a: i32) callconv(.C) void;
    pub extern fn ImColor_ImColorU32(self: *Color, rgba: u32) callconv(.C) void;
    pub extern fn ImColor_ImColorFloat(self: *Color, r: f32, g: f32, b: f32, a: f32) callconv(.C) void;
    pub extern fn ImColor_ImColorVec4(self: *Color, col: Vec4) callconv(.C) void;
    pub extern fn ImColor_SetHSV(self: *Color, h: f32, s: f32, v: f32, a: f32) callconv(.C) void;
    pub extern fn ImColor_destroy(self: *Color) callconv(.C) void;
    pub extern fn ImDrawCmd_ImDrawCmd(self: *DrawCmd) callconv(.C) void;
    pub extern fn ImDrawCmd_destroy(self: *DrawCmd) callconv(.C) void;
    pub extern fn ImDrawData_Clear(self: *DrawData) callconv(.C) void;
    pub extern fn ImDrawData_DeIndexAllBuffers(self: *DrawData) callconv(.C) void;
    pub extern fn ImDrawData_ImDrawData(self: *DrawData) callconv(.C) void;
    pub extern fn ImDrawData_ScaleClipRects(self: *DrawData, fb_scale: Vec2) callconv(.C) void;
    pub extern fn ImDrawData_destroy(self: *DrawData) callconv(.C) void;
    pub extern fn ImDrawListSplitter_Clear(self: *DrawListSplitter) callconv(.C) void;
    pub extern fn ImDrawListSplitter_ClearFreeMemory(self: *DrawListSplitter) callconv(.C) void;
    pub extern fn ImDrawListSplitter_ImDrawListSplitter(self: *DrawListSplitter) callconv(.C) void;
    pub extern fn ImDrawListSplitter_Merge(self: *DrawListSplitter, draw_list: ?*DrawList) callconv(.C) void;
    pub extern fn ImDrawListSplitter_SetCurrentChannel(self: *DrawListSplitter, draw_list: ?*DrawList, channel_idx: i32) callconv(.C) void;
    pub extern fn ImDrawListSplitter_Split(self: *DrawListSplitter, draw_list: ?*DrawList, count: i32) callconv(.C) void;
    pub extern fn ImDrawListSplitter_destroy(self: *DrawListSplitter) callconv(.C) void;
    pub extern fn ImDrawList_AddBezierCurve(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32, thickness: f32, num_segments: i32) callconv(.C) void;
    pub extern fn ImDrawList_AddCallback(self: *DrawList, callback: DrawCallback, callback_data: ?*c_void) callconv(.C) void;
    pub extern fn ImDrawList_AddCircle(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddCircleFilled(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32) callconv(.C) void;
    pub extern fn ImDrawList_AddConvexPolyFilled(self: *DrawList, points: ?[*]const Vec2, num_points: i32, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_AddDrawCmd(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_AddImage(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2, uv_min: Vec2, uv_max: Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_AddImageQuad(self: *DrawList, user_texture_id: TextureID, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, uv1: Vec2, uv2: Vec2, uv3: Vec2, uv4: Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_AddImageRounded(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2, uv_min: Vec2, uv_max: Vec2, col: u32, rounding: f32, rounding_corners: DrawCornerFlagsInt) callconv(.C) void;
    pub extern fn ImDrawList_AddLine(self: *DrawList, p1: Vec2, p2: Vec2, col: u32, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddNgon(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddNgonFilled(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32) callconv(.C) void;
    pub extern fn ImDrawList_AddPolyline(self: *DrawList, points: ?[*]const Vec2, num_points: i32, col: u32, closed: bool, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddQuad(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddQuadFilled(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_AddRect(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32, rounding: f32, rounding_corners: DrawCornerFlagsInt, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddRectFilled(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32, rounding: f32, rounding_corners: DrawCornerFlagsInt) callconv(.C) void;
    pub extern fn ImDrawList_AddRectFilledMultiColor(self: *DrawList, p_min: Vec2, p_max: Vec2, col_upr_left: u32, col_upr_right: u32, col_bot_right: u32, col_bot_left: u32) callconv(.C) void;
    pub extern fn ImDrawList_AddTextVec2(self: *DrawList, pos: Vec2, col: u32, text_begin: ?[*]const u8, text_end: ?[*]const u8) callconv(.C) void;
    pub extern fn ImDrawList_AddTextFontPtr(self: *DrawList, font: ?*const Font, font_size: f32, pos: Vec2, col: u32, text_begin: ?[*]const u8, text_end: ?[*]const u8, wrap_width: f32, cpu_fine_clip_rect: ?*const Vec4) callconv(.C) void;
    pub extern fn ImDrawList_AddTriangle(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_AddTriangleFilled(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_ChannelsMerge(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_ChannelsSetCurrent(self: *DrawList, n: i32) callconv(.C) void;
    pub extern fn ImDrawList_ChannelsSplit(self: *DrawList, count: i32) callconv(.C) void;
    pub extern fn ImDrawList_Clear(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_ClearFreeMemory(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_CloneOutput(self: *const DrawList) callconv(.C) ?*DrawList;
    pub extern fn ImDrawList_GetClipRectMax_nonUDT(pOut: *Vec2, self: *const DrawList) callconv(.C) void;
    pub extern fn ImDrawList_GetClipRectMin_nonUDT(pOut: *Vec2, self: *const DrawList) callconv(.C) void;
    pub extern fn ImDrawList_ImDrawList(self: *DrawList, shared_data: ?*const DrawListSharedData) callconv(.C) void;
    pub extern fn ImDrawList_PathArcTo(self: *DrawList, center: Vec2, radius: f32, a_min: f32, a_max: f32, num_segments: i32) callconv(.C) void;
    pub extern fn ImDrawList_PathArcToFast(self: *DrawList, center: Vec2, radius: f32, a_min_of_12: i32, a_max_of_12: i32) callconv(.C) void;
    pub extern fn ImDrawList_PathBezierCurveTo(self: *DrawList, p2: Vec2, p3: Vec2, p4: Vec2, num_segments: i32) callconv(.C) void;
    pub extern fn ImDrawList_PathClear(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_PathFillConvex(self: *DrawList, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_PathLineTo(self: *DrawList, pos: Vec2) callconv(.C) void;
    pub extern fn ImDrawList_PathLineToMergeDuplicate(self: *DrawList, pos: Vec2) callconv(.C) void;
    pub extern fn ImDrawList_PathRect(self: *DrawList, rect_min: Vec2, rect_max: Vec2, rounding: f32, rounding_corners: DrawCornerFlagsInt) callconv(.C) void;
    pub extern fn ImDrawList_PathStroke(self: *DrawList, col: u32, closed: bool, thickness: f32) callconv(.C) void;
    pub extern fn ImDrawList_PopClipRect(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_PopTextureID(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_PrimQuadUV(self: *DrawList, a: Vec2, b: Vec2, c: Vec2, d: Vec2, uv_a: Vec2, uv_b: Vec2, uv_c: Vec2, uv_d: Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_PrimRect(self: *DrawList, a: Vec2, b: Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_PrimRectUV(self: *DrawList, a: Vec2, b: Vec2, uv_a: Vec2, uv_b: Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_PrimReserve(self: *DrawList, idx_count: i32, vtx_count: i32) callconv(.C) void;
    pub extern fn ImDrawList_PrimUnreserve(self: *DrawList, idx_count: i32, vtx_count: i32) callconv(.C) void;
    pub extern fn ImDrawList_PrimVtx(self: *DrawList, pos: Vec2, uv: Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_PrimWriteIdx(self: *DrawList, idx: DrawIdx) callconv(.C) void;
    pub extern fn ImDrawList_PrimWriteVtx(self: *DrawList, pos: Vec2, uv: Vec2, col: u32) callconv(.C) void;
    pub extern fn ImDrawList_PushClipRect(self: *DrawList, clip_rect_min: Vec2, clip_rect_max: Vec2, intersect_with_current_clip_rect: bool) callconv(.C) void;
    pub extern fn ImDrawList_PushClipRectFullScreen(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_PushTextureID(self: *DrawList, texture_id: TextureID) callconv(.C) void;
    pub extern fn ImDrawList_UpdateClipRect(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_UpdateTextureID(self: *DrawList) callconv(.C) void;
    pub extern fn ImDrawList_destroy(self: *DrawList) callconv(.C) void;
    pub extern fn ImFontAtlasCustomRect_ImFontAtlasCustomRect(self: *FontAtlasCustomRect) callconv(.C) void;
    pub extern fn ImFontAtlasCustomRect_IsPacked(self: *const FontAtlasCustomRect) callconv(.C) bool;
    pub extern fn ImFontAtlasCustomRect_destroy(self: *FontAtlasCustomRect) callconv(.C) void;
    pub extern fn ImFontAtlas_AddCustomRectFontGlyph(self: *FontAtlas, font: ?*Font, id: Wchar, width: i32, height: i32, advance_x: f32, offset: Vec2) callconv(.C) i32;
    pub extern fn ImFontAtlas_AddCustomRectRegular(self: *FontAtlas, id: u32, width: i32, height: i32) callconv(.C) i32;
    pub extern fn ImFontAtlas_AddFont(self: *FontAtlas, font_cfg: ?*const FontConfig) callconv(.C) ?*Font;
    pub extern fn ImFontAtlas_AddFontDefault(self: *FontAtlas, font_cfg: ?*const FontConfig) callconv(.C) ?*Font;
    pub extern fn ImFontAtlas_AddFontFromFileTTF(self: *FontAtlas, filename: ?[*:0]const u8, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) callconv(.C) ?*Font;
    pub extern fn ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(self: *FontAtlas, compressed_font_data_base85: ?[*]const u8, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) callconv(.C) ?*Font;
    pub extern fn ImFontAtlas_AddFontFromMemoryCompressedTTF(self: *FontAtlas, compressed_font_data: ?*const c_void, compressed_font_size: i32, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) callconv(.C) ?*Font;
    pub extern fn ImFontAtlas_AddFontFromMemoryTTF(self: *FontAtlas, font_data: ?*c_void, font_size: i32, size_pixels: f32, font_cfg: ?*const FontConfig, glyph_ranges: ?[*:0]const Wchar) callconv(.C) ?*Font;
    pub extern fn ImFontAtlas_Build(self: *FontAtlas) callconv(.C) bool;
    pub extern fn ImFontAtlas_CalcCustomRectUV(self: *const FontAtlas, rect: ?*const FontAtlasCustomRect, out_uv_min: ?*Vec2, out_uv_max: ?*Vec2) callconv(.C) void;
    pub extern fn ImFontAtlas_Clear(self: *FontAtlas) callconv(.C) void;
    pub extern fn ImFontAtlas_ClearFonts(self: *FontAtlas) callconv(.C) void;
    pub extern fn ImFontAtlas_ClearInputData(self: *FontAtlas) callconv(.C) void;
    pub extern fn ImFontAtlas_ClearTexData(self: *FontAtlas) callconv(.C) void;
    pub extern fn ImFontAtlas_GetCustomRectByIndex(self: *const FontAtlas, index: i32) callconv(.C) ?*const FontAtlasCustomRect;
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
    pub extern fn ImFontAtlas_ImFontAtlas(self: *FontAtlas) callconv(.C) void;
    pub extern fn ImFontAtlas_IsBuilt(self: *const FontAtlas) callconv(.C) bool;
    pub extern fn ImFontAtlas_SetTexID(self: *FontAtlas, id: TextureID) callconv(.C) void;
    pub extern fn ImFontAtlas_destroy(self: *FontAtlas) callconv(.C) void;
    pub extern fn ImFontConfig_ImFontConfig(self: *FontConfig) callconv(.C) void;
    pub extern fn ImFontConfig_destroy(self: *FontConfig) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_AddChar(self: *FontGlyphRangesBuilder, c: Wchar) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_AddRanges(self: *FontGlyphRangesBuilder, ranges: ?[*:0]const Wchar) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_AddText(self: *FontGlyphRangesBuilder, text: ?[*]const u8, text_end: ?[*]const u8) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_BuildRanges(self: *FontGlyphRangesBuilder, out_ranges: *Vector(Wchar)) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_Clear(self: *FontGlyphRangesBuilder) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_GetBit(self: *const FontGlyphRangesBuilder, n: i32) callconv(.C) bool;
    pub extern fn ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder(self: *FontGlyphRangesBuilder) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_SetBit(self: *FontGlyphRangesBuilder, n: i32) callconv(.C) void;
    pub extern fn ImFontGlyphRangesBuilder_destroy(self: *FontGlyphRangesBuilder) callconv(.C) void;
    pub extern fn ImFont_AddGlyph(self: *Font, c: Wchar, x0: f32, y0: f32, x1: f32, y1: f32, u0: f32, v0: f32, u1: f32, v1: f32, advance_x: f32) callconv(.C) void;
    pub extern fn ImFont_AddRemapChar(self: *Font, dst: Wchar, src: Wchar, overwrite_dst: bool) callconv(.C) void;
    pub extern fn ImFont_BuildLookupTable(self: *Font) callconv(.C) void;
    pub extern fn ImFont_CalcTextSizeA_nonUDT(pOut: *Vec2, self: *const Font, size: f32, max_width: f32, wrap_width: f32, text_begin: ?[*]const u8, text_end: ?[*]const u8, remaining: ?*?[*:0]const u8) callconv(.C) void;
    pub extern fn ImFont_CalcWordWrapPositionA(self: *const Font, scale: f32, text: ?[*]const u8, text_end: ?[*]const u8, wrap_width: f32) callconv(.C) ?[*]const u8;
    pub extern fn ImFont_ClearOutputData(self: *Font) callconv(.C) void;
    pub extern fn ImFont_FindGlyph(self: *const Font, c: Wchar) callconv(.C) ?*const FontGlyph;
    pub extern fn ImFont_FindGlyphNoFallback(self: *const Font, c: Wchar) callconv(.C) ?*const FontGlyph;
    pub extern fn ImFont_GetCharAdvance(self: *const Font, c: Wchar) callconv(.C) f32;
    pub extern fn ImFont_GetDebugName(self: *const Font) callconv(.C) ?[*:0]const u8;
    pub extern fn ImFont_GrowIndex(self: *Font, new_size: i32) callconv(.C) void;
    pub extern fn ImFont_ImFont(self: *Font) callconv(.C) void;
    pub extern fn ImFont_IsLoaded(self: *const Font) callconv(.C) bool;
    pub extern fn ImFont_RenderChar(self: *const Font, draw_list: ?*DrawList, size: f32, pos: Vec2, col: u32, c: Wchar) callconv(.C) void;
    pub extern fn ImFont_RenderText(self: *const Font, draw_list: ?*DrawList, size: f32, pos: Vec2, col: u32, clip_rect: Vec4, text_begin: ?[*]const u8, text_end: ?[*]const u8, wrap_width: f32, cpu_fine_clip: bool) callconv(.C) void;
    pub extern fn ImFont_SetFallbackChar(self: *Font, c: Wchar) callconv(.C) void;
    pub extern fn ImFont_destroy(self: *Font) callconv(.C) void;
    pub extern fn ImGuiIO_AddInputCharacter(self: *IO, c: u32) callconv(.C) void;
    pub extern fn ImGuiIO_AddInputCharactersUTF8(self: *IO, str: ?[*:0]const u8) callconv(.C) void;
    pub extern fn ImGuiIO_ClearInputCharacters(self: *IO) callconv(.C) void;
    pub extern fn ImGuiIO_ImGuiIO(self: *IO) callconv(.C) void;
    pub extern fn ImGuiIO_destroy(self: *IO) callconv(.C) void;
    pub extern fn ImGuiInputTextCallbackData_DeleteChars(self: *InputTextCallbackData, pos: i32, bytes_count: i32) callconv(.C) void;
    pub extern fn ImGuiInputTextCallbackData_HasSelection(self: *const InputTextCallbackData) callconv(.C) bool;
    pub extern fn ImGuiInputTextCallbackData_ImGuiInputTextCallbackData(self: *InputTextCallbackData) callconv(.C) void;
    pub extern fn ImGuiInputTextCallbackData_InsertChars(self: *InputTextCallbackData, pos: i32, text: ?[*]const u8, text_end: ?[*]const u8) callconv(.C) void;
    pub extern fn ImGuiInputTextCallbackData_destroy(self: *InputTextCallbackData) callconv(.C) void;
    pub extern fn ImGuiListClipper_Begin(self: *ListClipper, items_count: i32, items_height: f32) callconv(.C) void;
    pub extern fn ImGuiListClipper_End(self: *ListClipper) callconv(.C) void;
    pub extern fn ImGuiListClipper_ImGuiListClipper(self: *ListClipper, items_count: i32, items_height: f32) callconv(.C) void;
    pub extern fn ImGuiListClipper_Step(self: *ListClipper) callconv(.C) bool;
    pub extern fn ImGuiListClipper_destroy(self: *ListClipper) callconv(.C) void;
    pub extern fn ImGuiOnceUponAFrame_ImGuiOnceUponAFrame(self: *OnceUponAFrame) callconv(.C) void;
    pub extern fn ImGuiOnceUponAFrame_destroy(self: *OnceUponAFrame) callconv(.C) void;
    pub extern fn ImGuiPayload_Clear(self: *Payload) callconv(.C) void;
    pub extern fn ImGuiPayload_ImGuiPayload(self: *Payload) callconv(.C) void;
    pub extern fn ImGuiPayload_IsDataType(self: *const Payload, kind: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn ImGuiPayload_IsDelivery(self: *const Payload) callconv(.C) bool;
    pub extern fn ImGuiPayload_IsPreview(self: *const Payload) callconv(.C) bool;
    pub extern fn ImGuiPayload_destroy(self: *Payload) callconv(.C) void;
    pub extern fn ImGuiStoragePair_ImGuiStoragePairInt(self: *StoragePair, _key: ID, _val_i: i32) callconv(.C) void;
    pub extern fn ImGuiStoragePair_ImGuiStoragePairFloat(self: *StoragePair, _key: ID, _val_f: f32) callconv(.C) void;
    pub extern fn ImGuiStoragePair_ImGuiStoragePairPtr(self: *StoragePair, _key: ID, _val_p: ?*c_void) callconv(.C) void;
    pub extern fn ImGuiStoragePair_destroy(self: *StoragePair) callconv(.C) void;
    pub extern fn ImGuiStorage_BuildSortByKey(self: *Storage) callconv(.C) void;
    pub extern fn ImGuiStorage_Clear(self: *Storage) callconv(.C) void;
    pub extern fn ImGuiStorage_GetBool(self: *const Storage, key: ID, default_val: bool) callconv(.C) bool;
    pub extern fn ImGuiStorage_GetBoolRef(self: *Storage, key: ID, default_val: bool) callconv(.C) ?*bool;
    pub extern fn ImGuiStorage_GetFloat(self: *const Storage, key: ID, default_val: f32) callconv(.C) f32;
    pub extern fn ImGuiStorage_GetFloatRef(self: *Storage, key: ID, default_val: f32) callconv(.C) ?*f32;
    pub extern fn ImGuiStorage_GetInt(self: *const Storage, key: ID, default_val: i32) callconv(.C) i32;
    pub extern fn ImGuiStorage_GetIntRef(self: *Storage, key: ID, default_val: i32) callconv(.C) ?*i32;
    pub extern fn ImGuiStorage_GetVoidPtr(self: *const Storage, key: ID) callconv(.C) ?*c_void;
    pub extern fn ImGuiStorage_GetVoidPtrRef(self: *Storage, key: ID, default_val: ?*c_void) callconv(.C) ?*?*c_void;
    pub extern fn ImGuiStorage_SetAllInt(self: *Storage, val: i32) callconv(.C) void;
    pub extern fn ImGuiStorage_SetBool(self: *Storage, key: ID, val: bool) callconv(.C) void;
    pub extern fn ImGuiStorage_SetFloat(self: *Storage, key: ID, val: f32) callconv(.C) void;
    pub extern fn ImGuiStorage_SetInt(self: *Storage, key: ID, val: i32) callconv(.C) void;
    pub extern fn ImGuiStorage_SetVoidPtr(self: *Storage, key: ID, val: ?*c_void) callconv(.C) void;
    pub extern fn ImGuiStyle_ImGuiStyle(self: *Style) callconv(.C) void;
    pub extern fn ImGuiStyle_ScaleAllSizes(self: *Style, scale_factor: f32) callconv(.C) void;
    pub extern fn ImGuiStyle_destroy(self: *Style) callconv(.C) void;
    pub extern fn ImGuiTextBuffer_ImGuiTextBuffer(self: *TextBuffer) callconv(.C) void;
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
    pub extern fn ImGuiTextFilter_ImGuiTextFilter(self: *TextFilter, default_filter: ?[*:0]const u8) callconv(.C) void;
    pub extern fn ImGuiTextFilter_IsActive(self: *const TextFilter) callconv(.C) bool;
    pub extern fn ImGuiTextFilter_PassFilter(self: *const TextFilter, text: ?[*]const u8, text_end: ?[*]const u8) callconv(.C) bool;
    pub extern fn ImGuiTextFilter_destroy(self: *TextFilter) callconv(.C) void;
    pub extern fn ImGuiTextRange_ImGuiTextRange(self: *TextRange) callconv(.C) void;
    pub extern fn ImGuiTextRange_ImGuiTextRangeStr(self: *TextRange, _b: ?[*]const u8, _e: ?[*]const u8) callconv(.C) void;
    pub extern fn ImGuiTextRange_destroy(self: *TextRange) callconv(.C) void;
    pub extern fn ImGuiTextRange_empty(self: *const TextRange) callconv(.C) bool;
    pub extern fn ImGuiTextRange_split(self: *const TextRange, separator: u8, out: ?*Vector(TextRange)) callconv(.C) void;
    pub extern fn ImVec2_ImVec2(self: *Vec2) callconv(.C) void;
    pub extern fn ImVec2_ImVec2Float(self: *Vec2, _x: f32, _y: f32) callconv(.C) void;
    pub extern fn ImVec2_destroy(self: *Vec2) callconv(.C) void;
    pub extern fn ImVec4_ImVec4(self: *Vec4) callconv(.C) void;
    pub extern fn ImVec4_ImVec4Float(self: *Vec4, _x: f32, _y: f32, _z: f32, _w: f32) callconv(.C) void;
    pub extern fn ImVec4_destroy(self: *Vec4) callconv(.C) void;
    pub extern fn ImVector_ImDrawChannel_ImVector_ImDrawChannel(self: *Vector(DrawChannel)) callconv(.C) void;
    pub extern fn ImVector_ImDrawCmd_ImVector_ImDrawCmd(self: *Vector(DrawCmd)) callconv(.C) void;
    pub extern fn ImVector_ImDrawIdx_ImVector_ImDrawIdx(self: *Vector(DrawIdx)) callconv(.C) void;
    pub extern fn ImVector_ImDrawVert_ImVector_ImDrawVert(self: *Vector(DrawVert)) callconv(.C) void;
    pub extern fn ImVector_ImFontPtr_ImVector_ImFontPtr(self: *Vector(*Font)) callconv(.C) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_ImVector_ImFontAtlasCustomRect(self: *Vector(FontAtlasCustomRect)) callconv(.C) void;
    pub extern fn ImVector_ImFontConfig_ImVector_ImFontConfig(self: *Vector(FontConfig)) callconv(.C) void;
    pub extern fn ImVector_ImFontGlyph_ImVector_ImFontGlyph(self: *Vector(FontGlyph)) callconv(.C) void;
    pub extern fn ImVector_ImGuiStoragePair_ImVector_ImGuiStoragePair(self: *Vector(StoragePair)) callconv(.C) void;
    pub extern fn ImVector_ImGuiTextRange_ImVector_ImGuiTextRange(self: *Vector(TextRange)) callconv(.C) void;
    pub extern fn ImVector_ImTextureID_ImVector_ImTextureID(self: *Vector(TextureID)) callconv(.C) void;
    pub extern fn ImVector_ImU32_ImVector_ImU32(self: *Vector(u32)) callconv(.C) void;
    pub extern fn ImVector_ImVec2_ImVector_ImVec2(self: *Vector(Vec2)) callconv(.C) void;
    pub extern fn ImVector_ImVec4_ImVector_ImVec4(self: *Vector(Vec4)) callconv(.C) void;
    pub extern fn ImVector_ImWchar_ImVector_ImWchar(self: *Vector(Wchar)) callconv(.C) void;
    pub extern fn ImVector_char_ImVector_char(self: *Vector(u8)) callconv(.C) void;
    pub extern fn ImVector_float_ImVector_float(self: *Vector(f32)) callconv(.C) void;
    pub extern fn ImVector_ImDrawChannel_ImVector_ImDrawChannelVector(self: *Vector(DrawChannel), src: Vector(DrawChannel)) callconv(.C) void;
    pub extern fn ImVector_ImDrawCmd_ImVector_ImDrawCmdVector(self: *Vector(DrawCmd), src: Vector(DrawCmd)) callconv(.C) void;
    pub extern fn ImVector_ImDrawIdx_ImVector_ImDrawIdxVector(self: *Vector(DrawIdx), src: Vector(DrawIdx)) callconv(.C) void;
    pub extern fn ImVector_ImDrawVert_ImVector_ImDrawVertVector(self: *Vector(DrawVert), src: Vector(DrawVert)) callconv(.C) void;
    pub extern fn ImVector_ImFontPtr_ImVector_ImFontPtrVector(self: *Vector(*Font), src: Vector(*Font)) callconv(.C) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_ImVector_ImFontAtlasCustomRectVector(self: *Vector(FontAtlasCustomRect), src: Vector(FontAtlasCustomRect)) callconv(.C) void;
    pub extern fn ImVector_ImFontConfig_ImVector_ImFontConfigVector(self: *Vector(FontConfig), src: Vector(FontConfig)) callconv(.C) void;
    pub extern fn ImVector_ImFontGlyph_ImVector_ImFontGlyphVector(self: *Vector(FontGlyph), src: Vector(FontGlyph)) callconv(.C) void;
    pub extern fn ImVector_ImGuiStoragePair_ImVector_ImGuiStoragePairVector(self: *Vector(StoragePair), src: Vector(StoragePair)) callconv(.C) void;
    pub extern fn ImVector_ImGuiTextRange_ImVector_ImGuiTextRangeVector(self: *Vector(TextRange), src: Vector(TextRange)) callconv(.C) void;
    pub extern fn ImVector_ImTextureID_ImVector_ImTextureIDVector(self: *Vector(TextureID), src: Vector(TextureID)) callconv(.C) void;
    pub extern fn ImVector_ImU32_ImVector_ImU32Vector(self: *Vector(u32), src: Vector(u32)) callconv(.C) void;
    pub extern fn ImVector_ImVec2_ImVector_ImVec2Vector(self: *Vector(Vec2), src: Vector(Vec2)) callconv(.C) void;
    pub extern fn ImVector_ImVec4_ImVector_ImVec4Vector(self: *Vector(Vec4), src: Vector(Vec4)) callconv(.C) void;
    pub extern fn ImVector_ImWchar_ImVector_ImWcharVector(self: *Vector(Wchar), src: Vector(Wchar)) callconv(.C) void;
    pub extern fn ImVector_char_ImVector_charVector(self: *Vector(u8), src: Vector(u8)) callconv(.C) void;
    pub extern fn ImVector_float_ImVector_floatVector(self: *Vector(f32), src: Vector(f32)) callconv(.C) void;
    pub extern fn ImVector_ImDrawChannel__grow_capacity(self: *const Vector(DrawChannel), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImDrawCmd__grow_capacity(self: *const Vector(DrawCmd), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImDrawIdx__grow_capacity(self: *const Vector(DrawIdx), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImDrawVert__grow_capacity(self: *const Vector(DrawVert), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImFontPtr__grow_capacity(self: *const Vector(*Font), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImFontAtlasCustomRect__grow_capacity(self: *const Vector(FontAtlasCustomRect), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImFontConfig__grow_capacity(self: *const Vector(FontConfig), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImFontGlyph__grow_capacity(self: *const Vector(FontGlyph), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImGuiStoragePair__grow_capacity(self: *const Vector(StoragePair), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImGuiTextRange__grow_capacity(self: *const Vector(TextRange), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImTextureID__grow_capacity(self: *const Vector(TextureID), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImU32__grow_capacity(self: *const Vector(u32), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImVec2__grow_capacity(self: *const Vector(Vec2), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImVec4__grow_capacity(self: *const Vector(Vec4), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImWchar__grow_capacity(self: *const Vector(Wchar), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_char__grow_capacity(self: *const Vector(u8), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_float__grow_capacity(self: *const Vector(f32), sz: i32) callconv(.C) i32;
    pub extern fn ImVector_ImDrawChannel_back(self: *Vector(DrawChannel)) callconv(.C) *DrawChannel;
    pub extern fn ImVector_ImDrawCmd_back(self: *Vector(DrawCmd)) callconv(.C) *DrawCmd;
    pub extern fn ImVector_ImDrawIdx_back(self: *Vector(DrawIdx)) callconv(.C) *DrawIdx;
    pub extern fn ImVector_ImDrawVert_back(self: *Vector(DrawVert)) callconv(.C) *DrawVert;
    pub extern fn ImVector_ImFontPtr_back(self: *Vector(*Font)) callconv(.C) **Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_back(self: *Vector(FontAtlasCustomRect)) callconv(.C) *FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_back(self: *Vector(FontConfig)) callconv(.C) *FontConfig;
    pub extern fn ImVector_ImFontGlyph_back(self: *Vector(FontGlyph)) callconv(.C) *FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_back(self: *Vector(StoragePair)) callconv(.C) *StoragePair;
    pub extern fn ImVector_ImGuiTextRange_back(self: *Vector(TextRange)) callconv(.C) *TextRange;
    pub extern fn ImVector_ImTextureID_back(self: *Vector(TextureID)) callconv(.C) *TextureID;
    pub extern fn ImVector_ImU32_back(self: *Vector(u32)) callconv(.C) *u32;
    pub extern fn ImVector_ImVec2_back(self: *Vector(Vec2)) callconv(.C) *Vec2;
    pub extern fn ImVector_ImVec4_back(self: *Vector(Vec4)) callconv(.C) *Vec4;
    pub extern fn ImVector_ImWchar_back(self: *Vector(Wchar)) callconv(.C) *Wchar;
    pub extern fn ImVector_char_back(self: *Vector(u8)) callconv(.C) *u8;
    pub extern fn ImVector_float_back(self: *Vector(f32)) callconv(.C) *f32;
    pub extern fn ImVector_ImDrawChannel_back_const(self: *const Vector(DrawChannel)) callconv(.C) *const DrawChannel;
    pub extern fn ImVector_ImDrawCmd_back_const(self: *const Vector(DrawCmd)) callconv(.C) *const DrawCmd;
    pub extern fn ImVector_ImDrawIdx_back_const(self: *const Vector(DrawIdx)) callconv(.C) *const DrawIdx;
    pub extern fn ImVector_ImDrawVert_back_const(self: *const Vector(DrawVert)) callconv(.C) *const DrawVert;
    pub extern fn ImVector_ImFontPtr_back_const(self: *const Vector(*Font)) callconv(.C) *const *Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_back_const(self: *const Vector(FontAtlasCustomRect)) callconv(.C) *const FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_back_const(self: *const Vector(FontConfig)) callconv(.C) *const FontConfig;
    pub extern fn ImVector_ImFontGlyph_back_const(self: *const Vector(FontGlyph)) callconv(.C) *const FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_back_const(self: *const Vector(StoragePair)) callconv(.C) *const StoragePair;
    pub extern fn ImVector_ImGuiTextRange_back_const(self: *const Vector(TextRange)) callconv(.C) *const TextRange;
    pub extern fn ImVector_ImTextureID_back_const(self: *const Vector(TextureID)) callconv(.C) *const TextureID;
    pub extern fn ImVector_ImU32_back_const(self: *const Vector(u32)) callconv(.C) *const u32;
    pub extern fn ImVector_ImVec2_back_const(self: *const Vector(Vec2)) callconv(.C) *const Vec2;
    pub extern fn ImVector_ImVec4_back_const(self: *const Vector(Vec4)) callconv(.C) *const Vec4;
    pub extern fn ImVector_ImWchar_back_const(self: *const Vector(Wchar)) callconv(.C) *const Wchar;
    pub extern fn ImVector_char_back_const(self: *const Vector(u8)) callconv(.C) *const u8;
    pub extern fn ImVector_float_back_const(self: *const Vector(f32)) callconv(.C) *const f32;
    pub extern fn ImVector_ImDrawChannel_begin(self: *Vector(DrawChannel)) callconv(.C) [*]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_begin(self: *Vector(DrawCmd)) callconv(.C) [*]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_begin(self: *Vector(DrawIdx)) callconv(.C) [*]DrawIdx;
    pub extern fn ImVector_ImDrawVert_begin(self: *Vector(DrawVert)) callconv(.C) [*]DrawVert;
    pub extern fn ImVector_ImFontPtr_begin(self: *Vector(*Font)) callconv(.C) [*]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_begin(self: *Vector(FontAtlasCustomRect)) callconv(.C) [*]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_begin(self: *Vector(FontConfig)) callconv(.C) [*]FontConfig;
    pub extern fn ImVector_ImFontGlyph_begin(self: *Vector(FontGlyph)) callconv(.C) [*]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_begin(self: *Vector(StoragePair)) callconv(.C) [*]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_begin(self: *Vector(TextRange)) callconv(.C) [*]TextRange;
    pub extern fn ImVector_ImTextureID_begin(self: *Vector(TextureID)) callconv(.C) [*]TextureID;
    pub extern fn ImVector_ImU32_begin(self: *Vector(u32)) callconv(.C) [*]u32;
    pub extern fn ImVector_ImVec2_begin(self: *Vector(Vec2)) callconv(.C) [*]Vec2;
    pub extern fn ImVector_ImVec4_begin(self: *Vector(Vec4)) callconv(.C) [*]Vec4;
    pub extern fn ImVector_ImWchar_begin(self: *Vector(Wchar)) callconv(.C) [*]Wchar;
    pub extern fn ImVector_char_begin(self: *Vector(u8)) callconv(.C) [*]u8;
    pub extern fn ImVector_float_begin(self: *Vector(f32)) callconv(.C) [*]f32;
    pub extern fn ImVector_ImDrawChannel_begin_const(self: *const Vector(DrawChannel)) callconv(.C) [*]const DrawChannel;
    pub extern fn ImVector_ImDrawCmd_begin_const(self: *const Vector(DrawCmd)) callconv(.C) [*]const DrawCmd;
    pub extern fn ImVector_ImDrawIdx_begin_const(self: *const Vector(DrawIdx)) callconv(.C) [*]const DrawIdx;
    pub extern fn ImVector_ImDrawVert_begin_const(self: *const Vector(DrawVert)) callconv(.C) [*]const DrawVert;
    pub extern fn ImVector_ImFontPtr_begin_const(self: *const Vector(*Font)) callconv(.C) [*]const *Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_begin_const(self: *const Vector(FontAtlasCustomRect)) callconv(.C) [*]const FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_begin_const(self: *const Vector(FontConfig)) callconv(.C) [*]const FontConfig;
    pub extern fn ImVector_ImFontGlyph_begin_const(self: *const Vector(FontGlyph)) callconv(.C) [*]const FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_begin_const(self: *const Vector(StoragePair)) callconv(.C) [*]const StoragePair;
    pub extern fn ImVector_ImGuiTextRange_begin_const(self: *const Vector(TextRange)) callconv(.C) [*]const TextRange;
    pub extern fn ImVector_ImTextureID_begin_const(self: *const Vector(TextureID)) callconv(.C) [*]const TextureID;
    pub extern fn ImVector_ImU32_begin_const(self: *const Vector(u32)) callconv(.C) [*]const u32;
    pub extern fn ImVector_ImVec2_begin_const(self: *const Vector(Vec2)) callconv(.C) [*]const Vec2;
    pub extern fn ImVector_ImVec4_begin_const(self: *const Vector(Vec4)) callconv(.C) [*]const Vec4;
    pub extern fn ImVector_ImWchar_begin_const(self: *const Vector(Wchar)) callconv(.C) [*]const Wchar;
    pub extern fn ImVector_char_begin_const(self: *const Vector(u8)) callconv(.C) [*]const u8;
    pub extern fn ImVector_float_begin_const(self: *const Vector(f32)) callconv(.C) [*]const f32;
    pub extern fn ImVector_ImDrawChannel_capacity(self: *const Vector(DrawChannel)) callconv(.C) i32;
    pub extern fn ImVector_ImDrawCmd_capacity(self: *const Vector(DrawCmd)) callconv(.C) i32;
    pub extern fn ImVector_ImDrawIdx_capacity(self: *const Vector(DrawIdx)) callconv(.C) i32;
    pub extern fn ImVector_ImDrawVert_capacity(self: *const Vector(DrawVert)) callconv(.C) i32;
    pub extern fn ImVector_ImFontPtr_capacity(self: *const Vector(*Font)) callconv(.C) i32;
    pub extern fn ImVector_ImFontAtlasCustomRect_capacity(self: *const Vector(FontAtlasCustomRect)) callconv(.C) i32;
    pub extern fn ImVector_ImFontConfig_capacity(self: *const Vector(FontConfig)) callconv(.C) i32;
    pub extern fn ImVector_ImFontGlyph_capacity(self: *const Vector(FontGlyph)) callconv(.C) i32;
    pub extern fn ImVector_ImGuiStoragePair_capacity(self: *const Vector(StoragePair)) callconv(.C) i32;
    pub extern fn ImVector_ImGuiTextRange_capacity(self: *const Vector(TextRange)) callconv(.C) i32;
    pub extern fn ImVector_ImTextureID_capacity(self: *const Vector(TextureID)) callconv(.C) i32;
    pub extern fn ImVector_ImU32_capacity(self: *const Vector(u32)) callconv(.C) i32;
    pub extern fn ImVector_ImVec2_capacity(self: *const Vector(Vec2)) callconv(.C) i32;
    pub extern fn ImVector_ImVec4_capacity(self: *const Vector(Vec4)) callconv(.C) i32;
    pub extern fn ImVector_ImWchar_capacity(self: *const Vector(Wchar)) callconv(.C) i32;
    pub extern fn ImVector_char_capacity(self: *const Vector(u8)) callconv(.C) i32;
    pub extern fn ImVector_float_capacity(self: *const Vector(f32)) callconv(.C) i32;
    pub extern fn ImVector_ImDrawChannel_clear(self: *Vector(DrawChannel)) callconv(.C) void;
    pub extern fn ImVector_ImDrawCmd_clear(self: *Vector(DrawCmd)) callconv(.C) void;
    pub extern fn ImVector_ImDrawIdx_clear(self: *Vector(DrawIdx)) callconv(.C) void;
    pub extern fn ImVector_ImDrawVert_clear(self: *Vector(DrawVert)) callconv(.C) void;
    pub extern fn ImVector_ImFontPtr_clear(self: *Vector(*Font)) callconv(.C) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_clear(self: *Vector(FontAtlasCustomRect)) callconv(.C) void;
    pub extern fn ImVector_ImFontConfig_clear(self: *Vector(FontConfig)) callconv(.C) void;
    pub extern fn ImVector_ImFontGlyph_clear(self: *Vector(FontGlyph)) callconv(.C) void;
    pub extern fn ImVector_ImGuiStoragePair_clear(self: *Vector(StoragePair)) callconv(.C) void;
    pub extern fn ImVector_ImGuiTextRange_clear(self: *Vector(TextRange)) callconv(.C) void;
    pub extern fn ImVector_ImTextureID_clear(self: *Vector(TextureID)) callconv(.C) void;
    pub extern fn ImVector_ImU32_clear(self: *Vector(u32)) callconv(.C) void;
    pub extern fn ImVector_ImVec2_clear(self: *Vector(Vec2)) callconv(.C) void;
    pub extern fn ImVector_ImVec4_clear(self: *Vector(Vec4)) callconv(.C) void;
    pub extern fn ImVector_ImWchar_clear(self: *Vector(Wchar)) callconv(.C) void;
    pub extern fn ImVector_char_clear(self: *Vector(u8)) callconv(.C) void;
    pub extern fn ImVector_float_clear(self: *Vector(f32)) callconv(.C) void;
    pub extern fn ImVector_ImDrawIdx_contains(self: *const Vector(DrawIdx), v: DrawIdx) callconv(.C) bool;
    pub extern fn ImVector_ImFontPtr_contains(self: *const Vector(*Font), v: *Font) callconv(.C) bool;
    pub extern fn ImVector_ImTextureID_contains(self: *const Vector(TextureID), v: TextureID) callconv(.C) bool;
    pub extern fn ImVector_ImU32_contains(self: *const Vector(u32), v: u32) callconv(.C) bool;
    pub extern fn ImVector_ImWchar_contains(self: *const Vector(Wchar), v: Wchar) callconv(.C) bool;
    pub extern fn ImVector_char_contains(self: *const Vector(u8), v: u8) callconv(.C) bool;
    pub extern fn ImVector_float_contains(self: *const Vector(f32), v: f32) callconv(.C) bool;
    pub extern fn ImVector_ImDrawChannel_destroy(self: *Vector(DrawChannel)) callconv(.C) void;
    pub extern fn ImVector_ImDrawCmd_destroy(self: *Vector(DrawCmd)) callconv(.C) void;
    pub extern fn ImVector_ImDrawIdx_destroy(self: *Vector(DrawIdx)) callconv(.C) void;
    pub extern fn ImVector_ImDrawVert_destroy(self: *Vector(DrawVert)) callconv(.C) void;
    pub extern fn ImVector_ImFontPtr_destroy(self: *Vector(*Font)) callconv(.C) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_destroy(self: *Vector(FontAtlasCustomRect)) callconv(.C) void;
    pub extern fn ImVector_ImFontConfig_destroy(self: *Vector(FontConfig)) callconv(.C) void;
    pub extern fn ImVector_ImFontGlyph_destroy(self: *Vector(FontGlyph)) callconv(.C) void;
    pub extern fn ImVector_ImGuiStoragePair_destroy(self: *Vector(StoragePair)) callconv(.C) void;
    pub extern fn ImVector_ImGuiTextRange_destroy(self: *Vector(TextRange)) callconv(.C) void;
    pub extern fn ImVector_ImTextureID_destroy(self: *Vector(TextureID)) callconv(.C) void;
    pub extern fn ImVector_ImU32_destroy(self: *Vector(u32)) callconv(.C) void;
    pub extern fn ImVector_ImVec2_destroy(self: *Vector(Vec2)) callconv(.C) void;
    pub extern fn ImVector_ImVec4_destroy(self: *Vector(Vec4)) callconv(.C) void;
    pub extern fn ImVector_ImWchar_destroy(self: *Vector(Wchar)) callconv(.C) void;
    pub extern fn ImVector_char_destroy(self: *Vector(u8)) callconv(.C) void;
    pub extern fn ImVector_float_destroy(self: *Vector(f32)) callconv(.C) void;
    pub extern fn ImVector_ImDrawChannel_empty(self: *const Vector(DrawChannel)) callconv(.C) bool;
    pub extern fn ImVector_ImDrawCmd_empty(self: *const Vector(DrawCmd)) callconv(.C) bool;
    pub extern fn ImVector_ImDrawIdx_empty(self: *const Vector(DrawIdx)) callconv(.C) bool;
    pub extern fn ImVector_ImDrawVert_empty(self: *const Vector(DrawVert)) callconv(.C) bool;
    pub extern fn ImVector_ImFontPtr_empty(self: *const Vector(*Font)) callconv(.C) bool;
    pub extern fn ImVector_ImFontAtlasCustomRect_empty(self: *const Vector(FontAtlasCustomRect)) callconv(.C) bool;
    pub extern fn ImVector_ImFontConfig_empty(self: *const Vector(FontConfig)) callconv(.C) bool;
    pub extern fn ImVector_ImFontGlyph_empty(self: *const Vector(FontGlyph)) callconv(.C) bool;
    pub extern fn ImVector_ImGuiStoragePair_empty(self: *const Vector(StoragePair)) callconv(.C) bool;
    pub extern fn ImVector_ImGuiTextRange_empty(self: *const Vector(TextRange)) callconv(.C) bool;
    pub extern fn ImVector_ImTextureID_empty(self: *const Vector(TextureID)) callconv(.C) bool;
    pub extern fn ImVector_ImU32_empty(self: *const Vector(u32)) callconv(.C) bool;
    pub extern fn ImVector_ImVec2_empty(self: *const Vector(Vec2)) callconv(.C) bool;
    pub extern fn ImVector_ImVec4_empty(self: *const Vector(Vec4)) callconv(.C) bool;
    pub extern fn ImVector_ImWchar_empty(self: *const Vector(Wchar)) callconv(.C) bool;
    pub extern fn ImVector_char_empty(self: *const Vector(u8)) callconv(.C) bool;
    pub extern fn ImVector_float_empty(self: *const Vector(f32)) callconv(.C) bool;
    pub extern fn ImVector_ImDrawChannel_end(self: *Vector(DrawChannel)) callconv(.C) [*]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_end(self: *Vector(DrawCmd)) callconv(.C) [*]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_end(self: *Vector(DrawIdx)) callconv(.C) [*]DrawIdx;
    pub extern fn ImVector_ImDrawVert_end(self: *Vector(DrawVert)) callconv(.C) [*]DrawVert;
    pub extern fn ImVector_ImFontPtr_end(self: *Vector(*Font)) callconv(.C) [*]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_end(self: *Vector(FontAtlasCustomRect)) callconv(.C) [*]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_end(self: *Vector(FontConfig)) callconv(.C) [*]FontConfig;
    pub extern fn ImVector_ImFontGlyph_end(self: *Vector(FontGlyph)) callconv(.C) [*]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_end(self: *Vector(StoragePair)) callconv(.C) [*]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_end(self: *Vector(TextRange)) callconv(.C) [*]TextRange;
    pub extern fn ImVector_ImTextureID_end(self: *Vector(TextureID)) callconv(.C) [*]TextureID;
    pub extern fn ImVector_ImU32_end(self: *Vector(u32)) callconv(.C) [*]u32;
    pub extern fn ImVector_ImVec2_end(self: *Vector(Vec2)) callconv(.C) [*]Vec2;
    pub extern fn ImVector_ImVec4_end(self: *Vector(Vec4)) callconv(.C) [*]Vec4;
    pub extern fn ImVector_ImWchar_end(self: *Vector(Wchar)) callconv(.C) [*]Wchar;
    pub extern fn ImVector_char_end(self: *Vector(u8)) callconv(.C) [*]u8;
    pub extern fn ImVector_float_end(self: *Vector(f32)) callconv(.C) [*]f32;
    pub extern fn ImVector_ImDrawChannel_end_const(self: *const Vector(DrawChannel)) callconv(.C) [*]const DrawChannel;
    pub extern fn ImVector_ImDrawCmd_end_const(self: *const Vector(DrawCmd)) callconv(.C) [*]const DrawCmd;
    pub extern fn ImVector_ImDrawIdx_end_const(self: *const Vector(DrawIdx)) callconv(.C) [*]const DrawIdx;
    pub extern fn ImVector_ImDrawVert_end_const(self: *const Vector(DrawVert)) callconv(.C) [*]const DrawVert;
    pub extern fn ImVector_ImFontPtr_end_const(self: *const Vector(*Font)) callconv(.C) [*]const *Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_end_const(self: *const Vector(FontAtlasCustomRect)) callconv(.C) [*]const FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_end_const(self: *const Vector(FontConfig)) callconv(.C) [*]const FontConfig;
    pub extern fn ImVector_ImFontGlyph_end_const(self: *const Vector(FontGlyph)) callconv(.C) [*]const FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_end_const(self: *const Vector(StoragePair)) callconv(.C) [*]const StoragePair;
    pub extern fn ImVector_ImGuiTextRange_end_const(self: *const Vector(TextRange)) callconv(.C) [*]const TextRange;
    pub extern fn ImVector_ImTextureID_end_const(self: *const Vector(TextureID)) callconv(.C) [*]const TextureID;
    pub extern fn ImVector_ImU32_end_const(self: *const Vector(u32)) callconv(.C) [*]const u32;
    pub extern fn ImVector_ImVec2_end_const(self: *const Vector(Vec2)) callconv(.C) [*]const Vec2;
    pub extern fn ImVector_ImVec4_end_const(self: *const Vector(Vec4)) callconv(.C) [*]const Vec4;
    pub extern fn ImVector_ImWchar_end_const(self: *const Vector(Wchar)) callconv(.C) [*]const Wchar;
    pub extern fn ImVector_char_end_const(self: *const Vector(u8)) callconv(.C) [*]const u8;
    pub extern fn ImVector_float_end_const(self: *const Vector(f32)) callconv(.C) [*]const f32;
    pub extern fn ImVector_ImDrawChannel_erase(self: *Vector(DrawChannel), it: [*]const DrawChannel) callconv(.C) [*]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_erase(self: *Vector(DrawCmd), it: [*]const DrawCmd) callconv(.C) [*]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_erase(self: *Vector(DrawIdx), it: [*]const DrawIdx) callconv(.C) [*]DrawIdx;
    pub extern fn ImVector_ImDrawVert_erase(self: *Vector(DrawVert), it: [*]const DrawVert) callconv(.C) [*]DrawVert;
    pub extern fn ImVector_ImFontPtr_erase(self: *Vector(*Font), it: [*]const *Font) callconv(.C) [*]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_erase(self: *Vector(FontAtlasCustomRect), it: [*]const FontAtlasCustomRect) callconv(.C) [*]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_erase(self: *Vector(FontConfig), it: [*]const FontConfig) callconv(.C) [*]FontConfig;
    pub extern fn ImVector_ImFontGlyph_erase(self: *Vector(FontGlyph), it: [*]const FontGlyph) callconv(.C) [*]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_erase(self: *Vector(StoragePair), it: [*]const StoragePair) callconv(.C) [*]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_erase(self: *Vector(TextRange), it: [*]const TextRange) callconv(.C) [*]TextRange;
    pub extern fn ImVector_ImTextureID_erase(self: *Vector(TextureID), it: [*]const TextureID) callconv(.C) [*]TextureID;
    pub extern fn ImVector_ImU32_erase(self: *Vector(u32), it: [*]const u32) callconv(.C) [*]u32;
    pub extern fn ImVector_ImVec2_erase(self: *Vector(Vec2), it: [*]const Vec2) callconv(.C) [*]Vec2;
    pub extern fn ImVector_ImVec4_erase(self: *Vector(Vec4), it: [*]const Vec4) callconv(.C) [*]Vec4;
    pub extern fn ImVector_ImWchar_erase(self: *Vector(Wchar), it: [*]const Wchar) callconv(.C) [*]Wchar;
    pub extern fn ImVector_char_erase(self: *Vector(u8), it: [*]const u8) callconv(.C) [*]u8;
    pub extern fn ImVector_float_erase(self: *Vector(f32), it: [*]const f32) callconv(.C) [*]f32;
    pub extern fn ImVector_ImDrawChannel_eraseTPtr(self: *Vector(DrawChannel), it: [*]const DrawChannel, it_last: [*]const DrawChannel) callconv(.C) [*]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_eraseTPtr(self: *Vector(DrawCmd), it: [*]const DrawCmd, it_last: [*]const DrawCmd) callconv(.C) [*]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_eraseTPtr(self: *Vector(DrawIdx), it: [*]const DrawIdx, it_last: [*]const DrawIdx) callconv(.C) [*]DrawIdx;
    pub extern fn ImVector_ImDrawVert_eraseTPtr(self: *Vector(DrawVert), it: [*]const DrawVert, it_last: [*]const DrawVert) callconv(.C) [*]DrawVert;
    pub extern fn ImVector_ImFontPtr_eraseTPtr(self: *Vector(*Font), it: [*]const *Font, it_last: [*]const *Font) callconv(.C) [*]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_eraseTPtr(self: *Vector(FontAtlasCustomRect), it: [*]const FontAtlasCustomRect, it_last: [*]const FontAtlasCustomRect) callconv(.C) [*]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_eraseTPtr(self: *Vector(FontConfig), it: [*]const FontConfig, it_last: [*]const FontConfig) callconv(.C) [*]FontConfig;
    pub extern fn ImVector_ImFontGlyph_eraseTPtr(self: *Vector(FontGlyph), it: [*]const FontGlyph, it_last: [*]const FontGlyph) callconv(.C) [*]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_eraseTPtr(self: *Vector(StoragePair), it: [*]const StoragePair, it_last: [*]const StoragePair) callconv(.C) [*]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_eraseTPtr(self: *Vector(TextRange), it: [*]const TextRange, it_last: [*]const TextRange) callconv(.C) [*]TextRange;
    pub extern fn ImVector_ImTextureID_eraseTPtr(self: *Vector(TextureID), it: [*]const TextureID, it_last: [*]const TextureID) callconv(.C) [*]TextureID;
    pub extern fn ImVector_ImU32_eraseTPtr(self: *Vector(u32), it: [*]const u32, it_last: [*]const u32) callconv(.C) [*]u32;
    pub extern fn ImVector_ImVec2_eraseTPtr(self: *Vector(Vec2), it: [*]const Vec2, it_last: [*]const Vec2) callconv(.C) [*]Vec2;
    pub extern fn ImVector_ImVec4_eraseTPtr(self: *Vector(Vec4), it: [*]const Vec4, it_last: [*]const Vec4) callconv(.C) [*]Vec4;
    pub extern fn ImVector_ImWchar_eraseTPtr(self: *Vector(Wchar), it: [*]const Wchar, it_last: [*]const Wchar) callconv(.C) [*]Wchar;
    pub extern fn ImVector_char_eraseTPtr(self: *Vector(u8), it: [*]const u8, it_last: [*]const u8) callconv(.C) [*]u8;
    pub extern fn ImVector_float_eraseTPtr(self: *Vector(f32), it: [*]const f32, it_last: [*]const f32) callconv(.C) [*]f32;
    pub extern fn ImVector_ImDrawChannel_erase_unsorted(self: *Vector(DrawChannel), it: [*]const DrawChannel) callconv(.C) [*]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_erase_unsorted(self: *Vector(DrawCmd), it: [*]const DrawCmd) callconv(.C) [*]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_erase_unsorted(self: *Vector(DrawIdx), it: [*]const DrawIdx) callconv(.C) [*]DrawIdx;
    pub extern fn ImVector_ImDrawVert_erase_unsorted(self: *Vector(DrawVert), it: [*]const DrawVert) callconv(.C) [*]DrawVert;
    pub extern fn ImVector_ImFontPtr_erase_unsorted(self: *Vector(*Font), it: [*]const *Font) callconv(.C) [*]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_erase_unsorted(self: *Vector(FontAtlasCustomRect), it: [*]const FontAtlasCustomRect) callconv(.C) [*]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_erase_unsorted(self: *Vector(FontConfig), it: [*]const FontConfig) callconv(.C) [*]FontConfig;
    pub extern fn ImVector_ImFontGlyph_erase_unsorted(self: *Vector(FontGlyph), it: [*]const FontGlyph) callconv(.C) [*]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_erase_unsorted(self: *Vector(StoragePair), it: [*]const StoragePair) callconv(.C) [*]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_erase_unsorted(self: *Vector(TextRange), it: [*]const TextRange) callconv(.C) [*]TextRange;
    pub extern fn ImVector_ImTextureID_erase_unsorted(self: *Vector(TextureID), it: [*]const TextureID) callconv(.C) [*]TextureID;
    pub extern fn ImVector_ImU32_erase_unsorted(self: *Vector(u32), it: [*]const u32) callconv(.C) [*]u32;
    pub extern fn ImVector_ImVec2_erase_unsorted(self: *Vector(Vec2), it: [*]const Vec2) callconv(.C) [*]Vec2;
    pub extern fn ImVector_ImVec4_erase_unsorted(self: *Vector(Vec4), it: [*]const Vec4) callconv(.C) [*]Vec4;
    pub extern fn ImVector_ImWchar_erase_unsorted(self: *Vector(Wchar), it: [*]const Wchar) callconv(.C) [*]Wchar;
    pub extern fn ImVector_char_erase_unsorted(self: *Vector(u8), it: [*]const u8) callconv(.C) [*]u8;
    pub extern fn ImVector_float_erase_unsorted(self: *Vector(f32), it: [*]const f32) callconv(.C) [*]f32;
    pub extern fn ImVector_ImDrawIdx_find(self: *Vector(DrawIdx), v: DrawIdx) callconv(.C) [*]DrawIdx;
    pub extern fn ImVector_ImFontPtr_find(self: *Vector(*Font), v: *Font) callconv(.C) [*]*Font;
    pub extern fn ImVector_ImTextureID_find(self: *Vector(TextureID), v: TextureID) callconv(.C) [*]TextureID;
    pub extern fn ImVector_ImU32_find(self: *Vector(u32), v: u32) callconv(.C) [*]u32;
    pub extern fn ImVector_ImWchar_find(self: *Vector(Wchar), v: Wchar) callconv(.C) [*]Wchar;
    pub extern fn ImVector_char_find(self: *Vector(u8), v: u8) callconv(.C) [*]u8;
    pub extern fn ImVector_float_find(self: *Vector(f32), v: f32) callconv(.C) [*]f32;
    pub extern fn ImVector_ImDrawIdx_find_const(self: *const Vector(DrawIdx), v: DrawIdx) callconv(.C) [*]const DrawIdx;
    pub extern fn ImVector_ImFontPtr_find_const(self: *const Vector(*Font), v: *Font) callconv(.C) [*]const *Font;
    pub extern fn ImVector_ImTextureID_find_const(self: *const Vector(TextureID), v: TextureID) callconv(.C) [*]const TextureID;
    pub extern fn ImVector_ImU32_find_const(self: *const Vector(u32), v: u32) callconv(.C) [*]const u32;
    pub extern fn ImVector_ImWchar_find_const(self: *const Vector(Wchar), v: Wchar) callconv(.C) [*]const Wchar;
    pub extern fn ImVector_char_find_const(self: *const Vector(u8), v: u8) callconv(.C) [*]const u8;
    pub extern fn ImVector_float_find_const(self: *const Vector(f32), v: f32) callconv(.C) [*]const f32;
    pub extern fn ImVector_ImDrawIdx_find_erase(self: *Vector(DrawIdx), v: DrawIdx) callconv(.C) bool;
    pub extern fn ImVector_ImFontPtr_find_erase(self: *Vector(*Font), v: *Font) callconv(.C) bool;
    pub extern fn ImVector_ImTextureID_find_erase(self: *Vector(TextureID), v: TextureID) callconv(.C) bool;
    pub extern fn ImVector_ImU32_find_erase(self: *Vector(u32), v: u32) callconv(.C) bool;
    pub extern fn ImVector_ImWchar_find_erase(self: *Vector(Wchar), v: Wchar) callconv(.C) bool;
    pub extern fn ImVector_char_find_erase(self: *Vector(u8), v: u8) callconv(.C) bool;
    pub extern fn ImVector_float_find_erase(self: *Vector(f32), v: f32) callconv(.C) bool;
    pub extern fn ImVector_ImDrawIdx_find_erase_unsorted(self: *Vector(DrawIdx), v: DrawIdx) callconv(.C) bool;
    pub extern fn ImVector_ImFontPtr_find_erase_unsorted(self: *Vector(*Font), v: *Font) callconv(.C) bool;
    pub extern fn ImVector_ImTextureID_find_erase_unsorted(self: *Vector(TextureID), v: TextureID) callconv(.C) bool;
    pub extern fn ImVector_ImU32_find_erase_unsorted(self: *Vector(u32), v: u32) callconv(.C) bool;
    pub extern fn ImVector_ImWchar_find_erase_unsorted(self: *Vector(Wchar), v: Wchar) callconv(.C) bool;
    pub extern fn ImVector_char_find_erase_unsorted(self: *Vector(u8), v: u8) callconv(.C) bool;
    pub extern fn ImVector_float_find_erase_unsorted(self: *Vector(f32), v: f32) callconv(.C) bool;
    pub extern fn ImVector_ImDrawChannel_front(self: *Vector(DrawChannel)) callconv(.C) *DrawChannel;
    pub extern fn ImVector_ImDrawCmd_front(self: *Vector(DrawCmd)) callconv(.C) *DrawCmd;
    pub extern fn ImVector_ImDrawIdx_front(self: *Vector(DrawIdx)) callconv(.C) *DrawIdx;
    pub extern fn ImVector_ImDrawVert_front(self: *Vector(DrawVert)) callconv(.C) *DrawVert;
    pub extern fn ImVector_ImFontPtr_front(self: *Vector(*Font)) callconv(.C) **Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_front(self: *Vector(FontAtlasCustomRect)) callconv(.C) *FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_front(self: *Vector(FontConfig)) callconv(.C) *FontConfig;
    pub extern fn ImVector_ImFontGlyph_front(self: *Vector(FontGlyph)) callconv(.C) *FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_front(self: *Vector(StoragePair)) callconv(.C) *StoragePair;
    pub extern fn ImVector_ImGuiTextRange_front(self: *Vector(TextRange)) callconv(.C) *TextRange;
    pub extern fn ImVector_ImTextureID_front(self: *Vector(TextureID)) callconv(.C) *TextureID;
    pub extern fn ImVector_ImU32_front(self: *Vector(u32)) callconv(.C) *u32;
    pub extern fn ImVector_ImVec2_front(self: *Vector(Vec2)) callconv(.C) *Vec2;
    pub extern fn ImVector_ImVec4_front(self: *Vector(Vec4)) callconv(.C) *Vec4;
    pub extern fn ImVector_ImWchar_front(self: *Vector(Wchar)) callconv(.C) *Wchar;
    pub extern fn ImVector_char_front(self: *Vector(u8)) callconv(.C) *u8;
    pub extern fn ImVector_float_front(self: *Vector(f32)) callconv(.C) *f32;
    pub extern fn ImVector_ImDrawChannel_front_const(self: *const Vector(DrawChannel)) callconv(.C) *const DrawChannel;
    pub extern fn ImVector_ImDrawCmd_front_const(self: *const Vector(DrawCmd)) callconv(.C) *const DrawCmd;
    pub extern fn ImVector_ImDrawIdx_front_const(self: *const Vector(DrawIdx)) callconv(.C) *const DrawIdx;
    pub extern fn ImVector_ImDrawVert_front_const(self: *const Vector(DrawVert)) callconv(.C) *const DrawVert;
    pub extern fn ImVector_ImFontPtr_front_const(self: *const Vector(*Font)) callconv(.C) *const *Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_front_const(self: *const Vector(FontAtlasCustomRect)) callconv(.C) *const FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_front_const(self: *const Vector(FontConfig)) callconv(.C) *const FontConfig;
    pub extern fn ImVector_ImFontGlyph_front_const(self: *const Vector(FontGlyph)) callconv(.C) *const FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_front_const(self: *const Vector(StoragePair)) callconv(.C) *const StoragePair;
    pub extern fn ImVector_ImGuiTextRange_front_const(self: *const Vector(TextRange)) callconv(.C) *const TextRange;
    pub extern fn ImVector_ImTextureID_front_const(self: *const Vector(TextureID)) callconv(.C) *const TextureID;
    pub extern fn ImVector_ImU32_front_const(self: *const Vector(u32)) callconv(.C) *const u32;
    pub extern fn ImVector_ImVec2_front_const(self: *const Vector(Vec2)) callconv(.C) *const Vec2;
    pub extern fn ImVector_ImVec4_front_const(self: *const Vector(Vec4)) callconv(.C) *const Vec4;
    pub extern fn ImVector_ImWchar_front_const(self: *const Vector(Wchar)) callconv(.C) *const Wchar;
    pub extern fn ImVector_char_front_const(self: *const Vector(u8)) callconv(.C) *const u8;
    pub extern fn ImVector_float_front_const(self: *const Vector(f32)) callconv(.C) *const f32;
    pub extern fn ImVector_ImDrawChannel_index_from_ptr(self: *const Vector(DrawChannel), it: [*]const DrawChannel) callconv(.C) i32;
    pub extern fn ImVector_ImDrawCmd_index_from_ptr(self: *const Vector(DrawCmd), it: [*]const DrawCmd) callconv(.C) i32;
    pub extern fn ImVector_ImDrawIdx_index_from_ptr(self: *const Vector(DrawIdx), it: [*]const DrawIdx) callconv(.C) i32;
    pub extern fn ImVector_ImDrawVert_index_from_ptr(self: *const Vector(DrawVert), it: [*]const DrawVert) callconv(.C) i32;
    pub extern fn ImVector_ImFontPtr_index_from_ptr(self: *const Vector(*Font), it: [*]const *Font) callconv(.C) i32;
    pub extern fn ImVector_ImFontAtlasCustomRect_index_from_ptr(self: *const Vector(FontAtlasCustomRect), it: [*]const FontAtlasCustomRect) callconv(.C) i32;
    pub extern fn ImVector_ImFontConfig_index_from_ptr(self: *const Vector(FontConfig), it: [*]const FontConfig) callconv(.C) i32;
    pub extern fn ImVector_ImFontGlyph_index_from_ptr(self: *const Vector(FontGlyph), it: [*]const FontGlyph) callconv(.C) i32;
    pub extern fn ImVector_ImGuiStoragePair_index_from_ptr(self: *const Vector(StoragePair), it: [*]const StoragePair) callconv(.C) i32;
    pub extern fn ImVector_ImGuiTextRange_index_from_ptr(self: *const Vector(TextRange), it: [*]const TextRange) callconv(.C) i32;
    pub extern fn ImVector_ImTextureID_index_from_ptr(self: *const Vector(TextureID), it: [*]const TextureID) callconv(.C) i32;
    pub extern fn ImVector_ImU32_index_from_ptr(self: *const Vector(u32), it: [*]const u32) callconv(.C) i32;
    pub extern fn ImVector_ImVec2_index_from_ptr(self: *const Vector(Vec2), it: [*]const Vec2) callconv(.C) i32;
    pub extern fn ImVector_ImVec4_index_from_ptr(self: *const Vector(Vec4), it: [*]const Vec4) callconv(.C) i32;
    pub extern fn ImVector_ImWchar_index_from_ptr(self: *const Vector(Wchar), it: [*]const Wchar) callconv(.C) i32;
    pub extern fn ImVector_char_index_from_ptr(self: *const Vector(u8), it: [*]const u8) callconv(.C) i32;
    pub extern fn ImVector_float_index_from_ptr(self: *const Vector(f32), it: [*]const f32) callconv(.C) i32;
    pub extern fn ImVector_ImDrawChannel_insert(self: *Vector(DrawChannel), it: [*]const DrawChannel, v: DrawChannel) callconv(.C) [*]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_insert(self: *Vector(DrawCmd), it: [*]const DrawCmd, v: DrawCmd) callconv(.C) [*]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_insert(self: *Vector(DrawIdx), it: [*]const DrawIdx, v: DrawIdx) callconv(.C) [*]DrawIdx;
    pub extern fn ImVector_ImDrawVert_insert(self: *Vector(DrawVert), it: [*]const DrawVert, v: DrawVert) callconv(.C) [*]DrawVert;
    pub extern fn ImVector_ImFontPtr_insert(self: *Vector(*Font), it: [*]const *Font, v: *Font) callconv(.C) [*]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_insert(self: *Vector(FontAtlasCustomRect), it: [*]const FontAtlasCustomRect, v: FontAtlasCustomRect) callconv(.C) [*]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_insert(self: *Vector(FontConfig), it: [*]const FontConfig, v: FontConfig) callconv(.C) [*]FontConfig;
    pub extern fn ImVector_ImFontGlyph_insert(self: *Vector(FontGlyph), it: [*]const FontGlyph, v: FontGlyph) callconv(.C) [*]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_insert(self: *Vector(StoragePair), it: [*]const StoragePair, v: StoragePair) callconv(.C) [*]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_insert(self: *Vector(TextRange), it: [*]const TextRange, v: TextRange) callconv(.C) [*]TextRange;
    pub extern fn ImVector_ImTextureID_insert(self: *Vector(TextureID), it: [*]const TextureID, v: TextureID) callconv(.C) [*]TextureID;
    pub extern fn ImVector_ImU32_insert(self: *Vector(u32), it: [*]const u32, v: u32) callconv(.C) [*]u32;
    pub extern fn ImVector_ImVec2_insert(self: *Vector(Vec2), it: [*]const Vec2, v: Vec2) callconv(.C) [*]Vec2;
    pub extern fn ImVector_ImVec4_insert(self: *Vector(Vec4), it: [*]const Vec4, v: Vec4) callconv(.C) [*]Vec4;
    pub extern fn ImVector_ImWchar_insert(self: *Vector(Wchar), it: [*]const Wchar, v: Wchar) callconv(.C) [*]Wchar;
    pub extern fn ImVector_char_insert(self: *Vector(u8), it: [*]const u8, v: u8) callconv(.C) [*]u8;
    pub extern fn ImVector_float_insert(self: *Vector(f32), it: [*]const f32, v: f32) callconv(.C) [*]f32;
    pub extern fn ImVector_ImDrawChannel_pop_back(self: *Vector(DrawChannel)) callconv(.C) void;
    pub extern fn ImVector_ImDrawCmd_pop_back(self: *Vector(DrawCmd)) callconv(.C) void;
    pub extern fn ImVector_ImDrawIdx_pop_back(self: *Vector(DrawIdx)) callconv(.C) void;
    pub extern fn ImVector_ImDrawVert_pop_back(self: *Vector(DrawVert)) callconv(.C) void;
    pub extern fn ImVector_ImFontPtr_pop_back(self: *Vector(*Font)) callconv(.C) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_pop_back(self: *Vector(FontAtlasCustomRect)) callconv(.C) void;
    pub extern fn ImVector_ImFontConfig_pop_back(self: *Vector(FontConfig)) callconv(.C) void;
    pub extern fn ImVector_ImFontGlyph_pop_back(self: *Vector(FontGlyph)) callconv(.C) void;
    pub extern fn ImVector_ImGuiStoragePair_pop_back(self: *Vector(StoragePair)) callconv(.C) void;
    pub extern fn ImVector_ImGuiTextRange_pop_back(self: *Vector(TextRange)) callconv(.C) void;
    pub extern fn ImVector_ImTextureID_pop_back(self: *Vector(TextureID)) callconv(.C) void;
    pub extern fn ImVector_ImU32_pop_back(self: *Vector(u32)) callconv(.C) void;
    pub extern fn ImVector_ImVec2_pop_back(self: *Vector(Vec2)) callconv(.C) void;
    pub extern fn ImVector_ImVec4_pop_back(self: *Vector(Vec4)) callconv(.C) void;
    pub extern fn ImVector_ImWchar_pop_back(self: *Vector(Wchar)) callconv(.C) void;
    pub extern fn ImVector_char_pop_back(self: *Vector(u8)) callconv(.C) void;
    pub extern fn ImVector_float_pop_back(self: *Vector(f32)) callconv(.C) void;
    pub extern fn ImVector_ImDrawChannel_push_back(self: *Vector(DrawChannel), v: DrawChannel) callconv(.C) void;
    pub extern fn ImVector_ImDrawCmd_push_back(self: *Vector(DrawCmd), v: DrawCmd) callconv(.C) void;
    pub extern fn ImVector_ImDrawIdx_push_back(self: *Vector(DrawIdx), v: DrawIdx) callconv(.C) void;
    pub extern fn ImVector_ImDrawVert_push_back(self: *Vector(DrawVert), v: DrawVert) callconv(.C) void;
    pub extern fn ImVector_ImFontPtr_push_back(self: *Vector(*Font), v: *Font) callconv(.C) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_push_back(self: *Vector(FontAtlasCustomRect), v: FontAtlasCustomRect) callconv(.C) void;
    pub extern fn ImVector_ImFontConfig_push_back(self: *Vector(FontConfig), v: FontConfig) callconv(.C) void;
    pub extern fn ImVector_ImFontGlyph_push_back(self: *Vector(FontGlyph), v: FontGlyph) callconv(.C) void;
    pub extern fn ImVector_ImGuiStoragePair_push_back(self: *Vector(StoragePair), v: StoragePair) callconv(.C) void;
    pub extern fn ImVector_ImGuiTextRange_push_back(self: *Vector(TextRange), v: TextRange) callconv(.C) void;
    pub extern fn ImVector_ImTextureID_push_back(self: *Vector(TextureID), v: TextureID) callconv(.C) void;
    pub extern fn ImVector_ImU32_push_back(self: *Vector(u32), v: u32) callconv(.C) void;
    pub extern fn ImVector_ImVec2_push_back(self: *Vector(Vec2), v: Vec2) callconv(.C) void;
    pub extern fn ImVector_ImVec4_push_back(self: *Vector(Vec4), v: Vec4) callconv(.C) void;
    pub extern fn ImVector_ImWchar_push_back(self: *Vector(Wchar), v: Wchar) callconv(.C) void;
    pub extern fn ImVector_char_push_back(self: *Vector(u8), v: u8) callconv(.C) void;
    pub extern fn ImVector_float_push_back(self: *Vector(f32), v: f32) callconv(.C) void;
    pub extern fn ImVector_ImDrawChannel_push_front(self: *Vector(DrawChannel), v: DrawChannel) callconv(.C) void;
    pub extern fn ImVector_ImDrawCmd_push_front(self: *Vector(DrawCmd), v: DrawCmd) callconv(.C) void;
    pub extern fn ImVector_ImDrawIdx_push_front(self: *Vector(DrawIdx), v: DrawIdx) callconv(.C) void;
    pub extern fn ImVector_ImDrawVert_push_front(self: *Vector(DrawVert), v: DrawVert) callconv(.C) void;
    pub extern fn ImVector_ImFontPtr_push_front(self: *Vector(*Font), v: *Font) callconv(.C) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_push_front(self: *Vector(FontAtlasCustomRect), v: FontAtlasCustomRect) callconv(.C) void;
    pub extern fn ImVector_ImFontConfig_push_front(self: *Vector(FontConfig), v: FontConfig) callconv(.C) void;
    pub extern fn ImVector_ImFontGlyph_push_front(self: *Vector(FontGlyph), v: FontGlyph) callconv(.C) void;
    pub extern fn ImVector_ImGuiStoragePair_push_front(self: *Vector(StoragePair), v: StoragePair) callconv(.C) void;
    pub extern fn ImVector_ImGuiTextRange_push_front(self: *Vector(TextRange), v: TextRange) callconv(.C) void;
    pub extern fn ImVector_ImTextureID_push_front(self: *Vector(TextureID), v: TextureID) callconv(.C) void;
    pub extern fn ImVector_ImU32_push_front(self: *Vector(u32), v: u32) callconv(.C) void;
    pub extern fn ImVector_ImVec2_push_front(self: *Vector(Vec2), v: Vec2) callconv(.C) void;
    pub extern fn ImVector_ImVec4_push_front(self: *Vector(Vec4), v: Vec4) callconv(.C) void;
    pub extern fn ImVector_ImWchar_push_front(self: *Vector(Wchar), v: Wchar) callconv(.C) void;
    pub extern fn ImVector_char_push_front(self: *Vector(u8), v: u8) callconv(.C) void;
    pub extern fn ImVector_float_push_front(self: *Vector(f32), v: f32) callconv(.C) void;
    pub extern fn ImVector_ImDrawChannel_reserve(self: *Vector(DrawChannel), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImDrawCmd_reserve(self: *Vector(DrawCmd), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImDrawIdx_reserve(self: *Vector(DrawIdx), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImDrawVert_reserve(self: *Vector(DrawVert), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImFontPtr_reserve(self: *Vector(*Font), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_reserve(self: *Vector(FontAtlasCustomRect), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImFontConfig_reserve(self: *Vector(FontConfig), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImFontGlyph_reserve(self: *Vector(FontGlyph), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImGuiStoragePair_reserve(self: *Vector(StoragePair), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImGuiTextRange_reserve(self: *Vector(TextRange), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImTextureID_reserve(self: *Vector(TextureID), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImU32_reserve(self: *Vector(u32), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImVec2_reserve(self: *Vector(Vec2), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImVec4_reserve(self: *Vector(Vec4), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImWchar_reserve(self: *Vector(Wchar), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_char_reserve(self: *Vector(u8), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_float_reserve(self: *Vector(f32), new_capacity: i32) callconv(.C) void;
    pub extern fn ImVector_ImDrawChannel_resize(self: *Vector(DrawChannel), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImDrawCmd_resize(self: *Vector(DrawCmd), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImDrawIdx_resize(self: *Vector(DrawIdx), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImDrawVert_resize(self: *Vector(DrawVert), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImFontPtr_resize(self: *Vector(*Font), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_resize(self: *Vector(FontAtlasCustomRect), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImFontConfig_resize(self: *Vector(FontConfig), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImFontGlyph_resize(self: *Vector(FontGlyph), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImGuiStoragePair_resize(self: *Vector(StoragePair), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImGuiTextRange_resize(self: *Vector(TextRange), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImTextureID_resize(self: *Vector(TextureID), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImU32_resize(self: *Vector(u32), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImVec2_resize(self: *Vector(Vec2), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImVec4_resize(self: *Vector(Vec4), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImWchar_resize(self: *Vector(Wchar), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_char_resize(self: *Vector(u8), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_float_resize(self: *Vector(f32), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImDrawChannel_resizeT(self: *Vector(DrawChannel), new_size: i32, v: DrawChannel) callconv(.C) void;
    pub extern fn ImVector_ImDrawCmd_resizeT(self: *Vector(DrawCmd), new_size: i32, v: DrawCmd) callconv(.C) void;
    pub extern fn ImVector_ImDrawIdx_resizeT(self: *Vector(DrawIdx), new_size: i32, v: DrawIdx) callconv(.C) void;
    pub extern fn ImVector_ImDrawVert_resizeT(self: *Vector(DrawVert), new_size: i32, v: DrawVert) callconv(.C) void;
    pub extern fn ImVector_ImFontPtr_resizeT(self: *Vector(*Font), new_size: i32, v: *Font) callconv(.C) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_resizeT(self: *Vector(FontAtlasCustomRect), new_size: i32, v: FontAtlasCustomRect) callconv(.C) void;
    pub extern fn ImVector_ImFontConfig_resizeT(self: *Vector(FontConfig), new_size: i32, v: FontConfig) callconv(.C) void;
    pub extern fn ImVector_ImFontGlyph_resizeT(self: *Vector(FontGlyph), new_size: i32, v: FontGlyph) callconv(.C) void;
    pub extern fn ImVector_ImGuiStoragePair_resizeT(self: *Vector(StoragePair), new_size: i32, v: StoragePair) callconv(.C) void;
    pub extern fn ImVector_ImGuiTextRange_resizeT(self: *Vector(TextRange), new_size: i32, v: TextRange) callconv(.C) void;
    pub extern fn ImVector_ImTextureID_resizeT(self: *Vector(TextureID), new_size: i32, v: TextureID) callconv(.C) void;
    pub extern fn ImVector_ImU32_resizeT(self: *Vector(u32), new_size: i32, v: u32) callconv(.C) void;
    pub extern fn ImVector_ImVec2_resizeT(self: *Vector(Vec2), new_size: i32, v: Vec2) callconv(.C) void;
    pub extern fn ImVector_ImVec4_resizeT(self: *Vector(Vec4), new_size: i32, v: Vec4) callconv(.C) void;
    pub extern fn ImVector_ImWchar_resizeT(self: *Vector(Wchar), new_size: i32, v: Wchar) callconv(.C) void;
    pub extern fn ImVector_char_resizeT(self: *Vector(u8), new_size: i32, v: u8) callconv(.C) void;
    pub extern fn ImVector_float_resizeT(self: *Vector(f32), new_size: i32, v: f32) callconv(.C) void;
    pub extern fn ImVector_ImDrawChannel_shrink(self: *Vector(DrawChannel), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImDrawCmd_shrink(self: *Vector(DrawCmd), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImDrawIdx_shrink(self: *Vector(DrawIdx), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImDrawVert_shrink(self: *Vector(DrawVert), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImFontPtr_shrink(self: *Vector(*Font), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_shrink(self: *Vector(FontAtlasCustomRect), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImFontConfig_shrink(self: *Vector(FontConfig), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImFontGlyph_shrink(self: *Vector(FontGlyph), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImGuiStoragePair_shrink(self: *Vector(StoragePair), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImGuiTextRange_shrink(self: *Vector(TextRange), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImTextureID_shrink(self: *Vector(TextureID), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImU32_shrink(self: *Vector(u32), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImVec2_shrink(self: *Vector(Vec2), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImVec4_shrink(self: *Vector(Vec4), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImWchar_shrink(self: *Vector(Wchar), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_char_shrink(self: *Vector(u8), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_float_shrink(self: *Vector(f32), new_size: i32) callconv(.C) void;
    pub extern fn ImVector_ImDrawChannel_size(self: *const Vector(DrawChannel)) callconv(.C) i32;
    pub extern fn ImVector_ImDrawCmd_size(self: *const Vector(DrawCmd)) callconv(.C) i32;
    pub extern fn ImVector_ImDrawIdx_size(self: *const Vector(DrawIdx)) callconv(.C) i32;
    pub extern fn ImVector_ImDrawVert_size(self: *const Vector(DrawVert)) callconv(.C) i32;
    pub extern fn ImVector_ImFontPtr_size(self: *const Vector(*Font)) callconv(.C) i32;
    pub extern fn ImVector_ImFontAtlasCustomRect_size(self: *const Vector(FontAtlasCustomRect)) callconv(.C) i32;
    pub extern fn ImVector_ImFontConfig_size(self: *const Vector(FontConfig)) callconv(.C) i32;
    pub extern fn ImVector_ImFontGlyph_size(self: *const Vector(FontGlyph)) callconv(.C) i32;
    pub extern fn ImVector_ImGuiStoragePair_size(self: *const Vector(StoragePair)) callconv(.C) i32;
    pub extern fn ImVector_ImGuiTextRange_size(self: *const Vector(TextRange)) callconv(.C) i32;
    pub extern fn ImVector_ImTextureID_size(self: *const Vector(TextureID)) callconv(.C) i32;
    pub extern fn ImVector_ImU32_size(self: *const Vector(u32)) callconv(.C) i32;
    pub extern fn ImVector_ImVec2_size(self: *const Vector(Vec2)) callconv(.C) i32;
    pub extern fn ImVector_ImVec4_size(self: *const Vector(Vec4)) callconv(.C) i32;
    pub extern fn ImVector_ImWchar_size(self: *const Vector(Wchar)) callconv(.C) i32;
    pub extern fn ImVector_char_size(self: *const Vector(u8)) callconv(.C) i32;
    pub extern fn ImVector_float_size(self: *const Vector(f32)) callconv(.C) i32;
    pub extern fn ImVector_ImDrawChannel_size_in_bytes(self: *const Vector(DrawChannel)) callconv(.C) i32;
    pub extern fn ImVector_ImDrawCmd_size_in_bytes(self: *const Vector(DrawCmd)) callconv(.C) i32;
    pub extern fn ImVector_ImDrawIdx_size_in_bytes(self: *const Vector(DrawIdx)) callconv(.C) i32;
    pub extern fn ImVector_ImDrawVert_size_in_bytes(self: *const Vector(DrawVert)) callconv(.C) i32;
    pub extern fn ImVector_ImFontPtr_size_in_bytes(self: *const Vector(*Font)) callconv(.C) i32;
    pub extern fn ImVector_ImFontAtlasCustomRect_size_in_bytes(self: *const Vector(FontAtlasCustomRect)) callconv(.C) i32;
    pub extern fn ImVector_ImFontConfig_size_in_bytes(self: *const Vector(FontConfig)) callconv(.C) i32;
    pub extern fn ImVector_ImFontGlyph_size_in_bytes(self: *const Vector(FontGlyph)) callconv(.C) i32;
    pub extern fn ImVector_ImGuiStoragePair_size_in_bytes(self: *const Vector(StoragePair)) callconv(.C) i32;
    pub extern fn ImVector_ImGuiTextRange_size_in_bytes(self: *const Vector(TextRange)) callconv(.C) i32;
    pub extern fn ImVector_ImTextureID_size_in_bytes(self: *const Vector(TextureID)) callconv(.C) i32;
    pub extern fn ImVector_ImU32_size_in_bytes(self: *const Vector(u32)) callconv(.C) i32;
    pub extern fn ImVector_ImVec2_size_in_bytes(self: *const Vector(Vec2)) callconv(.C) i32;
    pub extern fn ImVector_ImVec4_size_in_bytes(self: *const Vector(Vec4)) callconv(.C) i32;
    pub extern fn ImVector_ImWchar_size_in_bytes(self: *const Vector(Wchar)) callconv(.C) i32;
    pub extern fn ImVector_char_size_in_bytes(self: *const Vector(u8)) callconv(.C) i32;
    pub extern fn ImVector_float_size_in_bytes(self: *const Vector(f32)) callconv(.C) i32;
    pub extern fn ImVector_ImDrawChannel_swap(self: *Vector(DrawChannel), rhs: *Vector(DrawChannel)) callconv(.C) void;
    pub extern fn ImVector_ImDrawCmd_swap(self: *Vector(DrawCmd), rhs: *Vector(DrawCmd)) callconv(.C) void;
    pub extern fn ImVector_ImDrawIdx_swap(self: *Vector(DrawIdx), rhs: *Vector(DrawIdx)) callconv(.C) void;
    pub extern fn ImVector_ImDrawVert_swap(self: *Vector(DrawVert), rhs: *Vector(DrawVert)) callconv(.C) void;
    pub extern fn ImVector_ImFontPtr_swap(self: *Vector(*Font), rhs: *Vector(*Font)) callconv(.C) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_swap(self: *Vector(FontAtlasCustomRect), rhs: *Vector(FontAtlasCustomRect)) callconv(.C) void;
    pub extern fn ImVector_ImFontConfig_swap(self: *Vector(FontConfig), rhs: *Vector(FontConfig)) callconv(.C) void;
    pub extern fn ImVector_ImFontGlyph_swap(self: *Vector(FontGlyph), rhs: *Vector(FontGlyph)) callconv(.C) void;
    pub extern fn ImVector_ImGuiStoragePair_swap(self: *Vector(StoragePair), rhs: *Vector(StoragePair)) callconv(.C) void;
    pub extern fn ImVector_ImGuiTextRange_swap(self: *Vector(TextRange), rhs: *Vector(TextRange)) callconv(.C) void;
    pub extern fn ImVector_ImTextureID_swap(self: *Vector(TextureID), rhs: *Vector(TextureID)) callconv(.C) void;
    pub extern fn ImVector_ImU32_swap(self: *Vector(u32), rhs: *Vector(u32)) callconv(.C) void;
    pub extern fn ImVector_ImVec2_swap(self: *Vector(Vec2), rhs: *Vector(Vec2)) callconv(.C) void;
    pub extern fn ImVector_ImVec4_swap(self: *Vector(Vec4), rhs: *Vector(Vec4)) callconv(.C) void;
    pub extern fn ImVector_ImWchar_swap(self: *Vector(Wchar), rhs: *Vector(Wchar)) callconv(.C) void;
    pub extern fn ImVector_char_swap(self: *Vector(u8), rhs: *Vector(u8)) callconv(.C) void;
    pub extern fn ImVector_float_swap(self: *Vector(f32), rhs: *Vector(f32)) callconv(.C) void;
    pub extern fn igAcceptDragDropPayload(kind: ?[*:0]const u8, flags: DragDropFlagsInt) callconv(.C) ?*const Payload;
    pub extern fn igAlignTextToFramePadding() callconv(.C) void;
    pub extern fn igArrowButton(str_id: ?[*:0]const u8, dir: Dir) callconv(.C) bool;
    pub extern fn igBegin(name: ?[*:0]const u8, p_open: ?*bool, flags: WindowFlagsInt) callconv(.C) bool;
    pub extern fn igBeginChildStr(str_id: ?[*:0]const u8, size: Vec2, border: bool, flags: WindowFlagsInt) callconv(.C) bool;
    pub extern fn igBeginChildID(id: ID, size: Vec2, border: bool, flags: WindowFlagsInt) callconv(.C) bool;
    pub extern fn igBeginChildFrame(id: ID, size: Vec2, flags: WindowFlagsInt) callconv(.C) bool;
    pub extern fn igBeginCombo(label: ?[*:0]const u8, preview_value: ?[*:0]const u8, flags: ComboFlagsInt) callconv(.C) bool;
    pub extern fn igBeginDragDropSource(flags: DragDropFlagsInt) callconv(.C) bool;
    pub extern fn igBeginDragDropTarget() callconv(.C) bool;
    pub extern fn igBeginGroup() callconv(.C) void;
    pub extern fn igBeginMainMenuBar() callconv(.C) bool;
    pub extern fn igBeginMenu(label: ?[*:0]const u8, enabled: bool) callconv(.C) bool;
    pub extern fn igBeginMenuBar() callconv(.C) bool;
    pub extern fn igBeginPopup(str_id: ?[*:0]const u8, flags: WindowFlagsInt) callconv(.C) bool;
    pub extern fn igBeginPopupContextItem(str_id: ?[*:0]const u8, mouse_button: MouseButton) callconv(.C) bool;
    pub extern fn igBeginPopupContextVoid(str_id: ?[*:0]const u8, mouse_button: MouseButton) callconv(.C) bool;
    pub extern fn igBeginPopupContextWindow(str_id: ?[*:0]const u8, mouse_button: MouseButton, also_over_items: bool) callconv(.C) bool;
    pub extern fn igBeginPopupModal(name: ?[*:0]const u8, p_open: ?*bool, flags: WindowFlagsInt) callconv(.C) bool;
    pub extern fn igBeginTabBar(str_id: ?[*:0]const u8, flags: TabBarFlagsInt) callconv(.C) bool;
    pub extern fn igBeginTabItem(label: ?[*:0]const u8, p_open: ?*bool, flags: TabItemFlagsInt) callconv(.C) bool;
    pub extern fn igBeginTooltip() callconv(.C) void;
    pub extern fn igBullet() callconv(.C) void;
    pub extern fn igBulletText(fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igButton(label: ?[*:0]const u8, size: Vec2) callconv(.C) bool;
    pub extern fn igCalcItemWidth() callconv(.C) f32;
    pub extern fn igCalcListClipping(items_count: i32, items_height: f32, out_items_display_start: *i32, out_items_display_end: *i32) callconv(.C) void;
    pub extern fn igCalcTextSize_nonUDT(pOut: *Vec2, text: ?[*]const u8, text_end: ?[*]const u8, hide_text_after_double_hash: bool, wrap_width: f32) callconv(.C) void;
    pub extern fn igCaptureKeyboardFromApp(want_capture_keyboard_value: bool) callconv(.C) void;
    pub extern fn igCaptureMouseFromApp(want_capture_mouse_value: bool) callconv(.C) void;
    pub extern fn igCheckbox(label: ?[*:0]const u8, v: *bool) callconv(.C) bool;
    pub extern fn igCheckboxFlags(label: ?[*:0]const u8, flags: ?*u32, flags_value: u32) callconv(.C) bool;
    pub extern fn igCloseCurrentPopup() callconv(.C) void;
    pub extern fn igCollapsingHeader(label: ?[*:0]const u8, flags: TreeNodeFlagsInt) callconv(.C) bool;
    pub extern fn igCollapsingHeaderBoolPtr(label: ?[*:0]const u8, p_open: ?*bool, flags: TreeNodeFlagsInt) callconv(.C) bool;
    pub extern fn igColorButton(desc_id: ?[*:0]const u8, col: Vec4, flags: ColorEditFlagsInt, size: Vec2) callconv(.C) bool;
    pub extern fn igColorConvertFloat4ToU32(in: Vec4) callconv(.C) u32;
    pub extern fn igColorConvertHSVtoRGB(h: f32, s: f32, v: f32, out_r: *f32, out_g: *f32, out_b: *f32) callconv(.C) void;
    pub extern fn igColorConvertRGBtoHSV(r: f32, g: f32, b: f32, out_h: *f32, out_s: *f32, out_v: *f32) callconv(.C) void;
    pub extern fn igColorConvertU32ToFloat4_nonUDT(pOut: *Vec4, in: u32) callconv(.C) void;
    pub extern fn igColorEdit3(label: ?[*:0]const u8, col: *[3]f32, flags: ColorEditFlagsInt) callconv(.C) bool;
    pub extern fn igColorEdit4(label: ?[*:0]const u8, col: *[4]f32, flags: ColorEditFlagsInt) callconv(.C) bool;
    pub extern fn igColorPicker3(label: ?[*:0]const u8, col: *[3]f32, flags: ColorEditFlagsInt) callconv(.C) bool;
    pub extern fn igColorPicker4(label: ?[*:0]const u8, col: *[4]f32, flags: ColorEditFlagsInt, ref_col: ?*const[4]f32) callconv(.C) bool;
    pub extern fn igColumns(count: i32, id: ?[*:0]const u8, border: bool) callconv(.C) void;
    pub extern fn igCombo(label: ?[*:0]const u8, current_item: ?*i32, items: [*]const[*:0]const u8, items_count: i32, popup_max_height_in_items: i32) callconv(.C) bool;
    pub extern fn igComboStr(label: ?[*:0]const u8, current_item: ?*i32, items_separated_by_zeros: ?[*]const u8, popup_max_height_in_items: i32) callconv(.C) bool;
    pub extern fn igComboFnPtr(label: ?[*:0]const u8, current_item: ?*i32, items_getter: ?fn (data: ?*c_void, idx: i32, out_text: *?[*:0]const u8) callconv(.C) bool, data: ?*c_void, items_count: i32, popup_max_height_in_items: i32) callconv(.C) bool;
    pub extern fn igCreateContext(shared_font_atlas: ?*FontAtlas) callconv(.C) ?*Context;
    pub extern fn igDebugCheckVersionAndDataLayout(version_str: ?[*:0]const u8, sz_io: usize, sz_style: usize, sz_vec2: usize, sz_vec4: usize, sz_drawvert: usize, sz_drawidx: usize) callconv(.C) bool;
    pub extern fn igDestroyContext(ctx: ?*Context) callconv(.C) void;
    pub extern fn igDragFloat(label: ?[*:0]const u8, v: *f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igDragFloat2(label: ?[*:0]const u8, v: *[2]f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igDragFloat3(label: ?[*:0]const u8, v: *[3]f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igDragFloat4(label: ?[*:0]const u8, v: *[4]f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igDragFloatRange2(label: ?[*:0]const u8, v_current_min: *f32, v_current_max: *f32, v_speed: f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, format_max: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igDragInt(label: ?[*:0]const u8, v: *i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igDragInt2(label: ?[*:0]const u8, v: *[2]i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igDragInt3(label: ?[*:0]const u8, v: *[3]i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igDragInt4(label: ?[*:0]const u8, v: *[4]i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igDragIntRange2(label: ?[*:0]const u8, v_current_min: *i32, v_current_max: *i32, v_speed: f32, v_min: i32, v_max: i32, format: ?[*:0]const u8, format_max: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igDragScalar(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, v_speed: f32, p_min: ?*const c_void, p_max: ?*const c_void, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igDragScalarN(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, components: i32, v_speed: f32, p_min: ?*const c_void, p_max: ?*const c_void, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igDummy(size: Vec2) callconv(.C) void;
    pub extern fn igEnd() callconv(.C) void;
    pub extern fn igEndChild() callconv(.C) void;
    pub extern fn igEndChildFrame() callconv(.C) void;
    pub extern fn igEndCombo() callconv(.C) void;
    pub extern fn igEndDragDropSource() callconv(.C) void;
    pub extern fn igEndDragDropTarget() callconv(.C) void;
    pub extern fn igEndFrame() callconv(.C) void;
    pub extern fn igEndGroup() callconv(.C) void;
    pub extern fn igEndMainMenuBar() callconv(.C) void;
    pub extern fn igEndMenu() callconv(.C) void;
    pub extern fn igEndMenuBar() callconv(.C) void;
    pub extern fn igEndPopup() callconv(.C) void;
    pub extern fn igEndTabBar() callconv(.C) void;
    pub extern fn igEndTabItem() callconv(.C) void;
    pub extern fn igEndTooltip() callconv(.C) void;
    pub extern fn igGetBackgroundDrawList() callconv(.C) ?*DrawList;
    pub extern fn igGetClipboardText() callconv(.C) ?[*:0]const u8;
    pub extern fn igGetColorU32(idx: Col, alpha_mul: f32) callconv(.C) u32;
    pub extern fn igGetColorU32Vec4(col: Vec4) callconv(.C) u32;
    pub extern fn igGetColorU32U32(col: u32) callconv(.C) u32;
    pub extern fn igGetColumnIndex() callconv(.C) i32;
    pub extern fn igGetColumnOffset(column_index: i32) callconv(.C) f32;
    pub extern fn igGetColumnWidth(column_index: i32) callconv(.C) f32;
    pub extern fn igGetColumnsCount() callconv(.C) i32;
    pub extern fn igGetContentRegionAvail_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetContentRegionMax_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetCurrentContext() callconv(.C) ?*Context;
    pub extern fn igGetCursorPos_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetCursorPosX() callconv(.C) f32;
    pub extern fn igGetCursorPosY() callconv(.C) f32;
    pub extern fn igGetCursorScreenPos_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetCursorStartPos_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetDragDropPayload() callconv(.C) ?*const Payload;
    pub extern fn igGetDrawData() callconv(.C) *DrawData;
    pub extern fn igGetDrawListSharedData() callconv(.C) ?*DrawListSharedData;
    pub extern fn igGetFont() callconv(.C) ?*Font;
    pub extern fn igGetFontSize() callconv(.C) f32;
    pub extern fn igGetFontTexUvWhitePixel_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetForegroundDrawList() callconv(.C) ?*DrawList;
    pub extern fn igGetFrameCount() callconv(.C) i32;
    pub extern fn igGetFrameHeight() callconv(.C) f32;
    pub extern fn igGetFrameHeightWithSpacing() callconv(.C) f32;
    pub extern fn igGetIDStr(str_id: ?[*:0]const u8) callconv(.C) ID;
    pub extern fn igGetIDRange(str_id_begin: ?[*]const u8, str_id_end: ?[*]const u8) callconv(.C) ID;
    pub extern fn igGetIDPtr(ptr_id: ?*const c_void) callconv(.C) ID;
    pub extern fn igGetIO() callconv(.C) *IO;
    pub extern fn igGetItemRectMax_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetItemRectMin_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetItemRectSize_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetKeyIndex(imgui_key: Key) callconv(.C) i32;
    pub extern fn igGetKeyPressedAmount(key_index: i32, repeat_delay: f32, rate: f32) callconv(.C) i32;
    pub extern fn igGetMouseCursor() callconv(.C) MouseCursor;
    pub extern fn igGetMouseDragDelta_nonUDT(pOut: *Vec2, button: MouseButton, lock_threshold: f32) callconv(.C) void;
    pub extern fn igGetMousePos_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetMousePosOnOpeningCurrentPopup_nonUDT(pOut: *Vec2) callconv(.C) void;
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
    pub extern fn igGetWindowContentRegionMax_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetWindowContentRegionMin_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetWindowContentRegionWidth() callconv(.C) f32;
    pub extern fn igGetWindowDrawList() callconv(.C) ?*DrawList;
    pub extern fn igGetWindowHeight() callconv(.C) f32;
    pub extern fn igGetWindowPos_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetWindowSize_nonUDT(pOut: *Vec2) callconv(.C) void;
    pub extern fn igGetWindowWidth() callconv(.C) f32;
    pub extern fn igImage(user_texture_id: TextureID, size: Vec2, uv0: Vec2, uv1: Vec2, tint_col: Vec4, border_col: Vec4) callconv(.C) void;
    pub extern fn igImageButton(user_texture_id: TextureID, size: Vec2, uv0: Vec2, uv1: Vec2, frame_padding: i32, bg_col: Vec4, tint_col: Vec4) callconv(.C) bool;
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
    pub extern fn igInputScalar(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, p_step: ?*const c_void, p_step_fast: ?*const c_void, format: ?[*:0]const u8, flags: InputTextFlagsInt) callconv(.C) bool;
    pub extern fn igInputScalarN(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, components: i32, p_step: ?*const c_void, p_step_fast: ?*const c_void, format: ?[*:0]const u8, flags: InputTextFlagsInt) callconv(.C) bool;
    pub extern fn igInputText(label: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize, flags: InputTextFlagsInt, callback: InputTextCallback, user_data: ?*c_void) callconv(.C) bool;
    pub extern fn igInputTextMultiline(label: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize, size: Vec2, flags: InputTextFlagsInt, callback: InputTextCallback, user_data: ?*c_void) callconv(.C) bool;
    pub extern fn igInputTextWithHint(label: ?[*:0]const u8, hint: ?[*:0]const u8, buf: ?[*]u8, buf_size: usize, flags: InputTextFlagsInt, callback: InputTextCallback, user_data: ?*c_void) callconv(.C) bool;
    pub extern fn igInvisibleButton(str_id: ?[*:0]const u8, size: Vec2) callconv(.C) bool;
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
    pub extern fn igIsKeyDown(user_key_index: i32) callconv(.C) bool;
    pub extern fn igIsKeyPressed(user_key_index: i32, repeat: bool) callconv(.C) bool;
    pub extern fn igIsKeyReleased(user_key_index: i32) callconv(.C) bool;
    pub extern fn igIsMouseClicked(button: MouseButton, repeat: bool) callconv(.C) bool;
    pub extern fn igIsMouseDoubleClicked(button: MouseButton) callconv(.C) bool;
    pub extern fn igIsMouseDown(button: MouseButton) callconv(.C) bool;
    pub extern fn igIsMouseDragging(button: MouseButton, lock_threshold: f32) callconv(.C) bool;
    pub extern fn igIsMouseHoveringRect(r_min: Vec2, r_max: Vec2, clip: bool) callconv(.C) bool;
    pub extern fn igIsMousePosValid(mouse_pos: ?*const Vec2) callconv(.C) bool;
    pub extern fn igIsMouseReleased(button: MouseButton) callconv(.C) bool;
    pub extern fn igIsPopupOpen(str_id: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igIsRectVisible(size: Vec2) callconv(.C) bool;
    pub extern fn igIsRectVisibleVec2(rect_min: Vec2, rect_max: Vec2) callconv(.C) bool;
    pub extern fn igIsWindowAppearing() callconv(.C) bool;
    pub extern fn igIsWindowCollapsed() callconv(.C) bool;
    pub extern fn igIsWindowFocused(flags: FocusedFlagsInt) callconv(.C) bool;
    pub extern fn igIsWindowHovered(flags: HoveredFlagsInt) callconv(.C) bool;
    pub extern fn igLabelText(label: ?[*:0]const u8, fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igListBoxStr_arr(label: ?[*:0]const u8, current_item: ?*i32, items: [*]const[*:0]const u8, items_count: i32, height_in_items: i32) callconv(.C) bool;
    pub extern fn igListBoxFnPtr(label: ?[*:0]const u8, current_item: ?*i32, items_getter: ?fn (data: ?*c_void, idx: i32, out_text: *?[*:0]const u8) callconv(.C) bool, data: ?*c_void, items_count: i32, height_in_items: i32) callconv(.C) bool;
    pub extern fn igListBoxFooter() callconv(.C) void;
    pub extern fn igListBoxHeaderVec2(label: ?[*:0]const u8, size: Vec2) callconv(.C) bool;
    pub extern fn igListBoxHeaderInt(label: ?[*:0]const u8, items_count: i32, height_in_items: i32) callconv(.C) bool;
    pub extern fn igLoadIniSettingsFromDisk(ini_filename: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igLoadIniSettingsFromMemory(ini_data: ?[*]const u8, ini_size: usize) callconv(.C) void;
    pub extern fn igLogButtons() callconv(.C) void;
    pub extern fn igLogFinish() callconv(.C) void;
    pub extern fn igLogText(fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igLogToClipboard(auto_open_depth: i32) callconv(.C) void;
    pub extern fn igLogToFile(auto_open_depth: i32, filename: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igLogToTTY(auto_open_depth: i32) callconv(.C) void;
    pub extern fn igMemAlloc(size: usize) callconv(.C) ?*c_void;
    pub extern fn igMemFree(ptr: ?*c_void) callconv(.C) void;
    pub extern fn igMenuItemBool(label: ?[*:0]const u8, shortcut: ?[*:0]const u8, selected: bool, enabled: bool) callconv(.C) bool;
    pub extern fn igMenuItemBoolPtr(label: ?[*:0]const u8, shortcut: ?[*:0]const u8, p_selected: ?*bool, enabled: bool) callconv(.C) bool;
    pub extern fn igNewFrame() callconv(.C) void;
    pub extern fn igNewLine() callconv(.C) void;
    pub extern fn igNextColumn() callconv(.C) void;
    pub extern fn igOpenPopup(str_id: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igOpenPopupOnItemClick(str_id: ?[*:0]const u8, mouse_button: MouseButton) callconv(.C) bool;
    pub extern fn igPlotHistogramFloatPtr(label: ?[*:0]const u8, values: *const f32, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2, stride: i32) callconv(.C) void;
    pub extern fn igPlotHistogramFnPtr(label: ?[*:0]const u8, values_getter: ?fn (data: ?*c_void, idx: i32) callconv(.C) f32, data: ?*c_void, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2) callconv(.C) void;
    pub extern fn igPlotLines(label: ?[*:0]const u8, values: *const f32, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2, stride: i32) callconv(.C) void;
    pub extern fn igPlotLinesFnPtr(label: ?[*:0]const u8, values_getter: ?fn (data: ?*c_void, idx: i32) callconv(.C) f32, data: ?*c_void, values_count: i32, values_offset: i32, overlay_text: ?[*:0]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2) callconv(.C) void;
    pub extern fn igPopAllowKeyboardFocus() callconv(.C) void;
    pub extern fn igPopButtonRepeat() callconv(.C) void;
    pub extern fn igPopClipRect() callconv(.C) void;
    pub extern fn igPopFont() callconv(.C) void;
    pub extern fn igPopID() callconv(.C) void;
    pub extern fn igPopItemWidth() callconv(.C) void;
    pub extern fn igPopStyleColor(count: i32) callconv(.C) void;
    pub extern fn igPopStyleVar(count: i32) callconv(.C) void;
    pub extern fn igPopTextWrapPos() callconv(.C) void;
    pub extern fn igProgressBar(fraction: f32, size_arg: Vec2, overlay: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igPushAllowKeyboardFocus(allow_keyboard_focus: bool) callconv(.C) void;
    pub extern fn igPushButtonRepeat(repeat: bool) callconv(.C) void;
    pub extern fn igPushClipRect(clip_rect_min: Vec2, clip_rect_max: Vec2, intersect_with_current_clip_rect: bool) callconv(.C) void;
    pub extern fn igPushFont(font: ?*Font) callconv(.C) void;
    pub extern fn igPushIDStr(str_id: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igPushIDRange(str_id_begin: ?[*]const u8, str_id_end: ?[*]const u8) callconv(.C) void;
    pub extern fn igPushIDPtr(ptr_id: ?*const c_void) callconv(.C) void;
    pub extern fn igPushIDInt(int_id: i32) callconv(.C) void;
    pub extern fn igPushItemWidth(item_width: f32) callconv(.C) void;
    pub extern fn igPushStyleColorU32(idx: Col, col: u32) callconv(.C) void;
    pub extern fn igPushStyleColorVec4(idx: Col, col: Vec4) callconv(.C) void;
    pub extern fn igPushStyleVarFloat(idx: StyleVar, val: f32) callconv(.C) void;
    pub extern fn igPushStyleVarVec2(idx: StyleVar, val: Vec2) callconv(.C) void;
    pub extern fn igPushTextWrapPos(wrap_local_pos_x: f32) callconv(.C) void;
    pub extern fn igRadioButtonBool(label: ?[*:0]const u8, active: bool) callconv(.C) bool;
    pub extern fn igRadioButtonIntPtr(label: ?[*:0]const u8, v: *i32, v_button: i32) callconv(.C) bool;
    pub extern fn igRender() callconv(.C) void;
    pub extern fn igResetMouseDragDelta(button: MouseButton) callconv(.C) void;
    pub extern fn igSameLine(offset_from_start_x: f32, spacing: f32) callconv(.C) void;
    pub extern fn igSaveIniSettingsToDisk(ini_filename: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igSaveIniSettingsToMemory(out_ini_size: ?*usize) callconv(.C) ?[*:0]const u8;
    pub extern fn igSelectableBool(label: ?[*:0]const u8, selected: bool, flags: SelectableFlagsInt, size: Vec2) callconv(.C) bool;
    pub extern fn igSelectableBoolPtr(label: ?[*:0]const u8, p_selected: ?*bool, flags: SelectableFlagsInt, size: Vec2) callconv(.C) bool;
    pub extern fn igSeparator() callconv(.C) void;
    pub extern fn igSetAllocatorFunctions(alloc_func: ?fn (sz: usize, user_data: ?*c_void) callconv(.C) ?*c_void, free_func: ?fn (ptr: ?*c_void, user_data: ?*c_void) callconv(.C) void, user_data: ?*c_void) callconv(.C) void;
    pub extern fn igSetClipboardText(text: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igSetColorEditOptions(flags: ColorEditFlagsInt) callconv(.C) void;
    pub extern fn igSetColumnOffset(column_index: i32, offset_x: f32) callconv(.C) void;
    pub extern fn igSetColumnWidth(column_index: i32, width: f32) callconv(.C) void;
    pub extern fn igSetCurrentContext(ctx: ?*Context) callconv(.C) void;
    pub extern fn igSetCursorPos(local_pos: Vec2) callconv(.C) void;
    pub extern fn igSetCursorPosX(local_x: f32) callconv(.C) void;
    pub extern fn igSetCursorPosY(local_y: f32) callconv(.C) void;
    pub extern fn igSetCursorScreenPos(pos: Vec2) callconv(.C) void;
    pub extern fn igSetDragDropPayload(kind: ?[*:0]const u8, data: ?*const c_void, sz: usize, cond: CondFlagsInt) callconv(.C) bool;
    pub extern fn igSetItemAllowOverlap() callconv(.C) void;
    pub extern fn igSetItemDefaultFocus() callconv(.C) void;
    pub extern fn igSetKeyboardFocusHere(offset: i32) callconv(.C) void;
    pub extern fn igSetMouseCursor(cursor_type: MouseCursor) callconv(.C) void;
    pub extern fn igSetNextItemOpen(is_open: bool, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetNextItemWidth(item_width: f32) callconv(.C) void;
    pub extern fn igSetNextWindowBgAlpha(alpha: f32) callconv(.C) void;
    pub extern fn igSetNextWindowCollapsed(collapsed: bool, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetNextWindowContentSize(size: Vec2) callconv(.C) void;
    pub extern fn igSetNextWindowFocus() callconv(.C) void;
    pub extern fn igSetNextWindowPos(pos: Vec2, cond: CondFlagsInt, pivot: Vec2) callconv(.C) void;
    pub extern fn igSetNextWindowSize(size: Vec2, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetNextWindowSizeConstraints(size_min: Vec2, size_max: Vec2, custom_callback: SizeCallback, custom_callback_data: ?*c_void) callconv(.C) void;
    pub extern fn igSetScrollFromPosX(local_x: f32, center_x_ratio: f32) callconv(.C) void;
    pub extern fn igSetScrollFromPosY(local_y: f32, center_y_ratio: f32) callconv(.C) void;
    pub extern fn igSetScrollHereX(center_x_ratio: f32) callconv(.C) void;
    pub extern fn igSetScrollHereY(center_y_ratio: f32) callconv(.C) void;
    pub extern fn igSetScrollX(scroll_x: f32) callconv(.C) void;
    pub extern fn igSetScrollY(scroll_y: f32) callconv(.C) void;
    pub extern fn igSetStateStorage(storage: ?*Storage) callconv(.C) void;
    pub extern fn igSetTabItemClosed(tab_or_docked_window_label: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igSetTooltip(fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igSetWindowCollapsedBool(collapsed: bool, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetWindowCollapsedStr(name: ?[*:0]const u8, collapsed: bool, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetWindowFocus() callconv(.C) void;
    pub extern fn igSetWindowFocusStr(name: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igSetWindowFontScale(scale: f32) callconv(.C) void;
    pub extern fn igSetWindowPosVec2(pos: Vec2, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetWindowPosStr(name: ?[*:0]const u8, pos: Vec2, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetWindowSizeVec2(size: Vec2, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igSetWindowSizeStr(name: ?[*:0]const u8, size: Vec2, cond: CondFlagsInt) callconv(.C) void;
    pub extern fn igShowAboutWindow(p_open: ?*bool) callconv(.C) void;
    pub extern fn igShowDemoWindow(p_open: ?*bool) callconv(.C) void;
    pub extern fn igShowFontSelector(label: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igShowMetricsWindow(p_open: ?*bool) callconv(.C) void;
    pub extern fn igShowStyleEditor(ref: ?*Style) callconv(.C) void;
    pub extern fn igShowStyleSelector(label: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igShowUserGuide() callconv(.C) void;
    pub extern fn igSliderAngle(label: ?[*:0]const u8, v_rad: *f32, v_degrees_min: f32, v_degrees_max: f32, format: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igSliderFloat(label: ?[*:0]const u8, v: *f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igSliderFloat2(label: ?[*:0]const u8, v: *[2]f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igSliderFloat3(label: ?[*:0]const u8, v: *[3]f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igSliderFloat4(label: ?[*:0]const u8, v: *[4]f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igSliderInt(label: ?[*:0]const u8, v: *i32, v_min: i32, v_max: i32, format: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igSliderInt2(label: ?[*:0]const u8, v: *[2]i32, v_min: i32, v_max: i32, format: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igSliderInt3(label: ?[*:0]const u8, v: *[3]i32, v_min: i32, v_max: i32, format: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igSliderInt4(label: ?[*:0]const u8, v: *[4]i32, v_min: i32, v_max: i32, format: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igSliderScalar(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, p_min: ?*const c_void, p_max: ?*const c_void, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igSliderScalarN(label: ?[*:0]const u8, data_type: DataType, p_data: ?*c_void, components: i32, p_min: ?*const c_void, p_max: ?*const c_void, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igSmallButton(label: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igSpacing() callconv(.C) void;
    pub extern fn igStyleColorsClassic(dst: ?*Style) callconv(.C) void;
    pub extern fn igStyleColorsDark(dst: ?*Style) callconv(.C) void;
    pub extern fn igStyleColorsLight(dst: ?*Style) callconv(.C) void;
    pub extern fn igText(fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igTextColored(col: Vec4, fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igTextDisabled(fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igTextUnformatted(text: ?[*]const u8, text_end: ?[*]const u8) callconv(.C) void;
    pub extern fn igTextWrapped(fmt: ?[*:0]const u8, ...) callconv(.C) void;
    pub extern fn igTreeNodeStr(label: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igTreeNodeStrStr(str_id: ?[*:0]const u8, fmt: ?[*:0]const u8, ...) callconv(.C) bool;
    pub extern fn igTreeNodePtr(ptr_id: ?*const c_void, fmt: ?[*:0]const u8, ...) callconv(.C) bool;
    pub extern fn igTreeNodeExStr(label: ?[*:0]const u8, flags: TreeNodeFlagsInt) callconv(.C) bool;
    pub extern fn igTreeNodeExStrStr(str_id: ?[*:0]const u8, flags: TreeNodeFlagsInt, fmt: ?[*:0]const u8, ...) callconv(.C) bool;
    pub extern fn igTreeNodeExPtr(ptr_id: ?*const c_void, flags: TreeNodeFlagsInt, fmt: ?[*:0]const u8, ...) callconv(.C) bool;
    pub extern fn igTreePop() callconv(.C) void;
    pub extern fn igTreePushStr(str_id: ?[*:0]const u8) callconv(.C) void;
    pub extern fn igTreePushPtr(ptr_id: ?*const c_void) callconv(.C) void;
    pub extern fn igUnindent(indent_w: f32) callconv(.C) void;
    pub extern fn igVSliderFloat(label: ?[*:0]const u8, size: Vec2, v: *f32, v_min: f32, v_max: f32, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igVSliderInt(label: ?[*:0]const u8, size: Vec2, v: *i32, v_min: i32, v_max: i32, format: ?[*:0]const u8) callconv(.C) bool;
    pub extern fn igVSliderScalar(label: ?[*:0]const u8, size: Vec2, data_type: DataType, p_data: ?*c_void, p_min: ?*const c_void, p_max: ?*const c_void, format: ?[*:0]const u8, power: f32) callconv(.C) bool;
    pub extern fn igValueBool(prefix: ?[*:0]const u8, b: bool) callconv(.C) void;
    pub extern fn igValueInt(prefix: ?[*:0]const u8, v: i32) callconv(.C) void;
    pub extern fn igValueUint(prefix: ?[*:0]const u8, v: u32) callconv(.C) void;
    pub extern fn igValueFloat(prefix: ?[*:0]const u8, v: f32, float_format: ?[*:0]const u8) callconv(.C) void;
};
