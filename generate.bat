@echo off

git submodule update --init --recursive

:LUA_GENERATE
	where gcc || goto NO_GCC
	where luajit || goto NO_LUAJIT

	pushd "%~dp0\cimgui\generator"
	del ..\..\cimgui.cpp
	del ..\..\cimgui.h
	luajit .\generator.lua "gcc" ""
	copy ..\cimgui.cpp ..\..\zig-imgui\cimgui.cpp
	copy ..\cimgui.h ..\..\zig-imgui\cimgui.h
	popd

	goto PYTHON_GENERATE

:NO_LUAJIT
	echo Couldn't find LuaJIT, make sure it is installed and on your path.
	exit /b 1

:NO_GCC
	echo Couldn't find gcc, make sure it is installed and on your path.
	exit /b 1

:NO_BUILD
	:: build_lib.bat prints the specific error that prevented the build
	echo Skipping library build.
	goto PYTHON_GENERATE

:PYTHON_GENERATE
	where python || goto NO_PYTHON
	python "%~dp0\generate.py"
	goto CLEANUP

:CLEANUP
	pushd "%~dp0\cimgui"
	git restore .
	del generator\preprocesed.h
	popd
	goto DONE

:NO_PYTHON
	echo Couldn't find python, make sure it is installed and on your path.
	goto DONE

:DONE
	exit /b 0

