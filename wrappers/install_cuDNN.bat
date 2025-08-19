echo.
echo ==============================
echo STARTING cuDNN INSTALLATION...
echo ==============================
echo.

set cudnn_installer=cudnn.exe
set cudnn_url=https://developer.download.nvidia.com/compute/cudnn/9.12.0/local_installers/cudnn_9.12.0_windows.exe
set cuda_root=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.0

REM === Step 1: Download cuDNN if not present ===
if exist "%cudnn_installer%" (
    echo [INFO] cuDNN installer already exists: %cudnn_installer%
) else (
    echo [INFO] Downloading cuDNN installer...
    curl -L -o "%cudnn_installer%" --progress-bar "%cudnn_url%"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to download cuDNN installer.
        exit /b 1
    )
)

REM === Step 2: Run installer ===
echo [INFO] Running cuDNN installer...
start /wait "" "%cudnn_installer%"
echo [INFO] cuDNN installation finished.
echo.

REM === Step 3: Locate cuDNN installation path ===
REM Assuming cuDNN installs into Program Files\NVIDIA\cudnn* by default
set cudnn_base=C:\Program Files\NVIDIA\cuDNN\v9.12
if not exist "%cudnn_base%" (
    echo [ERROR] Could not find cuDNN installation folder: %cudnn_base%
    echo Please verify installation path manually.
    goto :eof
)

REM === Step 4: Copy cuDNN files into CUDA directories ===
echo [INFO] Copying cuDNN files into CUDA directories...

if exist "%cudnn_base%\bin" (
    xcopy /Y /E "%cudnn_base%\bin\13.0\*" "%cuda_root%\bin\"
)
if exist "%cudnn_base%\include" (
    xcopy /Y /E "%cudnn_base%\include\13.0\*" "%cuda_root%\include\"
)
if exist "%cudnn_base%\lib" (
    xcopy /Y /E "%cudnn_base%\lib\13.0\*" "%cuda_root%\lib\"
)

echo [SUCCESS] cuDNN setup completed and integrated with CUDA 13.0.
echo.
