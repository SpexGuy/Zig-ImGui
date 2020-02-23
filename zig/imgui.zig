pub const DrawListSharedData = @OpaqueType();
pub const Context = @OpaqueType();
pub const DrawCallback = ?extern fn (parent_list: *const DrawList, cmd: *const DrawCmd) void;
pub const DrawIdx = u16;
pub const ID = u32;
pub const InputTextCallback = ?extern fn (data: *InputTextCallbackData) i32;
pub const SizeCallback = ?extern fn (data: *SizeCallbackData) void;
pub const TextureID = ?*c_void;
pub const Wchar = u16;

pub const DrawCornerFlags = u32;
pub const DrawCornerFlagBits = struct {
    pub const None: DrawCornerFlags = 0;
    pub const TopLeft: DrawCornerFlags = 1 << 0;
    pub const TopRight: DrawCornerFlags = 1 << 1;
    pub const BotLeft: DrawCornerFlags = 1 << 2;
    pub const BotRight: DrawCornerFlags = 1 << 3;
    pub const Top: DrawCornerFlags = TopLeft | TopRight;
    pub const Bot: DrawCornerFlags = BotLeft | BotRight;
    pub const Left: DrawCornerFlags = TopLeft | BotLeft;
    pub const Right: DrawCornerFlags = TopRight | BotRight;
    pub const All: DrawCornerFlags = 0xF;
};

pub const DrawListFlags = u32;
pub const DrawListFlagBits = struct {
    pub const None: DrawListFlags = 0;
    pub const AntiAliasedLines: DrawListFlags = 1 << 0;
    pub const AntiAliasedFill: DrawListFlags = 1 << 1;
    pub const AllowVtxOffset: DrawListFlags = 1 << 2;
};

pub const FontAtlasFlags = u32;
pub const FontAtlasFlagBits = struct {
    pub const None: FontAtlasFlags = 0;
    pub const NoPowerOfTwoHeight: FontAtlasFlags = 1 << 0;
    pub const NoMouseCursors: FontAtlasFlags = 1 << 1;
};

pub const BackendFlags = u32;
pub const BackendFlagBits = struct {
    pub const None: BackendFlags = 0;
    pub const HasGamepad: BackendFlags = 1 << 0;
    pub const HasMouseCursors: BackendFlags = 1 << 1;
    pub const HasSetMousePos: BackendFlags = 1 << 2;
    pub const RendererHasVtxOffset: BackendFlags = 1 << 3;
};

pub const ColorEditFlags = u32;
pub const ColorEditFlagBits = struct {
    pub const None: ColorEditFlags = 0;
    pub const NoAlpha: ColorEditFlags = 1 << 1;
    pub const NoPicker: ColorEditFlags = 1 << 2;
    pub const NoOptions: ColorEditFlags = 1 << 3;
    pub const NoSmallPreview: ColorEditFlags = 1 << 4;
    pub const NoInputs: ColorEditFlags = 1 << 5;
    pub const NoTooltip: ColorEditFlags = 1 << 6;
    pub const NoLabel: ColorEditFlags = 1 << 7;
    pub const NoSidePreview: ColorEditFlags = 1 << 8;
    pub const NoDragDrop: ColorEditFlags = 1 << 9;
    pub const AlphaBar: ColorEditFlags = 1 << 16;
    pub const AlphaPreview: ColorEditFlags = 1 << 17;
    pub const AlphaPreviewHalf: ColorEditFlags = 1 << 18;
    pub const HDR: ColorEditFlags = 1 << 19;
    pub const DisplayRGB: ColorEditFlags = 1 << 20;
    pub const DisplayHSV: ColorEditFlags = 1 << 21;
    pub const DisplayHex: ColorEditFlags = 1 << 22;
    pub const Uint8: ColorEditFlags = 1 << 23;
    pub const Float: ColorEditFlags = 1 << 24;
    pub const PickerHueBar: ColorEditFlags = 1 << 25;
    pub const PickerHueWheel: ColorEditFlags = 1 << 26;
    pub const InputRGB: ColorEditFlags = 1 << 27;
    pub const InputHSV: ColorEditFlags = 1 << 28;
    pub const _OptionsDefault: ColorEditFlags = Uint8|DisplayRGB|InputRGB|PickerHueBar;
    pub const _DisplayMask: ColorEditFlags = DisplayRGB|DisplayHSV|DisplayHex;
    pub const _DataTypeMask: ColorEditFlags = Uint8|Float;
    pub const _PickerMask: ColorEditFlags = PickerHueWheel|PickerHueBar;
    pub const _InputMask: ColorEditFlags = InputRGB|InputHSV;
};

pub const ComboFlags = u32;
pub const ComboFlagBits = struct {
    pub const None: ComboFlags = 0;
    pub const PopupAlignLeft: ComboFlags = 1 << 0;
    pub const HeightSmall: ComboFlags = 1 << 1;
    pub const HeightRegular: ComboFlags = 1 << 2;
    pub const HeightLarge: ComboFlags = 1 << 3;
    pub const HeightLargest: ComboFlags = 1 << 4;
    pub const NoArrowButton: ComboFlags = 1 << 5;
    pub const NoPreview: ComboFlags = 1 << 6;
    pub const HeightMask_: ComboFlags = HeightSmall | HeightRegular | HeightLarge | HeightLargest;
};

pub const CondFlags = u32;
pub const CondFlagBits = struct {
    pub const Always: CondFlags = 1 << 0;
    pub const Once: CondFlags = 1 << 1;
    pub const FirstUseEver: CondFlags = 1 << 2;
    pub const Appearing: CondFlags = 1 << 3;
};

pub const ConfigFlags = u32;
pub const ConfigFlagBits = struct {
    pub const None: ConfigFlags = 0;
    pub const NavEnableKeyboard: ConfigFlags = 1 << 0;
    pub const NavEnableGamepad: ConfigFlags = 1 << 1;
    pub const NavEnableSetMousePos: ConfigFlags = 1 << 2;
    pub const NavNoCaptureKeyboard: ConfigFlags = 1 << 3;
    pub const NoMouse: ConfigFlags = 1 << 4;
    pub const NoMouseCursorChange: ConfigFlags = 1 << 5;
    pub const IsSRGB: ConfigFlags = 1 << 20;
    pub const IsTouchScreen: ConfigFlags = 1 << 21;
};

pub const DragDropFlags = u32;
pub const DragDropFlagBits = struct {
    pub const None: DragDropFlags = 0;
    pub const SourceNoPreviewTooltip: DragDropFlags = 1 << 0;
    pub const SourceNoDisableHover: DragDropFlags = 1 << 1;
    pub const SourceNoHoldToOpenOthers: DragDropFlags = 1 << 2;
    pub const SourceAllowNullID: DragDropFlags = 1 << 3;
    pub const SourceExtern: DragDropFlags = 1 << 4;
    pub const SourceAutoExpirePayload: DragDropFlags = 1 << 5;
    pub const AcceptBeforeDelivery: DragDropFlags = 1 << 10;
    pub const AcceptNoDrawDefaultRect: DragDropFlags = 1 << 11;
    pub const AcceptNoPreviewTooltip: DragDropFlags = 1 << 12;
    pub const AcceptPeekOnly: DragDropFlags = AcceptBeforeDelivery | AcceptNoDrawDefaultRect;
};

pub const FocusedFlags = u32;
pub const FocusedFlagBits = struct {
    pub const None: FocusedFlags = 0;
    pub const ChildWindows: FocusedFlags = 1 << 0;
    pub const RootWindow: FocusedFlags = 1 << 1;
    pub const AnyWindow: FocusedFlags = 1 << 2;
    pub const RootAndChildWindows: FocusedFlags = RootWindow | ChildWindows;
};

pub const HoveredFlags = u32;
pub const HoveredFlagBits = struct {
    pub const None: HoveredFlags = 0;
    pub const ChildWindows: HoveredFlags = 1 << 0;
    pub const RootWindow: HoveredFlags = 1 << 1;
    pub const AnyWindow: HoveredFlags = 1 << 2;
    pub const AllowWhenBlockedByPopup: HoveredFlags = 1 << 3;
    pub const AllowWhenBlockedByActiveItem: HoveredFlags = 1 << 5;
    pub const AllowWhenOverlapped: HoveredFlags = 1 << 6;
    pub const AllowWhenDisabled: HoveredFlags = 1 << 7;
    pub const RectOnly: HoveredFlags = AllowWhenBlockedByPopup | AllowWhenBlockedByActiveItem | AllowWhenOverlapped;
    pub const RootAndChildWindows: HoveredFlags = RootWindow | ChildWindows;
};

pub const InputTextFlags = u32;
pub const InputTextFlagBits = struct {
    pub const None: InputTextFlags = 0;
    pub const CharsDecimal: InputTextFlags = 1 << 0;
    pub const CharsHexadecimal: InputTextFlags = 1 << 1;
    pub const CharsUppercase: InputTextFlags = 1 << 2;
    pub const CharsNoBlank: InputTextFlags = 1 << 3;
    pub const AutoSelectAll: InputTextFlags = 1 << 4;
    pub const EnterReturnsTrue: InputTextFlags = 1 << 5;
    pub const CallbackCompletion: InputTextFlags = 1 << 6;
    pub const CallbackHistory: InputTextFlags = 1 << 7;
    pub const CallbackAlways: InputTextFlags = 1 << 8;
    pub const CallbackCharFilter: InputTextFlags = 1 << 9;
    pub const AllowTabInput: InputTextFlags = 1 << 10;
    pub const CtrlEnterForNewLine: InputTextFlags = 1 << 11;
    pub const NoHorizontalScroll: InputTextFlags = 1 << 12;
    pub const AlwaysInsertMode: InputTextFlags = 1 << 13;
    pub const ReadOnly: InputTextFlags = 1 << 14;
    pub const Password: InputTextFlags = 1 << 15;
    pub const NoUndoRedo: InputTextFlags = 1 << 16;
    pub const CharsScientific: InputTextFlags = 1 << 17;
    pub const CallbackResize: InputTextFlags = 1 << 18;
    pub const Multiline: InputTextFlags = 1 << 20;
    pub const NoMarkEdited: InputTextFlags = 1 << 21;
};

pub const SelectableFlags = u32;
pub const SelectableFlagBits = struct {
    pub const None: SelectableFlags = 0;
    pub const DontClosePopups: SelectableFlags = 1 << 0;
    pub const SpanAllColumns: SelectableFlags = 1 << 1;
    pub const AllowDoubleClick: SelectableFlags = 1 << 2;
    pub const Disabled: SelectableFlags = 1 << 3;
    pub const AllowItemOverlap: SelectableFlags = 1 << 4;
};

pub const TabBarFlags = u32;
pub const TabBarFlagBits = struct {
    pub const None: TabBarFlags = 0;
    pub const Reorderable: TabBarFlags = 1 << 0;
    pub const AutoSelectNewTabs: TabBarFlags = 1 << 1;
    pub const TabListPopupButton: TabBarFlags = 1 << 2;
    pub const NoCloseWithMiddleMouseButton: TabBarFlags = 1 << 3;
    pub const NoTabListScrollingButtons: TabBarFlags = 1 << 4;
    pub const NoTooltip: TabBarFlags = 1 << 5;
    pub const FittingPolicyResizeDown: TabBarFlags = 1 << 6;
    pub const FittingPolicyScroll: TabBarFlags = 1 << 7;
    pub const FittingPolicyMask_: TabBarFlags = FittingPolicyResizeDown | FittingPolicyScroll;
    pub const FittingPolicyDefault_: TabBarFlags = FittingPolicyResizeDown;
};

pub const TabItemFlags = u32;
pub const TabItemFlagBits = struct {
    pub const None: TabItemFlags = 0;
    pub const UnsavedDocument: TabItemFlags = 1 << 0;
    pub const SetSelected: TabItemFlags = 1 << 1;
    pub const NoCloseWithMiddleMouseButton: TabItemFlags = 1 << 2;
    pub const NoPushId: TabItemFlags = 1 << 3;
};

pub const TreeNodeFlags = u32;
pub const TreeNodeFlagBits = struct {
    pub const None: TreeNodeFlags = 0;
    pub const Selected: TreeNodeFlags = 1 << 0;
    pub const Framed: TreeNodeFlags = 1 << 1;
    pub const AllowItemOverlap: TreeNodeFlags = 1 << 2;
    pub const NoTreePushOnOpen: TreeNodeFlags = 1 << 3;
    pub const NoAutoOpenOnLog: TreeNodeFlags = 1 << 4;
    pub const DefaultOpen: TreeNodeFlags = 1 << 5;
    pub const OpenOnDoubleClick: TreeNodeFlags = 1 << 6;
    pub const OpenOnArrow: TreeNodeFlags = 1 << 7;
    pub const Leaf: TreeNodeFlags = 1 << 8;
    pub const Bullet: TreeNodeFlags = 1 << 9;
    pub const FramePadding: TreeNodeFlags = 1 << 10;
    pub const SpanAvailWidth: TreeNodeFlags = 1 << 11;
    pub const SpanFullWidth: TreeNodeFlags = 1 << 12;
    pub const NavLeftJumpsBackHere: TreeNodeFlags = 1 << 13;
    pub const CollapsingHeader: TreeNodeFlags = Framed | NoTreePushOnOpen | NoAutoOpenOnLog;
};

pub const WindowFlags = u32;
pub const WindowFlagBits = struct {
    pub const None: WindowFlags = 0;
    pub const NoTitleBar: WindowFlags = 1 << 0;
    pub const NoResize: WindowFlags = 1 << 1;
    pub const NoMove: WindowFlags = 1 << 2;
    pub const NoScrollbar: WindowFlags = 1 << 3;
    pub const NoScrollWithMouse: WindowFlags = 1 << 4;
    pub const NoCollapse: WindowFlags = 1 << 5;
    pub const AlwaysAutoResize: WindowFlags = 1 << 6;
    pub const NoBackground: WindowFlags = 1 << 7;
    pub const NoSavedSettings: WindowFlags = 1 << 8;
    pub const NoMouseInputs: WindowFlags = 1 << 9;
    pub const MenuBar: WindowFlags = 1 << 10;
    pub const HorizontalScrollbar: WindowFlags = 1 << 11;
    pub const NoFocusOnAppearing: WindowFlags = 1 << 12;
    pub const NoBringToFrontOnFocus: WindowFlags = 1 << 13;
    pub const AlwaysVerticalScrollbar: WindowFlags = 1 << 14;
    pub const AlwaysHorizontalScrollbar: WindowFlags = 1<< 15;
    pub const AlwaysUseWindowPadding: WindowFlags = 1 << 16;
    pub const NoNavInputs: WindowFlags = 1 << 18;
    pub const NoNavFocus: WindowFlags = 1 << 19;
    pub const UnsavedDocument: WindowFlags = 1 << 20;
    pub const NoNav: WindowFlags = NoNavInputs | NoNavFocus;
    pub const NoDecoration: WindowFlags = NoTitleBar | NoResize | NoScrollbar | NoCollapse;
    pub const NoInputs: WindowFlags = NoMouseInputs | NoNavInputs | NoNavFocus;
    pub const NavFlattened: WindowFlags = 1 << 23;
    pub const ChildWindow: WindowFlags = 1 << 24;
    pub const Tooltip: WindowFlags = 1 << 25;
    pub const Popup: WindowFlags = 1 << 26;
    pub const Modal: WindowFlags = 1 << 27;
    pub const ChildMenu: WindowFlags = 1 << 28;
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

    pub const HSV = raw.ImColor_HSV;
    pub const init = raw.ImColor_ImColor;
    pub const initInt = raw.ImColor_ImColorInt;
    pub const initU32 = raw.ImColor_ImColorU32;
    pub const initFloat = raw.ImColor_ImColorFloat;
    pub const initVec4 = raw.ImColor_ImColorVec4;
    pub const SetHSV = raw.ImColor_SetHSV;
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

    pub const init = raw.ImDrawCmd_ImDrawCmd;
    pub const deinit = raw.ImDrawCmd_destroy;
};

pub const DrawData = extern struct {
    Valid: bool,
    CmdLists: [*]*DrawList,
    CmdListsCount: i32,
    TotalIdxCount: i32,
    TotalVtxCount: i32,
    DisplayPos: Vec2,
    DisplaySize: Vec2,
    FramebufferScale: Vec2,

    pub const Clear = raw.ImDrawData_Clear;
    pub const DeIndexAllBuffers = raw.ImDrawData_DeIndexAllBuffers;
    pub const init = raw.ImDrawData_ImDrawData;
    pub const ScaleClipRects = raw.ImDrawData_ScaleClipRects;
    pub const deinit = raw.ImDrawData_destroy;
};

pub const DrawList = extern struct {
    CmdBuffer: Vector(DrawCmd),
    IdxBuffer: Vector(DrawIdx),
    VtxBuffer: Vector(DrawVert),
    Flags: DrawListFlags,
    _Data: *const DrawListSharedData,
    _OwnerName: [*]const u8,
    _VtxCurrentOffset: u32,
    _VtxCurrentIdx: u32,
    _VtxWritePtr: *DrawVert,
    _IdxWritePtr: *DrawIdx,
    _ClipRectStack: Vector(Vec4),
    _TextureIdStack: Vector(TextureID),
    _Path: Vector(Vec2),
    _Splitter: DrawListSplitter,

    pub const AddBezierCurve = raw.ImDrawList_AddBezierCurve;
    pub const AddCallback = raw.ImDrawList_AddCallback;
    pub const AddCircle = raw.ImDrawList_AddCircle;
    pub const AddCircleFilled = raw.ImDrawList_AddCircleFilled;
    pub const AddConvexPolyFilled = raw.ImDrawList_AddConvexPolyFilled;
    pub const AddDrawCmd = raw.ImDrawList_AddDrawCmd;
    pub const AddImage = raw.ImDrawList_AddImage;
    pub const AddImageQuad = raw.ImDrawList_AddImageQuad;
    pub const AddImageRounded = raw.ImDrawList_AddImageRounded;
    pub const AddLine = raw.ImDrawList_AddLine;
    pub const AddNgon = raw.ImDrawList_AddNgon;
    pub const AddNgonFilled = raw.ImDrawList_AddNgonFilled;
    pub const AddPolyline = raw.ImDrawList_AddPolyline;
    pub const AddQuad = raw.ImDrawList_AddQuad;
    pub const AddQuadFilled = raw.ImDrawList_AddQuadFilled;
    pub const AddRect = raw.ImDrawList_AddRect;
    pub const AddRectFilled = raw.ImDrawList_AddRectFilled;
    pub const AddRectFilledMultiColor = raw.ImDrawList_AddRectFilledMultiColor;
    pub const AddTextVec2 = raw.ImDrawList_AddTextVec2;
    pub const AddTextFontPtr = raw.ImDrawList_AddTextFontPtr;
    pub const AddTriangle = raw.ImDrawList_AddTriangle;
    pub const AddTriangleFilled = raw.ImDrawList_AddTriangleFilled;
    pub const ChannelsMerge = raw.ImDrawList_ChannelsMerge;
    pub const ChannelsSetCurrent = raw.ImDrawList_ChannelsSetCurrent;
    pub const ChannelsSplit = raw.ImDrawList_ChannelsSplit;
    pub const Clear = raw.ImDrawList_Clear;
    pub const ClearFreeMemory = raw.ImDrawList_ClearFreeMemory;
    pub const CloneOutput = raw.ImDrawList_CloneOutput;
    pub const GetClipRectMax = raw.ImDrawList_GetClipRectMax;
    pub const GetClipRectMin = raw.ImDrawList_GetClipRectMin;
    pub const init = raw.ImDrawList_ImDrawList;
    pub const PathArcTo = raw.ImDrawList_PathArcTo;
    pub const PathArcToFast = raw.ImDrawList_PathArcToFast;
    pub const PathBezierCurveTo = raw.ImDrawList_PathBezierCurveTo;
    pub const PathClear = raw.ImDrawList_PathClear;
    pub const PathFillConvex = raw.ImDrawList_PathFillConvex;
    pub const PathLineTo = raw.ImDrawList_PathLineTo;
    pub const PathLineToMergeDuplicate = raw.ImDrawList_PathLineToMergeDuplicate;
    pub const PathRect = raw.ImDrawList_PathRect;
    pub const PathStroke = raw.ImDrawList_PathStroke;
    pub const PopClipRect = raw.ImDrawList_PopClipRect;
    pub const PopTextureID = raw.ImDrawList_PopTextureID;
    pub const PrimQuadUV = raw.ImDrawList_PrimQuadUV;
    pub const PrimRect = raw.ImDrawList_PrimRect;
    pub const PrimRectUV = raw.ImDrawList_PrimRectUV;
    pub const PrimReserve = raw.ImDrawList_PrimReserve;
    pub const PrimUnreserve = raw.ImDrawList_PrimUnreserve;
    pub const PrimVtx = raw.ImDrawList_PrimVtx;
    pub const PrimWriteIdx = raw.ImDrawList_PrimWriteIdx;
    pub const PrimWriteVtx = raw.ImDrawList_PrimWriteVtx;
    pub const PushClipRect = raw.ImDrawList_PushClipRect;
    pub const PushClipRectFullScreen = raw.ImDrawList_PushClipRectFullScreen;
    pub const PushTextureID = raw.ImDrawList_PushTextureID;
    pub const UpdateClipRect = raw.ImDrawList_UpdateClipRect;
    pub const UpdateTextureID = raw.ImDrawList_UpdateTextureID;
    pub const deinit = raw.ImDrawList_destroy;
};

pub const DrawListSplitter = extern struct {
    _Current: i32,
    _Count: i32,
    _Channels: Vector(DrawChannel),

    pub const Clear = raw.ImDrawListSplitter_Clear;
    pub const ClearFreeMemory = raw.ImDrawListSplitter_ClearFreeMemory;
    pub const init = raw.ImDrawListSplitter_ImDrawListSplitter;
    pub const Merge = raw.ImDrawListSplitter_Merge;
    pub const SetCurrentChannel = raw.ImDrawListSplitter_SetCurrentChannel;
    pub const Split = raw.ImDrawListSplitter_Split;
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
    FallbackGlyph: *const FontGlyph,
    DisplayOffset: Vec2,
    ContainerAtlas: *FontAtlas,
    ConfigData: *const FontConfig,
    ConfigDataCount: i16,
    FallbackChar: Wchar,
    EllipsisChar: Wchar,
    DirtyLookupTables: bool,
    Scale: f32,
    Ascent: f32,
    Descent: f32,
    MetricsTotalSurface: i32,

    pub const AddGlyph = raw.ImFont_AddGlyph;
    pub const AddRemapChar = raw.ImFont_AddRemapChar;
    pub const BuildLookupTable = raw.ImFont_BuildLookupTable;
    pub const CalcTextSizeA = raw.ImFont_CalcTextSizeA;
    pub const CalcWordWrapPositionA = raw.ImFont_CalcWordWrapPositionA;
    pub const ClearOutputData = raw.ImFont_ClearOutputData;
    pub const FindGlyph = raw.ImFont_FindGlyph;
    pub const FindGlyphNoFallback = raw.ImFont_FindGlyphNoFallback;
    pub const GetCharAdvance = raw.ImFont_GetCharAdvance;
    pub const GetDebugName = raw.ImFont_GetDebugName;
    pub const GrowIndex = raw.ImFont_GrowIndex;
    pub const init = raw.ImFont_ImFont;
    pub const IsLoaded = raw.ImFont_IsLoaded;
    pub const RenderChar = raw.ImFont_RenderChar;
    pub const RenderText = raw.ImFont_RenderText;
    pub const SetFallbackChar = raw.ImFont_SetFallbackChar;
    pub const deinit = raw.ImFont_destroy;
};

pub const FontAtlas = extern struct {
    Locked: bool,
    Flags: FontAtlasFlags,
    TexID: TextureID,
    TexDesiredWidth: i32,
    TexGlyphPadding: i32,
    TexPixelsAlpha8: [*c]u8,
    TexPixelsRGBA32: [*c]u32,
    TexWidth: i32,
    TexHeight: i32,
    TexUvScale: Vec2,
    TexUvWhitePixel: Vec2,
    Fonts: Vector(*Font),
    CustomRects: Vector(FontAtlasCustomRect),
    ConfigData: Vector(FontConfig),
    CustomRectIds: [1]i32,

    pub const AddCustomRectFontGlyph = raw.ImFontAtlas_AddCustomRectFontGlyph;
    pub const AddCustomRectRegular = raw.ImFontAtlas_AddCustomRectRegular;
    pub const AddFont = raw.ImFontAtlas_AddFont;
    pub const AddFontDefault = raw.ImFontAtlas_AddFontDefault;
    pub const AddFontFromFileTTF = raw.ImFontAtlas_AddFontFromFileTTF;
    pub const AddFontFromMemoryCompressedBase85TTF = raw.ImFontAtlas_AddFontFromMemoryCompressedBase85TTF;
    pub const AddFontFromMemoryCompressedTTF = raw.ImFontAtlas_AddFontFromMemoryCompressedTTF;
    pub const AddFontFromMemoryTTF = raw.ImFontAtlas_AddFontFromMemoryTTF;
    pub const Build = raw.ImFontAtlas_Build;
    pub const CalcCustomRectUV = raw.ImFontAtlas_CalcCustomRectUV;
    pub const Clear = raw.ImFontAtlas_Clear;
    pub const ClearFonts = raw.ImFontAtlas_ClearFonts;
    pub const ClearInputData = raw.ImFontAtlas_ClearInputData;
    pub const ClearTexData = raw.ImFontAtlas_ClearTexData;
    pub const GetCustomRectByIndex = raw.ImFontAtlas_GetCustomRectByIndex;
    pub const GetGlyphRangesChineseFull = raw.ImFontAtlas_GetGlyphRangesChineseFull;
    pub const GetGlyphRangesChineseSimplifiedCommon = raw.ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon;
    pub const GetGlyphRangesCyrillic = raw.ImFontAtlas_GetGlyphRangesCyrillic;
    pub const GetGlyphRangesDefault = raw.ImFontAtlas_GetGlyphRangesDefault;
    pub const GetGlyphRangesJapanese = raw.ImFontAtlas_GetGlyphRangesJapanese;
    pub const GetGlyphRangesKorean = raw.ImFontAtlas_GetGlyphRangesKorean;
    pub const GetGlyphRangesThai = raw.ImFontAtlas_GetGlyphRangesThai;
    pub const GetGlyphRangesVietnamese = raw.ImFontAtlas_GetGlyphRangesVietnamese;
    pub const GetMouseCursorTexData = raw.ImFontAtlas_GetMouseCursorTexData;
    pub const GetTexDataAsAlpha8 = raw.ImFontAtlas_GetTexDataAsAlpha8;
    pub const GetTexDataAsRGBA32 = raw.ImFontAtlas_GetTexDataAsRGBA32;
    pub const init = raw.ImFontAtlas_ImFontAtlas;
    pub const IsBuilt = raw.ImFontAtlas_IsBuilt;
    pub const SetTexID = raw.ImFontAtlas_SetTexID;
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
    Font: *Font,

    pub const init = raw.ImFontAtlasCustomRect_ImFontAtlasCustomRect;
    pub const IsPacked = raw.ImFontAtlasCustomRect_IsPacked;
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
    GlyphRanges: [*]const Wchar,
    GlyphMinAdvanceX: f32,
    GlyphMaxAdvanceX: f32,
    MergeMode: bool,
    RasterizerFlags: u32,
    RasterizerMultiply: f32,
    EllipsisChar: Wchar,
    Name: [40]u8,
    DstFont: *Font,

    pub const init = raw.ImFontConfig_ImFontConfig;
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

    pub const AddChar = raw.ImFontGlyphRangesBuilder_AddChar;
    pub const AddRanges = raw.ImFontGlyphRangesBuilder_AddRanges;
    pub const AddText = raw.ImFontGlyphRangesBuilder_AddText;
    pub const BuildRanges = raw.ImFontGlyphRangesBuilder_BuildRanges;
    pub const Clear = raw.ImFontGlyphRangesBuilder_Clear;
    pub const GetBit = raw.ImFontGlyphRangesBuilder_GetBit;
    pub const init = raw.ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder;
    pub const SetBit = raw.ImFontGlyphRangesBuilder_SetBit;
    pub const deinit = raw.ImFontGlyphRangesBuilder_destroy;
};

