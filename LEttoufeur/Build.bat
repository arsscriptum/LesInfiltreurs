@echo off
setlocal EnableDelayedExpansion

:: ==============================================================================
:: 
::      Build.bat
::
::      Build different configuration of the app
::
:: ==============================================================================
::   cybercastor - made in quebec 2020 <guillaumeplante.qc@gmail.com>
:: ==============================================================================

goto :init

:init
    set "__script_file=%~0"
    set "__script_path=%~dp0"
    set "__makefile=%__script_path%scripts\make\make.bat"
    set "__lib_out=%__script_path%scripts\batlibs\out.bat"
    set "__lib_out=%__script_path%scripts\batlibs\out.bat"
    ::*** This is the important line ***
    set "__build_cfg=%__script_path%buildcfg.ini"
    set "__build_cancelled=0"
    goto :build

:: ==============================================================================
::   call make
:: ==============================================================================
:call_make_build
    set config=%1
    set platform=%2
    call %__makefile% /v /i %__build_cfg% /t Build /c %config% /p %platform%
    goto :finished

:: ==============================================================================
::   Build static
:: ==============================================================================
:build_x86
    call :call_make_build Debug x86
    call :call_make_build Release x86

    goto :eof

:: ==============================================================================
::   Build dll
:: ==============================================================================
:build_x64
    call :call_make_build Debug x64
    call :call_make_build Release x64
    goto :eof

:: ==============================================================================
::   Build dll
:: ==============================================================================
:build
  
    call :build_x86
    call :build_x64
    goto :finished

:finished
    call %__lib_out% :__out_d_grn "*   *   *   *   *   build complete   *   *   *   *   *"
