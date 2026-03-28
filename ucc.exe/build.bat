REM ucc -o usecode usecode.uc

@echo off
cls
echo Compiling usecode.uc...
cd /d "%~dp0"
ucc -o usecode usecode.uc

if %ERRORLEVEL% EQU 0 (
    echo Compilation successful! Updating Usecode in Game Directory.
    copy usecode .\patch\usecode
) else (
    echo Compilation failed. Exit code: %ERRORLEVEL%
)