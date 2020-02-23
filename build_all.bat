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
	where cl || goto BUILD_NO_CL

	rd /S /Q "%~dp0\cimgui\build\"
	mkdir "%~dp0\cimgui\build"

	:: manual cl build
	::mkdir "%~dp0\cimgui\build\obj"
	::pushd "%~dp0\cimgui"
	::cl /I. /Iimgui /c /MTd /Od /RTC1 /DDEBUG /Zi /Fobuild\obj\cimguid.obj /Fdbuild\cimguid.pdb build_cl.cpp
	::lib /OUT:build\cimguid.lib build\obj\cimguid.obj
	::cl /I. /Iimgui /c /MT /O2 /Fobuild\obj\cimgui.obj build_cl.cpp
	::lib /OUT:build\cimgui.lib build\obj\cimgui.obj
	::popd
	::rd /S /Q "%~dp0\lib\win"
	::mkdir "%~dp0\lib\win"
	::copy /B /Y "%~dp0\cimgui\build\cimguid.pdb" "%~dp0\lib\win\cimguid.pdb"
	::copy /B /Y "%~dp0\cimgui\build\cimguid.lib" "%~dp0\lib\win\cimguid.lib"
	::copy /B /Y "%~dp0\cimgui\build\cimgui.lib" "%~dp0\lib\win\cimgui.lib"

	:: mingw cmake build
	::pushd "%~dp0\cimgui\build"
	::cmake -G "MinGW Makefiles" .. -DIMGUI_STATIC:STRING=yes
	::cmake --build .
	::popd
	::rd /S /Q "%~dp0\lib\win"
	::mkdir "%~dp0\lib\win"
	::copy /B /Y "%~dp0\cimgui\build\cimgui.lib" "%~dp0\lib\win\cimgui.lib"

	:: MSVC cmake build
	pushd "%~dp0\cimgui\build"
	cmake .. -DIMGUI_STATIC:STRING=yes
	cmake --build . --config Debug
	cmake --build . --config Release
	popd
	rd /S /Q "%~dp0\lib\win"
	mkdir "%~dp0\lib\win"
	copy /B /Y "%~dp0\cimgui\build\Debug\cimgui.pdb" "%~dp0\lib\win\cimguid.pdb"
	copy /B /Y "%~dp0\cimgui\build\Debug\cimgui.lib" "%~dp0\lib\win\cimguid.lib"
	copy /B /Y "%~dp0\cimgui\build\Release\cimgui.lib" "%~dp0\lib\win\cimgui.lib"

	goto PYTHON_GENERATE

:BUILD_NO_CL
	echo "Couldn't find cl to build libraries."
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
