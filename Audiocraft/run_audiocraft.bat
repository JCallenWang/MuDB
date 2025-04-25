@echo off
setlocal enabledelayedexpansion

:: Get current directory
set "ENV_DIR=%CD%\audiocraft_env"

::Activate env
echo Activating environment...
call conda activate "%ENV_DIR%"

echo start...
cd audiocraft_repo
python -m demos.musicgen_app
pause
