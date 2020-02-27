rem @echo off

:LUA_GENERATE
	where luajit || goto NO_LUAJIT
	where g++ || goto GENERATE_NO_GPP

	pushd "%~dp0\cimgui\generator"
	luajit .\generator.lua g++
	popd

	goto AFTER_LUA_GENERATE


:GENERATE_NO_GPP
	echo "Couldn't find g++, make sure MinGW is installed and on your path."
	echo "Trying to generate with CL instead."
	where cl || goto GENERATE_NO_CL

	pushd "%~dp0\cimgui\generator"
	luajit .\generator.lua cl
	popd
	goto AFTER_LUA_GENERATE

:GENERATE_NO_CL
	echo "Couldn't find cl either."
	echo "Skipping cimgui.cpp generation, using repo data."
	goto AFTER_LUA_GENERATE

:NO_LUAJIT
	echo "Couldn't find LuaJIT, make sure it is installed and on your path."
	echo "Skipping cimgui.cpp generation, using repo data."
	goto AFTER_LUA_GENERATE

:AFTER_LUA_GENERATE
	call "%~dp0\build_lib.bat" || goto NO_BUILD
	goto PYTHON_GENERATE

:NO_BUILD
	:: build_lib.bat prints the specific error that prevented the build
	echo "Skipping library build."
	goto PYTHON_GENERATE

:PYTHON_GENERATE
	where python || goto NO_PYTHON
	"%~dp0\generate.py"
	goto DONE

:NO_PYTHON
	echo "Couldn't find python, make sure it is installed and on your path."
	goto DONE

:DONE
	exit /b 0
