@echo off

pushd "%~dp0"
git submodule update --init --recursive
popd

where gcc || goto NO_GCC
where luajit || goto NO_LUAJIT
where python || goto NO_PYTHON

:LUA_GENERATE
	@echo Generating C Bindings...
	pushd "%~dp0\cimgui\generator"
	del ..\..\zig-imgui\cimgui.cpp
	del ..\..\zig-imgui\cimgui.h
	luajit .\generator.lua "gcc" ""
	copy ..\cimgui.cpp ..\..\zig-imgui\cimgui.cpp >nul
	copy ..\cimgui.h ..\..\zig-imgui\cimgui.h >nul
	popd

:PYTHON_GENERATE
	@echo Generating Zig Bindings...
	python "%~dp0\generate.py"

:VENDOR_IMGUI
	pushd "%~dp0"
	rd /S /Q zig-imgui\imgui
	mkdir zig-imgui\imgui
	@for %%F in (cimgui\imgui\*.h) do copy %%F zig-imgui\imgui\ >nul
	@for %%F in (cimgui\imgui\*.cpp) do copy %%F zig-imgui\imgui\ >nul
	copy cimgui\imgui\LICENSE.txt zig-imgui\imgui\ >nul
	popd

	pushd "%~dp0\cimgui\imgui"
	git rev-parse HEAD > ..\..\zig-imgui\imgui\VERSION.txt
	popd

:CLEANUP
	@echo Cleaning up...
	pushd "%~dp0\cimgui"
	git restore .
	del generator\preprocesed.h
	popd

:DONE
	@echo Done
	exit /b 0

:NO_LUAJIT
	echo Couldn't find LuaJIT, make sure it is installed and on your path.
	exit /b 1

:NO_GCC
	echo Couldn't find gcc, make sure it is installed and on your path.
	exit /b 1

:NO_PYTHON
	echo Couldn't find python, make sure it is installed and on your path.
	exit /b 1
