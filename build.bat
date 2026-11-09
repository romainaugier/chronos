@echo off

rem SPDX-License-Identifier: BSD-3-Clause 
rem Copyright (c) 2026 - Present Romain Augier
rem All rights reserved. 

rem Little utility batch script to build the library

call :LogInfo "Building chronos"

set BUILDTYPE=Release
set RUNTESTS=0
set REMOVEOLDDIR=0
set ARCH=x64
if /i "%PROCESSOR_ARCHITECTURE%" equ "ARM64" set ARCH=ARM64
set VERSION=0.0.0
set INSTALL=0
set INSTALLDIR=%CD%\install
set ADDRSAN=0
set REBUILDSTDROMANO=0
set VCPKGPATH=
set STDROMANO_DIR=%CD%\ext\stdromano

for %%x in (%*) do (
    call :ParseArg %%~x
)

if %REMOVEOLDDIR% equ 1 (
    if exist build (
        call :LogInfo "Removing old build directory"
        rmdir /s /q build
    )
    if exist bin (
        call :LogInfo "Removing old bin directory"
        rmdir /s /q bin
    )
    if exist lib (
        call :LogInfo "Removing old lib directory"
        rmdir /s /q lib
    )
    if exist %INSTALLDIR% (
        call :LogInfo "Removing old install directory"
        rmdir /s /q %INSTALLDIR%
    )
)

call :LogInfo "Build type: %BUILDTYPE%"
call :LogInfo "Build version: %VERSION%"
call :LogInfo "Build architecture: %ARCH%"

call :BuildStdromano

if %errorlevel% neq 0 (
    call :LogError "Error caught during the stdromano build"
    exit /B 1
)

cmake -S . -B build -A %ARCH% -DRUN_TESTS=%RUNTESTS% -DVERSION=%VERSION% -DADDRSAN=%ADDRSAN%

if %errorlevel% neq 0 (
    call :LogError "Error caught during CMake configuration"
    exit /B 1
)

cd build
cmake --build . --config %BUILDTYPE% -j %NUMBER_OF_PROCESSORS%

if %errorlevel% neq 0 (
    call :LogError "Error caught during CMake compilation"
    cd ..
    exit /B 1
)

rem Inside a parenthesized block %errorlevel% is expanded when the block is parsed, use "if errorlevel"
if %RUNTESTS% equ 1 (
    ctest --output-on-failure -C %BUILDTYPE%

    if errorlevel 1 (
        call :LogError "Error caught during CMake testing"
        type Testing\Temporary\LastTest.log

        cd ..
        exit /B 1
    )
)

if %INSTALL% equ 1 (
    cmake --install . --config %BUILDTYPE% --prefix "%INSTALLDIR%"

    if errorlevel 1 (
        call :LogError "Error caught during CMake installation"
        cd ..
        exit /B 1
    )
)

cd ..

exit /B 0

rem //////////////////////////////////
rem Little function to process args
:ParseArg

if "%~1" equ "--debug" set BUILDTYPE=Debug

if "%~1" equ "--reldebug" set BUILDTYPE=RelWithDebInfo

if "%~1" equ "--tests" set RUNTESTS=1

if "%~1" equ "--clean" set REMOVEOLDDIR=1

if "%~1" equ "--install" set INSTALL=1

if "%~1" equ "--addrsan" set ADDRSAN=1

if /i "%~1" equ "--arch:x64" set ARCH=x64

if /i "%~1" equ "--arch:arm64" set ARCH=ARM64

if "%~1" equ "--rebuild-stdromano" set REBUILDSTDROMANO=1

if "%~1" equ "--export-compile-commands" (
    call :LogWarning "Exporting compile commands is not supported on Windows for now"
)

echo "%~1" | find /I "version">nul && (
    call :ParseVersion %~1
)

echo "%~1" | find /I "installdir">nul && (
    call :ParseInstallDir %~1
)

echo "%~1" | find /I "vcpkgpath">nul && (
    call :ParseVcpkgPath %~1
)