pub const IO = extern struct {
    ConfigFlags: ConfigFlags,
    BackendFlags: BackendFlags,
    DisplaySize: Vec2,
    DeltaTime: f32,
    IniSavingRate: f32,
    IniFilename: [*]const u8,
    LogFilename: [*]const u8,
    MouseDoubleClickTime: f32,
    MouseDoubleClickMaxDist: f32,
    MouseDragThreshold: f32,
    KeyMap: [Key.COUNT]i32,
    KeyRepeatDelay: f32,
    KeyRepeatRate: f32,
    UserData: ?*c_void,
    Fonts: *FontAtlas,
    FontGlobalScale: f32,
    FontAllowUserScaling: bool,
    FontDefault: *Font,
    DisplayFramebufferScale: Vec2,
    MouseDrawCursor: bool,
    ConfigMacOSXBehaviors: bool,
    ConfigInputTextCursorBlink: bool,
    ConfigWindowsResizeFromEdges: bool,
    ConfigWindowsMoveFromTitleBarOnly: bool,
    ConfigWindowsMemoryCompactTimer: f32,
    BackendPlatformName: [*]const u8,
    BackendRendererName: [*]const u8,
    BackendPlatformUserData: ?*c_void,
    BackendRendererUserData: ?*c_void,
    BackendLanguageUserData: ?*c_void,
    GetClipboardTextFn: ?extern fn (user_data: ?*c_void) [*]const u8,
    SetClipboardTextFn: ?extern fn (user_data: ?*c_void, text: [*]const u8) void,
    ClipboardUserData: ?*c_void,
    ImeSetInputScreenPosFn: ?extern fn (x: i32, y: i32) void,
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

    pub const AddInputCharacter = raw.ImGuiIO_AddInputCharacter;
    pub const AddInputCharactersUTF8 = raw.ImGuiIO_AddInputCharactersUTF8;
    pub const ClearInputCharacters = raw.ImGuiIO_ClearInputCharacters;
    pub const init = raw.ImGuiIO_ImGuiIO;
    pub const deinit = raw.ImGuiIO_destroy;
};

pub const InputTextCallbackData = extern struct {
    EventFlag: InputTextFlags,
    Flags: InputTextFlags,
    UserData: ?*c_void,
    EventChar: Wchar,
    EventKey: Key,
    Buf: [*]u8,
    BufTextLen: i32,
    BufSize: i32,
    BufDirty: bool,
    CursorPos: i32,
    SelectionStart: i32,
    SelectionEnd: i32,

    pub const DeleteChars = raw.ImGuiInputTextCallbackData_DeleteChars;
    pub const HasSelection = raw.ImGuiInputTextCallbackData_HasSelection;
    pub const init = raw.ImGuiInputTextCallbackData_ImGuiInputTextCallbackData;
    pub const InsertChars = raw.ImGuiInputTextCallbackData_InsertChars;
    pub const deinit = raw.ImGuiInputTextCallbackData_destroy;
};

pub const ListClipper = extern struct {
    DisplayStart: i32,
    DisplayEnd: i32,
    ItemsCount: i32,
    StepNo: i32,
    ItemsHeight: f32,
    StartPosY: f32,

    pub const Begin = raw.ImGuiListClipper_Begin;
    pub const End = raw.ImGuiListClipper_End;
    pub const init = raw.ImGuiListClipper_ImGuiListClipper;
    pub const Step = raw.ImGuiListClipper_Step;
    pub const deinit = raw.ImGuiListClipper_destroy;
};

pub const OnceUponAFrame = extern struct {
    RefFrame: i32,

    pub const init = raw.ImGuiOnceUponAFrame_ImGuiOnceUponAFrame;
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

    pub const Clear = raw.ImGuiPayload_Clear;
    pub const init = raw.ImGuiPayload_ImGuiPayload;
    pub const IsDataType = raw.ImGuiPayload_IsDataType;
    pub const IsDelivery = raw.ImGuiPayload_IsDelivery;
    pub const IsPreview = raw.ImGuiPayload_IsPreview;
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

    pub const BuildSortByKey = raw.ImGuiStorage_BuildSortByKey;
    pub const Clear = raw.ImGuiStorage_Clear;
    pub const GetBool = raw.ImGuiStorage_GetBool;
    pub const GetBoolRef = raw.ImGuiStorage_GetBoolRef;
    pub const GetFloat = raw.ImGuiStorage_GetFloat;
    pub const GetFloatRef = raw.ImGuiStorage_GetFloatRef;
    pub const GetInt = raw.ImGuiStorage_GetInt;
    pub const GetIntRef = raw.ImGuiStorage_GetIntRef;
    pub const GetVoidPtr = raw.ImGuiStorage_GetVoidPtr;
    pub const GetVoidPtrRef = raw.ImGuiStorage_GetVoidPtrRef;
    pub const SetAllInt = raw.ImGuiStorage_SetAllInt;
    pub const SetBool = raw.ImGuiStorage_SetBool;
    pub const SetFloat = raw.ImGuiStorage_SetFloat;
    pub const SetInt = raw.ImGuiStorage_SetInt;
    pub const SetVoidPtr = raw.ImGuiStorage_SetVoidPtr;
};

pub const StoragePair = extern struct {
    key: ID,
    value: extern union { val_i: i32, val_f: f32, val_p: ?*c_void },

    pub const initInt = raw.ImGuiStoragePair_ImGuiStoragePairInt;
    pub const initFloat = raw.ImGuiStoragePair_ImGuiStoragePairFloat;
    pub const initPtr = raw.ImGuiStoragePair_ImGuiStoragePairPtr;
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

    pub const init = raw.ImGuiStyle_ImGuiStyle;
    pub const ScaleAllSizes = raw.ImGuiStyle_ScaleAllSizes;
    pub const deinit = raw.ImGuiStyle_destroy;
};

pub const TextBuffer = extern struct {
    Buf: Vector(u8),

    pub const init = raw.ImGuiTextBuffer_ImGuiTextBuffer;
    pub const append = raw.ImGuiTextBuffer_append;
    pub const appendf = raw.ImGuiTextBuffer_appendf;
    pub const begin = raw.ImGuiTextBuffer_begin;
    pub const c_str = raw.ImGuiTextBuffer_c_str;
    pub const clear = raw.ImGuiTextBuffer_clear;
    pub const deinit = raw.ImGuiTextBuffer_destroy;
    pub const empty = raw.ImGuiTextBuffer_empty;
    pub const end = raw.ImGuiTextBuffer_end;
    pub const reserve = raw.ImGuiTextBuffer_reserve;
    pub const size = raw.ImGuiTextBuffer_size;
};

pub const TextFilter = extern struct {
    InputBuf: [256]u8,
    Filters: Vector(TextRange),
    CountGrep: i32,

    pub const Build = raw.ImGuiTextFilter_Build;
    pub const Clear = raw.ImGuiTextFilter_Clear;
    pub const Draw = raw.ImGuiTextFilter_Draw;
    pub const init = raw.ImGuiTextFilter_ImGuiTextFilter;
    pub const IsActive = raw.ImGuiTextFilter_IsActive;
    pub const PassFilter = raw.ImGuiTextFilter_PassFilter;
    pub const deinit = raw.ImGuiTextFilter_destroy;
};

pub const TextRange = extern struct {
    b: [*]const u8,
    e: [*]const u8,

    pub const init = raw.ImGuiTextRange_ImGuiTextRange;
    pub const initStr = raw.ImGuiTextRange_ImGuiTextRangeStr;
    pub const deinit = raw.ImGuiTextRange_destroy;
    pub const empty = raw.ImGuiTextRange_empty;
    pub const split = raw.ImGuiTextRange_split;
};

pub const Vec2 = extern struct {
    x: f32,
    y: f32,

    pub const init = raw.ImVec2_ImVec2;
    pub const initFloat = raw.ImVec2_ImVec2Float;
    pub const deinit = raw.ImVec2_destroy;
};

pub const Vec4 = extern struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,

    pub const init = raw.ImVec4_ImVec4;
    pub const initFloat = raw.ImVec4_ImVec4Float;
    pub const deinit = raw.ImVec4_destroy;
};

const FTABLE_ImVector_ImDrawChannel = struct {
    pub const init = raw.ImVector_ImDrawChannel_ImVector_ImDrawChannel;
    pub const initVector = raw.ImVector_ImDrawChannel_ImVector_ImDrawChannelVector;
    pub const _grow_capacity = raw.ImVector_ImDrawChannel__grow_capacity;
    pub const back = raw.ImVector_ImDrawChannel_back;
    pub const back_const = raw.ImVector_ImDrawChannel_back_const;
    pub const begin = raw.ImVector_ImDrawChannel_begin;
    pub const begin_const = raw.ImVector_ImDrawChannel_begin_const;
    pub const capacity = raw.ImVector_ImDrawChannel_capacity;
    pub const clear = raw.ImVector_ImDrawChannel_clear;
    pub const deinit = raw.ImVector_ImDrawChannel_destroy;
    pub const empty = raw.ImVector_ImDrawChannel_empty;
    pub const end = raw.ImVector_ImDrawChannel_end;
    pub const end_const = raw.ImVector_ImDrawChannel_end_const;
    pub const erase = raw.ImVector_ImDrawChannel_erase;
    pub const eraseTPtr = raw.ImVector_ImDrawChannel_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImDrawChannel_erase_unsorted;
    pub const front = raw.ImVector_ImDrawChannel_front;
    pub const front_const = raw.ImVector_ImDrawChannel_front_const;
    pub const index_from_ptr = raw.ImVector_ImDrawChannel_index_from_ptr;
    pub const insert = raw.ImVector_ImDrawChannel_insert;
    pub const pop_back = raw.ImVector_ImDrawChannel_pop_back;
    pub const push_back = raw.ImVector_ImDrawChannel_push_back;
    pub const push_front = raw.ImVector_ImDrawChannel_push_front;
    pub const reserve = raw.ImVector_ImDrawChannel_reserve;
    pub const resize = raw.ImVector_ImDrawChannel_resize;
    pub const resizeT = raw.ImVector_ImDrawChannel_resizeT;
    pub const shrink = raw.ImVector_ImDrawChannel_shrink;
    pub const size = raw.ImVector_ImDrawChannel_size;
    pub const size_in_bytes = raw.ImVector_ImDrawChannel_size_in_bytes;
    pub const swap = raw.ImVector_ImDrawChannel_swap;
};

const FTABLE_ImVector_ImDrawCmd = struct {
    pub const init = raw.ImVector_ImDrawCmd_ImVector_ImDrawCmd;
    pub const initVector = raw.ImVector_ImDrawCmd_ImVector_ImDrawCmdVector;
    pub const _grow_capacity = raw.ImVector_ImDrawCmd__grow_capacity;
    pub const back = raw.ImVector_ImDrawCmd_back;
    pub const back_const = raw.ImVector_ImDrawCmd_back_const;
    pub const begin = raw.ImVector_ImDrawCmd_begin;
    pub const begin_const = raw.ImVector_ImDrawCmd_begin_const;
    pub const capacity = raw.ImVector_ImDrawCmd_capacity;
    pub const clear = raw.ImVector_ImDrawCmd_clear;
    pub const deinit = raw.ImVector_ImDrawCmd_destroy;
    pub const empty = raw.ImVector_ImDrawCmd_empty;
    pub const end = raw.ImVector_ImDrawCmd_end;
    pub const end_const = raw.ImVector_ImDrawCmd_end_const;
    pub const erase = raw.ImVector_ImDrawCmd_erase;
    pub const eraseTPtr = raw.ImVector_ImDrawCmd_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImDrawCmd_erase_unsorted;
    pub const front = raw.ImVector_ImDrawCmd_front;
    pub const front_const = raw.ImVector_ImDrawCmd_front_const;
    pub const index_from_ptr = raw.ImVector_ImDrawCmd_index_from_ptr;
    pub const insert = raw.ImVector_ImDrawCmd_insert;
    pub const pop_back = raw.ImVector_ImDrawCmd_pop_back;
    pub const push_back = raw.ImVector_ImDrawCmd_push_back;
    pub const push_front = raw.ImVector_ImDrawCmd_push_front;
    pub const reserve = raw.ImVector_ImDrawCmd_reserve;
    pub const resize = raw.ImVector_ImDrawCmd_resize;
    pub const resizeT = raw.ImVector_ImDrawCmd_resizeT;
    pub const shrink = raw.ImVector_ImDrawCmd_shrink;
    pub const size = raw.ImVector_ImDrawCmd_size;
    pub const size_in_bytes = raw.ImVector_ImDrawCmd_size_in_bytes;
    pub const swap = raw.ImVector_ImDrawCmd_swap;
};

const FTABLE_ImVector_ImDrawIdx = struct {
    pub const init = raw.ImVector_ImDrawIdx_ImVector_ImDrawIdx;
    pub const initVector = raw.ImVector_ImDrawIdx_ImVector_ImDrawIdxVector;
    pub const _grow_capacity = raw.ImVector_ImDrawIdx__grow_capacity;
    pub const back = raw.ImVector_ImDrawIdx_back;
    pub const back_const = raw.ImVector_ImDrawIdx_back_const;
    pub const begin = raw.ImVector_ImDrawIdx_begin;
    pub const begin_const = raw.ImVector_ImDrawIdx_begin_const;
    pub const capacity = raw.ImVector_ImDrawIdx_capacity;
    pub const clear = raw.ImVector_ImDrawIdx_clear;
    pub const contains = raw.ImVector_ImDrawIdx_contains;
    pub const deinit = raw.ImVector_ImDrawIdx_destroy;
    pub const empty = raw.ImVector_ImDrawIdx_empty;
    pub const end = raw.ImVector_ImDrawIdx_end;
    pub const end_const = raw.ImVector_ImDrawIdx_end_const;
    pub const erase = raw.ImVector_ImDrawIdx_erase;
    pub const eraseTPtr = raw.ImVector_ImDrawIdx_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImDrawIdx_erase_unsorted;
    pub const find = raw.ImVector_ImDrawIdx_find;
    pub const find_const = raw.ImVector_ImDrawIdx_find_const;
    pub const find_erase = raw.ImVector_ImDrawIdx_find_erase;
    pub const find_erase_unsorted = raw.ImVector_ImDrawIdx_find_erase_unsorted;
    pub const front = raw.ImVector_ImDrawIdx_front;
    pub const front_const = raw.ImVector_ImDrawIdx_front_const;
    pub const index_from_ptr = raw.ImVector_ImDrawIdx_index_from_ptr;
    pub const insert = raw.ImVector_ImDrawIdx_insert;
    pub const pop_back = raw.ImVector_ImDrawIdx_pop_back;
    pub const push_back = raw.ImVector_ImDrawIdx_push_back;
    pub const push_front = raw.ImVector_ImDrawIdx_push_front;
    pub const reserve = raw.ImVector_ImDrawIdx_reserve;
    pub const resize = raw.ImVector_ImDrawIdx_resize;
    pub const resizeT = raw.ImVector_ImDrawIdx_resizeT;
    pub const shrink = raw.ImVector_ImDrawIdx_shrink;
    pub const size = raw.ImVector_ImDrawIdx_size;
    pub const size_in_bytes = raw.ImVector_ImDrawIdx_size_in_bytes;
    pub const swap = raw.ImVector_ImDrawIdx_swap;
};

const FTABLE_ImVector_ImDrawVert = struct {
    pub const init = raw.ImVector_ImDrawVert_ImVector_ImDrawVert;
    pub const initVector = raw.ImVector_ImDrawVert_ImVector_ImDrawVertVector;
    pub const _grow_capacity = raw.ImVector_ImDrawVert__grow_capacity;
    pub const back = raw.ImVector_ImDrawVert_back;
    pub const back_const = raw.ImVector_ImDrawVert_back_const;
    pub const begin = raw.ImVector_ImDrawVert_begin;
    pub const begin_const = raw.ImVector_ImDrawVert_begin_const;
    pub const capacity = raw.ImVector_ImDrawVert_capacity;
    pub const clear = raw.ImVector_ImDrawVert_clear;
    pub const deinit = raw.ImVector_ImDrawVert_destroy;
    pub const empty = raw.ImVector_ImDrawVert_empty;
    pub const end = raw.ImVector_ImDrawVert_end;
    pub const end_const = raw.ImVector_ImDrawVert_end_const;
    pub const erase = raw.ImVector_ImDrawVert_erase;
    pub const eraseTPtr = raw.ImVector_ImDrawVert_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImDrawVert_erase_unsorted;
    pub const front = raw.ImVector_ImDrawVert_front;
    pub const front_const = raw.ImVector_ImDrawVert_front_const;
    pub const index_from_ptr = raw.ImVector_ImDrawVert_index_from_ptr;
    pub const insert = raw.ImVector_ImDrawVert_insert;
    pub const pop_back = raw.ImVector_ImDrawVert_pop_back;
    pub const push_back = raw.ImVector_ImDrawVert_push_back;
    pub const push_front = raw.ImVector_ImDrawVert_push_front;
    pub const reserve = raw.ImVector_ImDrawVert_reserve;
    pub const resize = raw.ImVector_ImDrawVert_resize;
    pub const resizeT = raw.ImVector_ImDrawVert_resizeT;
    pub const shrink = raw.ImVector_ImDrawVert_shrink;
    pub const size = raw.ImVector_ImDrawVert_size;
    pub const size_in_bytes = raw.ImVector_ImDrawVert_size_in_bytes;
    pub const swap = raw.ImVector_ImDrawVert_swap;
};

const FTABLE_ImVector_ImFontPtr = struct {
    pub const init = raw.ImVector_ImFontPtr_ImVector_ImFontPtr;
    pub const initVector = raw.ImVector_ImFontPtr_ImVector_ImFontPtrVector;
    pub const _grow_capacity = raw.ImVector_ImFontPtr__grow_capacity;
    pub const back = raw.ImVector_ImFontPtr_back;
    pub const back_const = raw.ImVector_ImFontPtr_back_const;
    pub const begin = raw.ImVector_ImFontPtr_begin;
    pub const begin_const = raw.ImVector_ImFontPtr_begin_const;
    pub const capacity = raw.ImVector_ImFontPtr_capacity;
    pub const clear = raw.ImVector_ImFontPtr_clear;
    pub const contains = raw.ImVector_ImFontPtr_contains;
    pub const deinit = raw.ImVector_ImFontPtr_destroy;
    pub const empty = raw.ImVector_ImFontPtr_empty;
    pub const end = raw.ImVector_ImFontPtr_end;
    pub const end_const = raw.ImVector_ImFontPtr_end_const;
    pub const erase = raw.ImVector_ImFontPtr_erase;
    pub const eraseTPtr = raw.ImVector_ImFontPtr_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImFontPtr_erase_unsorted;
    pub const find = raw.ImVector_ImFontPtr_find;
    pub const find_const = raw.ImVector_ImFontPtr_find_const;
    pub const find_erase = raw.ImVector_ImFontPtr_find_erase;
    pub const find_erase_unsorted = raw.ImVector_ImFontPtr_find_erase_unsorted;
    pub const front = raw.ImVector_ImFontPtr_front;
    pub const front_const = raw.ImVector_ImFontPtr_front_const;
    pub const index_from_ptr = raw.ImVector_ImFontPtr_index_from_ptr;
    pub const insert = raw.ImVector_ImFontPtr_insert;
    pub const pop_back = raw.ImVector_ImFontPtr_pop_back;
    pub const push_back = raw.ImVector_ImFontPtr_push_back;
    pub const push_front = raw.ImVector_ImFontPtr_push_front;
    pub const reserve = raw.ImVector_ImFontPtr_reserve;
    pub const resize = raw.ImVector_ImFontPtr_resize;
    pub const resizeT = raw.ImVector_ImFontPtr_resizeT;
    pub const shrink = raw.ImVector_ImFontPtr_shrink;
    pub const size = raw.ImVector_ImFontPtr_size;
    pub const size_in_bytes = raw.ImVector_ImFontPtr_size_in_bytes;
    pub const swap = raw.ImVector_ImFontPtr_swap;
};

const FTABLE_ImVector_ImFontAtlasCustomRect = struct {
    pub const init = raw.ImVector_ImFontAtlasCustomRect_ImVector_ImFontAtlasCustomRect;
    pub const initVector = raw.ImVector_ImFontAtlasCustomRect_ImVector_ImFontAtlasCustomRectVector;
    pub const _grow_capacity = raw.ImVector_ImFontAtlasCustomRect__grow_capacity;
    pub const back = raw.ImVector_ImFontAtlasCustomRect_back;
    pub const back_const = raw.ImVector_ImFontAtlasCustomRect_back_const;
    pub const begin = raw.ImVector_ImFontAtlasCustomRect_begin;
    pub const begin_const = raw.ImVector_ImFontAtlasCustomRect_begin_const;
    pub const capacity = raw.ImVector_ImFontAtlasCustomRect_capacity;
    pub const clear = raw.ImVector_ImFontAtlasCustomRect_clear;
    pub const deinit = raw.ImVector_ImFontAtlasCustomRect_destroy;
    pub const empty = raw.ImVector_ImFontAtlasCustomRect_empty;
    pub const end = raw.ImVector_ImFontAtlasCustomRect_end;
    pub const end_const = raw.ImVector_ImFontAtlasCustomRect_end_const;
    pub const erase = raw.ImVector_ImFontAtlasCustomRect_erase;
    pub const eraseTPtr = raw.ImVector_ImFontAtlasCustomRect_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImFontAtlasCustomRect_erase_unsorted;
    pub const front = raw.ImVector_ImFontAtlasCustomRect_front;
    pub const front_const = raw.ImVector_ImFontAtlasCustomRect_front_const;
    pub const index_from_ptr = raw.ImVector_ImFontAtlasCustomRect_index_from_ptr;
    pub const insert = raw.ImVector_ImFontAtlasCustomRect_insert;
    pub const pop_back = raw.ImVector_ImFontAtlasCustomRect_pop_back;
    pub const push_back = raw.ImVector_ImFontAtlasCustomRect_push_back;
    pub const push_front = raw.ImVector_ImFontAtlasCustomRect_push_front;
    pub const reserve = raw.ImVector_ImFontAtlasCustomRect_reserve;
    pub const resize = raw.ImVector_ImFontAtlasCustomRect_resize;
    pub const resizeT = raw.ImVector_ImFontAtlasCustomRect_resizeT;
    pub const shrink = raw.ImVector_ImFontAtlasCustomRect_shrink;
    pub const size = raw.ImVector_ImFontAtlasCustomRect_size;
    pub const size_in_bytes = raw.ImVector_ImFontAtlasCustomRect_size_in_bytes;
    pub const swap = raw.ImVector_ImFontAtlasCustomRect_swap;
};

const FTABLE_ImVector_ImFontConfig = struct {
    pub const init = raw.ImVector_ImFontConfig_ImVector_ImFontConfig;
    pub const initVector = raw.ImVector_ImFontConfig_ImVector_ImFontConfigVector;
    pub const _grow_capacity = raw.ImVector_ImFontConfig__grow_capacity;
    pub const back = raw.ImVector_ImFontConfig_back;
    pub const back_const = raw.ImVector_ImFontConfig_back_const;
    pub const begin = raw.ImVector_ImFontConfig_begin;
    pub const begin_const = raw.ImVector_ImFontConfig_begin_const;
    pub const capacity = raw.ImVector_ImFontConfig_capacity;
    pub const clear = raw.ImVector_ImFontConfig_clear;
    pub const deinit = raw.ImVector_ImFontConfig_destroy;
    pub const empty = raw.ImVector_ImFontConfig_empty;
    pub const end = raw.ImVector_ImFontConfig_end;
    pub const end_const = raw.ImVector_ImFontConfig_end_const;
    pub const erase = raw.ImVector_ImFontConfig_erase;
    pub const eraseTPtr = raw.ImVector_ImFontConfig_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImFontConfig_erase_unsorted;
    pub const front = raw.ImVector_ImFontConfig_front;
    pub const front_const = raw.ImVector_ImFontConfig_front_const;
    pub const index_from_ptr = raw.ImVector_ImFontConfig_index_from_ptr;
    pub const insert = raw.ImVector_ImFontConfig_insert;
    pub const pop_back = raw.ImVector_ImFontConfig_pop_back;
    pub const push_back = raw.ImVector_ImFontConfig_push_back;
    pub const push_front = raw.ImVector_ImFontConfig_push_front;
    pub const reserve = raw.ImVector_ImFontConfig_reserve;
    pub const resize = raw.ImVector_ImFontConfig_resize;
    pub const resizeT = raw.ImVector_ImFontConfig_resizeT;
    pub const shrink = raw.ImVector_ImFontConfig_shrink;
    pub const size = raw.ImVector_ImFontConfig_size;
    pub const size_in_bytes = raw.ImVector_ImFontConfig_size_in_bytes;
    pub const swap = raw.ImVector_ImFontConfig_swap;
};

const FTABLE_ImVector_ImFontGlyph = struct {
    pub const init = raw.ImVector_ImFontGlyph_ImVector_ImFontGlyph;
    pub const initVector = raw.ImVector_ImFontGlyph_ImVector_ImFontGlyphVector;
    pub const _grow_capacity = raw.ImVector_ImFontGlyph__grow_capacity;
    pub const back = raw.ImVector_ImFontGlyph_back;
    pub const back_const = raw.ImVector_ImFontGlyph_back_const;
    pub const begin = raw.ImVector_ImFontGlyph_begin;
    pub const begin_const = raw.ImVector_ImFontGlyph_begin_const;
    pub const capacity = raw.ImVector_ImFontGlyph_capacity;
    pub const clear = raw.ImVector_ImFontGlyph_clear;
    pub const deinit = raw.ImVector_ImFontGlyph_destroy;
    pub const empty = raw.ImVector_ImFontGlyph_empty;
    pub const end = raw.ImVector_ImFontGlyph_end;
    pub const end_const = raw.ImVector_ImFontGlyph_end_const;
    pub const erase = raw.ImVector_ImFontGlyph_erase;
    pub const eraseTPtr = raw.ImVector_ImFontGlyph_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImFontGlyph_erase_unsorted;
    pub const front = raw.ImVector_ImFontGlyph_front;
    pub const front_const = raw.ImVector_ImFontGlyph_front_const;
    pub const index_from_ptr = raw.ImVector_ImFontGlyph_index_from_ptr;
    pub const insert = raw.ImVector_ImFontGlyph_insert;
    pub const pop_back = raw.ImVector_ImFontGlyph_pop_back;
    pub const push_back = raw.ImVector_ImFontGlyph_push_back;
    pub const push_front = raw.ImVector_ImFontGlyph_push_front;
    pub const reserve = raw.ImVector_ImFontGlyph_reserve;
    pub const resize = raw.ImVector_ImFontGlyph_resize;
    pub const resizeT = raw.ImVector_ImFontGlyph_resizeT;
    pub const shrink = raw.ImVector_ImFontGlyph_shrink;
    pub const size = raw.ImVector_ImFontGlyph_size;
    pub const size_in_bytes = raw.ImVector_ImFontGlyph_size_in_bytes;
    pub const swap = raw.ImVector_ImFontGlyph_swap;
};

