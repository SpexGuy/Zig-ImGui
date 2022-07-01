@echo off

git submodule update --init --recursive

where gcc || goto NO_GCC
where luajit || goto NO_LUAJIT
where python || goto NO_PYTHON

:LUA_GENERATE
	pushd "%~dp0\cimgui\generator"
	del ..\..\cimgui.cpp
	del ..\..\cimgui.h
	luajit .\generator.lua "gcc" ""
	copy ..\cimgui.cpp ..\..\zig-imgui\cimgui.cpp
	copy ..\cimgui.h ..\..\zig-imgui\cimgui.h
	popd

:PYTHON_GENERATE
	python "%~dp0\generate.py"

:CLEANUP
	pushd "%~dp0\cimgui"
	git restore .
	del generator\preprocesed.h
	popd

:DONE
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