exit /B 0
rem //////////////////////////////////

rem //////////////////////////////////
rem Little function to parse the version from the command line arg (ex: --version:0.1.3)
:ParseVersion

for /f "tokens=2 delims=:" %%a in ("%~1") do (
    set VERSION=%%a
    call :LogInfo "Version specified by the user: %%a"
)

exit /B 0
rem //////////////////////////////////

rem //////////////////////////////////
rem Little function to parse the install dir from the command line 
:ParseInstallDir

for /f "tokens=1* delims=:" %%a in ("%~1") do (
    set INSTALLDIR=%%b
    call :LogInfo "Install directory specified by the user: %%b"
)

exit /B 0
rem //////////////////////////////////

rem //////////////////////////////////
rem Little function to parse the vcpkg path from the command line, forwarded to the stdromano build
:ParseVcpkgPath

for /f "tokens=1* delims=:" %%a in ("%~1") do (
    set VCPKGPATH=%%b
    call :LogInfo "Vcpkg path specified by the user: %%b"
)

exit /B 0
rem //////////////////////////////////

rem //////////////////////////////////
rem stdromano is built with the same build type, architecture and sanitizers as chronos, and installed
rem in ext\stdromano\install. A stamp per variant (debug/release) records the flags of the install
:BuildStdromano

if not exist "%STDROMANO_DIR%\build.bat" (
    call :LogError "ext\stdromano is empty, run: git submodule update --init --recursive"
    exit /B 1
)

set STDROMANO_VARIANT=release
set STDROMANO_FLAGS=--arch:%ARCH%

if "%BUILDTYPE%" equ "Debug" set STDROMANO_VARIANT=debug
if "%BUILDTYPE%" equ "Debug" set STDROMANO_FLAGS=%STDROMANO_FLAGS% --debug
if "%BUILDTYPE%" equ "RelWithDebInfo" set STDROMANO_FLAGS=%STDROMANO_FLAGS% --reldebug
if %ADDRSAN% equ 1 set STDROMANO_FLAGS=%STDROMANO_FLAGS% --addrsan

set STDROMANO_STAMP=%STDROMANO_DIR%\install\chronos_%STDROMANO_VARIANT%.stamp
set STDROMANO_INSTALLED_FLAGS=

if exist "%STDROMANO_STAMP%" set /p STDROMANO_INSTALLED_FLAGS=<"%STDROMANO_STAMP%"

if %REBUILDSTDROMANO% equ 0 if "%STDROMANO_INSTALLED_FLAGS%" equ "%STDROMANO_FLAGS%" (
    call :LogInfo "stdromano (%STDROMANO_VARIANT%) is up to date"
    exit /B 0
)

call :LogInfo "Building stdromano (%STDROMANO_FLAGS%)"

set STDROMANO_VCPKG_FLAG=
if defined VCPKGPATH set STDROMANO_VCPKG_FLAG=--vcpkgpath:%VCPKGPATH%

pushd "%STDROMANO_DIR%"
call build.bat --install %STDROMANO_FLAGS% %STDROMANO_VCPKG_FLAG%
set STDROMANO_ERROR=%errorlevel%
popd

if %STDROMANO_ERROR% neq 0 exit /B 1

>"%STDROMANO_STAMP%" echo %STDROMANO_FLAGS%

exit /B 0
rem //////////////////////////////////

rem //////////////////////////////////
rem Little function to check for errors
:CheckErrors

if %errorlevel% neq 0 (
    echo %~1
    exit /B 1
)

exit /B 0
rem //////////////////////////////////

rem //////////////////////////////////
rem Little function to log errors
:LogError

echo [ERROR] : %~1

exit /B 0
rem //////////////////////////////////

rem //////////////////////////////////
rem Little function to log warnings 
:LogWarning

echo [WARNING] : %~1

exit /B 0
rem //////////////////////////////////

rem //////////////////////////////////
rem Little function to log infos 
:LogInfo

echo [INFO] : %~1

exit /B 0
rem //////////////////////////////////