const FTABLE_ImVector_ImGuiStoragePair = struct {
    pub const init = raw.ImVector_ImGuiStoragePair_ImVector_ImGuiStoragePair;
    pub const initVector = raw.ImVector_ImGuiStoragePair_ImVector_ImGuiStoragePairVector;
    pub const _grow_capacity = raw.ImVector_ImGuiStoragePair__grow_capacity;
    pub const back = raw.ImVector_ImGuiStoragePair_back;
    pub const back_const = raw.ImVector_ImGuiStoragePair_back_const;
    pub const begin = raw.ImVector_ImGuiStoragePair_begin;
    pub const begin_const = raw.ImVector_ImGuiStoragePair_begin_const;
    pub const capacity = raw.ImVector_ImGuiStoragePair_capacity;
    pub const clear = raw.ImVector_ImGuiStoragePair_clear;
    pub const deinit = raw.ImVector_ImGuiStoragePair_destroy;
    pub const empty = raw.ImVector_ImGuiStoragePair_empty;
    pub const end = raw.ImVector_ImGuiStoragePair_end;
    pub const end_const = raw.ImVector_ImGuiStoragePair_end_const;
    pub const erase = raw.ImVector_ImGuiStoragePair_erase;
    pub const eraseTPtr = raw.ImVector_ImGuiStoragePair_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImGuiStoragePair_erase_unsorted;
    pub const front = raw.ImVector_ImGuiStoragePair_front;
    pub const front_const = raw.ImVector_ImGuiStoragePair_front_const;
    pub const index_from_ptr = raw.ImVector_ImGuiStoragePair_index_from_ptr;
    pub const insert = raw.ImVector_ImGuiStoragePair_insert;
    pub const pop_back = raw.ImVector_ImGuiStoragePair_pop_back;
    pub const push_back = raw.ImVector_ImGuiStoragePair_push_back;
    pub const push_front = raw.ImVector_ImGuiStoragePair_push_front;
    pub const reserve = raw.ImVector_ImGuiStoragePair_reserve;
    pub const resize = raw.ImVector_ImGuiStoragePair_resize;
    pub const resizeT = raw.ImVector_ImGuiStoragePair_resizeT;
    pub const shrink = raw.ImVector_ImGuiStoragePair_shrink;
    pub const size = raw.ImVector_ImGuiStoragePair_size;
    pub const size_in_bytes = raw.ImVector_ImGuiStoragePair_size_in_bytes;
    pub const swap = raw.ImVector_ImGuiStoragePair_swap;
};

const FTABLE_ImVector_ImGuiTextRange = struct {
    pub const init = raw.ImVector_ImGuiTextRange_ImVector_ImGuiTextRange;
    pub const initVector = raw.ImVector_ImGuiTextRange_ImVector_ImGuiTextRangeVector;
    pub const _grow_capacity = raw.ImVector_ImGuiTextRange__grow_capacity;
    pub const back = raw.ImVector_ImGuiTextRange_back;
    pub const back_const = raw.ImVector_ImGuiTextRange_back_const;
    pub const begin = raw.ImVector_ImGuiTextRange_begin;
    pub const begin_const = raw.ImVector_ImGuiTextRange_begin_const;
    pub const capacity = raw.ImVector_ImGuiTextRange_capacity;
    pub const clear = raw.ImVector_ImGuiTextRange_clear;
    pub const deinit = raw.ImVector_ImGuiTextRange_destroy;
    pub const empty = raw.ImVector_ImGuiTextRange_empty;
    pub const end = raw.ImVector_ImGuiTextRange_end;
    pub const end_const = raw.ImVector_ImGuiTextRange_end_const;
    pub const erase = raw.ImVector_ImGuiTextRange_erase;
    pub const eraseTPtr = raw.ImVector_ImGuiTextRange_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImGuiTextRange_erase_unsorted;
    pub const front = raw.ImVector_ImGuiTextRange_front;
    pub const front_const = raw.ImVector_ImGuiTextRange_front_const;
    pub const index_from_ptr = raw.ImVector_ImGuiTextRange_index_from_ptr;
    pub const insert = raw.ImVector_ImGuiTextRange_insert;
    pub const pop_back = raw.ImVector_ImGuiTextRange_pop_back;
    pub const push_back = raw.ImVector_ImGuiTextRange_push_back;
    pub const push_front = raw.ImVector_ImGuiTextRange_push_front;
    pub const reserve = raw.ImVector_ImGuiTextRange_reserve;
    pub const resize = raw.ImVector_ImGuiTextRange_resize;
    pub const resizeT = raw.ImVector_ImGuiTextRange_resizeT;
    pub const shrink = raw.ImVector_ImGuiTextRange_shrink;
    pub const size = raw.ImVector_ImGuiTextRange_size;
    pub const size_in_bytes = raw.ImVector_ImGuiTextRange_size_in_bytes;
    pub const swap = raw.ImVector_ImGuiTextRange_swap;
};

const FTABLE_ImVector_ImTextureID = struct {
    pub const init = raw.ImVector_ImTextureID_ImVector_ImTextureID;
    pub const initVector = raw.ImVector_ImTextureID_ImVector_ImTextureIDVector;
    pub const _grow_capacity = raw.ImVector_ImTextureID__grow_capacity;
    pub const back = raw.ImVector_ImTextureID_back;
    pub const back_const = raw.ImVector_ImTextureID_back_const;
    pub const begin = raw.ImVector_ImTextureID_begin;
    pub const begin_const = raw.ImVector_ImTextureID_begin_const;
    pub const capacity = raw.ImVector_ImTextureID_capacity;
    pub const clear = raw.ImVector_ImTextureID_clear;
    pub const contains = raw.ImVector_ImTextureID_contains;
    pub const deinit = raw.ImVector_ImTextureID_destroy;
    pub const empty = raw.ImVector_ImTextureID_empty;
    pub const end = raw.ImVector_ImTextureID_end;
    pub const end_const = raw.ImVector_ImTextureID_end_const;
    pub const erase = raw.ImVector_ImTextureID_erase;
    pub const eraseTPtr = raw.ImVector_ImTextureID_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImTextureID_erase_unsorted;
    pub const find = raw.ImVector_ImTextureID_find;
    pub const find_const = raw.ImVector_ImTextureID_find_const;
    pub const find_erase = raw.ImVector_ImTextureID_find_erase;
    pub const find_erase_unsorted = raw.ImVector_ImTextureID_find_erase_unsorted;
    pub const front = raw.ImVector_ImTextureID_front;
    pub const front_const = raw.ImVector_ImTextureID_front_const;
    pub const index_from_ptr = raw.ImVector_ImTextureID_index_from_ptr;
    pub const insert = raw.ImVector_ImTextureID_insert;
    pub const pop_back = raw.ImVector_ImTextureID_pop_back;
    pub const push_back = raw.ImVector_ImTextureID_push_back;
    pub const push_front = raw.ImVector_ImTextureID_push_front;
    pub const reserve = raw.ImVector_ImTextureID_reserve;
    pub const resize = raw.ImVector_ImTextureID_resize;
    pub const resizeT = raw.ImVector_ImTextureID_resizeT;
    pub const shrink = raw.ImVector_ImTextureID_shrink;
    pub const size = raw.ImVector_ImTextureID_size;
    pub const size_in_bytes = raw.ImVector_ImTextureID_size_in_bytes;
    pub const swap = raw.ImVector_ImTextureID_swap;
};

const FTABLE_ImVector_ImU32 = struct {
    pub const init = raw.ImVector_ImU32_ImVector_ImU32;
    pub const initVector = raw.ImVector_ImU32_ImVector_ImU32Vector;
    pub const _grow_capacity = raw.ImVector_ImU32__grow_capacity;
    pub const back = raw.ImVector_ImU32_back;
    pub const back_const = raw.ImVector_ImU32_back_const;
    pub const begin = raw.ImVector_ImU32_begin;
    pub const begin_const = raw.ImVector_ImU32_begin_const;
    pub const capacity = raw.ImVector_ImU32_capacity;
    pub const clear = raw.ImVector_ImU32_clear;
    pub const contains = raw.ImVector_ImU32_contains;
    pub const deinit = raw.ImVector_ImU32_destroy;
    pub const empty = raw.ImVector_ImU32_empty;
    pub const end = raw.ImVector_ImU32_end;
    pub const end_const = raw.ImVector_ImU32_end_const;
    pub const erase = raw.ImVector_ImU32_erase;
    pub const eraseTPtr = raw.ImVector_ImU32_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImU32_erase_unsorted;
    pub const find = raw.ImVector_ImU32_find;
    pub const find_const = raw.ImVector_ImU32_find_const;
    pub const find_erase = raw.ImVector_ImU32_find_erase;
    pub const find_erase_unsorted = raw.ImVector_ImU32_find_erase_unsorted;
    pub const front = raw.ImVector_ImU32_front;
    pub const front_const = raw.ImVector_ImU32_front_const;
    pub const index_from_ptr = raw.ImVector_ImU32_index_from_ptr;
    pub const insert = raw.ImVector_ImU32_insert;
    pub const pop_back = raw.ImVector_ImU32_pop_back;
    pub const push_back = raw.ImVector_ImU32_push_back;
    pub const push_front = raw.ImVector_ImU32_push_front;
    pub const reserve = raw.ImVector_ImU32_reserve;
    pub const resize = raw.ImVector_ImU32_resize;
    pub const resizeT = raw.ImVector_ImU32_resizeT;
    pub const shrink = raw.ImVector_ImU32_shrink;
    pub const size = raw.ImVector_ImU32_size;
    pub const size_in_bytes = raw.ImVector_ImU32_size_in_bytes;
    pub const swap = raw.ImVector_ImU32_swap;
};

const FTABLE_ImVector_ImVec2 = struct {
    pub const init = raw.ImVector_ImVec2_ImVector_ImVec2;
    pub const initVector = raw.ImVector_ImVec2_ImVector_ImVec2Vector;
    pub const _grow_capacity = raw.ImVector_ImVec2__grow_capacity;
    pub const back = raw.ImVector_ImVec2_back;
    pub const back_const = raw.ImVector_ImVec2_back_const;
    pub const begin = raw.ImVector_ImVec2_begin;
    pub const begin_const = raw.ImVector_ImVec2_begin_const;
    pub const capacity = raw.ImVector_ImVec2_capacity;
    pub const clear = raw.ImVector_ImVec2_clear;
    pub const deinit = raw.ImVector_ImVec2_destroy;
    pub const empty = raw.ImVector_ImVec2_empty;
    pub const end = raw.ImVector_ImVec2_end;
    pub const end_const = raw.ImVector_ImVec2_end_const;
    pub const erase = raw.ImVector_ImVec2_erase;
    pub const eraseTPtr = raw.ImVector_ImVec2_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImVec2_erase_unsorted;
    pub const front = raw.ImVector_ImVec2_front;
    pub const front_const = raw.ImVector_ImVec2_front_const;
    pub const index_from_ptr = raw.ImVector_ImVec2_index_from_ptr;
    pub const insert = raw.ImVector_ImVec2_insert;
    pub const pop_back = raw.ImVector_ImVec2_pop_back;
    pub const push_back = raw.ImVector_ImVec2_push_back;
    pub const push_front = raw.ImVector_ImVec2_push_front;
    pub const reserve = raw.ImVector_ImVec2_reserve;
    pub const resize = raw.ImVector_ImVec2_resize;
    pub const resizeT = raw.ImVector_ImVec2_resizeT;
    pub const shrink = raw.ImVector_ImVec2_shrink;
    pub const size = raw.ImVector_ImVec2_size;
    pub const size_in_bytes = raw.ImVector_ImVec2_size_in_bytes;
    pub const swap = raw.ImVector_ImVec2_swap;
};

const FTABLE_ImVector_ImVec4 = struct {
    pub const init = raw.ImVector_ImVec4_ImVector_ImVec4;
    pub const initVector = raw.ImVector_ImVec4_ImVector_ImVec4Vector;
    pub const _grow_capacity = raw.ImVector_ImVec4__grow_capacity;
    pub const back = raw.ImVector_ImVec4_back;
    pub const back_const = raw.ImVector_ImVec4_back_const;
    pub const begin = raw.ImVector_ImVec4_begin;
    pub const begin_const = raw.ImVector_ImVec4_begin_const;
    pub const capacity = raw.ImVector_ImVec4_capacity;
    pub const clear = raw.ImVector_ImVec4_clear;
    pub const deinit = raw.ImVector_ImVec4_destroy;
    pub const empty = raw.ImVector_ImVec4_empty;
    pub const end = raw.ImVector_ImVec4_end;
    pub const end_const = raw.ImVector_ImVec4_end_const;
    pub const erase = raw.ImVector_ImVec4_erase;
    pub const eraseTPtr = raw.ImVector_ImVec4_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImVec4_erase_unsorted;
    pub const front = raw.ImVector_ImVec4_front;
    pub const front_const = raw.ImVector_ImVec4_front_const;
    pub const index_from_ptr = raw.ImVector_ImVec4_index_from_ptr;
    pub const insert = raw.ImVector_ImVec4_insert;
    pub const pop_back = raw.ImVector_ImVec4_pop_back;
    pub const push_back = raw.ImVector_ImVec4_push_back;
    pub const push_front = raw.ImVector_ImVec4_push_front;
    pub const reserve = raw.ImVector_ImVec4_reserve;
    pub const resize = raw.ImVector_ImVec4_resize;
    pub const resizeT = raw.ImVector_ImVec4_resizeT;
    pub const shrink = raw.ImVector_ImVec4_shrink;
    pub const size = raw.ImVector_ImVec4_size;
    pub const size_in_bytes = raw.ImVector_ImVec4_size_in_bytes;
    pub const swap = raw.ImVector_ImVec4_swap;
};

const FTABLE_ImVector_ImWchar = struct {
    pub const init = raw.ImVector_ImWchar_ImVector_ImWchar;
    pub const initVector = raw.ImVector_ImWchar_ImVector_ImWcharVector;
    pub const _grow_capacity = raw.ImVector_ImWchar__grow_capacity;
    pub const back = raw.ImVector_ImWchar_back;
    pub const back_const = raw.ImVector_ImWchar_back_const;
    pub const begin = raw.ImVector_ImWchar_begin;
    pub const begin_const = raw.ImVector_ImWchar_begin_const;
    pub const capacity = raw.ImVector_ImWchar_capacity;
    pub const clear = raw.ImVector_ImWchar_clear;
    pub const contains = raw.ImVector_ImWchar_contains;
    pub const deinit = raw.ImVector_ImWchar_destroy;
    pub const empty = raw.ImVector_ImWchar_empty;
    pub const end = raw.ImVector_ImWchar_end;
    pub const end_const = raw.ImVector_ImWchar_end_const;
    pub const erase = raw.ImVector_ImWchar_erase;
    pub const eraseTPtr = raw.ImVector_ImWchar_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_ImWchar_erase_unsorted;
    pub const find = raw.ImVector_ImWchar_find;
    pub const find_const = raw.ImVector_ImWchar_find_const;
    pub const find_erase = raw.ImVector_ImWchar_find_erase;
    pub const find_erase_unsorted = raw.ImVector_ImWchar_find_erase_unsorted;
    pub const front = raw.ImVector_ImWchar_front;
    pub const front_const = raw.ImVector_ImWchar_front_const;
    pub const index_from_ptr = raw.ImVector_ImWchar_index_from_ptr;
    pub const insert = raw.ImVector_ImWchar_insert;
    pub const pop_back = raw.ImVector_ImWchar_pop_back;
    pub const push_back = raw.ImVector_ImWchar_push_back;
    pub const push_front = raw.ImVector_ImWchar_push_front;
    pub const reserve = raw.ImVector_ImWchar_reserve;
    pub const resize = raw.ImVector_ImWchar_resize;
    pub const resizeT = raw.ImVector_ImWchar_resizeT;
    pub const shrink = raw.ImVector_ImWchar_shrink;
    pub const size = raw.ImVector_ImWchar_size;
    pub const size_in_bytes = raw.ImVector_ImWchar_size_in_bytes;
    pub const swap = raw.ImVector_ImWchar_swap;
};

const FTABLE_ImVector_char = struct {
    pub const init = raw.ImVector_char_ImVector_char;
    pub const initVector = raw.ImVector_char_ImVector_charVector;
    pub const _grow_capacity = raw.ImVector_char__grow_capacity;
    pub const back = raw.ImVector_char_back;
    pub const back_const = raw.ImVector_char_back_const;
    pub const begin = raw.ImVector_char_begin;
    pub const begin_const = raw.ImVector_char_begin_const;
    pub const capacity = raw.ImVector_char_capacity;
    pub const clear = raw.ImVector_char_clear;
    pub const contains = raw.ImVector_char_contains;
    pub const deinit = raw.ImVector_char_destroy;
    pub const empty = raw.ImVector_char_empty;
    pub const end = raw.ImVector_char_end;
    pub const end_const = raw.ImVector_char_end_const;
    pub const erase = raw.ImVector_char_erase;
    pub const eraseTPtr = raw.ImVector_char_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_char_erase_unsorted;
    pub const find = raw.ImVector_char_find;
    pub const find_const = raw.ImVector_char_find_const;
    pub const find_erase = raw.ImVector_char_find_erase;
    pub const find_erase_unsorted = raw.ImVector_char_find_erase_unsorted;
    pub const front = raw.ImVector_char_front;
    pub const front_const = raw.ImVector_char_front_const;
    pub const index_from_ptr = raw.ImVector_char_index_from_ptr;
    pub const insert = raw.ImVector_char_insert;
    pub const pop_back = raw.ImVector_char_pop_back;
    pub const push_back = raw.ImVector_char_push_back;
    pub const push_front = raw.ImVector_char_push_front;
    pub const reserve = raw.ImVector_char_reserve;
    pub const resize = raw.ImVector_char_resize;
    pub const resizeT = raw.ImVector_char_resizeT;
    pub const shrink = raw.ImVector_char_shrink;
    pub const size = raw.ImVector_char_size;
    pub const size_in_bytes = raw.ImVector_char_size_in_bytes;
    pub const swap = raw.ImVector_char_swap;
};

const FTABLE_ImVector_float = struct {
    pub const init = raw.ImVector_float_ImVector_float;
    pub const initVector = raw.ImVector_float_ImVector_floatVector;
    pub const _grow_capacity = raw.ImVector_float__grow_capacity;
    pub const back = raw.ImVector_float_back;
    pub const back_const = raw.ImVector_float_back_const;
    pub const begin = raw.ImVector_float_begin;
    pub const begin_const = raw.ImVector_float_begin_const;
    pub const capacity = raw.ImVector_float_capacity;
    pub const clear = raw.ImVector_float_clear;
    pub const contains = raw.ImVector_float_contains;
    pub const deinit = raw.ImVector_float_destroy;
    pub const empty = raw.ImVector_float_empty;
    pub const end = raw.ImVector_float_end;
    pub const end_const = raw.ImVector_float_end_const;
    pub const erase = raw.ImVector_float_erase;
    pub const eraseTPtr = raw.ImVector_float_eraseTPtr;
    pub const erase_unsorted = raw.ImVector_float_erase_unsorted;
    pub const find = raw.ImVector_float_find;
    pub const find_const = raw.ImVector_float_find_const;
    pub const find_erase = raw.ImVector_float_find_erase;
    pub const find_erase_unsorted = raw.ImVector_float_find_erase_unsorted;
    pub const front = raw.ImVector_float_front;
    pub const front_const = raw.ImVector_float_front_const;
    pub const index_from_ptr = raw.ImVector_float_index_from_ptr;
    pub const insert = raw.ImVector_float_insert;
    pub const pop_back = raw.ImVector_float_pop_back;
    pub const push_back = raw.ImVector_float_push_back;
    pub const push_front = raw.ImVector_float_push_front;
    pub const reserve = raw.ImVector_float_reserve;
    pub const resize = raw.ImVector_float_resize;
    pub const resizeT = raw.ImVector_float_resizeT;
    pub const shrink = raw.ImVector_float_shrink;
    pub const size = raw.ImVector_float_size;
    pub const size_in_bytes = raw.ImVector_float_size_in_bytes;
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

        const FTABLE = getFTABLE_ImVector(T);
        pub const init = if (@hasDecl(FTABLE, "init")) FTABLE.init else @compileError("Invalid template instantiation");
        pub const initVector = if (@hasDecl(FTABLE, "initVector")) FTABLE.initVector else @compileError("Invalid template instantiation");
        pub const _grow_capacity = if (@hasDecl(FTABLE, "_grow_capacity")) FTABLE._grow_capacity else @compileError("Invalid template instantiation");
        pub const back = if (@hasDecl(FTABLE, "back")) FTABLE.back else @compileError("Invalid template instantiation");
        pub const back_const = if (@hasDecl(FTABLE, "back_const")) FTABLE.back_const else @compileError("Invalid template instantiation");
        pub const begin = if (@hasDecl(FTABLE, "begin")) FTABLE.begin else @compileError("Invalid template instantiation");
        pub const begin_const = if (@hasDecl(FTABLE, "begin_const")) FTABLE.begin_const else @compileError("Invalid template instantiation");
        pub const capacity = if (@hasDecl(FTABLE, "capacity")) FTABLE.capacity else @compileError("Invalid template instantiation");
        pub const clear = if (@hasDecl(FTABLE, "clear")) FTABLE.clear else @compileError("Invalid template instantiation");
        pub const contains = if (@hasDecl(FTABLE, "contains")) FTABLE.contains else @compileError("Invalid template instantiation");
        pub const deinit = if (@hasDecl(FTABLE, "deinit")) FTABLE.deinit else @compileError("Invalid template instantiation");
        pub const empty = if (@hasDecl(FTABLE, "empty")) FTABLE.empty else @compileError("Invalid template instantiation");
        pub const end = if (@hasDecl(FTABLE, "end")) FTABLE.end else @compileError("Invalid template instantiation");
        pub const end_const = if (@hasDecl(FTABLE, "end_const")) FTABLE.end_const else @compileError("Invalid template instantiation");
        pub const erase = if (@hasDecl(FTABLE, "erase")) FTABLE.erase else @compileError("Invalid template instantiation");
        pub const eraseTPtr = if (@hasDecl(FTABLE, "eraseTPtr")) FTABLE.eraseTPtr else @compileError("Invalid template instantiation");
        pub const erase_unsorted = if (@hasDecl(FTABLE, "erase_unsorted")) FTABLE.erase_unsorted else @compileError("Invalid template instantiation");
        pub const find = if (@hasDecl(FTABLE, "find")) FTABLE.find else @compileError("Invalid template instantiation");
        pub const find_const = if (@hasDecl(FTABLE, "find_const")) FTABLE.find_const else @compileError("Invalid template instantiation");
        pub const find_erase = if (@hasDecl(FTABLE, "find_erase")) FTABLE.find_erase else @compileError("Invalid template instantiation");
        pub const find_erase_unsorted = if (@hasDecl(FTABLE, "find_erase_unsorted")) FTABLE.find_erase_unsorted else @compileError("Invalid template instantiation");
        pub const front = if (@hasDecl(FTABLE, "front")) FTABLE.front else @compileError("Invalid template instantiation");
        pub const front_const = if (@hasDecl(FTABLE, "front_const")) FTABLE.front_const else @compileError("Invalid template instantiation");
        pub const index_from_ptr = if (@hasDecl(FTABLE, "index_from_ptr")) FTABLE.index_from_ptr else @compileError("Invalid template instantiation");
        pub const insert = if (@hasDecl(FTABLE, "insert")) FTABLE.insert else @compileError("Invalid template instantiation");
        pub const pop_back = if (@hasDecl(FTABLE, "pop_back")) FTABLE.pop_back else @compileError("Invalid template instantiation");
        pub const push_back = if (@hasDecl(FTABLE, "push_back")) FTABLE.push_back else @compileError("Invalid template instantiation");
        pub const push_front = if (@hasDecl(FTABLE, "push_front")) FTABLE.push_front else @compileError("Invalid template instantiation");
        pub const reserve = if (@hasDecl(FTABLE, "reserve")) FTABLE.reserve else @compileError("Invalid template instantiation");
        pub const resize = if (@hasDecl(FTABLE, "resize")) FTABLE.resize else @compileError("Invalid template instantiation");
        pub const resizeT = if (@hasDecl(FTABLE, "resizeT")) FTABLE.resizeT else @compileError("Invalid template instantiation");
        pub const shrink = if (@hasDecl(FTABLE, "shrink")) FTABLE.shrink else @compileError("Invalid template instantiation");
        pub const size = if (@hasDecl(FTABLE, "size")) FTABLE.size else @compileError("Invalid template instantiation");
        pub const size_in_bytes = if (@hasDecl(FTABLE, "size_in_bytes")) FTABLE.size_in_bytes else @compileError("Invalid template instantiation");
        pub const swap = if (@hasDecl(FTABLE, "swap")) FTABLE.swap else @compileError("Invalid template instantiation");
    };
}

