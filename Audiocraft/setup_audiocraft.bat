@echo off
rem for using !variable! which expand its value at runtime
setlocal enabledelayedexpansion

rem Get current directory
set "ENV_DIR=%CD%\audiocraft_env"
set "REPO_DIR=%CD%\audiocraft_repo"

rem Check Miniconda
echo Checking for Conda...
where conda >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Conda not found.
    echo Please install Miniconda from:
    echo https://docs.conda.io/en/latest/miniconda.html
    pause
    exit /b 1
)
echo [OK] Conda is installed.

rem Check for CUDA 11.8 (basic check)
echo.
echo Checking for CUDA 11.8 Toolkit...
set "cuda_path=%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v11.8"
if exist "%cuda_path%" (
    echo [OK] CUDA 11.8 appears to be installed at: %cuda_path%
) else (
    echo [WARNING] CUDA 11.8 not found in default path: %cuda_path%
    echo Make sure it is installed and added to PATH if you're using GPU acceleration.
)

rem Create conda environment
echo. 
echo Checking conda environment...
if exist "%ENV_DIR%" (
	call :askUser "Remove the exist environment and create a new one?"
	if /i "!choice!"=="y" (
		rmdir /s /q "%ENV_DIR%"
		call conda env create --prefix "%ENV_DIR%" -f environment.yml
		if errorlevel 1 (
			echo [ERROR] Failed to create conda environment.
			pause
			exit /b 1
		)
	)
) else (
    call conda env create --prefix "%ENV_DIR%" -f environment.yml
    if errorlevel 1 (
        echo [ERROR] Failed to create conda environment.
        pause
        exit /b 1
    )
)

rem Activate env
echo Activating environment...
call conda activate "%ENV_DIR%"
echo [OK] Conda environment has been activated.

rem Clone repo of Audiocraft
echo.
if exist "%REPO_DIR%" (
	call :askUser "Remove the exist audiocraft_repo and clone a new one?"
	if /i "!choice!"=="y" (
		rmdir /s /q "%REPO_DIR%"
		call git clone https://github.com/facebookresearch/audiocraft.git audiocraft_repo
	)
) else (
    call git clone https://github.com/facebookresearch/audiocraft.git audiocraft_repo
)
cd audiocraft_repo

::rem Pip install
echo.
echo Installing required packages: PyTorch (CUDA 11.8 version), audiocraft editable packages, pydantic-2.10.6, xformers-0.0.22.post4
python -m pip install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu118
python -m pip install -e .
python -m pip install pydantic==2.10.6
python -m pip install xformers==0.0.22.post4 --index-url https://download.pytorch.org/whl/cu118

echo.
echo Setup complete. Run run_audiocraft.bat for local demo with gradio.
pause
goto :eof


:askUser
:: %1 = prompt text, %2 = return var
set "response="
:promptLoop
set /p response=%~1 (y/n): 
if /i "%response%"=="y" (
    set choice=y
    goto :eof
) else if /i "%response%"=="n" (
    set choice=n
    goto :eof
) else (
    echo Invalid input. Please type y or n.
    goto promptLoop
)