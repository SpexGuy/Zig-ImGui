# Zig-ImGui

Zig-ImGui uses [cimgui](https://github.com/cimgui/cimgui) to generate [Zig](https://github.com/ziglang/zig) bindings for [Dear ImGui](https://github.com/ocornut/imgui).

It is currently up to date with [Dear ImGui v1.88](https://github.com/ocornut/imgui/tree/v1.88).

## Using the pre-generated bindings

Zig-ImGui strives to be easy to use.  To use the pre-generated bindings, do the following:

- Copy the zig-imgui directory into your project
- In your build.zig, do the following:
    ```zig
    const imgui_build = @import("path/to/zig-imgui/imgui_build.zig");
    imgui_build.link(exe_that_needs_imgui);
    ```
- If you would like to run basic tests on the bindings in your project, add this to build.zig:
    ```zig
    imgui_build.addTestStep(b, "imgui:test", mode, target);
    ```
    and then run `zig build imgui:test`
- If you need to use zig-imgui as a dependency of another package, use `imgui_build.pkg` as the dependency.  Be sure to call `imgui_build.link` or `imgui_build.linkWithoutPackage` on any executable or test which uses this dependency.
- In your project, use `@import("imgui")` to obtain the bindings.
- See the examples in `example/` for basic usage examples.
- For more detailed documentation, see the [official ImGui documentation](https://github.com/ocornut/imgui/tree/v1.88/docs).
- For an example of a real project using these bindings, see [SpexGuy/Zig-Gltf-Display](https://github.com/SpexGuy/Zig-Gltf-Display).

## Binding style

These bindings generally prefer the original ImGui naming styles over Zig style.  Functions, types, and fields match the casing of the original.  Prefixes like ImGui* or Im* have been stripped.  Enum names as prefixes to enum values have also been stripped.

"Flags" enums have been translated to packed structs of bools, with helper functions for performing bit operations.  ImGuiCond specifically has been translated to CondFlags to match the naming style of other flag enums.

Const reference parameters have been translated to by-value parameters, which the Zig compiler will implement as by-const-reference with extra restrictions.  Mutable reference parameters have been converted to pointers.

Functions with default values have two generated variants.  The original name maps to the "simple" version with all defaults set.  Adding "Ext" to the end of the function will produce the more complex version with all available parameters.

Functions with multiple overloads have a postfix appended based on the first difference in parameter types.

For example, these two C++ functions generate four Zig functions:
```c++
void ImGui::SetWindowCollapsed(char const *name, bool collapsed, ImGuiCond cond = 0);
void ImGui::SetWindowCollapsed(bool collapsed, ImGuiCond cond = 0);
```
```zig
fn SetWindowCollapsed_Str(name: ?[*:0]const u8, collapsed: bool) void;
fn SetWindowCollapsed_StrExt(name: ?[*:0]const u8, collapsed: bool, cond: CondFlags) void;
fn SetWindowCollapsed_Bool(collapsed: bool) void;
fn SetWindowCollapsed_BoolExt(collapsed: bool, cond: CondFlags) void;
```

Nullability and array-ness of pointer parameters is hand-tuned by the logic in pointer_rules.py.  If you find any incorrect translations, please open an issue.

## Running the examples

This project also contains some example backends in the examples/ folder, which have been ported to Zig. You may want to vendor the `impl` files into your project for a quick start. To run the examples in-place, use
- `zig build example_glfw_opengl3`
- `zig build example_glfw_vulkan`

See build.zig for more information on how the examples are built.

## Generating new bindings

To use a different version of Dear ImGui, new bindings need to be generated.
You will need to do some setup for this:

- Download and install luajit, and add it to your path
- Download and install gcc, through mingw or other means, and add it to your path
- Download and install Python 3, and add it to your path

Once you are set up, run `generate.bat` to attempt to generate the bindings.

NOTE: `generate.bat` will revert any local changes in the cimgui submodule, so don't run it if you have any.

Some changes to Dear ImGui may require more in-depth changes to generate correct bindings.
You may need to check for updates to upstream cimgui, or add rules to pointer_rules.py.

You can do a quick check of the integrity of the bindings with `zig build test`.  This will verify that the version of Dear ImGui matches the bindings, and compile all wrapper functions in the bindings.