pub const AcceptDragDropPayload = raw.igAcceptDragDropPayload;
pub const AlignTextToFramePadding = raw.igAlignTextToFramePadding;
pub const ArrowButton = raw.igArrowButton;
pub const Begin = raw.igBegin;
pub const BeginChildStr = raw.igBeginChildStr;
pub const BeginChildID = raw.igBeginChildID;
pub const BeginChildFrame = raw.igBeginChildFrame;
pub const BeginCombo = raw.igBeginCombo;
pub const BeginDragDropSource = raw.igBeginDragDropSource;
pub const BeginDragDropTarget = raw.igBeginDragDropTarget;
pub const BeginGroup = raw.igBeginGroup;
pub const BeginMainMenuBar = raw.igBeginMainMenuBar;
pub const BeginMenu = raw.igBeginMenu;
pub const BeginMenuBar = raw.igBeginMenuBar;
pub const BeginPopup = raw.igBeginPopup;
pub const BeginPopupContextItem = raw.igBeginPopupContextItem;
pub const BeginPopupContextVoid = raw.igBeginPopupContextVoid;
pub const BeginPopupContextWindow = raw.igBeginPopupContextWindow;
pub const BeginPopupModal = raw.igBeginPopupModal;
pub const BeginTabBar = raw.igBeginTabBar;
pub const BeginTabItem = raw.igBeginTabItem;
pub const BeginTooltip = raw.igBeginTooltip;
pub const Bullet = raw.igBullet;
pub const BulletText = raw.igBulletText;
pub const Button = raw.igButton;
pub const CalcItemWidth = raw.igCalcItemWidth;
pub const CalcListClipping = raw.igCalcListClipping;
pub const CalcTextSize = raw.igCalcTextSize;
pub const CaptureKeyboardFromApp = raw.igCaptureKeyboardFromApp;
pub const CaptureMouseFromApp = raw.igCaptureMouseFromApp;
pub const Checkbox = raw.igCheckbox;
pub const CheckboxFlags = raw.igCheckboxFlags;
pub const CloseCurrentPopup = raw.igCloseCurrentPopup;
pub const CollapsingHeader = raw.igCollapsingHeader;
pub const CollapsingHeaderBoolPtr = raw.igCollapsingHeaderBoolPtr;
pub const ColorButton = raw.igColorButton;
pub const ColorConvertFloat4ToU32 = raw.igColorConvertFloat4ToU32;
pub const ColorConvertHSVtoRGB = raw.igColorConvertHSVtoRGB;
pub const ColorConvertRGBtoHSV = raw.igColorConvertRGBtoHSV;
pub const ColorConvertU32ToFloat4 = raw.igColorConvertU32ToFloat4;
pub const ColorEdit3 = raw.igColorEdit3;
pub const ColorEdit4 = raw.igColorEdit4;
pub const ColorPicker3 = raw.igColorPicker3;
pub const ColorPicker4 = raw.igColorPicker4;
pub const Columns = raw.igColumns;
pub const Combo = raw.igCombo;
pub const ComboStr = raw.igComboStr;
pub const ComboFnPtr = raw.igComboFnPtr;
pub const CreateContext = raw.igCreateContext;
pub const DebugCheckVersionAndDataLayout = raw.igDebugCheckVersionAndDataLayout;
pub const DestroyContext = raw.igDestroyContext;
pub const DragFloat = raw.igDragFloat;
pub const DragFloat2 = raw.igDragFloat2;
pub const DragFloat3 = raw.igDragFloat3;
pub const DragFloat4 = raw.igDragFloat4;
pub const DragFloatRange2 = raw.igDragFloatRange2;
pub const DragInt = raw.igDragInt;
pub const DragInt2 = raw.igDragInt2;
pub const DragInt3 = raw.igDragInt3;
pub const DragInt4 = raw.igDragInt4;
pub const DragIntRange2 = raw.igDragIntRange2;
pub const DragScalar = raw.igDragScalar;
pub const DragScalarN = raw.igDragScalarN;
pub const Dummy = raw.igDummy;
pub const End = raw.igEnd;
pub const EndChild = raw.igEndChild;
pub const EndChildFrame = raw.igEndChildFrame;
pub const EndCombo = raw.igEndCombo;
pub const EndDragDropSource = raw.igEndDragDropSource;
pub const EndDragDropTarget = raw.igEndDragDropTarget;
pub const EndFrame = raw.igEndFrame;
pub const EndGroup = raw.igEndGroup;
pub const EndMainMenuBar = raw.igEndMainMenuBar;
pub const EndMenu = raw.igEndMenu;
pub const EndMenuBar = raw.igEndMenuBar;
pub const EndPopup = raw.igEndPopup;
pub const EndTabBar = raw.igEndTabBar;
pub const EndTabItem = raw.igEndTabItem;
pub const EndTooltip = raw.igEndTooltip;
pub const GetBackgroundDrawList = raw.igGetBackgroundDrawList;
pub const GetClipboardText = raw.igGetClipboardText;
pub const GetColorU32 = raw.igGetColorU32;
pub const GetColorU32Vec4 = raw.igGetColorU32Vec4;
pub const GetColorU32U32 = raw.igGetColorU32U32;
pub const GetColumnIndex = raw.igGetColumnIndex;
pub const GetColumnOffset = raw.igGetColumnOffset;
pub const GetColumnWidth = raw.igGetColumnWidth;
pub const GetColumnsCount = raw.igGetColumnsCount;
pub const GetContentRegionAvail = raw.igGetContentRegionAvail;
pub const GetContentRegionMax = raw.igGetContentRegionMax;
pub const GetCurrentContext = raw.igGetCurrentContext;
pub const GetCursorPos = raw.igGetCursorPos;
pub const GetCursorPosX = raw.igGetCursorPosX;
pub const GetCursorPosY = raw.igGetCursorPosY;
pub const GetCursorScreenPos = raw.igGetCursorScreenPos;
pub const GetCursorStartPos = raw.igGetCursorStartPos;
pub const GetDragDropPayload = raw.igGetDragDropPayload;
pub const GetDrawData = raw.igGetDrawData;
pub const GetDrawListSharedData = raw.igGetDrawListSharedData;
pub const GetFont = raw.igGetFont;
pub const GetFontSize = raw.igGetFontSize;
pub const GetFontTexUvWhitePixel = raw.igGetFontTexUvWhitePixel;
pub const GetForegroundDrawList = raw.igGetForegroundDrawList;
pub const GetFrameCount = raw.igGetFrameCount;
pub const GetFrameHeight = raw.igGetFrameHeight;
pub const GetFrameHeightWithSpacing = raw.igGetFrameHeightWithSpacing;
pub const GetIDStr = raw.igGetIDStr;
pub const GetIDRange = raw.igGetIDRange;
pub const GetIDPtr = raw.igGetIDPtr;
pub const GetIO = raw.igGetIO;
pub const GetItemRectMax = raw.igGetItemRectMax;
pub const GetItemRectMin = raw.igGetItemRectMin;
pub const GetItemRectSize = raw.igGetItemRectSize;
pub const GetKeyIndex = raw.igGetKeyIndex;
pub const GetKeyPressedAmount = raw.igGetKeyPressedAmount;
pub const GetMouseCursor = raw.igGetMouseCursor;
pub const GetMouseDragDelta = raw.igGetMouseDragDelta;
pub const GetMousePos = raw.igGetMousePos;
pub const GetMousePosOnOpeningCurrentPopup = raw.igGetMousePosOnOpeningCurrentPopup;
pub const GetScrollMaxX = raw.igGetScrollMaxX;
pub const GetScrollMaxY = raw.igGetScrollMaxY;
pub const GetScrollX = raw.igGetScrollX;
pub const GetScrollY = raw.igGetScrollY;
pub const GetStateStorage = raw.igGetStateStorage;
pub const GetStyle = raw.igGetStyle;
pub const GetStyleColorName = raw.igGetStyleColorName;
pub const GetStyleColorVec4 = raw.igGetStyleColorVec4;
pub const GetTextLineHeight = raw.igGetTextLineHeight;
pub const GetTextLineHeightWithSpacing = raw.igGetTextLineHeightWithSpacing;
pub const GetTime = raw.igGetTime;
pub const GetTreeNodeToLabelSpacing = raw.igGetTreeNodeToLabelSpacing;
pub const GetVersion = raw.igGetVersion;
pub const GetWindowContentRegionMax = raw.igGetWindowContentRegionMax;
pub const GetWindowContentRegionMin = raw.igGetWindowContentRegionMin;
pub const GetWindowContentRegionWidth = raw.igGetWindowContentRegionWidth;
pub const GetWindowDrawList = raw.igGetWindowDrawList;
pub const GetWindowHeight = raw.igGetWindowHeight;
pub const GetWindowPos = raw.igGetWindowPos;
pub const GetWindowSize = raw.igGetWindowSize;
pub const GetWindowWidth = raw.igGetWindowWidth;
pub const Image = raw.igImage;
pub const ImageButton = raw.igImageButton;
pub const Indent = raw.igIndent;
pub const InputDouble = raw.igInputDouble;
pub const InputFloat = raw.igInputFloat;
pub const InputFloat2 = raw.igInputFloat2;
pub const InputFloat3 = raw.igInputFloat3;
pub const InputFloat4 = raw.igInputFloat4;
pub const InputInt = raw.igInputInt;
pub const InputInt2 = raw.igInputInt2;
pub const InputInt3 = raw.igInputInt3;
pub const InputInt4 = raw.igInputInt4;
pub const InputScalar = raw.igInputScalar;
pub const InputScalarN = raw.igInputScalarN;
pub const InputText = raw.igInputText;
pub const InputTextMultiline = raw.igInputTextMultiline;
pub const InputTextWithHint = raw.igInputTextWithHint;
pub const InvisibleButton = raw.igInvisibleButton;
pub const IsAnyItemActive = raw.igIsAnyItemActive;
pub const IsAnyItemFocused = raw.igIsAnyItemFocused;
pub const IsAnyItemHovered = raw.igIsAnyItemHovered;
pub const IsAnyMouseDown = raw.igIsAnyMouseDown;
pub const IsItemActivated = raw.igIsItemActivated;
pub const IsItemActive = raw.igIsItemActive;
pub const IsItemClicked = raw.igIsItemClicked;
pub const IsItemDeactivated = raw.igIsItemDeactivated;
pub const IsItemDeactivatedAfterEdit = raw.igIsItemDeactivatedAfterEdit;
pub const IsItemEdited = raw.igIsItemEdited;
pub const IsItemFocused = raw.igIsItemFocused;
pub const IsItemHovered = raw.igIsItemHovered;
pub const IsItemToggledOpen = raw.igIsItemToggledOpen;
pub const IsItemVisible = raw.igIsItemVisible;
pub const IsKeyDown = raw.igIsKeyDown;
pub const IsKeyPressed = raw.igIsKeyPressed;
pub const IsKeyReleased = raw.igIsKeyReleased;
pub const IsMouseClicked = raw.igIsMouseClicked;
pub const IsMouseDoubleClicked = raw.igIsMouseDoubleClicked;
pub const IsMouseDown = raw.igIsMouseDown;
pub const IsMouseDragging = raw.igIsMouseDragging;
pub const IsMouseHoveringRect = raw.igIsMouseHoveringRect;
pub const IsMousePosValid = raw.igIsMousePosValid;
pub const IsMouseReleased = raw.igIsMouseReleased;
pub const IsPopupOpen = raw.igIsPopupOpen;
pub const IsRectVisible = raw.igIsRectVisible;
pub const IsRectVisibleVec2 = raw.igIsRectVisibleVec2;
pub const IsWindowAppearing = raw.igIsWindowAppearing;
pub const IsWindowCollapsed = raw.igIsWindowCollapsed;
pub const IsWindowFocused = raw.igIsWindowFocused;
pub const IsWindowHovered = raw.igIsWindowHovered;
pub const LabelText = raw.igLabelText;
pub const ListBoxStr_arr = raw.igListBoxStr_arr;
pub const ListBoxFnPtr = raw.igListBoxFnPtr;
pub const ListBoxFooter = raw.igListBoxFooter;
pub const ListBoxHeaderVec2 = raw.igListBoxHeaderVec2;
pub const ListBoxHeaderInt = raw.igListBoxHeaderInt;
pub const LoadIniSettingsFromDisk = raw.igLoadIniSettingsFromDisk;
pub const LoadIniSettingsFromMemory = raw.igLoadIniSettingsFromMemory;
pub const LogButtons = raw.igLogButtons;
pub const LogFinish = raw.igLogFinish;
pub const LogText = raw.igLogText;
pub const LogToClipboard = raw.igLogToClipboard;
pub const LogToFile = raw.igLogToFile;
pub const LogToTTY = raw.igLogToTTY;
pub const MemAlloc = raw.igMemAlloc;
pub const MemFree = raw.igMemFree;
pub const MenuItemBool = raw.igMenuItemBool;
pub const MenuItemBoolPtr = raw.igMenuItemBoolPtr;
pub const NewFrame = raw.igNewFrame;
pub const NewLine = raw.igNewLine;
pub const NextColumn = raw.igNextColumn;
pub const OpenPopup = raw.igOpenPopup;
pub const OpenPopupOnItemClick = raw.igOpenPopupOnItemClick;
pub const PlotHistogramFloatPtr = raw.igPlotHistogramFloatPtr;
pub const PlotHistogramFnPtr = raw.igPlotHistogramFnPtr;
pub const PlotLines = raw.igPlotLines;
pub const PlotLinesFnPtr = raw.igPlotLinesFnPtr;
pub const PopAllowKeyboardFocus = raw.igPopAllowKeyboardFocus;
pub const PopButtonRepeat = raw.igPopButtonRepeat;
pub const PopClipRect = raw.igPopClipRect;
pub const PopFont = raw.igPopFont;
pub const PopID = raw.igPopID;
pub const PopItemWidth = raw.igPopItemWidth;
pub const PopStyleColor = raw.igPopStyleColor;
pub const PopStyleVar = raw.igPopStyleVar;
pub const PopTextWrapPos = raw.igPopTextWrapPos;
pub const ProgressBar = raw.igProgressBar;
pub const PushAllowKeyboardFocus = raw.igPushAllowKeyboardFocus;
pub const PushButtonRepeat = raw.igPushButtonRepeat;
pub const PushClipRect = raw.igPushClipRect;
pub const PushFont = raw.igPushFont;
pub const PushIDStr = raw.igPushIDStr;
pub const PushIDRange = raw.igPushIDRange;
pub const PushIDPtr = raw.igPushIDPtr;
pub const PushIDInt = raw.igPushIDInt;
pub const PushItemWidth = raw.igPushItemWidth;
pub const PushStyleColorU32 = raw.igPushStyleColorU32;
pub const PushStyleColorVec4 = raw.igPushStyleColorVec4;
pub const PushStyleVarFloat = raw.igPushStyleVarFloat;
pub const PushStyleVarVec2 = raw.igPushStyleVarVec2;
pub const PushTextWrapPos = raw.igPushTextWrapPos;
pub const RadioButtonBool = raw.igRadioButtonBool;
pub const RadioButtonIntPtr = raw.igRadioButtonIntPtr;
pub const Render = raw.igRender;
pub const ResetMouseDragDelta = raw.igResetMouseDragDelta;
pub const SameLine = raw.igSameLine;
pub const SaveIniSettingsToDisk = raw.igSaveIniSettingsToDisk;
pub const SaveIniSettingsToMemory = raw.igSaveIniSettingsToMemory;
pub const SelectableBool = raw.igSelectableBool;
pub const SelectableBoolPtr = raw.igSelectableBoolPtr;
pub const Separator = raw.igSeparator;
pub const SetAllocatorFunctions = raw.igSetAllocatorFunctions;
pub const SetClipboardText = raw.igSetClipboardText;
pub const SetColorEditOptions = raw.igSetColorEditOptions;
pub const SetColumnOffset = raw.igSetColumnOffset;
pub const SetColumnWidth = raw.igSetColumnWidth;
pub const SetCurrentContext = raw.igSetCurrentContext;
pub const SetCursorPos = raw.igSetCursorPos;
pub const SetCursorPosX = raw.igSetCursorPosX;
pub const SetCursorPosY = raw.igSetCursorPosY;
pub const SetCursorScreenPos = raw.igSetCursorScreenPos;
pub const SetDragDropPayload = raw.igSetDragDropPayload;
pub const SetItemAllowOverlap = raw.igSetItemAllowOverlap;
pub const SetItemDefaultFocus = raw.igSetItemDefaultFocus;
pub const SetKeyboardFocusHere = raw.igSetKeyboardFocusHere;
pub const SetMouseCursor = raw.igSetMouseCursor;
pub const SetNextItemOpen = raw.igSetNextItemOpen;
pub const SetNextItemWidth = raw.igSetNextItemWidth;
pub const SetNextWindowBgAlpha = raw.igSetNextWindowBgAlpha;
pub const SetNextWindowCollapsed = raw.igSetNextWindowCollapsed;
pub const SetNextWindowContentSize = raw.igSetNextWindowContentSize;
pub const SetNextWindowFocus = raw.igSetNextWindowFocus;
pub const SetNextWindowPos = raw.igSetNextWindowPos;
pub const SetNextWindowSize = raw.igSetNextWindowSize;
pub const SetNextWindowSizeConstraints = raw.igSetNextWindowSizeConstraints;
pub const SetScrollFromPosX = raw.igSetScrollFromPosX;
pub const SetScrollFromPosY = raw.igSetScrollFromPosY;
pub const SetScrollHereX = raw.igSetScrollHereX;
pub const SetScrollHereY = raw.igSetScrollHereY;
pub const SetScrollX = raw.igSetScrollX;
pub const SetScrollY = raw.igSetScrollY;
pub const SetStateStorage = raw.igSetStateStorage;
pub const SetTabItemClosed = raw.igSetTabItemClosed;
pub const SetTooltip = raw.igSetTooltip;
pub const SetWindowCollapsedBool = raw.igSetWindowCollapsedBool;
pub const SetWindowCollapsedStr = raw.igSetWindowCollapsedStr;
pub const SetWindowFocus = raw.igSetWindowFocus;
pub const SetWindowFocusStr = raw.igSetWindowFocusStr;
pub const SetWindowFontScale = raw.igSetWindowFontScale;
pub const SetWindowPosVec2 = raw.igSetWindowPosVec2;
pub const SetWindowPosStr = raw.igSetWindowPosStr;
pub const SetWindowSizeVec2 = raw.igSetWindowSizeVec2;
pub const SetWindowSizeStr = raw.igSetWindowSizeStr;
pub const ShowAboutWindow = raw.igShowAboutWindow;
pub const ShowDemoWindow = raw.igShowDemoWindow;
pub const ShowFontSelector = raw.igShowFontSelector;
pub const ShowMetricsWindow = raw.igShowMetricsWindow;
pub const ShowStyleEditor = raw.igShowStyleEditor;
pub const ShowStyleSelector = raw.igShowStyleSelector;
pub const ShowUserGuide = raw.igShowUserGuide;
pub const SliderAngle = raw.igSliderAngle;
pub const SliderFloat = raw.igSliderFloat;
pub const SliderFloat2 = raw.igSliderFloat2;
pub const SliderFloat3 = raw.igSliderFloat3;
pub const SliderFloat4 = raw.igSliderFloat4;
pub const SliderInt = raw.igSliderInt;
pub const SliderInt2 = raw.igSliderInt2;
pub const SliderInt3 = raw.igSliderInt3;
pub const SliderInt4 = raw.igSliderInt4;
pub const SliderScalar = raw.igSliderScalar;
pub const SliderScalarN = raw.igSliderScalarN;
pub const SmallButton = raw.igSmallButton;
pub const Spacing = raw.igSpacing;
pub const StyleColorsClassic = raw.igStyleColorsClassic;
pub const StyleColorsDark = raw.igStyleColorsDark;
pub const StyleColorsLight = raw.igStyleColorsLight;
pub const Text = raw.igText;
pub const TextColored = raw.igTextColored;
pub const TextDisabled = raw.igTextDisabled;
pub const TextUnformatted = raw.igTextUnformatted;
pub const TextWrapped = raw.igTextWrapped;
pub const TreeNodeStr = raw.igTreeNodeStr;
pub const TreeNodeStrStr = raw.igTreeNodeStrStr;
pub const TreeNodePtr = raw.igTreeNodePtr;
pub const TreeNodeExStr = raw.igTreeNodeExStr;
pub const TreeNodeExStrStr = raw.igTreeNodeExStrStr;
pub const TreeNodeExPtr = raw.igTreeNodeExPtr;
pub const TreePop = raw.igTreePop;
pub const TreePushStr = raw.igTreePushStr;
pub const TreePushPtr = raw.igTreePushPtr;
pub const Unindent = raw.igUnindent;
pub const VSliderFloat = raw.igVSliderFloat;
pub const VSliderInt = raw.igVSliderInt;
pub const VSliderScalar = raw.igVSliderScalar;
pub const ValueBool = raw.igValueBool;
pub const ValueInt = raw.igValueInt;
pub const ValueUint = raw.igValueUint;
pub const ValueFloat = raw.igValueFloat;

