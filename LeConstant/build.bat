@echo off
setlocal EnableDelayedExpansion

:: ==============================================================================
:: 
::      Build.bat
::
::      Build different configuration of the app
::
:: ==============================================================================
::   arsccriptum - made in quebec 2020 <guillaumeplante.qc@gmail.com>
:: ==============================================================================

goto :init

:init
    set "__scripts_root=%AutomationScriptsRoot%"
    call :read_script_root development\build-automation  BuildAutomation
    set "__script_file=%~0"
    set "__target=%~1"
    set "__script_path=%~dp0"
    set "__makefile=%__scripts_root%\make\make.bat"
    set "__lib_date=%__scripts_root%\batlibs\date.bat"
    set "__lib_out=%__scripts_root%\batlibs\out.bat"
    ::*** This is the important line ***
   
    set "__build_cancelled=0"
    goto :validate


:header
    echo. %__script_name% v%__script_version%
    echo.    This script is part of codecastor build wrappers.
    echo.
    goto :eof

:header_err
    echo.**************************************************
    echo.This script is part of codecastor build wrappers.
    echo.**************************************************
    echo.
    echo. YOU NEED TO HAVE THE BuildAutomation Scripts setup on you system...
    echo. https://github.com/codecastor/BuildAutomation
    goto :eof


:read_script_root
    set regpath=%OrganizationHKCU::=%
    for /f "tokens=2,*" %%A in ('REG.exe query %regpath%\%1 /v %2') do (
            set "__scripts_root=%%B"
        )
    goto :eof

:validate
    if not defined __scripts_root          call :header_err && call :error_missing_path __scripts_root & goto :eof
    if not exist %__makefile%  call :error_missing_script "%__makefile%" & goto :eof
    if not exist %__lib_date%  call :error_missing_script "%__lib_date%" & goto :eof
    if not exist %__lib_out%  call :error_missing_script "%__lib_out%" & goto :eof

    goto :prebuild_config


:prebuild_config
	if not exist "%VS140COMNTOOLS%" (
	 call :show_error "ERROR Environment variable VS140COMNTOOLS set to invalid path" 
	)
	pushd %VS140COMNTOOLS%
	call %__lib_out% :__out_underline_red "Configuration Visual Studio 14.0 environment"
	call %__lib_out% :__out_n_l_gry " [*] VsMSBuildCmd.bat"
	call VsMSBuildCmd.bat
	call %__lib_out% :__out_d_grn " SUCCESS"
	call %__lib_out% :__out_n_l_gry " [*] VsDevCmd.bat"
	call VsDevCmd.bat
	call %__lib_out% :__out_d_grn " SUCCESS"
	call %__lib_out% :__out_n_l_gry " [*] Current Visual Studio Version: "
	call %__lib_out% :__out_d_grn "%VisualStudioVersion%"
	popd
	goto :build





:protek
	set CURRENT_BIN=%cd%\bin
	call %__lib_out% :__out_underline_cya "STEP 2) ENCRYPTION"
	call %__lib_out% :__out_n_l_gry "    bin/GetSystem.exe => bin/GetSystem_p.exe"
	"%AXPROTECTOR_SDK%\bin\AxProtector.exe" -x -kcm -f6000010 -p101001 -cf0 -d:6.20 -fw:3.00 -slw -nn -cav -cas100 -wu1000 -we100 -eac -eec -eusc1 -emc -v -cag23 -caa7 -o:"%CURRENT_BIN%\GetSystem_p.exe" "%CURRENT_BIN%\GetSystem.exe" > NUL
	call %__lib_out% :__out_d_grn " SUCCESS"
	goto :eof

:clean
	rmdir /s /q bin

:build
	if not exist bin ( mkdir bin )
	call %__lib_out% :__out_underline_mag "STEP 1) COMPILATION"
	call %__lib_out% :__out_n_l_gry "    building main.cpp => bin/GetSystem.exe..."
	cl src\main.cpp /Fe:bin\GetSystem.exe  2> NUL > NUL
	call %__lib_out% :__out_d_grn " SUCCESS"
	call :protek
	del /F /Q *.obj
	goto :finished


:show_error
	set ERROR_STRING="%~1"
	echo [31m%ERROR_STRING%[0m
	goto :eof





:error_missing_script
    echo.
    echo    Error
    echo    Missing bat script: %~1
    echo.
    goto :eof



:finished
    call %__lib_out% :__out_d_grn "Build complete"
    goto :eof

