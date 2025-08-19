@echo off
setlocal enabledelayedexpansion

:: --- Step 1: Check if nvcc exists ---
where nvcc >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] CUDA not found on system.
    set cuda_version=0.0
) else (
    for /f "tokens=2 delims=," %%a in ('nvcc --version ^| findstr /i "release"') do (
        for /f "tokens=2 delims= " %%b in ("%%a") do (
            set "cuda_version=%%b"
        )
    )
)

echo [INFO] Detected CUDA version: %cuda_version%

:: --- Step 2: Compare with 13.0 ---
set required_version=13.0
if "%cuda_version%"=="%required_version%" (
    echo [INFO] CUDA version %cuda_version% is already installed.
    goto :eof
)

:: If version is less than 13.0, install new one
for /f "tokens=1,2 delims=." %%x in ("%cuda_version%") do (
    set major=%%x
    set minor=%%y
)

if not defined major set major=0
if not defined minor set minor=0

if %major% gtr 13 (
    echo [INFO] CUDA version %cuda_version% is newer than 13.0. Skipping install.
    goto :eof
)

if %major%==13 if %minor% geq 0 (
    echo [INFO] CUDA version %cuda_version% is already >= 13.0.
    goto :eof
)
:: run directly without installation if cuda.exe is found

:: --- Step 3: Download & Install CUDA 13.0 ---
set installer=cuda.exe
set url=https://developer.download.nvidia.com/compute/cuda/13.0.0/local_installers/cuda_13.0.0_windows.exe

if exist "%installer%" (
    echo [INFO] Installer already exists: %installer%
) else (
    echo [INFO] Downloading CUDA 13.0 installer...
    curl -L -o "%installer%" --progress-bar "%url%"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to download installer.
        exit /b 1
    )
)

echo [INFO] Running installer...
start /wait "" "%installer%"

echo [INFO] CUDA 13.0 installation finished.
