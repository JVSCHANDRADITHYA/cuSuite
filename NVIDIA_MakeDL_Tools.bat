@echo off
setlocal EnableDelayedExpansion

:: ============================================================
:: CI GUARD
:: ============================================================
if defined GITHUB_ACTIONS (
    echo [INFO] GitHub Actions detected. Skipping GPU setup.
    exit /b 0
)

:: ============================================================
:: SELF ELEVATION
:: ============================================================
>nul 2>&1 net session || (
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ============================================================
echo            NVIDIA GPU / CUDA / cuDNN SETUP
echo ============================================================
echo.

:: ============================================================
:: GPU DETECTION
:: ============================================================
where nvidia-smi >nul 2>&1 || (
    echo [ERROR] NVIDIA driver not detected.
    exit /b 1
)

for /f "skip=1 delims=" %%i in ('nvidia-smi --query-gpu=name --format=csv') do set GPU_NAME=%%i
for /f "skip=1 delims=" %%i in ('nvidia-smi --query-gpu=driver_version --format=csv') do set DRIVER_VERSION=%%i
for /f "skip=1 delims=" %%i in ('nvidia-smi --query-gpu=compute_cap --format=csv') do set COMPUTE_CAP=%%i

echo GPU              : %GPU_NAME%
echo Driver Version   : %DRIVER_VERSION%
echo Compute Capability: %COMPUTE_CAP%
echo.

:: ============================================================
:: COMPUTE CAPABILITY CHECK (NUMERIC, SAFE)
:: ============================================================
powershell -NoProfile -Command ^
  "if ([double]'%COMPUTE_CAP%' -lt 7.5) { exit 1 } else { exit 0 }"

if errorlevel 1 (
    echo [ERROR] GPU compute capability < 7.5. CUDA not supported.
    exit /b 1
)

echo [OK] GPU is CUDA capable.
echo.

:: ============================================================
:: CUDA CHECK
:: ============================================================
set REQUIRED_CUDA=12.4
set CUDA_ROOT=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.4
set CUDA_INSTALLER=cuda_12.4.0_windows.exe
set CUDA_URL=https://developer.download.nvidia.com/compute/cuda/12.4.0/local_installers/cuda_12.4.0_windows.exe

where nvcc >nul 2>&1
if %errorlevel%==0 (
    for /f "tokens=5 delims= " %%a in ('nvcc --version ^| findstr "release"') do set CUDA_VERSION=%%a
) else (
    set CUDA_VERSION=0.0
)

echo Detected CUDA Version: %CUDA_VERSION%
echo.

powershell -NoProfile -Command ^
  "if ([version]'%CUDA_VERSION%' -ge [version]'%REQUIRED_CUDA%') { exit 0 } else { exit 1 }"

if errorlevel 1 (
    echo [INFO] Installing CUDA %REQUIRED_CUDA%
    if not exist "%CUDA_INSTALLER%" (
        echo Downloading CUDA installer...
        curl -L -o "%CUDA_INSTALLER%" "%CUDA_URL%" || exit /b 1
    )
    start /wait "" "%CUDA_INSTALLER%"
) else (
    echo [OK] CUDA already installed.
)

echo.

:: ============================================================
:: cuDNN SETUP
:: ============================================================
set CUDNN_VERSION=9.12
set CUDNN_INSTALLER=cudnn_9.12.0_windows.exe
set CUDNN_URL=https://developer.download.nvidia.com/compute/cudnn/9.12.0/local_installers/cudnn_9.12.0_windows.exe
set CUDNN_BASE=C:\Program Files\NVIDIA\cuDNN\v9.12

if not exist "%CUDNN_BASE%" (
    echo Downloading cuDNN installer...
    if not exist "%CUDNN_INSTALLER%" (
        curl -L -o "%CUDNN_INSTALLER%" "%CUDNN_URL%" || exit /b 1
    )
    start /wait "" "%CUDNN_INSTALLER%"
)

if not exist "%CUDA_ROOT%\include\cudnn.h" (
    echo Integrating cuDNN with CUDA...

    xcopy /Y /E "%CUDNN_BASE%\bin\12\*" "%CUDA_ROOT%\bin\"
    xcopy /Y /E "%CUDNN_BASE%\include\12\*" "%CUDA_ROOT%\include\"
    xcopy /Y /E "%CUDNN_BASE%\lib\12\x64\*" "%CUDA_ROOT%\lib\x64\"
)

if exist "%CUDA_ROOT%\include\cudnn.h" (
    echo [SUCCESS] cuDNN successfully integrated.
) else (
    echo [ERROR] cuDNN integration failed.
    exit /b 1
)

echo.
echo ============================================================
echo        CUDA + cuDNN SETUP COMPLETE
echo        © Chandradithya_MakeFiles 2025
echo ============================================================
echo.

pause
endlocal