pub const raw = struct {
    pub extern fn ImColor_HSV(self: *Color, h: f32, s: f32, v: f32, a: f32) Color;
    pub extern fn ImColor_ImColor(self: *Color) void;
    pub extern fn ImColor_ImColorInt(self: *Color, r: i32, g: i32, b: i32, a: i32) void;
    pub extern fn ImColor_ImColorU32(self: *Color, rgba: u32) void;
    pub extern fn ImColor_ImColorFloat(self: *Color, r: f32, g: f32, b: f32, a: f32) void;
    pub extern fn ImColor_ImColorVec4(self: *Color, col: Vec4) void;
    pub extern fn ImColor_SetHSV(self: *Color, h: f32, s: f32, v: f32, a: f32) void;
    pub extern fn ImColor_destroy(self: *Color) void;
    pub extern fn ImDrawCmd_ImDrawCmd(self: *DrawCmd) void;
    pub extern fn ImDrawCmd_destroy(self: *DrawCmd) void;
    pub extern fn ImDrawData_Clear(self: *DrawData) void;
    pub extern fn ImDrawData_DeIndexAllBuffers(self: *DrawData) void;
    pub extern fn ImDrawData_ImDrawData(self: *DrawData) void;
    pub extern fn ImDrawData_ScaleClipRects(self: *DrawData, fb_scale: Vec2) void;
    pub extern fn ImDrawData_destroy(self: *DrawData) void;
    pub extern fn ImDrawListSplitter_Clear(self: *DrawListSplitter) void;
    pub extern fn ImDrawListSplitter_ClearFreeMemory(self: *DrawListSplitter) void;
    pub extern fn ImDrawListSplitter_ImDrawListSplitter(self: *DrawListSplitter) void;
    pub extern fn ImDrawListSplitter_Merge(self: *DrawListSplitter, draw_list: *DrawList) void;
    pub extern fn ImDrawListSplitter_SetCurrentChannel(self: *DrawListSplitter, draw_list: *DrawList, channel_idx: i32) void;
    pub extern fn ImDrawListSplitter_Split(self: *DrawListSplitter, draw_list: *DrawList, count: i32) void;
    pub extern fn ImDrawListSplitter_destroy(self: *DrawListSplitter) void;
    pub extern fn ImDrawList_AddBezierCurve(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32, thickness: f32, num_segments: i32) void;
    pub extern fn ImDrawList_AddCallback(self: *DrawList, callback: DrawCallback, callback_data: ?*c_void) void;
    pub extern fn ImDrawList_AddCircle(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32, thickness: f32) void;
    pub extern fn ImDrawList_AddCircleFilled(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32) void;
    pub extern fn ImDrawList_AddConvexPolyFilled(self: *DrawList, points: [*c]const Vec2, num_points: i32, col: u32) void;
    pub extern fn ImDrawList_AddDrawCmd(self: *DrawList) void;
    pub extern fn ImDrawList_AddImage(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2, uv_min: Vec2, uv_max: Vec2, col: u32) void;
    pub extern fn ImDrawList_AddImageQuad(self: *DrawList, user_texture_id: TextureID, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, uv1: Vec2, uv2: Vec2, uv3: Vec2, uv4: Vec2, col: u32) void;
    pub extern fn ImDrawList_AddImageRounded(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2, uv_min: Vec2, uv_max: Vec2, col: u32, rounding: f32, rounding_corners: DrawCornerFlags) void;
    pub extern fn ImDrawList_AddLine(self: *DrawList, p1: Vec2, p2: Vec2, col: u32, thickness: f32) void;
    pub extern fn ImDrawList_AddNgon(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32, thickness: f32) void;
    pub extern fn ImDrawList_AddNgonFilled(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: i32) void;
    pub extern fn ImDrawList_AddPolyline(self: *DrawList, points: [*c]const Vec2, num_points: i32, col: u32, closed: bool, thickness: f32) void;
    pub extern fn ImDrawList_AddQuad(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32, thickness: f32) void;
    pub extern fn ImDrawList_AddQuadFilled(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32) void;
    pub extern fn ImDrawList_AddRect(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32, rounding: f32, rounding_corners: DrawCornerFlags, thickness: f32) void;
    pub extern fn ImDrawList_AddRectFilled(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32, rounding: f32, rounding_corners: DrawCornerFlags) void;
    pub extern fn ImDrawList_AddRectFilledMultiColor(self: *DrawList, p_min: Vec2, p_max: Vec2, col_upr_left: u32, col_upr_right: u32, col_bot_right: u32, col_bot_left: u32) void;
    pub extern fn ImDrawList_AddTextVec2(self: *DrawList, pos: Vec2, col: u32, text_begin: [*]const u8, text_end: [*]const u8) void;
    pub extern fn ImDrawList_AddTextFontPtr(self: *DrawList, font: *const Font, font_size: f32, pos: Vec2, col: u32, text_begin: [*]const u8, text_end: [*]const u8, wrap_width: f32, cpu_fine_clip_rect: [*c]const Vec4) void;
    pub extern fn ImDrawList_AddTriangle(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32, thickness: f32) void;
    pub extern fn ImDrawList_AddTriangleFilled(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32) void;
    pub extern fn ImDrawList_ChannelsMerge(self: *DrawList) void;
    pub extern fn ImDrawList_ChannelsSetCurrent(self: *DrawList, n: i32) void;
    pub extern fn ImDrawList_ChannelsSplit(self: *DrawList, count: i32) void;
    pub extern fn ImDrawList_Clear(self: *DrawList) void;
    pub extern fn ImDrawList_ClearFreeMemory(self: *DrawList) void;
    pub extern fn ImDrawList_CloneOutput(self: *const DrawList) *DrawList;
    pub extern fn ImDrawList_GetClipRectMax(self: *const DrawList) Vec2;
    pub extern fn ImDrawList_GetClipRectMin(self: *const DrawList) Vec2;
    pub extern fn ImDrawList_ImDrawList(self: *DrawList, shared_data: *const DrawListSharedData) void;
    pub extern fn ImDrawList_PathArcTo(self: *DrawList, center: Vec2, radius: f32, a_min: f32, a_max: f32, num_segments: i32) void;
    pub extern fn ImDrawList_PathArcToFast(self: *DrawList, center: Vec2, radius: f32, a_min_of_12: i32, a_max_of_12: i32) void;
    pub extern fn ImDrawList_PathBezierCurveTo(self: *DrawList, p2: Vec2, p3: Vec2, p4: Vec2, num_segments: i32) void;
    pub extern fn ImDrawList_PathClear(self: *DrawList) void;
    pub extern fn ImDrawList_PathFillConvex(self: *DrawList, col: u32) void;
    pub extern fn ImDrawList_PathLineTo(self: *DrawList, pos: Vec2) void;
    pub extern fn ImDrawList_PathLineToMergeDuplicate(self: *DrawList, pos: Vec2) void;
    pub extern fn ImDrawList_PathRect(self: *DrawList, rect_min: Vec2, rect_max: Vec2, rounding: f32, rounding_corners: DrawCornerFlags) void;
    pub extern fn ImDrawList_PathStroke(self: *DrawList, col: u32, closed: bool, thickness: f32) void;
    pub extern fn ImDrawList_PopClipRect(self: *DrawList) void;
    pub extern fn ImDrawList_PopTextureID(self: *DrawList) void;
    pub extern fn ImDrawList_PrimQuadUV(self: *DrawList, a: Vec2, b: Vec2, c: Vec2, d: Vec2, uv_a: Vec2, uv_b: Vec2, uv_c: Vec2, uv_d: Vec2, col: u32) void;
    pub extern fn ImDrawList_PrimRect(self: *DrawList, a: Vec2, b: Vec2, col: u32) void;
    pub extern fn ImDrawList_PrimRectUV(self: *DrawList, a: Vec2, b: Vec2, uv_a: Vec2, uv_b: Vec2, col: u32) void;
    pub extern fn ImDrawList_PrimReserve(self: *DrawList, idx_count: i32, vtx_count: i32) void;
    pub extern fn ImDrawList_PrimUnreserve(self: *DrawList, idx_count: i32, vtx_count: i32) void;
    pub extern fn ImDrawList_PrimVtx(self: *DrawList, pos: Vec2, uv: Vec2, col: u32) void;
    pub extern fn ImDrawList_PrimWriteIdx(self: *DrawList, idx: DrawIdx) void;
    pub extern fn ImDrawList_PrimWriteVtx(self: *DrawList, pos: Vec2, uv: Vec2, col: u32) void;
    pub extern fn ImDrawList_PushClipRect(self: *DrawList, clip_rect_min: Vec2, clip_rect_max: Vec2, intersect_with_current_clip_rect: bool) void;
    pub extern fn ImDrawList_PushClipRectFullScreen(self: *DrawList) void;
    pub extern fn ImDrawList_PushTextureID(self: *DrawList, texture_id: TextureID) void;
    pub extern fn ImDrawList_UpdateClipRect(self: *DrawList) void;
    pub extern fn ImDrawList_UpdateTextureID(self: *DrawList) void;
    pub extern fn ImDrawList_destroy(self: *DrawList) void;
    pub extern fn ImFontAtlasCustomRect_ImFontAtlasCustomRect(self: *FontAtlasCustomRect) void;
    pub extern fn ImFontAtlasCustomRect_IsPacked(self: *const FontAtlasCustomRect) bool;
    pub extern fn ImFontAtlasCustomRect_destroy(self: *FontAtlasCustomRect) void;
    pub extern fn ImFontAtlas_AddCustomRectFontGlyph(self: *FontAtlas, font: *Font, id: Wchar, width: i32, height: i32, advance_x: f32, offset: Vec2) i32;
    pub extern fn ImFontAtlas_AddCustomRectRegular(self: *FontAtlas, id: u32, width: i32, height: i32) i32;
    pub extern fn ImFontAtlas_AddFont(self: *FontAtlas, font_cfg: *const FontConfig) *Font;
    pub extern fn ImFontAtlas_AddFontDefault(self: *FontAtlas, font_cfg: *const FontConfig) *Font;
    pub extern fn ImFontAtlas_AddFontFromFileTTF(self: *FontAtlas, filename: [*]const u8, size_pixels: f32, font_cfg: *const FontConfig, glyph_ranges: [*]const Wchar) *Font;
    pub extern fn ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(self: *FontAtlas, compressed_font_data_base85: [*]const u8, size_pixels: f32, font_cfg: *const FontConfig, glyph_ranges: [*]const Wchar) *Font;
    pub extern fn ImFontAtlas_AddFontFromMemoryCompressedTTF(self: *FontAtlas, compressed_font_data: ?*const c_void, compressed_font_size: i32, size_pixels: f32, font_cfg: *const FontConfig, glyph_ranges: [*]const Wchar) *Font;
    pub extern fn ImFontAtlas_AddFontFromMemoryTTF(self: *FontAtlas, font_data: ?*c_void, font_size: i32, size_pixels: f32, font_cfg: *const FontConfig, glyph_ranges: [*]const Wchar) *Font;
    pub extern fn ImFontAtlas_Build(self: *FontAtlas) bool;
    pub extern fn ImFontAtlas_CalcCustomRectUV(self: *const FontAtlas, rect: *const FontAtlasCustomRect, out_uv_min: *Vec2, out_uv_max: *Vec2) void;
    pub extern fn ImFontAtlas_Clear(self: *FontAtlas) void;
    pub extern fn ImFontAtlas_ClearFonts(self: *FontAtlas) void;
    pub extern fn ImFontAtlas_ClearInputData(self: *FontAtlas) void;
    pub extern fn ImFontAtlas_ClearTexData(self: *FontAtlas) void;
    pub extern fn ImFontAtlas_GetCustomRectByIndex(self: *const FontAtlas, index: i32) *const FontAtlasCustomRect;
    pub extern fn ImFontAtlas_GetGlyphRangesChineseFull(self: *FontAtlas) [*]const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon(self: *FontAtlas) [*]const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesCyrillic(self: *FontAtlas) [*]const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesDefault(self: *FontAtlas) [*]const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesJapanese(self: *FontAtlas) [*]const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesKorean(self: *FontAtlas) [*]const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesThai(self: *FontAtlas) [*]const Wchar;
    pub extern fn ImFontAtlas_GetGlyphRangesVietnamese(self: *FontAtlas) [*]const Wchar;
    pub extern fn ImFontAtlas_GetMouseCursorTexData(self: *FontAtlas, cursor: MouseCursor, out_offset: *Vec2, out_size: *Vec2, out_uv_border: *[2]Vec2, out_uv_fill: *[2]Vec2) bool;
    pub extern fn ImFontAtlas_GetTexDataAsAlpha8(self: *FontAtlas, out_pixels: *[*c]u8, out_width: *i32, out_height: *i32, out_bytes_per_pixel: *i32) void;
    pub extern fn ImFontAtlas_GetTexDataAsRGBA32(self: *FontAtlas, out_pixels: *[*c]u8, out_width: *i32, out_height: *i32, out_bytes_per_pixel: *i32) void;
    pub extern fn ImFontAtlas_ImFontAtlas(self: *FontAtlas) void;
    pub extern fn ImFontAtlas_IsBuilt(self: *const FontAtlas) bool;
    pub extern fn ImFontAtlas_SetTexID(self: *FontAtlas, id: TextureID) void;
    pub extern fn ImFontAtlas_destroy(self: *FontAtlas) void;
    pub extern fn ImFontConfig_ImFontConfig(self: *FontConfig) void;
    pub extern fn ImFontConfig_destroy(self: *FontConfig) void;
    pub extern fn ImFontGlyphRangesBuilder_AddChar(self: *FontGlyphRangesBuilder, c: Wchar) void;
    pub extern fn ImFontGlyphRangesBuilder_AddRanges(self: *FontGlyphRangesBuilder, ranges: [*]const Wchar) void;
    pub extern fn ImFontGlyphRangesBuilder_AddText(self: *FontGlyphRangesBuilder, text: [*]const u8, text_end: [*]const u8) void;
    pub extern fn ImFontGlyphRangesBuilder_BuildRanges(self: *FontGlyphRangesBuilder, out_ranges: *Vector(Wchar)) void;
    pub extern fn ImFontGlyphRangesBuilder_Clear(self: *FontGlyphRangesBuilder) void;
    pub extern fn ImFontGlyphRangesBuilder_GetBit(self: *const FontGlyphRangesBuilder, n: i32) bool;
    pub extern fn ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder(self: *FontGlyphRangesBuilder) void;
    pub extern fn ImFontGlyphRangesBuilder_SetBit(self: *FontGlyphRangesBuilder, n: i32) void;
    pub extern fn ImFontGlyphRangesBuilder_destroy(self: *FontGlyphRangesBuilder) void;
    pub extern fn ImFont_AddGlyph(self: *Font, c: Wchar, x0: f32, y0: f32, x1: f32, y1: f32, u0: f32, v0: f32, u1: f32, v1: f32, advance_x: f32) void;
    pub extern fn ImFont_AddRemapChar(self: *Font, dst: Wchar, src: Wchar, overwrite_dst: bool) void;
    pub extern fn ImFont_BuildLookupTable(self: *Font) void;
    pub extern fn ImFont_CalcTextSizeA(self: *const Font, size: f32, max_width: f32, wrap_width: f32, text_begin: [*]const u8, text_end: [*]const u8, remaining: *[*]const u8) Vec2;
    pub extern fn ImFont_CalcWordWrapPositionA(self: *const Font, scale: f32, text: [*]const u8, text_end: [*]const u8, wrap_width: f32) [*]const u8;
    pub extern fn ImFont_ClearOutputData(self: *Font) void;
    pub extern fn ImFont_FindGlyph(self: *const Font, c: Wchar) *const FontGlyph;
    pub extern fn ImFont_FindGlyphNoFallback(self: *const Font, c: Wchar) *const FontGlyph;
    pub extern fn ImFont_GetCharAdvance(self: *const Font, c: Wchar) f32;
    pub extern fn ImFont_GetDebugName(self: *const Font) [*]const u8;
    pub extern fn ImFont_GrowIndex(self: *Font, new_size: i32) void;
    pub extern fn ImFont_ImFont(self: *Font) void;
    pub extern fn ImFont_IsLoaded(self: *const Font) bool;
    pub extern fn ImFont_RenderChar(self: *const Font, draw_list: *DrawList, size: f32, pos: Vec2, col: u32, c: Wchar) void;
    pub extern fn ImFont_RenderText(self: *const Font, draw_list: *DrawList, size: f32, pos: Vec2, col: u32, clip_rect: Vec4, text_begin: [*]const u8, text_end: [*]const u8, wrap_width: f32, cpu_fine_clip: bool) void;
    pub extern fn ImFont_SetFallbackChar(self: *Font, c: Wchar) void;
    pub extern fn ImFont_destroy(self: *Font) void;
    pub extern fn ImGuiIO_AddInputCharacter(self: *IO, c: u32) void;
    pub extern fn ImGuiIO_AddInputCharactersUTF8(self: *IO, str: [*]const u8) void;
    pub extern fn ImGuiIO_ClearInputCharacters(self: *IO) void;
    pub extern fn ImGuiIO_ImGuiIO(self: *IO) void;
    pub extern fn ImGuiIO_destroy(self: *IO) void;
    pub extern fn ImGuiInputTextCallbackData_DeleteChars(self: *InputTextCallbackData, pos: i32, bytes_count: i32) void;
    pub extern fn ImGuiInputTextCallbackData_HasSelection(self: *const InputTextCallbackData) bool;
    pub extern fn ImGuiInputTextCallbackData_ImGuiInputTextCallbackData(self: *InputTextCallbackData) void;
    pub extern fn ImGuiInputTextCallbackData_InsertChars(self: *InputTextCallbackData, pos: i32, text: [*]const u8, text_end: [*]const u8) void;
    pub extern fn ImGuiInputTextCallbackData_destroy(self: *InputTextCallbackData) void;
    pub extern fn ImGuiListClipper_Begin(self: *ListClipper, items_count: i32, items_height: f32) void;
    pub extern fn ImGuiListClipper_End(self: *ListClipper) void;
    pub extern fn ImGuiListClipper_ImGuiListClipper(self: *ListClipper, items_count: i32, items_height: f32) void;
    pub extern fn ImGuiListClipper_Step(self: *ListClipper) bool;
    pub extern fn ImGuiListClipper_destroy(self: *ListClipper) void;
    pub extern fn ImGuiOnceUponAFrame_ImGuiOnceUponAFrame(self: *OnceUponAFrame) void;
    pub extern fn ImGuiOnceUponAFrame_destroy(self: *OnceUponAFrame) void;
    pub extern fn ImGuiPayload_Clear(self: *Payload) void;
    pub extern fn ImGuiPayload_ImGuiPayload(self: *Payload) void;
    pub extern fn ImGuiPayload_IsDataType(self: *const Payload, type: [*]const u8) bool;
    pub extern fn ImGuiPayload_IsDelivery(self: *const Payload) bool;
    pub extern fn ImGuiPayload_IsPreview(self: *const Payload) bool;
    pub extern fn ImGuiPayload_destroy(self: *Payload) void;
    pub extern fn ImGuiStoragePair_ImGuiStoragePairInt(self: *StoragePair, _key: ID, _val_i: i32) void;
    pub extern fn ImGuiStoragePair_ImGuiStoragePairFloat(self: *StoragePair, _key: ID, _val_f: f32) void;
    pub extern fn ImGuiStoragePair_ImGuiStoragePairPtr(self: *StoragePair, _key: ID, _val_p: ?*c_void) void;
    pub extern fn ImGuiStoragePair_destroy(self: *StoragePair) void;
    pub extern fn ImGuiStorage_BuildSortByKey(self: *Storage) void;
    pub extern fn ImGuiStorage_Clear(self: *Storage) void;
    pub extern fn ImGuiStorage_GetBool(self: *const Storage, key: ID, default_val: bool) bool;
    pub extern fn ImGuiStorage_GetBoolRef(self: *Storage, key: ID, default_val: bool) [*c]bool;
    pub extern fn ImGuiStorage_GetFloat(self: *const Storage, key: ID, default_val: f32) f32;
    pub extern fn ImGuiStorage_GetFloatRef(self: *Storage, key: ID, default_val: f32) [*c]f32;
    pub extern fn ImGuiStorage_GetInt(self: *const Storage, key: ID, default_val: i32) i32;
    pub extern fn ImGuiStorage_GetIntRef(self: *Storage, key: ID, default_val: i32) [*c]i32;
    pub extern fn ImGuiStorage_GetVoidPtr(self: *const Storage, key: ID) ?*c_void;
    pub extern fn ImGuiStorage_GetVoidPtrRef(self: *Storage, key: ID, default_val: ?*c_void) [*c]?*c_void;
    pub extern fn ImGuiStorage_SetAllInt(self: *Storage, val: i32) void;
    pub extern fn ImGuiStorage_SetBool(self: *Storage, key: ID, val: bool) void;
    pub extern fn ImGuiStorage_SetFloat(self: *Storage, key: ID, val: f32) void;
    pub extern fn ImGuiStorage_SetInt(self: *Storage, key: ID, val: i32) void;
    pub extern fn ImGuiStorage_SetVoidPtr(self: *Storage, key: ID, val: ?*c_void) void;
    pub extern fn ImGuiStyle_ImGuiStyle(self: *Style) void;
    pub extern fn ImGuiStyle_ScaleAllSizes(self: *Style, scale_factor: f32) void;
    pub extern fn ImGuiStyle_destroy(self: *Style) void;
    pub extern fn ImGuiTextBuffer_ImGuiTextBuffer(self: *TextBuffer) void;
    pub extern fn ImGuiTextBuffer_append(self: *TextBuffer, str: [*]const u8, str_end: [*]const u8) void;
    pub extern fn ImGuiTextBuffer_appendf(self: *TextBuffer, fmt: [*]const u8, ...) void;
    pub extern fn ImGuiTextBuffer_begin(self: *const TextBuffer) [*]const u8;
    pub extern fn ImGuiTextBuffer_c_str(self: *const TextBuffer) [*]const u8;
    pub extern fn ImGuiTextBuffer_clear(self: *TextBuffer) void;
    pub extern fn ImGuiTextBuffer_destroy(self: *TextBuffer) void;
    pub extern fn ImGuiTextBuffer_empty(self: *const TextBuffer) bool;
    pub extern fn ImGuiTextBuffer_end(self: *const TextBuffer) [*]const u8;
    pub extern fn ImGuiTextBuffer_reserve(self: *TextBuffer, capacity: i32) void;
    pub extern fn ImGuiTextBuffer_size(self: *const TextBuffer) i32;
    pub extern fn ImGuiTextFilter_Build(self: *TextFilter) void;
    pub extern fn ImGuiTextFilter_Clear(self: *TextFilter) void;
    pub extern fn ImGuiTextFilter_Draw(self: *TextFilter, label: [*]const u8, width: f32) bool;
    pub extern fn ImGuiTextFilter_ImGuiTextFilter(self: *TextFilter, default_filter: [*]const u8) void;
    pub extern fn ImGuiTextFilter_IsActive(self: *const TextFilter) bool;
    pub extern fn ImGuiTextFilter_PassFilter(self: *const TextFilter, text: [*]const u8, text_end: [*]const u8) bool;
    pub extern fn ImGuiTextFilter_destroy(self: *TextFilter) void;
    pub extern fn ImGuiTextRange_ImGuiTextRange(self: *TextRange) void;
    pub extern fn ImGuiTextRange_ImGuiTextRangeStr(self: *TextRange, _b: [*]const u8, _e: [*]const u8) void;
    pub extern fn ImGuiTextRange_destroy(self: *TextRange) void;
    pub extern fn ImGuiTextRange_empty(self: *const TextRange) bool;
    pub extern fn ImGuiTextRange_split(self: *const TextRange, separator: u8, out: *Vector(TextRange)) void;
    pub extern fn ImVec2_ImVec2(self: *Vec2) void;
    pub extern fn ImVec2_ImVec2Float(self: *Vec2, _x: f32, _y: f32) void;
    pub extern fn ImVec2_destroy(self: *Vec2) void;
    pub extern fn ImVec4_ImVec4(self: *Vec4) void;
    pub extern fn ImVec4_ImVec4Float(self: *Vec4, _x: f32, _y: f32, _z: f32, _w: f32) void;
    pub extern fn ImVec4_destroy(self: *Vec4) void;
    pub extern fn ImVector_ImDrawChannel_ImVector_ImDrawChannel(self: *Vector(DrawChannel)) void;
    pub extern fn ImVector_ImDrawCmd_ImVector_ImDrawCmd(self: *Vector(DrawCmd)) void;
    pub extern fn ImVector_ImDrawIdx_ImVector_ImDrawIdx(self: *Vector(DrawIdx)) void;
    pub extern fn ImVector_ImDrawVert_ImVector_ImDrawVert(self: *Vector(DrawVert)) void;
    pub extern fn ImVector_ImFontPtr_ImVector_ImFontPtr(self: *Vector(*Font)) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_ImVector_ImFontAtlasCustomRect(self: *Vector(FontAtlasCustomRect)) void;
    pub extern fn ImVector_ImFontConfig_ImVector_ImFontConfig(self: *Vector(FontConfig)) void;
    pub extern fn ImVector_ImFontGlyph_ImVector_ImFontGlyph(self: *Vector(FontGlyph)) void;
    pub extern fn ImVector_ImGuiStoragePair_ImVector_ImGuiStoragePair(self: *Vector(StoragePair)) void;
    pub extern fn ImVector_ImGuiTextRange_ImVector_ImGuiTextRange(self: *Vector(TextRange)) void;
    pub extern fn ImVector_ImTextureID_ImVector_ImTextureID(self: *Vector(TextureID)) void;
    pub extern fn ImVector_ImU32_ImVector_ImU32(self: *Vector(u32)) void;
    pub extern fn ImVector_ImVec2_ImVector_ImVec2(self: *Vector(Vec2)) void;
    pub extern fn ImVector_ImVec4_ImVector_ImVec4(self: *Vector(Vec4)) void;
    pub extern fn ImVector_ImWchar_ImVector_ImWchar(self: *Vector(Wchar)) void;
    pub extern fn ImVector_char_ImVector_char(self: *Vector(u8)) void;
    pub extern fn ImVector_float_ImVector_float(self: *Vector(f32)) void;
    pub extern fn ImVector_ImDrawChannel_ImVector_ImDrawChannelVector(self: *Vector(DrawChannel), src: Vector(DrawChannel)) void;
    pub extern fn ImVector_ImDrawCmd_ImVector_ImDrawCmdVector(self: *Vector(DrawCmd), src: Vector(DrawCmd)) void;
    pub extern fn ImVector_ImDrawIdx_ImVector_ImDrawIdxVector(self: *Vector(DrawIdx), src: Vector(DrawIdx)) void;
    pub extern fn ImVector_ImDrawVert_ImVector_ImDrawVertVector(self: *Vector(DrawVert), src: Vector(DrawVert)) void;
    pub extern fn ImVector_ImFontPtr_ImVector_ImFontPtrVector(self: *Vector(*Font), src: Vector(*Font)) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_ImVector_ImFontAtlasCustomRectVector(self: *Vector(FontAtlasCustomRect), src: Vector(FontAtlasCustomRect)) void;
    pub extern fn ImVector_ImFontConfig_ImVector_ImFontConfigVector(self: *Vector(FontConfig), src: Vector(FontConfig)) void;
    pub extern fn ImVector_ImFontGlyph_ImVector_ImFontGlyphVector(self: *Vector(FontGlyph), src: Vector(FontGlyph)) void;
    pub extern fn ImVector_ImGuiStoragePair_ImVector_ImGuiStoragePairVector(self: *Vector(StoragePair), src: Vector(StoragePair)) void;
    pub extern fn ImVector_ImGuiTextRange_ImVector_ImGuiTextRangeVector(self: *Vector(TextRange), src: Vector(TextRange)) void;
    pub extern fn ImVector_ImTextureID_ImVector_ImTextureIDVector(self: *Vector(TextureID), src: Vector(TextureID)) void;
    pub extern fn ImVector_ImU32_ImVector_ImU32Vector(self: *Vector(u32), src: Vector(u32)) void;
    pub extern fn ImVector_ImVec2_ImVector_ImVec2Vector(self: *Vector(Vec2), src: Vector(Vec2)) void;
    pub extern fn ImVector_ImVec4_ImVector_ImVec4Vector(self: *Vector(Vec4), src: Vector(Vec4)) void;
    pub extern fn ImVector_ImWchar_ImVector_ImWcharVector(self: *Vector(Wchar), src: Vector(Wchar)) void;
    pub extern fn ImVector_char_ImVector_charVector(self: *Vector(u8), src: Vector(u8)) void;
    pub extern fn ImVector_float_ImVector_floatVector(self: *Vector(f32), src: Vector(f32)) void;
    pub extern fn ImVector_ImDrawChannel__grow_capacity(self: *const Vector(DrawChannel), sz: i32) i32;
    pub extern fn ImVector_ImDrawCmd__grow_capacity(self: *const Vector(DrawCmd), sz: i32) i32;
    pub extern fn ImVector_ImDrawIdx__grow_capacity(self: *const Vector(DrawIdx), sz: i32) i32;
    pub extern fn ImVector_ImDrawVert__grow_capacity(self: *const Vector(DrawVert), sz: i32) i32;
    pub extern fn ImVector_ImFontPtr__grow_capacity(self: *const Vector(*Font), sz: i32) i32;
    pub extern fn ImVector_ImFontAtlasCustomRect__grow_capacity(self: *const Vector(FontAtlasCustomRect), sz: i32) i32;
    pub extern fn ImVector_ImFontConfig__grow_capacity(self: *const Vector(FontConfig), sz: i32) i32;
    pub extern fn ImVector_ImFontGlyph__grow_capacity(self: *const Vector(FontGlyph), sz: i32) i32;
    pub extern fn ImVector_ImGuiStoragePair__grow_capacity(self: *const Vector(StoragePair), sz: i32) i32;
    pub extern fn ImVector_ImGuiTextRange__grow_capacity(self: *const Vector(TextRange), sz: i32) i32;
    pub extern fn ImVector_ImTextureID__grow_capacity(self: *const Vector(TextureID), sz: i32) i32;
    pub extern fn ImVector_ImU32__grow_capacity(self: *const Vector(u32), sz: i32) i32;
    pub extern fn ImVector_ImVec2__grow_capacity(self: *const Vector(Vec2), sz: i32) i32;
    pub extern fn ImVector_ImVec4__grow_capacity(self: *const Vector(Vec4), sz: i32) i32;
    pub extern fn ImVector_ImWchar__grow_capacity(self: *const Vector(Wchar), sz: i32) i32;
    pub extern fn ImVector_char__grow_capacity(self: *const Vector(u8), sz: i32) i32;
    pub extern fn ImVector_float__grow_capacity(self: *const Vector(f32), sz: i32) i32;
    pub extern fn ImVector_ImDrawChannel_back(self: *Vector(DrawChannel)) [*c]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_back(self: *Vector(DrawCmd)) [*c]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_back(self: *Vector(DrawIdx)) [*c]DrawIdx;
    pub extern fn ImVector_ImDrawVert_back(self: *Vector(DrawVert)) [*c]DrawVert;
    pub extern fn ImVector_ImFontPtr_back(self: *Vector(*Font)) [*c]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_back(self: *Vector(FontAtlasCustomRect)) [*c]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_back(self: *Vector(FontConfig)) [*c]FontConfig;
    pub extern fn ImVector_ImFontGlyph_back(self: *Vector(FontGlyph)) [*c]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_back(self: *Vector(StoragePair)) [*c]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_back(self: *Vector(TextRange)) [*c]TextRange;
    pub extern fn ImVector_ImTextureID_back(self: *Vector(TextureID)) [*c]TextureID;
    pub extern fn ImVector_ImU32_back(self: *Vector(u32)) [*c]u32;
    pub extern fn ImVector_ImVec2_back(self: *Vector(Vec2)) [*c]Vec2;
    pub extern fn ImVector_ImVec4_back(self: *Vector(Vec4)) [*c]Vec4;
    pub extern fn ImVector_ImWchar_back(self: *Vector(Wchar)) [*c]Wchar;
    pub extern fn ImVector_char_back(self: *Vector(u8)) [*c]u8;
    pub extern fn ImVector_float_back(self: *Vector(f32)) [*c]f32;
    pub extern fn ImVector_ImDrawChannel_back_const(self: *const Vector(DrawChannel)) [*c]const DrawChannel;
    pub extern fn ImVector_ImDrawCmd_back_const(self: *const Vector(DrawCmd)) [*c]const DrawCmd;
    pub extern fn ImVector_ImDrawIdx_back_const(self: *const Vector(DrawIdx)) [*c]const DrawIdx;
    pub extern fn ImVector_ImDrawVert_back_const(self: *const Vector(DrawVert)) [*c]const DrawVert;
    pub extern fn ImVector_ImFontPtr_back_const(self: *const Vector(*Font)) [*c]const*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_back_const(self: *const Vector(FontAtlasCustomRect)) [*c]const FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_back_const(self: *const Vector(FontConfig)) [*c]const FontConfig;
    pub extern fn ImVector_ImFontGlyph_back_const(self: *const Vector(FontGlyph)) [*c]const FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_back_const(self: *const Vector(StoragePair)) [*c]const StoragePair;
    pub extern fn ImVector_ImGuiTextRange_back_const(self: *const Vector(TextRange)) [*c]const TextRange;
    pub extern fn ImVector_ImTextureID_back_const(self: *const Vector(TextureID)) [*c]const TextureID;
    pub extern fn ImVector_ImU32_back_const(self: *const Vector(u32)) [*c]const u32;
    pub extern fn ImVector_ImVec2_back_const(self: *const Vector(Vec2)) [*c]const Vec2;
    pub extern fn ImVector_ImVec4_back_const(self: *const Vector(Vec4)) [*c]const Vec4;
    pub extern fn ImVector_ImWchar_back_const(self: *const Vector(Wchar)) [*c]const Wchar;
    pub extern fn ImVector_char_back_const(self: *const Vector(u8)) [*c]const u8;
    pub extern fn ImVector_float_back_const(self: *const Vector(f32)) [*c]const f32;
    pub extern fn ImVector_ImDrawChannel_begin(self: *Vector(DrawChannel)) [*c]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_begin(self: *Vector(DrawCmd)) [*c]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_begin(self: *Vector(DrawIdx)) [*c]DrawIdx;
    pub extern fn ImVector_ImDrawVert_begin(self: *Vector(DrawVert)) [*c]DrawVert;
    pub extern fn ImVector_ImFontPtr_begin(self: *Vector(*Font)) [*c]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_begin(self: *Vector(FontAtlasCustomRect)) [*c]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_begin(self: *Vector(FontConfig)) [*c]FontConfig;
    pub extern fn ImVector_ImFontGlyph_begin(self: *Vector(FontGlyph)) [*c]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_begin(self: *Vector(StoragePair)) [*c]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_begin(self: *Vector(TextRange)) [*c]TextRange;
    pub extern fn ImVector_ImTextureID_begin(self: *Vector(TextureID)) [*c]TextureID;
    pub extern fn ImVector_ImU32_begin(self: *Vector(u32)) [*c]u32;
    pub extern fn ImVector_ImVec2_begin(self: *Vector(Vec2)) [*c]Vec2;
    pub extern fn ImVector_ImVec4_begin(self: *Vector(Vec4)) [*c]Vec4;
    pub extern fn ImVector_ImWchar_begin(self: *Vector(Wchar)) [*c]Wchar;
    pub extern fn ImVector_char_begin(self: *Vector(u8)) [*c]u8;
    pub extern fn ImVector_float_begin(self: *Vector(f32)) [*c]f32;
    pub extern fn ImVector_ImDrawChannel_begin_const(self: *const Vector(DrawChannel)) [*c]const DrawChannel;
    pub extern fn ImVector_ImDrawCmd_begin_const(self: *const Vector(DrawCmd)) [*c]const DrawCmd;
    pub extern fn ImVector_ImDrawIdx_begin_const(self: *const Vector(DrawIdx)) [*c]const DrawIdx;
    pub extern fn ImVector_ImDrawVert_begin_const(self: *const Vector(DrawVert)) [*c]const DrawVert;
    pub extern fn ImVector_ImFontPtr_begin_const(self: *const Vector(*Font)) [*c]const*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_begin_const(self: *const Vector(FontAtlasCustomRect)) [*c]const FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_begin_const(self: *const Vector(FontConfig)) [*c]const FontConfig;
    pub extern fn ImVector_ImFontGlyph_begin_const(self: *const Vector(FontGlyph)) [*c]const FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_begin_const(self: *const Vector(StoragePair)) [*c]const StoragePair;
    pub extern fn ImVector_ImGuiTextRange_begin_const(self: *const Vector(TextRange)) [*c]const TextRange;
    pub extern fn ImVector_ImTextureID_begin_const(self: *const Vector(TextureID)) [*c]const TextureID;
    pub extern fn ImVector_ImU32_begin_const(self: *const Vector(u32)) [*c]const u32;
    pub extern fn ImVector_ImVec2_begin_const(self: *const Vector(Vec2)) [*c]const Vec2;
    pub extern fn ImVector_ImVec4_begin_const(self: *const Vector(Vec4)) [*c]const Vec4;
    pub extern fn ImVector_ImWchar_begin_const(self: *const Vector(Wchar)) [*c]const Wchar;
    pub extern fn ImVector_char_begin_const(self: *const Vector(u8)) [*c]const u8;
    pub extern fn ImVector_float_begin_const(self: *const Vector(f32)) [*c]const f32;
    pub extern fn ImVector_ImDrawChannel_capacity(self: *const Vector(DrawChannel)) i32;
    pub extern fn ImVector_ImDrawCmd_capacity(self: *const Vector(DrawCmd)) i32;
    pub extern fn ImVector_ImDrawIdx_capacity(self: *const Vector(DrawIdx)) i32;
    pub extern fn ImVector_ImDrawVert_capacity(self: *const Vector(DrawVert)) i32;
    pub extern fn ImVector_ImFontPtr_capacity(self: *const Vector(*Font)) i32;
    pub extern fn ImVector_ImFontAtlasCustomRect_capacity(self: *const Vector(FontAtlasCustomRect)) i32;
    pub extern fn ImVector_ImFontConfig_capacity(self: *const Vector(FontConfig)) i32;
    pub extern fn ImVector_ImFontGlyph_capacity(self: *const Vector(FontGlyph)) i32;
    pub extern fn ImVector_ImGuiStoragePair_capacity(self: *const Vector(StoragePair)) i32;
    pub extern fn ImVector_ImGuiTextRange_capacity(self: *const Vector(TextRange)) i32;
    pub extern fn ImVector_ImTextureID_capacity(self: *const Vector(TextureID)) i32;
    pub extern fn ImVector_ImU32_capacity(self: *const Vector(u32)) i32;
    pub extern fn ImVector_ImVec2_capacity(self: *const Vector(Vec2)) i32;
    pub extern fn ImVector_ImVec4_capacity(self: *const Vector(Vec4)) i32;
    pub extern fn ImVector_ImWchar_capacity(self: *const Vector(Wchar)) i32;
    pub extern fn ImVector_char_capacity(self: *const Vector(u8)) i32;
    pub extern fn ImVector_float_capacity(self: *const Vector(f32)) i32;
    pub extern fn ImVector_ImDrawChannel_clear(self: *Vector(DrawChannel)) void;
    pub extern fn ImVector_ImDrawCmd_clear(self: *Vector(DrawCmd)) void;
    pub extern fn ImVector_ImDrawIdx_clear(self: *Vector(DrawIdx)) void;
    pub extern fn ImVector_ImDrawVert_clear(self: *Vector(DrawVert)) void;
    pub extern fn ImVector_ImFontPtr_clear(self: *Vector(*Font)) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_clear(self: *Vector(FontAtlasCustomRect)) void;
    pub extern fn ImVector_ImFontConfig_clear(self: *Vector(FontConfig)) void;
    pub extern fn ImVector_ImFontGlyph_clear(self: *Vector(FontGlyph)) void;
    pub extern fn ImVector_ImGuiStoragePair_clear(self: *Vector(StoragePair)) void;
    pub extern fn ImVector_ImGuiTextRange_clear(self: *Vector(TextRange)) void;
    pub extern fn ImVector_ImTextureID_clear(self: *Vector(TextureID)) void;
    pub extern fn ImVector_ImU32_clear(self: *Vector(u32)) void;
    pub extern fn ImVector_ImVec2_clear(self: *Vector(Vec2)) void;
    pub extern fn ImVector_ImVec4_clear(self: *Vector(Vec4)) void;
    pub extern fn ImVector_ImWchar_clear(self: *Vector(Wchar)) void;
    pub extern fn ImVector_char_clear(self: *Vector(u8)) void;
    pub extern fn ImVector_float_clear(self: *Vector(f32)) void;
    pub extern fn ImVector_ImDrawIdx_contains(self: *const Vector(DrawIdx), v: DrawIdx) bool;
    pub extern fn ImVector_ImFontPtr_contains(self: *const Vector(*Font), v: *Font) bool;
    pub extern fn ImVector_ImTextureID_contains(self: *const Vector(TextureID), v: TextureID) bool;
    pub extern fn ImVector_ImU32_contains(self: *const Vector(u32), v: u32) bool;
    pub extern fn ImVector_ImWchar_contains(self: *const Vector(Wchar), v: Wchar) bool;
    pub extern fn ImVector_char_contains(self: *const Vector(u8), v: u8) bool;
    pub extern fn ImVector_float_contains(self: *const Vector(f32), v: f32) bool;
    pub extern fn ImVector_ImDrawChannel_destroy(self: *Vector(DrawChannel)) void;
    pub extern fn ImVector_ImDrawCmd_destroy(self: *Vector(DrawCmd)) void;
    pub extern fn ImVector_ImDrawIdx_destroy(self: *Vector(DrawIdx)) void;
    pub extern fn ImVector_ImDrawVert_destroy(self: *Vector(DrawVert)) void;
    pub extern fn ImVector_ImFontPtr_destroy(self: *Vector(*Font)) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_destroy(self: *Vector(FontAtlasCustomRect)) void;
    pub extern fn ImVector_ImFontConfig_destroy(self: *Vector(FontConfig)) void;
    pub extern fn ImVector_ImFontGlyph_destroy(self: *Vector(FontGlyph)) void;
    pub extern fn ImVector_ImGuiStoragePair_destroy(self: *Vector(StoragePair)) void;
    pub extern fn ImVector_ImGuiTextRange_destroy(self: *Vector(TextRange)) void;
    pub extern fn ImVector_ImTextureID_destroy(self: *Vector(TextureID)) void;
    pub extern fn ImVector_ImU32_destroy(self: *Vector(u32)) void;
    pub extern fn ImVector_ImVec2_destroy(self: *Vector(Vec2)) void;
    pub extern fn ImVector_ImVec4_destroy(self: *Vector(Vec4)) void;
    pub extern fn ImVector_ImWchar_destroy(self: *Vector(Wchar)) void;
    pub extern fn ImVector_char_destroy(self: *Vector(u8)) void;
    pub extern fn ImVector_float_destroy(self: *Vector(f32)) void;
    pub extern fn ImVector_ImDrawChannel_empty(self: *const Vector(DrawChannel)) bool;
    pub extern fn ImVector_ImDrawCmd_empty(self: *const Vector(DrawCmd)) bool;
    pub extern fn ImVector_ImDrawIdx_empty(self: *const Vector(DrawIdx)) bool;
    pub extern fn ImVector_ImDrawVert_empty(self: *const Vector(DrawVert)) bool;
    pub extern fn ImVector_ImFontPtr_empty(self: *const Vector(*Font)) bool;
    pub extern fn ImVector_ImFontAtlasCustomRect_empty(self: *const Vector(FontAtlasCustomRect)) bool;
    pub extern fn ImVector_ImFontConfig_empty(self: *const Vector(FontConfig)) bool;
    pub extern fn ImVector_ImFontGlyph_empty(self: *const Vector(FontGlyph)) bool;
    pub extern fn ImVector_ImGuiStoragePair_empty(self: *const Vector(StoragePair)) bool;
    pub extern fn ImVector_ImGuiTextRange_empty(self: *const Vector(TextRange)) bool;
    pub extern fn ImVector_ImTextureID_empty(self: *const Vector(TextureID)) bool;
    pub extern fn ImVector_ImU32_empty(self: *const Vector(u32)) bool;
    pub extern fn ImVector_ImVec2_empty(self: *const Vector(Vec2)) bool;
    pub extern fn ImVector_ImVec4_empty(self: *const Vector(Vec4)) bool;
    pub extern fn ImVector_ImWchar_empty(self: *const Vector(Wchar)) bool;
    pub extern fn ImVector_char_empty(self: *const Vector(u8)) bool;
    pub extern fn ImVector_float_empty(self: *const Vector(f32)) bool;
    pub extern fn ImVector_ImDrawChannel_end(self: *Vector(DrawChannel)) [*c]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_end(self: *Vector(DrawCmd)) [*c]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_end(self: *Vector(DrawIdx)) [*c]DrawIdx;
    pub extern fn ImVector_ImDrawVert_end(self: *Vector(DrawVert)) [*c]DrawVert;
    pub extern fn ImVector_ImFontPtr_end(self: *Vector(*Font)) [*c]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_end(self: *Vector(FontAtlasCustomRect)) [*c]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_end(self: *Vector(FontConfig)) [*c]FontConfig;
    pub extern fn ImVector_ImFontGlyph_end(self: *Vector(FontGlyph)) [*c]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_end(self: *Vector(StoragePair)) [*c]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_end(self: *Vector(TextRange)) [*c]TextRange;
    pub extern fn ImVector_ImTextureID_end(self: *Vector(TextureID)) [*c]TextureID;
    pub extern fn ImVector_ImU32_end(self: *Vector(u32)) [*c]u32;
    pub extern fn ImVector_ImVec2_end(self: *Vector(Vec2)) [*c]Vec2;
    pub extern fn ImVector_ImVec4_end(self: *Vector(Vec4)) [*c]Vec4;
    pub extern fn ImVector_ImWchar_end(self: *Vector(Wchar)) [*c]Wchar;
    pub extern fn ImVector_char_end(self: *Vector(u8)) [*c]u8;
    pub extern fn ImVector_float_end(self: *Vector(f32)) [*c]f32;
    pub extern fn ImVector_ImDrawChannel_end_const(self: *const Vector(DrawChannel)) [*c]const DrawChannel;
    pub extern fn ImVector_ImDrawCmd_end_const(self: *const Vector(DrawCmd)) [*c]const DrawCmd;
    pub extern fn ImVector_ImDrawIdx_end_const(self: *const Vector(DrawIdx)) [*c]const DrawIdx;
    pub extern fn ImVector_ImDrawVert_end_const(self: *const Vector(DrawVert)) [*c]const DrawVert;
    pub extern fn ImVector_ImFontPtr_end_const(self: *const Vector(*Font)) [*c]const*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_end_const(self: *const Vector(FontAtlasCustomRect)) [*c]const FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_end_const(self: *const Vector(FontConfig)) [*c]const FontConfig;
    pub extern fn ImVector_ImFontGlyph_end_const(self: *const Vector(FontGlyph)) [*c]const FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_end_const(self: *const Vector(StoragePair)) [*c]const StoragePair;
    pub extern fn ImVector_ImGuiTextRange_end_const(self: *const Vector(TextRange)) [*c]const TextRange;
    pub extern fn ImVector_ImTextureID_end_const(self: *const Vector(TextureID)) [*c]const TextureID;
    pub extern fn ImVector_ImU32_end_const(self: *const Vector(u32)) [*c]const u32;
    pub extern fn ImVector_ImVec2_end_const(self: *const Vector(Vec2)) [*c]const Vec2;
    pub extern fn ImVector_ImVec4_end_const(self: *const Vector(Vec4)) [*c]const Vec4;
    pub extern fn ImVector_ImWchar_end_const(self: *const Vector(Wchar)) [*c]const Wchar;
    pub extern fn ImVector_char_end_const(self: *const Vector(u8)) [*c]const u8;
    pub extern fn ImVector_float_end_const(self: *const Vector(f32)) [*c]const f32;
    pub extern fn ImVector_ImDrawChannel_erase(self: *Vector(DrawChannel), it: [*c]const DrawChannel) [*c]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_erase(self: *Vector(DrawCmd), it: [*c]const DrawCmd) [*c]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_erase(self: *Vector(DrawIdx), it: [*c]const DrawIdx) [*c]DrawIdx;
    pub extern fn ImVector_ImDrawVert_erase(self: *Vector(DrawVert), it: [*c]const DrawVert) [*c]DrawVert;
    pub extern fn ImVector_ImFontPtr_erase(self: *Vector(*Font), it: [*c]const*Font) [*c]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_erase(self: *Vector(FontAtlasCustomRect), it: [*c]const FontAtlasCustomRect) [*c]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_erase(self: *Vector(FontConfig), it: [*c]const FontConfig) [*c]FontConfig;
    pub extern fn ImVector_ImFontGlyph_erase(self: *Vector(FontGlyph), it: [*c]const FontGlyph) [*c]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_erase(self: *Vector(StoragePair), it: [*c]const StoragePair) [*c]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_erase(self: *Vector(TextRange), it: [*c]const TextRange) [*c]TextRange;
    pub extern fn ImVector_ImTextureID_erase(self: *Vector(TextureID), it: [*c]const TextureID) [*c]TextureID;
    pub extern fn ImVector_ImU32_erase(self: *Vector(u32), it: [*c]const u32) [*c]u32;
    pub extern fn ImVector_ImVec2_erase(self: *Vector(Vec2), it: [*c]const Vec2) [*c]Vec2;
    pub extern fn ImVector_ImVec4_erase(self: *Vector(Vec4), it: [*c]const Vec4) [*c]Vec4;
    pub extern fn ImVector_ImWchar_erase(self: *Vector(Wchar), it: [*c]const Wchar) [*c]Wchar;
    pub extern fn ImVector_char_erase(self: *Vector(u8), it: [*c]const u8) [*c]u8;
    pub extern fn ImVector_float_erase(self: *Vector(f32), it: [*c]const f32) [*c]f32;
    pub extern fn ImVector_ImDrawChannel_eraseTPtr(self: *Vector(DrawChannel), it: [*c]const DrawChannel, it_last: [*c]const DrawChannel) [*c]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_eraseTPtr(self: *Vector(DrawCmd), it: [*c]const DrawCmd, it_last: [*c]const DrawCmd) [*c]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_eraseTPtr(self: *Vector(DrawIdx), it: [*c]const DrawIdx, it_last: [*c]const DrawIdx) [*c]DrawIdx;
    pub extern fn ImVector_ImDrawVert_eraseTPtr(self: *Vector(DrawVert), it: [*c]const DrawVert, it_last: [*c]const DrawVert) [*c]DrawVert;
    pub extern fn ImVector_ImFontPtr_eraseTPtr(self: *Vector(*Font), it: [*c]const*Font, it_last: [*c]const*Font) [*c]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_eraseTPtr(self: *Vector(FontAtlasCustomRect), it: [*c]const FontAtlasCustomRect, it_last: [*c]const FontAtlasCustomRect) [*c]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_eraseTPtr(self: *Vector(FontConfig), it: [*c]const FontConfig, it_last: [*c]const FontConfig) [*c]FontConfig;
    pub extern fn ImVector_ImFontGlyph_eraseTPtr(self: *Vector(FontGlyph), it: [*c]const FontGlyph, it_last: [*c]const FontGlyph) [*c]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_eraseTPtr(self: *Vector(StoragePair), it: [*c]const StoragePair, it_last: [*c]const StoragePair) [*c]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_eraseTPtr(self: *Vector(TextRange), it: [*c]const TextRange, it_last: [*c]const TextRange) [*c]TextRange;
    pub extern fn ImVector_ImTextureID_eraseTPtr(self: *Vector(TextureID), it: [*c]const TextureID, it_last: [*c]const TextureID) [*c]TextureID;
    pub extern fn ImVector_ImU32_eraseTPtr(self: *Vector(u32), it: [*c]const u32, it_last: [*c]const u32) [*c]u32;
    pub extern fn ImVector_ImVec2_eraseTPtr(self: *Vector(Vec2), it: [*c]const Vec2, it_last: [*c]const Vec2) [*c]Vec2;
    pub extern fn ImVector_ImVec4_eraseTPtr(self: *Vector(Vec4), it: [*c]const Vec4, it_last: [*c]const Vec4) [*c]Vec4;
    pub extern fn ImVector_ImWchar_eraseTPtr(self: *Vector(Wchar), it: [*c]const Wchar, it_last: [*c]const Wchar) [*c]Wchar;
    pub extern fn ImVector_char_eraseTPtr(self: *Vector(u8), it: [*c]const u8, it_last: [*c]const u8) [*c]u8;
    pub extern fn ImVector_float_eraseTPtr(self: *Vector(f32), it: [*c]const f32, it_last: [*c]const f32) [*c]f32;
    pub extern fn ImVector_ImDrawChannel_erase_unsorted(self: *Vector(DrawChannel), it: [*c]const DrawChannel) [*c]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_erase_unsorted(self: *Vector(DrawCmd), it: [*c]const DrawCmd) [*c]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_erase_unsorted(self: *Vector(DrawIdx), it: [*c]const DrawIdx) [*c]DrawIdx;
    pub extern fn ImVector_ImDrawVert_erase_unsorted(self: *Vector(DrawVert), it: [*c]const DrawVert) [*c]DrawVert;
    pub extern fn ImVector_ImFontPtr_erase_unsorted(self: *Vector(*Font), it: [*c]const*Font) [*c]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_erase_unsorted(self: *Vector(FontAtlasCustomRect), it: [*c]const FontAtlasCustomRect) [*c]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_erase_unsorted(self: *Vector(FontConfig), it: [*c]const FontConfig) [*c]FontConfig;
    pub extern fn ImVector_ImFontGlyph_erase_unsorted(self: *Vector(FontGlyph), it: [*c]const FontGlyph) [*c]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_erase_unsorted(self: *Vector(StoragePair), it: [*c]const StoragePair) [*c]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_erase_unsorted(self: *Vector(TextRange), it: [*c]const TextRange) [*c]TextRange;
    pub extern fn ImVector_ImTextureID_erase_unsorted(self: *Vector(TextureID), it: [*c]const TextureID) [*c]TextureID;
    pub extern fn ImVector_ImU32_erase_unsorted(self: *Vector(u32), it: [*c]const u32) [*c]u32;
    pub extern fn ImVector_ImVec2_erase_unsorted(self: *Vector(Vec2), it: [*c]const Vec2) [*c]Vec2;
    pub extern fn ImVector_ImVec4_erase_unsorted(self: *Vector(Vec4), it: [*c]const Vec4) [*c]Vec4;
    pub extern fn ImVector_ImWchar_erase_unsorted(self: *Vector(Wchar), it: [*c]const Wchar) [*c]Wchar;
    pub extern fn ImVector_char_erase_unsorted(self: *Vector(u8), it: [*c]const u8) [*c]u8;
    pub extern fn ImVector_float_erase_unsorted(self: *Vector(f32), it: [*c]const f32) [*c]f32;
    pub extern fn ImVector_ImDrawIdx_find(self: *Vector(DrawIdx), v: DrawIdx) [*c]DrawIdx;
    pub extern fn ImVector_ImFontPtr_find(self: *Vector(*Font), v: *Font) [*c]*Font;
    pub extern fn ImVector_ImTextureID_find(self: *Vector(TextureID), v: TextureID) [*c]TextureID;
    pub extern fn ImVector_ImU32_find(self: *Vector(u32), v: u32) [*c]u32;
    pub extern fn ImVector_ImWchar_find(self: *Vector(Wchar), v: Wchar) [*c]Wchar;
    pub extern fn ImVector_char_find(self: *Vector(u8), v: u8) [*c]u8;
    pub extern fn ImVector_float_find(self: *Vector(f32), v: f32) [*c]f32;
    pub extern fn ImVector_ImDrawIdx_find_const(self: *const Vector(DrawIdx), v: DrawIdx) [*c]const DrawIdx;
    pub extern fn ImVector_ImFontPtr_find_const(self: *const Vector(*Font), v: *Font) [*c]const*Font;
    pub extern fn ImVector_ImTextureID_find_const(self: *const Vector(TextureID), v: TextureID) [*c]const TextureID;
    pub extern fn ImVector_ImU32_find_const(self: *const Vector(u32), v: u32) [*c]const u32;
    pub extern fn ImVector_ImWchar_find_const(self: *const Vector(Wchar), v: Wchar) [*c]const Wchar;
    pub extern fn ImVector_char_find_const(self: *const Vector(u8), v: u8) [*c]const u8;
    pub extern fn ImVector_float_find_const(self: *const Vector(f32), v: f32) [*c]const f32;
    pub extern fn ImVector_ImDrawIdx_find_erase(self: *Vector(DrawIdx), v: DrawIdx) bool;
    pub extern fn ImVector_ImFontPtr_find_erase(self: *Vector(*Font), v: *Font) bool;
    pub extern fn ImVector_ImTextureID_find_erase(self: *Vector(TextureID), v: TextureID) bool;
    pub extern fn ImVector_ImU32_find_erase(self: *Vector(u32), v: u32) bool;
    pub extern fn ImVector_ImWchar_find_erase(self: *Vector(Wchar), v: Wchar) bool;
    pub extern fn ImVector_char_find_erase(self: *Vector(u8), v: u8) bool;
    pub extern fn ImVector_float_find_erase(self: *Vector(f32), v: f32) bool;
    pub extern fn ImVector_ImDrawIdx_find_erase_unsorted(self: *Vector(DrawIdx), v: DrawIdx) bool;
    pub extern fn ImVector_ImFontPtr_find_erase_unsorted(self: *Vector(*Font), v: *Font) bool;
    pub extern fn ImVector_ImTextureID_find_erase_unsorted(self: *Vector(TextureID), v: TextureID) bool;
    pub extern fn ImVector_ImU32_find_erase_unsorted(self: *Vector(u32), v: u32) bool;
    pub extern fn ImVector_ImWchar_find_erase_unsorted(self: *Vector(Wchar), v: Wchar) bool;
    pub extern fn ImVector_char_find_erase_unsorted(self: *Vector(u8), v: u8) bool;
    pub extern fn ImVector_float_find_erase_unsorted(self: *Vector(f32), v: f32) bool;
    pub extern fn ImVector_ImDrawChannel_front(self: *Vector(DrawChannel)) [*c]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_front(self: *Vector(DrawCmd)) [*c]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_front(self: *Vector(DrawIdx)) [*c]DrawIdx;
    pub extern fn ImVector_ImDrawVert_front(self: *Vector(DrawVert)) [*c]DrawVert;
    pub extern fn ImVector_ImFontPtr_front(self: *Vector(*Font)) [*c]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_front(self: *Vector(FontAtlasCustomRect)) [*c]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_front(self: *Vector(FontConfig)) [*c]FontConfig;
    pub extern fn ImVector_ImFontGlyph_front(self: *Vector(FontGlyph)) [*c]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_front(self: *Vector(StoragePair)) [*c]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_front(self: *Vector(TextRange)) [*c]TextRange;
    pub extern fn ImVector_ImTextureID_front(self: *Vector(TextureID)) [*c]TextureID;
    pub extern fn ImVector_ImU32_front(self: *Vector(u32)) [*c]u32;
    pub extern fn ImVector_ImVec2_front(self: *Vector(Vec2)) [*c]Vec2;
    pub extern fn ImVector_ImVec4_front(self: *Vector(Vec4)) [*c]Vec4;
    pub extern fn ImVector_ImWchar_front(self: *Vector(Wchar)) [*c]Wchar;
    pub extern fn ImVector_char_front(self: *Vector(u8)) [*c]u8;
    pub extern fn ImVector_float_front(self: *Vector(f32)) [*c]f32;
    pub extern fn ImVector_ImDrawChannel_front_const(self: *const Vector(DrawChannel)) [*c]const DrawChannel;
    pub extern fn ImVector_ImDrawCmd_front_const(self: *const Vector(DrawCmd)) [*c]const DrawCmd;
    pub extern fn ImVector_ImDrawIdx_front_const(self: *const Vector(DrawIdx)) [*c]const DrawIdx;
    pub extern fn ImVector_ImDrawVert_front_const(self: *const Vector(DrawVert)) [*c]const DrawVert;
    pub extern fn ImVector_ImFontPtr_front_const(self: *const Vector(*Font)) [*c]const*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_front_const(self: *const Vector(FontAtlasCustomRect)) [*c]const FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_front_const(self: *const Vector(FontConfig)) [*c]const FontConfig;
    pub extern fn ImVector_ImFontGlyph_front_const(self: *const Vector(FontGlyph)) [*c]const FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_front_const(self: *const Vector(StoragePair)) [*c]const StoragePair;
    pub extern fn ImVector_ImGuiTextRange_front_const(self: *const Vector(TextRange)) [*c]const TextRange;
    pub extern fn ImVector_ImTextureID_front_const(self: *const Vector(TextureID)) [*c]const TextureID;
    pub extern fn ImVector_ImU32_front_const(self: *const Vector(u32)) [*c]const u32;
    pub extern fn ImVector_ImVec2_front_const(self: *const Vector(Vec2)) [*c]const Vec2;
    pub extern fn ImVector_ImVec4_front_const(self: *const Vector(Vec4)) [*c]const Vec4;
    pub extern fn ImVector_ImWchar_front_const(self: *const Vector(Wchar)) [*c]const Wchar;
    pub extern fn ImVector_char_front_const(self: *const Vector(u8)) [*c]const u8;
    pub extern fn ImVector_float_front_const(self: *const Vector(f32)) [*c]const f32;
    pub extern fn ImVector_ImDrawChannel_index_from_ptr(self: *const Vector(DrawChannel), it: [*c]const DrawChannel) i32;
    pub extern fn ImVector_ImDrawCmd_index_from_ptr(self: *const Vector(DrawCmd), it: [*c]const DrawCmd) i32;
    pub extern fn ImVector_ImDrawIdx_index_from_ptr(self: *const Vector(DrawIdx), it: [*c]const DrawIdx) i32;
    pub extern fn ImVector_ImDrawVert_index_from_ptr(self: *const Vector(DrawVert), it: [*c]const DrawVert) i32;
    pub extern fn ImVector_ImFontPtr_index_from_ptr(self: *const Vector(*Font), it: [*c]const*Font) i32;
    pub extern fn ImVector_ImFontAtlasCustomRect_index_from_ptr(self: *const Vector(FontAtlasCustomRect), it: [*c]const FontAtlasCustomRect) i32;
    pub extern fn ImVector_ImFontConfig_index_from_ptr(self: *const Vector(FontConfig), it: [*c]const FontConfig) i32;
    pub extern fn ImVector_ImFontGlyph_index_from_ptr(self: *const Vector(FontGlyph), it: [*c]const FontGlyph) i32;
    pub extern fn ImVector_ImGuiStoragePair_index_from_ptr(self: *const Vector(StoragePair), it: [*c]const StoragePair) i32;
    pub extern fn ImVector_ImGuiTextRange_index_from_ptr(self: *const Vector(TextRange), it: [*c]const TextRange) i32;
    pub extern fn ImVector_ImTextureID_index_from_ptr(self: *const Vector(TextureID), it: [*c]const TextureID) i32;
    pub extern fn ImVector_ImU32_index_from_ptr(self: *const Vector(u32), it: [*c]const u32) i32;
    pub extern fn ImVector_ImVec2_index_from_ptr(self: *const Vector(Vec2), it: [*c]const Vec2) i32;
    pub extern fn ImVector_ImVec4_index_from_ptr(self: *const Vector(Vec4), it: [*c]const Vec4) i32;
    pub extern fn ImVector_ImWchar_index_from_ptr(self: *const Vector(Wchar), it: [*c]const Wchar) i32;
    pub extern fn ImVector_char_index_from_ptr(self: *const Vector(u8), it: [*c]const u8) i32;
    pub extern fn ImVector_float_index_from_ptr(self: *const Vector(f32), it: [*c]const f32) i32;
    pub extern fn ImVector_ImDrawChannel_insert(self: *Vector(DrawChannel), it: [*c]const DrawChannel, v: DrawChannel) [*c]DrawChannel;
    pub extern fn ImVector_ImDrawCmd_insert(self: *Vector(DrawCmd), it: [*c]const DrawCmd, v: DrawCmd) [*c]DrawCmd;
    pub extern fn ImVector_ImDrawIdx_insert(self: *Vector(DrawIdx), it: [*c]const DrawIdx, v: DrawIdx) [*c]DrawIdx;
    pub extern fn ImVector_ImDrawVert_insert(self: *Vector(DrawVert), it: [*c]const DrawVert, v: DrawVert) [*c]DrawVert;
    pub extern fn ImVector_ImFontPtr_insert(self: *Vector(*Font), it: [*c]const*Font, v: *Font) [*c]*Font;
    pub extern fn ImVector_ImFontAtlasCustomRect_insert(self: *Vector(FontAtlasCustomRect), it: [*c]const FontAtlasCustomRect, v: FontAtlasCustomRect) [*c]FontAtlasCustomRect;
    pub extern fn ImVector_ImFontConfig_insert(self: *Vector(FontConfig), it: [*c]const FontConfig, v: FontConfig) [*c]FontConfig;
    pub extern fn ImVector_ImFontGlyph_insert(self: *Vector(FontGlyph), it: [*c]const FontGlyph, v: FontGlyph) [*c]FontGlyph;
    pub extern fn ImVector_ImGuiStoragePair_insert(self: *Vector(StoragePair), it: [*c]const StoragePair, v: StoragePair) [*c]StoragePair;
    pub extern fn ImVector_ImGuiTextRange_insert(self: *Vector(TextRange), it: [*c]const TextRange, v: TextRange) [*c]TextRange;
    pub extern fn ImVector_ImTextureID_insert(self: *Vector(TextureID), it: [*c]const TextureID, v: TextureID) [*c]TextureID;
    pub extern fn ImVector_ImU32_insert(self: *Vector(u32), it: [*c]const u32, v: u32) [*c]u32;
    pub extern fn ImVector_ImVec2_insert(self: *Vector(Vec2), it: [*c]const Vec2, v: Vec2) [*c]Vec2;
    pub extern fn ImVector_ImVec4_insert(self: *Vector(Vec4), it: [*c]const Vec4, v: Vec4) [*c]Vec4;
    pub extern fn ImVector_ImWchar_insert(self: *Vector(Wchar), it: [*c]const Wchar, v: Wchar) [*c]Wchar;
    pub extern fn ImVector_char_insert(self: *Vector(u8), it: [*c]const u8, v: u8) [*c]u8;
    pub extern fn ImVector_float_insert(self: *Vector(f32), it: [*c]const f32, v: f32) [*c]f32;
    pub extern fn ImVector_ImDrawChannel_pop_back(self: *Vector(DrawChannel)) void;
    pub extern fn ImVector_ImDrawCmd_pop_back(self: *Vector(DrawCmd)) void;
    pub extern fn ImVector_ImDrawIdx_pop_back(self: *Vector(DrawIdx)) void;
    pub extern fn ImVector_ImDrawVert_pop_back(self: *Vector(DrawVert)) void;
    pub extern fn ImVector_ImFontPtr_pop_back(self: *Vector(*Font)) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_pop_back(self: *Vector(FontAtlasCustomRect)) void;
    pub extern fn ImVector_ImFontConfig_pop_back(self: *Vector(FontConfig)) void;
    pub extern fn ImVector_ImFontGlyph_pop_back(self: *Vector(FontGlyph)) void;
    pub extern fn ImVector_ImGuiStoragePair_pop_back(self: *Vector(StoragePair)) void;
    pub extern fn ImVector_ImGuiTextRange_pop_back(self: *Vector(TextRange)) void;
    pub extern fn ImVector_ImTextureID_pop_back(self: *Vector(TextureID)) void;
    pub extern fn ImVector_ImU32_pop_back(self: *Vector(u32)) void;
    pub extern fn ImVector_ImVec2_pop_back(self: *Vector(Vec2)) void;
    pub extern fn ImVector_ImVec4_pop_back(self: *Vector(Vec4)) void;
    pub extern fn ImVector_ImWchar_pop_back(self: *Vector(Wchar)) void;
    pub extern fn ImVector_char_pop_back(self: *Vector(u8)) void;
    pub extern fn ImVector_float_pop_back(self: *Vector(f32)) void;
    pub extern fn ImVector_ImDrawChannel_push_back(self: *Vector(DrawChannel), v: DrawChannel) void;
    pub extern fn ImVector_ImDrawCmd_push_back(self: *Vector(DrawCmd), v: DrawCmd) void;
    pub extern fn ImVector_ImDrawIdx_push_back(self: *Vector(DrawIdx), v: DrawIdx) void;
    pub extern fn ImVector_ImDrawVert_push_back(self: *Vector(DrawVert), v: DrawVert) void;
    pub extern fn ImVector_ImFontPtr_push_back(self: *Vector(*Font), v: *Font) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_push_back(self: *Vector(FontAtlasCustomRect), v: FontAtlasCustomRect) void;
    pub extern fn ImVector_ImFontConfig_push_back(self: *Vector(FontConfig), v: FontConfig) void;
    pub extern fn ImVector_ImFontGlyph_push_back(self: *Vector(FontGlyph), v: FontGlyph) void;
    pub extern fn ImVector_ImGuiStoragePair_push_back(self: *Vector(StoragePair), v: StoragePair) void;
    pub extern fn ImVector_ImGuiTextRange_push_back(self: *Vector(TextRange), v: TextRange) void;
    pub extern fn ImVector_ImTextureID_push_back(self: *Vector(TextureID), v: TextureID) void;
    pub extern fn ImVector_ImU32_push_back(self: *Vector(u32), v: u32) void;
    pub extern fn ImVector_ImVec2_push_back(self: *Vector(Vec2), v: Vec2) void;
    pub extern fn ImVector_ImVec4_push_back(self: *Vector(Vec4), v: Vec4) void;
    pub extern fn ImVector_ImWchar_push_back(self: *Vector(Wchar), v: Wchar) void;
    pub extern fn ImVector_char_push_back(self: *Vector(u8), v: u8) void;
    pub extern fn ImVector_float_push_back(self: *Vector(f32), v: f32) void;
    pub extern fn ImVector_ImDrawChannel_push_front(self: *Vector(DrawChannel), v: DrawChannel) void;
    pub extern fn ImVector_ImDrawCmd_push_front(self: *Vector(DrawCmd), v: DrawCmd) void;
    pub extern fn ImVector_ImDrawIdx_push_front(self: *Vector(DrawIdx), v: DrawIdx) void;
    pub extern fn ImVector_ImDrawVert_push_front(self: *Vector(DrawVert), v: DrawVert) void;
    pub extern fn ImVector_ImFontPtr_push_front(self: *Vector(*Font), v: *Font) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_push_front(self: *Vector(FontAtlasCustomRect), v: FontAtlasCustomRect) void;
    pub extern fn ImVector_ImFontConfig_push_front(self: *Vector(FontConfig), v: FontConfig) void;
    pub extern fn ImVector_ImFontGlyph_push_front(self: *Vector(FontGlyph), v: FontGlyph) void;
    pub extern fn ImVector_ImGuiStoragePair_push_front(self: *Vector(StoragePair), v: StoragePair) void;
    pub extern fn ImVector_ImGuiTextRange_push_front(self: *Vector(TextRange), v: TextRange) void;
    pub extern fn ImVector_ImTextureID_push_front(self: *Vector(TextureID), v: TextureID) void;
    pub extern fn ImVector_ImU32_push_front(self: *Vector(u32), v: u32) void;
    pub extern fn ImVector_ImVec2_push_front(self: *Vector(Vec2), v: Vec2) void;
    pub extern fn ImVector_ImVec4_push_front(self: *Vector(Vec4), v: Vec4) void;
    pub extern fn ImVector_ImWchar_push_front(self: *Vector(Wchar), v: Wchar) void;
    pub extern fn ImVector_char_push_front(self: *Vector(u8), v: u8) void;
    pub extern fn ImVector_float_push_front(self: *Vector(f32), v: f32) void;
    pub extern fn ImVector_ImDrawChannel_reserve(self: *Vector(DrawChannel), new_capacity: i32) void;
    pub extern fn ImVector_ImDrawCmd_reserve(self: *Vector(DrawCmd), new_capacity: i32) void;
    pub extern fn ImVector_ImDrawIdx_reserve(self: *Vector(DrawIdx), new_capacity: i32) void;
    pub extern fn ImVector_ImDrawVert_reserve(self: *Vector(DrawVert), new_capacity: i32) void;
    pub extern fn ImVector_ImFontPtr_reserve(self: *Vector(*Font), new_capacity: i32) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_reserve(self: *Vector(FontAtlasCustomRect), new_capacity: i32) void;
    pub extern fn ImVector_ImFontConfig_reserve(self: *Vector(FontConfig), new_capacity: i32) void;
    pub extern fn ImVector_ImFontGlyph_reserve(self: *Vector(FontGlyph), new_capacity: i32) void;
    pub extern fn ImVector_ImGuiStoragePair_reserve(self: *Vector(StoragePair), new_capacity: i32) void;
    pub extern fn ImVector_ImGuiTextRange_reserve(self: *Vector(TextRange), new_capacity: i32) void;
    pub extern fn ImVector_ImTextureID_reserve(self: *Vector(TextureID), new_capacity: i32) void;
    pub extern fn ImVector_ImU32_reserve(self: *Vector(u32), new_capacity: i32) void;
    pub extern fn ImVector_ImVec2_reserve(self: *Vector(Vec2), new_capacity: i32) void;
    pub extern fn ImVector_ImVec4_reserve(self: *Vector(Vec4), new_capacity: i32) void;
    pub extern fn ImVector_ImWchar_reserve(self: *Vector(Wchar), new_capacity: i32) void;
    pub extern fn ImVector_char_reserve(self: *Vector(u8), new_capacity: i32) void;
    pub extern fn ImVector_float_reserve(self: *Vector(f32), new_capacity: i32) void;
    pub extern fn ImVector_ImDrawChannel_resize(self: *Vector(DrawChannel), new_size: i32) void;
    pub extern fn ImVector_ImDrawCmd_resize(self: *Vector(DrawCmd), new_size: i32) void;
    pub extern fn ImVector_ImDrawIdx_resize(self: *Vector(DrawIdx), new_size: i32) void;
    pub extern fn ImVector_ImDrawVert_resize(self: *Vector(DrawVert), new_size: i32) void;
    pub extern fn ImVector_ImFontPtr_resize(self: *Vector(*Font), new_size: i32) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_resize(self: *Vector(FontAtlasCustomRect), new_size: i32) void;
    pub extern fn ImVector_ImFontConfig_resize(self: *Vector(FontConfig), new_size: i32) void;
    pub extern fn ImVector_ImFontGlyph_resize(self: *Vector(FontGlyph), new_size: i32) void;
    pub extern fn ImVector_ImGuiStoragePair_resize(self: *Vector(StoragePair), new_size: i32) void;
    pub extern fn ImVector_ImGuiTextRange_resize(self: *Vector(TextRange), new_size: i32) void;
    pub extern fn ImVector_ImTextureID_resize(self: *Vector(TextureID), new_size: i32) void;
    pub extern fn ImVector_ImU32_resize(self: *Vector(u32), new_size: i32) void;
    pub extern fn ImVector_ImVec2_resize(self: *Vector(Vec2), new_size: i32) void;
    pub extern fn ImVector_ImVec4_resize(self: *Vector(Vec4), new_size: i32) void;
    pub extern fn ImVector_ImWchar_resize(self: *Vector(Wchar), new_size: i32) void;
    pub extern fn ImVector_char_resize(self: *Vector(u8), new_size: i32) void;
    pub extern fn ImVector_float_resize(self: *Vector(f32), new_size: i32) void;
    pub extern fn ImVector_ImDrawChannel_resizeT(self: *Vector(DrawChannel), new_size: i32, v: DrawChannel) void;
    pub extern fn ImVector_ImDrawCmd_resizeT(self: *Vector(DrawCmd), new_size: i32, v: DrawCmd) void;
    pub extern fn ImVector_ImDrawIdx_resizeT(self: *Vector(DrawIdx), new_size: i32, v: DrawIdx) void;
    pub extern fn ImVector_ImDrawVert_resizeT(self: *Vector(DrawVert), new_size: i32, v: DrawVert) void;
    pub extern fn ImVector_ImFontPtr_resizeT(self: *Vector(*Font), new_size: i32, v: *Font) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_resizeT(self: *Vector(FontAtlasCustomRect), new_size: i32, v: FontAtlasCustomRect) void;
    pub extern fn ImVector_ImFontConfig_resizeT(self: *Vector(FontConfig), new_size: i32, v: FontConfig) void;
    pub extern fn ImVector_ImFontGlyph_resizeT(self: *Vector(FontGlyph), new_size: i32, v: FontGlyph) void;
    pub extern fn ImVector_ImGuiStoragePair_resizeT(self: *Vector(StoragePair), new_size: i32, v: StoragePair) void;
    pub extern fn ImVector_ImGuiTextRange_resizeT(self: *Vector(TextRange), new_size: i32, v: TextRange) void;
    pub extern fn ImVector_ImTextureID_resizeT(self: *Vector(TextureID), new_size: i32, v: TextureID) void;
    pub extern fn ImVector_ImU32_resizeT(self: *Vector(u32), new_size: i32, v: u32) void;
    pub extern fn ImVector_ImVec2_resizeT(self: *Vector(Vec2), new_size: i32, v: Vec2) void;
    pub extern fn ImVector_ImVec4_resizeT(self: *Vector(Vec4), new_size: i32, v: Vec4) void;
    pub extern fn ImVector_ImWchar_resizeT(self: *Vector(Wchar), new_size: i32, v: Wchar) void;
    pub extern fn ImVector_char_resizeT(self: *Vector(u8), new_size: i32, v: u8) void;
    pub extern fn ImVector_float_resizeT(self: *Vector(f32), new_size: i32, v: f32) void;
    pub extern fn ImVector_ImDrawChannel_shrink(self: *Vector(DrawChannel), new_size: i32) void;
    pub extern fn ImVector_ImDrawCmd_shrink(self: *Vector(DrawCmd), new_size: i32) void;
    pub extern fn ImVector_ImDrawIdx_shrink(self: *Vector(DrawIdx), new_size: i32) void;
    pub extern fn ImVector_ImDrawVert_shrink(self: *Vector(DrawVert), new_size: i32) void;
    pub extern fn ImVector_ImFontPtr_shrink(self: *Vector(*Font), new_size: i32) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_shrink(self: *Vector(FontAtlasCustomRect), new_size: i32) void;
    pub extern fn ImVector_ImFontConfig_shrink(self: *Vector(FontConfig), new_size: i32) void;
    pub extern fn ImVector_ImFontGlyph_shrink(self: *Vector(FontGlyph), new_size: i32) void;
    pub extern fn ImVector_ImGuiStoragePair_shrink(self: *Vector(StoragePair), new_size: i32) void;
    pub extern fn ImVector_ImGuiTextRange_shrink(self: *Vector(TextRange), new_size: i32) void;
    pub extern fn ImVector_ImTextureID_shrink(self: *Vector(TextureID), new_size: i32) void;
    pub extern fn ImVector_ImU32_shrink(self: *Vector(u32), new_size: i32) void;
    pub extern fn ImVector_ImVec2_shrink(self: *Vector(Vec2), new_size: i32) void;
    pub extern fn ImVector_ImVec4_shrink(self: *Vector(Vec4), new_size: i32) void;
    pub extern fn ImVector_ImWchar_shrink(self: *Vector(Wchar), new_size: i32) void;
    pub extern fn ImVector_char_shrink(self: *Vector(u8), new_size: i32) void;
    pub extern fn ImVector_float_shrink(self: *Vector(f32), new_size: i32) void;
    pub extern fn ImVector_ImDrawChannel_size(self: *const Vector(DrawChannel)) i32;
    pub extern fn ImVector_ImDrawCmd_size(self: *const Vector(DrawCmd)) i32;
    pub extern fn ImVector_ImDrawIdx_size(self: *const Vector(DrawIdx)) i32;
    pub extern fn ImVector_ImDrawVert_size(self: *const Vector(DrawVert)) i32;
    pub extern fn ImVector_ImFontPtr_size(self: *const Vector(*Font)) i32;
    pub extern fn ImVector_ImFontAtlasCustomRect_size(self: *const Vector(FontAtlasCustomRect)) i32;
    pub extern fn ImVector_ImFontConfig_size(self: *const Vector(FontConfig)) i32;
    pub extern fn ImVector_ImFontGlyph_size(self: *const Vector(FontGlyph)) i32;
    pub extern fn ImVector_ImGuiStoragePair_size(self: *const Vector(StoragePair)) i32;
    pub extern fn ImVector_ImGuiTextRange_size(self: *const Vector(TextRange)) i32;
    pub extern fn ImVector_ImTextureID_size(self: *const Vector(TextureID)) i32;
    pub extern fn ImVector_ImU32_size(self: *const Vector(u32)) i32;
    pub extern fn ImVector_ImVec2_size(self: *const Vector(Vec2)) i32;
    pub extern fn ImVector_ImVec4_size(self: *const Vector(Vec4)) i32;
    pub extern fn ImVector_ImWchar_size(self: *const Vector(Wchar)) i32;
    pub extern fn ImVector_char_size(self: *const Vector(u8)) i32;
    pub extern fn ImVector_float_size(self: *const Vector(f32)) i32;
    pub extern fn ImVector_ImDrawChannel_size_in_bytes(self: *const Vector(DrawChannel)) i32;
    pub extern fn ImVector_ImDrawCmd_size_in_bytes(self: *const Vector(DrawCmd)) i32;
    pub extern fn ImVector_ImDrawIdx_size_in_bytes(self: *const Vector(DrawIdx)) i32;
    pub extern fn ImVector_ImDrawVert_size_in_bytes(self: *const Vector(DrawVert)) i32;
    pub extern fn ImVector_ImFontPtr_size_in_bytes(self: *const Vector(*Font)) i32;
    pub extern fn ImVector_ImFontAtlasCustomRect_size_in_bytes(self: *const Vector(FontAtlasCustomRect)) i32;
    pub extern fn ImVector_ImFontConfig_size_in_bytes(self: *const Vector(FontConfig)) i32;
    pub extern fn ImVector_ImFontGlyph_size_in_bytes(self: *const Vector(FontGlyph)) i32;
    pub extern fn ImVector_ImGuiStoragePair_size_in_bytes(self: *const Vector(StoragePair)) i32;
    pub extern fn ImVector_ImGuiTextRange_size_in_bytes(self: *const Vector(TextRange)) i32;
    pub extern fn ImVector_ImTextureID_size_in_bytes(self: *const Vector(TextureID)) i32;
    pub extern fn ImVector_ImU32_size_in_bytes(self: *const Vector(u32)) i32;
    pub extern fn ImVector_ImVec2_size_in_bytes(self: *const Vector(Vec2)) i32;
    pub extern fn ImVector_ImVec4_size_in_bytes(self: *const Vector(Vec4)) i32;
    pub extern fn ImVector_ImWchar_size_in_bytes(self: *const Vector(Wchar)) i32;
    pub extern fn ImVector_char_size_in_bytes(self: *const Vector(u8)) i32;
    pub extern fn ImVector_float_size_in_bytes(self: *const Vector(f32)) i32;
    pub extern fn ImVector_ImDrawChannel_swap(self: *Vector(DrawChannel), rhs: *Vector(DrawChannel)) void;
    pub extern fn ImVector_ImDrawCmd_swap(self: *Vector(DrawCmd), rhs: *Vector(DrawCmd)) void;
    pub extern fn ImVector_ImDrawIdx_swap(self: *Vector(DrawIdx), rhs: *Vector(DrawIdx)) void;
    pub extern fn ImVector_ImDrawVert_swap(self: *Vector(DrawVert), rhs: *Vector(DrawVert)) void;
    pub extern fn ImVector_ImFontPtr_swap(self: *Vector(*Font), rhs: *Vector(*Font)) void;
    pub extern fn ImVector_ImFontAtlasCustomRect_swap(self: *Vector(FontAtlasCustomRect), rhs: *Vector(FontAtlasCustomRect)) void;
    pub extern fn ImVector_ImFontConfig_swap(self: *Vector(FontConfig), rhs: *Vector(FontConfig)) void;
    pub extern fn ImVector_ImFontGlyph_swap(self: *Vector(FontGlyph), rhs: *Vector(FontGlyph)) void;
    pub extern fn ImVector_ImGuiStoragePair_swap(self: *Vector(StoragePair), rhs: *Vector(StoragePair)) void;
    pub extern fn ImVector_ImGuiTextRange_swap(self: *Vector(TextRange), rhs: *Vector(TextRange)) void;
    pub extern fn ImVector_ImTextureID_swap(self: *Vector(TextureID), rhs: *Vector(TextureID)) void;
    pub extern fn ImVector_ImU32_swap(self: *Vector(u32), rhs: *Vector(u32)) void;
    pub extern fn ImVector_ImVec2_swap(self: *Vector(Vec2), rhs: *Vector(Vec2)) void;
    pub extern fn ImVector_ImVec4_swap(self: *Vector(Vec4), rhs: *Vector(Vec4)) void;
    pub extern fn ImVector_ImWchar_swap(self: *Vector(Wchar), rhs: *Vector(Wchar)) void;
    pub extern fn ImVector_char_swap(self: *Vector(u8), rhs: *Vector(u8)) void;
    pub extern fn ImVector_float_swap(self: *Vector(f32), rhs: *Vector(f32)) void;
    pub extern fn igAcceptDragDropPayload(type: [*]const u8, flags: DragDropFlags) *const Payload;
    pub extern fn igAlignTextToFramePadding() void;
    pub extern fn igArrowButton(str_id: [*]const u8, dir: Dir) bool;
    pub extern fn igBegin(name: [*]const u8, p_open: [*c]bool, flags: WindowFlags) bool;
    pub extern fn igBeginChildStr(str_id: [*]const u8, size: Vec2, border: bool, flags: WindowFlags) bool;
    pub extern fn igBeginChildID(id: ID, size: Vec2, border: bool, flags: WindowFlags) bool;
    pub extern fn igBeginChildFrame(id: ID, size: Vec2, flags: WindowFlags) bool;
    pub extern fn igBeginCombo(label: [*]const u8, preview_value: [*]const u8, flags: ComboFlags) bool;
    pub extern fn igBeginDragDropSource(flags: DragDropFlags) bool;
    pub extern fn igBeginDragDropTarget() bool;
    pub extern fn igBeginGroup() void;
    pub extern fn igBeginMainMenuBar() bool;
    pub extern fn igBeginMenu(label: [*]const u8, enabled: bool) bool;
    pub extern fn igBeginMenuBar() bool;
    pub extern fn igBeginPopup(str_id: [*]const u8, flags: WindowFlags) bool;
    pub extern fn igBeginPopupContextItem(str_id: [*]const u8, mouse_button: MouseButton) bool;
    pub extern fn igBeginPopupContextVoid(str_id: [*]const u8, mouse_button: MouseButton) bool;
    pub extern fn igBeginPopupContextWindow(str_id: [*]const u8, mouse_button: MouseButton, also_over_items: bool) bool;
    pub extern fn igBeginPopupModal(name: [*]const u8, p_open: [*c]bool, flags: WindowFlags) bool;
    pub extern fn igBeginTabBar(str_id: [*]const u8, flags: TabBarFlags) bool;
    pub extern fn igBeginTabItem(label: [*]const u8, p_open: [*c]bool, flags: TabItemFlags) bool;
    pub extern fn igBeginTooltip() void;
    pub extern fn igBullet() void;
    pub extern fn igBulletText(fmt: [*]const u8, ...) void;
    pub extern fn igButton(label: [*]const u8, size: Vec2) bool;
    pub extern fn igCalcItemWidth() f32;
    pub extern fn igCalcListClipping(items_count: i32, items_height: f32, out_items_display_start: *i32, out_items_display_end: *i32) void;
    pub extern fn igCalcTextSize(text: [*]const u8, text_end: [*]const u8, hide_text_after_double_hash: bool, wrap_width: f32) Vec2;
    pub extern fn igCaptureKeyboardFromApp(want_capture_keyboard_value: bool) void;
    pub extern fn igCaptureMouseFromApp(want_capture_mouse_value: bool) void;
    pub extern fn igCheckbox(label: [*]const u8, v: [*c]bool) bool;
    pub extern fn igCheckboxFlags(label: [*]const u8, flags: [*c]u32, flags_value: u32) bool;
    pub extern fn igCloseCurrentPopup() void;
    pub extern fn igCollapsingHeader(label: [*]const u8, flags: TreeNodeFlags) bool;
    pub extern fn igCollapsingHeaderBoolPtr(label: [*]const u8, p_open: [*c]bool, flags: TreeNodeFlags) bool;
    pub extern fn igColorButton(desc_id: [*]const u8, col: Vec4, flags: ColorEditFlags, size: Vec2) bool;
    pub extern fn igColorConvertFloat4ToU32(in: Vec4) u32;
    pub extern fn igColorConvertHSVtoRGB(h: f32, s: f32, v: f32, out_r: *f32, out_g: *f32, out_b: *f32) void;
    pub extern fn igColorConvertRGBtoHSV(r: f32, g: f32, b: f32, out_h: *f32, out_s: *f32, out_v: *f32) void;
    pub extern fn igColorConvertU32ToFloat4(in: u32) Vec4;
    pub extern fn igColorEdit3(label: [*]const u8, col: *[3]f32, flags: ColorEditFlags) bool;
    pub extern fn igColorEdit4(label: [*]const u8, col: *[4]f32, flags: ColorEditFlags) bool;
    pub extern fn igColorPicker3(label: [*]const u8, col: *[3]f32, flags: ColorEditFlags) bool;
    pub extern fn igColorPicker4(label: [*]const u8, col: *[4]f32, flags: ColorEditFlags, ref_col: [*c]const f32) bool;
    pub extern fn igColumns(count: i32, id: [*]const u8, border: bool) void;
    pub extern fn igCombo(label: [*]const u8, current_item: [*c]i32, items: [*]const[*]const u8, items_count: i32, popup_max_height_in_items: i32) bool;
    pub extern fn igComboStr(label: [*]const u8, current_item: [*c]i32, items_separated_by_zeros: [*]const u8, popup_max_height_in_items: i32) bool;
    pub extern fn igComboFnPtr(label: [*]const u8, current_item: [*c]i32, items_getter: ?extern fn (data: ?*c_void, idx: i32, out_text: *[*]const u8) bool, data: ?*c_void, items_count: i32, popup_max_height_in_items: i32) bool;
    pub extern fn igCreateContext(shared_font_atlas: *FontAtlas) *Context;
    pub extern fn igDebugCheckVersionAndDataLayout(version_str: [*]const u8, sz_io: usize, sz_style: usize, sz_vec2: usize, sz_vec4: usize, sz_drawvert: usize, sz_drawidx: usize) bool;
    pub extern fn igDestroyContext(ctx: *Context) void;
    pub extern fn igDragFloat(label: [*]const u8, v: [*c]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*]const u8, power: f32) bool;
    pub extern fn igDragFloat2(label: [*]const u8, v: *[2]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*]const u8, power: f32) bool;
    pub extern fn igDragFloat3(label: [*]const u8, v: *[3]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*]const u8, power: f32) bool;
    pub extern fn igDragFloat4(label: [*]const u8, v: *[4]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*]const u8, power: f32) bool;
    pub extern fn igDragFloatRange2(label: [*]const u8, v_current_min: [*c]f32, v_current_max: [*c]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*]const u8, format_max: [*]const u8, power: f32) bool;
    pub extern fn igDragInt(label: [*]const u8, v: [*c]i32, v_speed: f32, v_min: i32, v_max: i32, format: [*]const u8) bool;
    pub extern fn igDragInt2(label: [*]const u8, v: *[2]i32, v_speed: f32, v_min: i32, v_max: i32, format: [*]const u8) bool;
    pub extern fn igDragInt3(label: [*]const u8, v: *[3]i32, v_speed: f32, v_min: i32, v_max: i32, format: [*]const u8) bool;
    pub extern fn igDragInt4(label: [*]const u8, v: *[4]i32, v_speed: f32, v_min: i32, v_max: i32, format: [*]const u8) bool;
    pub extern fn igDragIntRange2(label: [*]const u8, v_current_min: [*c]i32, v_current_max: [*c]i32, v_speed: f32, v_min: i32, v_max: i32, format: [*]const u8, format_max: [*]const u8) bool;
    pub extern fn igDragScalar(label: [*]const u8, data_type: DataType, p_data: ?*c_void, v_speed: f32, p_min: ?*const c_void, p_max: ?*const c_void, format: [*]const u8, power: f32) bool;
    pub extern fn igDragScalarN(label: [*]const u8, data_type: DataType, p_data: ?*c_void, components: i32, v_speed: f32, p_min: ?*const c_void, p_max: ?*const c_void, format: [*]const u8, power: f32) bool;
    pub extern fn igDummy(size: Vec2) void;
    pub extern fn igEnd() void;
    pub extern fn igEndChild() void;
    pub extern fn igEndChildFrame() void;
    pub extern fn igEndCombo() void;
    pub extern fn igEndDragDropSource() void;
    pub extern fn igEndDragDropTarget() void;
    pub extern fn igEndFrame() void;
    pub extern fn igEndGroup() void;
    pub extern fn igEndMainMenuBar() void;
    pub extern fn igEndMenu() void;
    pub extern fn igEndMenuBar() void;
    pub extern fn igEndPopup() void;
    pub extern fn igEndTabBar() void;
    pub extern fn igEndTabItem() void;
    pub extern fn igEndTooltip() void;
    pub extern fn igGetBackgroundDrawList() *DrawList;
    pub extern fn igGetClipboardText() [*]const u8;
    pub extern fn igGetColorU32(idx: Col, alpha_mul: f32) u32;
    pub extern fn igGetColorU32Vec4(col: Vec4) u32;
    pub extern fn igGetColorU32U32(col: u32) u32;
    pub extern fn igGetColumnIndex() i32;
    pub extern fn igGetColumnOffset(column_index: i32) f32;
    pub extern fn igGetColumnWidth(column_index: i32) f32;
    pub extern fn igGetColumnsCount() i32;
    pub extern fn igGetContentRegionAvail() Vec2;
    pub extern fn igGetContentRegionMax() Vec2;
    pub extern fn igGetCurrentContext() *Context;
    pub extern fn igGetCursorPos() Vec2;
    pub extern fn igGetCursorPosX() f32;
    pub extern fn igGetCursorPosY() f32;
    pub extern fn igGetCursorScreenPos() Vec2;
    pub extern fn igGetCursorStartPos() Vec2;
    pub extern fn igGetDragDropPayload() *const Payload;
    pub extern fn igGetDrawData() *DrawData;
    pub extern fn igGetDrawListSharedData() *DrawListSharedData;
    pub extern fn igGetFont() *Font;
    pub extern fn igGetFontSize() f32;
    pub extern fn igGetFontTexUvWhitePixel() Vec2;
    pub extern fn igGetForegroundDrawList() *DrawList;
    pub extern fn igGetFrameCount() i32;
    pub extern fn igGetFrameHeight() f32;
    pub extern fn igGetFrameHeightWithSpacing() f32;
    pub extern fn igGetIDStr(str_id: [*]const u8) ID;
    pub extern fn igGetIDRange(str_id_begin: [*]const u8, str_id_end: [*]const u8) ID;
    pub extern fn igGetIDPtr(ptr_id: ?*const c_void) ID;
    pub extern fn igGetIO() *IO;
    pub extern fn igGetItemRectMax() Vec2;
    pub extern fn igGetItemRectMin() Vec2;
    pub extern fn igGetItemRectSize() Vec2;
    pub extern fn igGetKeyIndex(imgui_key: Key) i32;
    pub extern fn igGetKeyPressedAmount(key_index: i32, repeat_delay: f32, rate: f32) i32;
    pub extern fn igGetMouseCursor() MouseCursor;
    pub extern fn igGetMouseDragDelta(button: MouseButton, lock_threshold: f32) Vec2;
    pub extern fn igGetMousePos() Vec2;
    pub extern fn igGetMousePosOnOpeningCurrentPopup() Vec2;
    pub extern fn igGetScrollMaxX() f32;
    pub extern fn igGetScrollMaxY() f32;
    pub extern fn igGetScrollX() f32;
    pub extern fn igGetScrollY() f32;
    pub extern fn igGetStateStorage() *Storage;
    pub extern fn igGetStyle() *Style;
    pub extern fn igGetStyleColorName(idx: Col) [*]const u8;
    pub extern fn igGetStyleColorVec4(idx: Col) [*c]const Vec4;
    pub extern fn igGetTextLineHeight() f32;
    pub extern fn igGetTextLineHeightWithSpacing() f32;
    pub extern fn igGetTime() f64;
    pub extern fn igGetTreeNodeToLabelSpacing() f32;
    pub extern fn igGetVersion() [*]const u8;
    pub extern fn igGetWindowContentRegionMax() Vec2;
    pub extern fn igGetWindowContentRegionMin() Vec2;
    pub extern fn igGetWindowContentRegionWidth() f32;
    pub extern fn igGetWindowDrawList() *DrawList;
    pub extern fn igGetWindowHeight() f32;
    pub extern fn igGetWindowPos() Vec2;
    pub extern fn igGetWindowSize() Vec2;
    pub extern fn igGetWindowWidth() f32;
    pub extern fn igImage(user_texture_id: TextureID, size: Vec2, uv0: Vec2, uv1: Vec2, tint_col: Vec4, border_col: Vec4) void;
    pub extern fn igImageButton(user_texture_id: TextureID, size: Vec2, uv0: Vec2, uv1: Vec2, frame_padding: i32, bg_col: Vec4, tint_col: Vec4) bool;
    pub extern fn igIndent(indent_w: f32) void;
    pub extern fn igInputDouble(label: [*]const u8, v: [*c]f64, step: f64, step_fast: f64, format: [*]const u8, flags: InputTextFlags) bool;
    pub extern fn igInputFloat(label: [*]const u8, v: [*c]f32, step: f32, step_fast: f32, format: [*]const u8, flags: InputTextFlags) bool;
    pub extern fn igInputFloat2(label: [*]const u8, v: *[2]f32, format: [*]const u8, flags: InputTextFlags) bool;
    pub extern fn igInputFloat3(label: [*]const u8, v: *[3]f32, format: [*]const u8, flags: InputTextFlags) bool;
    pub extern fn igInputFloat4(label: [*]const u8, v: *[4]f32, format: [*]const u8, flags: InputTextFlags) bool;
    pub extern fn igInputInt(label: [*]const u8, v: [*c]i32, step: i32, step_fast: i32, flags: InputTextFlags) bool;
    pub extern fn igInputInt2(label: [*]const u8, v: *[2]i32, flags: InputTextFlags) bool;
    pub extern fn igInputInt3(label: [*]const u8, v: *[3]i32, flags: InputTextFlags) bool;
    pub extern fn igInputInt4(label: [*]const u8, v: *[4]i32, flags: InputTextFlags) bool;
    pub extern fn igInputScalar(label: [*]const u8, data_type: DataType, p_data: ?*c_void, p_step: ?*const c_void, p_step_fast: ?*const c_void, format: [*]const u8, flags: InputTextFlags) bool;
    pub extern fn igInputScalarN(label: [*]const u8, data_type: DataType, p_data: ?*c_void, components: i32, p_step: ?*const c_void, p_step_fast: ?*const c_void, format: [*]const u8, flags: InputTextFlags) bool;
    pub extern fn igInputText(label: [*]const u8, buf: [*]u8, buf_size: usize, flags: InputTextFlags, callback: InputTextCallback, user_data: ?*c_void) bool;
    pub extern fn igInputTextMultiline(label: [*]const u8, buf: [*]u8, buf_size: usize, size: Vec2, flags: InputTextFlags, callback: InputTextCallback, user_data: ?*c_void) bool;
    pub extern fn igInputTextWithHint(label: [*]const u8, hint: [*]const u8, buf: [*]u8, buf_size: usize, flags: InputTextFlags, callback: InputTextCallback, user_data: ?*c_void) bool;
    pub extern fn igInvisibleButton(str_id: [*]const u8, size: Vec2) bool;
    pub extern fn igIsAnyItemActive() bool;
    pub extern fn igIsAnyItemFocused() bool;
    pub extern fn igIsAnyItemHovered() bool;
    pub extern fn igIsAnyMouseDown() bool;
    pub extern fn igIsItemActivated() bool;
    pub extern fn igIsItemActive() bool;
    pub extern fn igIsItemClicked(mouse_button: MouseButton) bool;
    pub extern fn igIsItemDeactivated() bool;
    pub extern fn igIsItemDeactivatedAfterEdit() bool;
    pub extern fn igIsItemEdited() bool;
    pub extern fn igIsItemFocused() bool;
    pub extern fn igIsItemHovered(flags: HoveredFlags) bool;
    pub extern fn igIsItemToggledOpen() bool;
    pub extern fn igIsItemVisible() bool;
    pub extern fn igIsKeyDown(user_key_index: i32) bool;
    pub extern fn igIsKeyPressed(user_key_index: i32, repeat: bool) bool;
    pub extern fn igIsKeyReleased(user_key_index: i32) bool;
    pub extern fn igIsMouseClicked(button: MouseButton, repeat: bool) bool;
    pub extern fn igIsMouseDoubleClicked(button: MouseButton) bool;
    pub extern fn igIsMouseDown(button: MouseButton) bool;
    pub extern fn igIsMouseDragging(button: MouseButton, lock_threshold: f32) bool;
    pub extern fn igIsMouseHoveringRect(r_min: Vec2, r_max: Vec2, clip: bool) bool;
    pub extern fn igIsMousePosValid(mouse_pos: [*c]const Vec2) bool;
    pub extern fn igIsMouseReleased(button: MouseButton) bool;
    pub extern fn igIsPopupOpen(str_id: [*]const u8) bool;
    pub extern fn igIsRectVisible(size: Vec2) bool;
    pub extern fn igIsRectVisibleVec2(rect_min: Vec2, rect_max: Vec2) bool;
    pub extern fn igIsWindowAppearing() bool;
    pub extern fn igIsWindowCollapsed() bool;
    pub extern fn igIsWindowFocused(flags: FocusedFlags) bool;
    pub extern fn igIsWindowHovered(flags: HoveredFlags) bool;
    pub extern fn igLabelText(label: [*]const u8, fmt: [*]const u8, ...) void;
    pub extern fn igListBoxStr_arr(label: [*]const u8, current_item: [*c]i32, items: [*]const[*]const u8, items_count: i32, height_in_items: i32) bool;
    pub extern fn igListBoxFnPtr(label: [*]const u8, current_item: [*c]i32, items_getter: ?extern fn (data: ?*c_void, idx: i32, out_text: *[*]const u8) bool, data: ?*c_void, items_count: i32, height_in_items: i32) bool;
    pub extern fn igListBoxFooter() void;
    pub extern fn igListBoxHeaderVec2(label: [*]const u8, size: Vec2) bool;
    pub extern fn igListBoxHeaderInt(label: [*]const u8, items_count: i32, height_in_items: i32) bool;
    pub extern fn igLoadIniSettingsFromDisk(ini_filename: [*]const u8) void;
    pub extern fn igLoadIniSettingsFromMemory(ini_data: [*]const u8, ini_size: usize) void;
    pub extern fn igLogButtons() void;
    pub extern fn igLogFinish() void;
    pub extern fn igLogText(fmt: [*]const u8, ...) void;
    pub extern fn igLogToClipboard(auto_open_depth: i32) void;
    pub extern fn igLogToFile(auto_open_depth: i32, filename: [*]const u8) void;
    pub extern fn igLogToTTY(auto_open_depth: i32) void;
    pub extern fn igMemAlloc(size: usize) ?*c_void;
    pub extern fn igMemFree(ptr: ?*c_void) void;
    pub extern fn igMenuItemBool(label: [*]const u8, shortcut: [*]const u8, selected: bool, enabled: bool) bool;
    pub extern fn igMenuItemBoolPtr(label: [*]const u8, shortcut: [*]const u8, p_selected: [*c]bool, enabled: bool) bool;
    pub extern fn igNewFrame() void;
    pub extern fn igNewLine() void;
    pub extern fn igNextColumn() void;
    pub extern fn igOpenPopup(str_id: [*]const u8) void;
    pub extern fn igOpenPopupOnItemClick(str_id: [*]const u8, mouse_button: MouseButton) bool;
    pub extern fn igPlotHistogramFloatPtr(label: [*]const u8, values: [*c]const f32, values_count: i32, values_offset: i32, overlay_text: [*]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2, stride: i32) void;
    pub extern fn igPlotHistogramFnPtr(label: [*]const u8, values_getter: ?extern fn (data: ?*c_void, idx: i32) f32, data: ?*c_void, values_count: i32, values_offset: i32, overlay_text: [*]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2) void;
    pub extern fn igPlotLines(label: [*]const u8, values: [*c]const f32, values_count: i32, values_offset: i32, overlay_text: [*]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2, stride: i32) void;
    pub extern fn igPlotLinesFnPtr(label: [*]const u8, values_getter: ?extern fn (data: ?*c_void, idx: i32) f32, data: ?*c_void, values_count: i32, values_offset: i32, overlay_text: [*]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2) void;
    pub extern fn igPopAllowKeyboardFocus() void;
    pub extern fn igPopButtonRepeat() void;
    pub extern fn igPopClipRect() void;
    pub extern fn igPopFont() void;
    pub extern fn igPopID() void;
    pub extern fn igPopItemWidth() void;
    pub extern fn igPopStyleColor(count: i32) void;
    pub extern fn igPopStyleVar(count: i32) void;
    pub extern fn igPopTextWrapPos() void;
    pub extern fn igProgressBar(fraction: f32, size_arg: Vec2, overlay: [*]const u8) void;
    pub extern fn igPushAllowKeyboardFocus(allow_keyboard_focus: bool) void;
    pub extern fn igPushButtonRepeat(repeat: bool) void;
    pub extern fn igPushClipRect(clip_rect_min: Vec2, clip_rect_max: Vec2, intersect_with_current_clip_rect: bool) void;
    pub extern fn igPushFont(font: *Font) void;
    pub extern fn igPushIDStr(str_id: [*]const u8) void;
    pub extern fn igPushIDRange(str_id_begin: [*]const u8, str_id_end: [*]const u8) void;
    pub extern fn igPushIDPtr(ptr_id: ?*const c_void) void;
    pub extern fn igPushIDInt(int_id: i32) void;
    pub extern fn igPushItemWidth(item_width: f32) void;
    pub extern fn igPushStyleColorU32(idx: Col, col: u32) void;
    pub extern fn igPushStyleColorVec4(idx: Col, col: Vec4) void;
    pub extern fn igPushStyleVarFloat(idx: StyleVar, val: f32) void;
    pub extern fn igPushStyleVarVec2(idx: StyleVar, val: Vec2) void;
    pub extern fn igPushTextWrapPos(wrap_local_pos_x: f32) void;
    pub extern fn igRadioButtonBool(label: [*]const u8, active: bool) bool;
    pub extern fn igRadioButtonIntPtr(label: [*]const u8, v: [*c]i32, v_button: i32) bool;
    pub extern fn igRender() void;
    pub extern fn igResetMouseDragDelta(button: MouseButton) void;
    pub extern fn igSameLine(offset_from_start_x: f32, spacing: f32) void;
    pub extern fn igSaveIniSettingsToDisk(ini_filename: [*]const u8) void;
    pub extern fn igSaveIniSettingsToMemory(out_ini_size: *usize) [*]const u8;
    pub extern fn igSelectableBool(label: [*]const u8, selected: bool, flags: SelectableFlags, size: Vec2) bool;
    pub extern fn igSelectableBoolPtr(label: [*]const u8, p_selected: [*c]bool, flags: SelectableFlags, size: Vec2) bool;
    pub extern fn igSeparator() void;
    pub extern fn igSetAllocatorFunctions(alloc_func: ?extern fn (sz: usize, user_data: ?*c_void) ?*c_void, free_func: ?extern fn (ptr: ?*c_void, user_data: ?*c_void) void, user_data: ?*c_void) void;
    pub extern fn igSetClipboardText(text: [*]const u8) void;
    pub extern fn igSetColorEditOptions(flags: ColorEditFlags) void;
    pub extern fn igSetColumnOffset(column_index: i32, offset_x: f32) void;
    pub extern fn igSetColumnWidth(column_index: i32, width: f32) void;
    pub extern fn igSetCurrentContext(ctx: *Context) void;
    pub extern fn igSetCursorPos(local_pos: Vec2) void;
    pub extern fn igSetCursorPosX(local_x: f32) void;
    pub extern fn igSetCursorPosY(local_y: f32) void;
    pub extern fn igSetCursorScreenPos(pos: Vec2) void;
    pub extern fn igSetDragDropPayload(type: [*]const u8, data: ?*const c_void, sz: usize, cond: CondFlags) bool;
    pub extern fn igSetItemAllowOverlap() void;
    pub extern fn igSetItemDefaultFocus() void;
    pub extern fn igSetKeyboardFocusHere(offset: i32) void;
    pub extern fn igSetMouseCursor(cursor_type: MouseCursor) void;
    pub extern fn igSetNextItemOpen(is_open: bool, cond: CondFlags) void;
    pub extern fn igSetNextItemWidth(item_width: f32) void;
    pub extern fn igSetNextWindowBgAlpha(alpha: f32) void;
    pub extern fn igSetNextWindowCollapsed(collapsed: bool, cond: CondFlags) void;
    pub extern fn igSetNextWindowContentSize(size: Vec2) void;
    pub extern fn igSetNextWindowFocus() void;
    pub extern fn igSetNextWindowPos(pos: Vec2, cond: CondFlags, pivot: Vec2) void;
    pub extern fn igSetNextWindowSize(size: Vec2, cond: CondFlags) void;
    pub extern fn igSetNextWindowSizeConstraints(size_min: Vec2, size_max: Vec2, custom_callback: SizeCallback, custom_callback_data: ?*c_void) void;
    pub extern fn igSetScrollFromPosX(local_x: f32, center_x_ratio: f32) void;
    pub extern fn igSetScrollFromPosY(local_y: f32, center_y_ratio: f32) void;
    pub extern fn igSetScrollHereX(center_x_ratio: f32) void;
    pub extern fn igSetScrollHereY(center_y_ratio: f32) void;
    pub extern fn igSetScrollX(scroll_x: f32) void;
    pub extern fn igSetScrollY(scroll_y: f32) void;
    pub extern fn igSetStateStorage(storage: *Storage) void;
    pub extern fn igSetTabItemClosed(tab_or_docked_window_label: [*]const u8) void;
    pub extern fn igSetTooltip(fmt: [*]const u8, ...) void;
    pub extern fn igSetWindowCollapsedBool(collapsed: bool, cond: CondFlags) void;
    pub extern fn igSetWindowCollapsedStr(name: [*]const u8, collapsed: bool, cond: CondFlags) void;
    pub extern fn igSetWindowFocus() void;
    pub extern fn igSetWindowFocusStr(name: [*]const u8) void;
    pub extern fn igSetWindowFontScale(scale: f32) void;
    pub extern fn igSetWindowPosVec2(pos: Vec2, cond: CondFlags) void;
    pub extern fn igSetWindowPosStr(name: [*]const u8, pos: Vec2, cond: CondFlags) void;
    pub extern fn igSetWindowSizeVec2(size: Vec2, cond: CondFlags) void;
    pub extern fn igSetWindowSizeStr(name: [*]const u8, size: Vec2, cond: CondFlags) void;
    pub extern fn igShowAboutWindow(p_open: [*c]bool) void;
    pub extern fn igShowDemoWindow(p_open: [*c]bool) void;
    pub extern fn igShowFontSelector(label: [*]const u8) void;
    pub extern fn igShowMetricsWindow(p_open: [*c]bool) void;
    pub extern fn igShowStyleEditor(ref: *Style) void;
    pub extern fn igShowStyleSelector(label: [*]const u8) bool;
    pub extern fn igShowUserGuide() void;
    pub extern fn igSliderAngle(label: [*]const u8, v_rad: [*c]f32, v_degrees_min: f32, v_degrees_max: f32, format: [*]const u8) bool;
    pub extern fn igSliderFloat(label: [*]const u8, v: [*c]f32, v_min: f32, v_max: f32, format: [*]const u8, power: f32) bool;
    pub extern fn igSliderFloat2(label: [*]const u8, v: *[2]f32, v_min: f32, v_max: f32, format: [*]const u8, power: f32) bool;
    pub extern fn igSliderFloat3(label: [*]const u8, v: *[3]f32, v_min: f32, v_max: f32, format: [*]const u8, power: f32) bool;
    pub extern fn igSliderFloat4(label: [*]const u8, v: *[4]f32, v_min: f32, v_max: f32, format: [*]const u8, power: f32) bool;
    pub extern fn igSliderInt(label: [*]const u8, v: [*c]i32, v_min: i32, v_max: i32, format: [*]const u8) bool;
    pub extern fn igSliderInt2(label: [*]const u8, v: *[2]i32, v_min: i32, v_max: i32, format: [*]const u8) bool;
    pub extern fn igSliderInt3(label: [*]const u8, v: *[3]i32, v_min: i32, v_max: i32, format: [*]const u8) bool;
    pub extern fn igSliderInt4(label: [*]const u8, v: *[4]i32, v_min: i32, v_max: i32, format: [*]const u8) bool;
    pub extern fn igSliderScalar(label: [*]const u8, data_type: DataType, p_data: ?*c_void, p_min: ?*const c_void, p_max: ?*const c_void, format: [*]const u8, power: f32) bool;
    pub extern fn igSliderScalarN(label: [*]const u8, data_type: DataType, p_data: ?*c_void, components: i32, p_min: ?*const c_void, p_max: ?*const c_void, format: [*]const u8, power: f32) bool;
    pub extern fn igSmallButton(label: [*]const u8) bool;
    pub extern fn igSpacing() void;
    pub extern fn igStyleColorsClassic(dst: *Style) void;
    pub extern fn igStyleColorsDark(dst: *Style) void;
    pub extern fn igStyleColorsLight(dst: *Style) void;
    pub extern fn igText(fmt: [*]const u8, ...) void;
    pub extern fn igTextColored(col: Vec4, fmt: [*]const u8, ...) void;
    pub extern fn igTextDisabled(fmt: [*]const u8, ...) void;
    pub extern fn igTextUnformatted(text: [*]const u8, text_end: [*]const u8) void;
    pub extern fn igTextWrapped(fmt: [*]const u8, ...) void;
    pub extern fn igTreeNodeStr(label: [*]const u8) bool;
    pub extern fn igTreeNodeStrStr(str_id: [*]const u8, fmt: [*]const u8, ...) bool;
    pub extern fn igTreeNodePtr(ptr_id: ?*const c_void, fmt: [*]const u8, ...) bool;
    pub extern fn igTreeNodeExStr(label: [*]const u8, flags: TreeNodeFlags) bool;
    pub extern fn igTreeNodeExStrStr(str_id: [*]const u8, flags: TreeNodeFlags, fmt: [*]const u8, ...) bool;
    pub extern fn igTreeNodeExPtr(ptr_id: ?*const c_void, flags: TreeNodeFlags, fmt: [*]const u8, ...) bool;
    pub extern fn igTreePop() void;
    pub extern fn igTreePushStr(str_id: [*]const u8) void;
    pub extern fn igTreePushPtr(ptr_id: ?*const c_void) void;
    pub extern fn igUnindent(indent_w: f32) void;
    pub extern fn igVSliderFloat(label: [*]const u8, size: Vec2, v: [*c]f32, v_min: f32, v_max: f32, format: [*]const u8, power: f32) bool;
    pub extern fn igVSliderInt(label: [*]const u8, size: Vec2, v: [*c]i32, v_min: i32, v_max: i32, format: [*]const u8) bool;
    pub extern fn igVSliderScalar(label: [*]const u8, size: Vec2, data_type: DataType, p_data: ?*c_void, p_min: ?*const c_void, p_max: ?*const c_void, format: [*]const u8, power: f32) bool;
    pub extern fn igValueBool(prefix: [*]const u8, b: bool) void;
    pub extern fn igValueInt(prefix: [*]const u8, v: i32) void;
    pub extern fn igValueUint(prefix: [*]const u8, v: u32) void;
    pub extern fn igValueFloat(prefix: [*]const u8, v: f32, float_format: [*]const u8) void;
};
