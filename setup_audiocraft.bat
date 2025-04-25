@echo off
setlocal enabledelayedexpansion

rem Get current directory
set "ENV_DIR=%CD%\audiocraft_env"

rem Check Miniconda
echo Checking for Conda...
where conda >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Conda not found.
    echo Please install Miniconda from:
    echo https://docs.conda.io/en/latest/miniconda.html
    pause
    exit /b 1
)
echo [OK] Conda is installed.

rem echo.
rem call :askUser "Install CUDA (11.8)?" choice
rem if /i "%choice%"=="n" goto :eof

rem Check for CUDA 11.8 (basic check)
echo.
echo Checking for CUDA 11.8 Toolkit...
set "cuda_path=%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v11.8"
if exist "%cuda_path%" (
    echo [OK] CUDA 11.8 appears to be installed at: %cuda_path%
) ELSE (
    echo [WARNING] CUDA 11.8 not found in default path: %cuda_path%
    echo Make sure it is installed and added to PATH if you're using GPU acceleration.
)

rem echo.
rem call :askUser "Create conda environment?" choice
rem if /i "%choice%"=="n" goto :eof

rem Create conda environment
echo.
echo Checking conda environment...
if exist "%ENV_DIR%" (
	echo found exist environment at "%ENV_DIR%"
	call :askUser "Remove the environment?" choice
	if /i "%choice%"=="y" (
		rmdir /s /q "%ENV_DIR%"
		echo.
		pause
		
		echo Creating conda environment from environment.yml in current directory...
		conda env create --prefix "%ENV_DIR%" -f environment.yml
		if %ERRORLEVEL% NEQ 0 (
			echo [ERROR] Failed to create conda environment.
			pause
			exit /b 1
		)
	)
) else (
	echo No existing environment found, creating new one...
    conda env create --prefix "%ENV_DIR%" -f environment.yml
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Failed to create conda environment.
        pause
        exit /b 1
    )
)


::rem echo.
::rem call :askUser "Activate conda environment?" choice
::rem if /i "%choice%"=="n" goto :eof
::
::rem Activate env
::echo.
::echo Activating environment...
::call conda activate "%ENV_DIR%"
::
::rem echo.
::rem call :askUser "Cloning Audiocraft repository?" choice
::rem if /i "%choice%"=="n" goto :eof
::
::rem Clone repo of Audiocraft
::echo.
::if exist audiocraft_repo (
::	echo fouund exist audiocraft_repo
::	call :askUser "Remove the audiocraft_repo?" choice
::	if /i "%choice%"=="y" (
::		rmdir /s /q audiocraft_repo
::		echo Cloning repository...
::		call git clone https://github.com/facebookresearch/audiocraft.git audiocraft_repo
::	)
::)
::cd audiocraft_repo
::
::rem echo.
::rem call :askUser "Install packages?" choice
::rem if /i "%choice%"=="n" goto :eof
::
::rem Pip install
::echo.
::echo Installing PyTorch (CUDA 11.8 version)...
::python -m pip install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu118
::echo.
::echo Installing local editable package...
::python -m pip install -e .
::echo.
::echo Installing pydantic...
::python -m pip install pydantic==2.10.6
::echo.
::echo Installing xformers...
::python -m pip install xformers==0.0.22.post4 --index-url https://download.pytorch.org/whl/cu118

echo.
echo Setup complete.
pause
goto :eof


:askUser
:: %1 = prompt text, %2 = return var
set "response="
:promptLoop
set /p response=%~1 (y/n): 
if /i "%response%"=="y" (
    set "%~2=y"
    goto :eof
) else if /i "%response%"=="n" (
    set "%~2=n"
    goto :eof
) else (
    echo Invalid input. Please type y or n.
    goto promptLoop
)