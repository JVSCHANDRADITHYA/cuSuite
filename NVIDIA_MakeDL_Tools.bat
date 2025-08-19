@echo off
setlocal enabledelayedexpansion

echo.
echo ==========================================================================================
echo                               STARTING GPU SETUP...
echo ==========================================================================================
echo.


echo.
echo ==========================================================================================
echo Checking for NVIDIA GPU and driver information...
echo ==========================================================================================
echo.
for /f "skip=1 delims=" %%i in ('nvidia-smi --query-gpu=name --format=csv') do set "gpu_name=%%i"
for /f "skip=1 delims=" %%i in ('nvidia-smi --query-gpu=driver_version --format=csv') do set "driver_version=%%i"
for /f "skip=1 delims=" %%i in ('nvidia-smi --query-gpu=compute_cap --format=csv') do set "compute_cap=%%i"

echo.
echo ==========================================================================================
echo GPU Name           : %gpu_name%
echo Driver Version     : %driver_version%
echo Compute Capability : %compute_cap%
echo ==========================================================================================
echo.


set "min_comp=7.5"

if "%compute_cap%" LSS "%min_comp%" (
    echo.
    echo ==========================================================================================
    echo  [ERROR] SORRY YOUR DEVICE IS NOT CUDA COMPATIBLE...
    echo ==========================================================================================
    echo.
    exit /b
) else (
    echo.
    echo ==========================================================================================
    echo  [INFO] Your device is CUDA compatible.
    echo ==========================================================================================
    echo.
)

set "gpu_info=%gpu_name%|%driver_version%|%compute_cap%"
echo.
echo ==========================================================================================
echo Checking latest NVIDIA Studio Driver version online...
echo ==========================================================================================
echo.

for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command ^
    "$url='https://www.nvidia.com/Download/processFind.aspx?psid=107&pfid=877&osid=135&lid=1&dtcid=1';" ^
    "$html=(Invoke-WebRequest -Uri $url).Content;" ^
    "$match=[regex]::Matches($html, '<td class=\"gridItem\">(\d+\.\d+)</td>');" ^
    "($match | ForEach-Object { $_.Groups[1].Value } | Sort-Object {[decimal]$_} -Descending | Select-Object -First 1)"`) do (
    set "latest_version=%%i"
)

:: clean both values: keep only digits and dot
set "driver_version=!driver_version: =!"
set "latest_version=!latest_version: =!"

for /f "tokens=1 delims=" %%A in ("!latest_version!") do set "latest_version=%%~A"
for /f "tokens=1 delims=" %%A in ("!driver_version!") do set "driver_version=%%~A"
for /f "delims=0123456789." %%A in ("!driver_version!") do set "driver_version=!driver_version:%%A=!"
for /f "delims=0123456789." %%A in ("!latest_version!") do set "latest_version=!latest_version:%%A=!"

echo.
echo ==========================================================================================
echo Latest Available Driver Version : !latest_version!
echo Installed Driver Version        : !driver_version!
echo ==========================================================================================
echo.



echo.
echo ==========================================================================================
echo                           STARTING DRIVER INSTALLATION...
echo ==========================================================================================
echo. 

if "%latest_version%" NEQ "%driver_version%" (
    echo [INFO] Installed driver %driver_version% is older than latest %latest_version%.
    echo.
    if exist NVIDIA_Driver.exe (
        echo.
        echo ==========================================================================================
        echo [INFO] Found existing NVIDIA_Driver.exe, running installer...
        echo ==========================================================================================
        start /wait NVIDIA_Driver.exe
        echo Installer finished. Path: %cd%\NVIDIA_Driver.exe
        echo Exit code: !errorlevel!
        echo ==========================================================================================
        echo.
        goto :cuda_start
    ) else (
        echo [INFO] Downloading and installing latest driver...
        echo.

        set "dl_url=https://us.download.nvidia.com/Windows/%latest_version%/%latest_version%-desktop-win10-win11-64bit-international-dch-whql.exe"

        echo Downloading from !dl_url!
        curl -L -# -o NVIDIA_Driver.exe "!dl_url!"

        echo Starting installer...
        start /wait NVIDIA_Driver.exe
        echo Exit code: !errorlevel!
    )
) else (
    echo ==========================================================================================
    echo [INFO] Your driver is already up to date.
    echo ==========================================================================================
    echo.
)

:cuda_start
echo.
echo ==========================================================================================
echo                           STARTING CUDA INSTALLATION...
echo ==========================================================================================
echo. 

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
echo.
echo ==========================================================================================
echo [INFO] Detected CUDA version: %cuda_version%
echo ==========================================================================================
echo.

set required_version=13.0
if "%cuda_version%"=="%required_version%" (
    echo ==========================================================================================
    echo [INFO] CUDA version %cuda_version% is already installed.
    echo ==========================================================================================
    goto :cudnn_start
)

for /f "tokens=1,2 delims=." %%x in ("%cuda_version%") do (
    set major=%%x
    set minor=%%y
)

if not defined major set major=0
if not defined minor set minor=0

if %major% gtr 13 (
    echo ==========================================================================================
    echo [INFO] CUDA version %cuda_version% is newer than 13.0. Skipping install.
    echo ==========================================================================================
    goto :cudnn_start
)

if %major%==13 if %minor% geq 0 (
    echo ==========================================================================================
    echo [INFO] CUDA version %cuda_version% is already >= 13.0.
    echo ==========================================================================================
    goto :cudnn_start
)

set installer=cuda_13.0.0_windows.exe
set url=https://developer.download.nvidia.com/compute/cuda/13.0.0/local_installers/cuda_13.0.0_windows.exe

if exist "%installer%" (
    echo ==========================================================================================
    echo [INFO] Installer already exists: %installer%
    echo ==========================================================================================
) else (
    echo ==========================================================================================
    echo [INFO] Downloading CUDA 13.0 installer...
    echo ==========================================================================================
    curl -L -o "%installer%" --progress-bar "%url%"
    if %errorlevel% neq 0 (
        echo ==========================================================================================
        echo [ERROR] Failed to download installer.
        echo ==========================================================================================
        exit /b 1
    )
)

echo ==========================================================================================
echo [INFO] Running CUDA installer...
echo ==========================================================================================
echo [ACTION] Approve UAC prompts if asked.
start /wait "" "%installer%"

echo ==========================================================================================
echo [INFO] CUDA 13.0 installation finished.
echo ==========================================================================================
echo.

if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.0" (
    echo ==========================================================================================
    echo [SUCCESS] CUDA 13.0 installation verified: Folder exists.
    echo ==========================================================================================
    echo.
) else (
    echo ==========================================================================================
    echo [ERROR] CUDA folder not found. Installation may have failed.
    echo ==========================================================================================
)

REM Check if nvcc is accessible again
where nvcc >nul 2>&1
if %errorlevel%==0 (
    nvcc --version
) else (
    echo ==========================================================================================
    echo [ERROR] nvcc not found in PATH.
    echo ==========================================================================================
)

:cudnn_start

echo.
echo ==========================================================================================
echo                           STARTING cuDNN INSTALLATION...
echo ==========================================================================================
echo.


set cudnn_installer=cudnn_9.12.0_windows.exe
set cudnn_url=https://developer.download.nvidia.com/compute/cudnn/9.12.0/local_installers/cudnn_9.12.0_windows.exe
set cuda_root=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.0
set cudnn_base=C:\Program Files\NVIDIA\cuDNN\v9.12
set cudnn_in_cuda=%cuda_root%\include\cudnn.h

if exist "%cudnn_base%" (
    echo ==========================================================================================
    echo [INFO] cuDNN base folder exists: %cudnn_base%
    echo ==========================================================================================
    if exist "%cudnn_in_cuda%" (
        echo ==========================================================================================
        echo [INFO] cuDNN header file exists in CUDA include directory: %cudnn_in_cuda%
        echo ==========================================================================================
        goto :success
    ) else (
        echo ==========================================================================================
        echo [ERROR] cuDNN header file not found in CUDA include directory: %cudnn_in_cuda%
        echo Copying cuDNN to CUDA directories...
        echo ==========================================================================================
        goto :copy_part
    )
)

REM === Step 1: Download cuDNN if not present ===
if exist "%cudnn_installer%" (
    echo ==========================================================================================
    echo [INFO] cuDNN installer already exists: %cudnn_installer%
    echo ==========================================================================================
) else (
    echo ==========================================================================================
    echo [INFO] Downloading cuDNN installer...
    echo ==========================================================================================
    curl -L -o "%cudnn_installer%" --progress-bar "%cudnn_url%"
    if %errorlevel% neq 0 (
        echo ==========================================================================================
        echo [ERROR] Failed to download cuDNN installer.
        echo ==========================================================================================
        exit /b 1
    )
)

REM === Step 2: Run installer ===
echo ==========================================================================================
echo [INFO] Running cuDNN installer...
echo ==========================================================================================
start /wait "" "%cudnn_installer%"
echo ==========================================================================================
echo [INFO] cuDNN installation finished.
echo ==========================================================================================
echo.

REM === Step 3: Locate cuDNN installation path ===
if not exist "%cudnn_base%" (
    echo ==========================================================================================
    echo [ERROR] Could not find cuDNN installation folder: %cudnn_base%
    echo Please verify installation path manually.
    echo ==========================================================================================
    goto :eof
)

:copy_part
REM === Step 4: Copy cuDNN files into CUDA directories ===
echo ==========================================================================================
echo [INFO] Copying cuDNN files into CUDA directories...
echo ==========================================================================================

if exist "%cudnn_base%\bin" (
    xcopy /Y /E "%cudnn_base%\bin\13.0\*" "%cuda_root%\bin\"
)
if exist "%cudnn_base%\include" (
    xcopy /Y /E "%cudnn_base%\include\13.0\*" "%cuda_root%\include\"
)
if exist "%cudnn_base%\lib" (
    xcopy /Y /E "%cudnn_base%\lib\13.0\x64\cudnn.lib*" "%cuda_root%\lib\x64\"
)

:success
echo.
echo ==========================================================================================
echo                [SUCCESS] cuDNN setup completed and integrated with CUDA 13.0.
echo                               © Chandradithya_MakeFiles 2025
echo ==========================================================================================
echo.


echo.
echo ==========================================================================================
echo                YOU CAN NOW USE YOUR NVIDIA GPU WITH CUDA AND cuDNN!
echo ==========================================================================================
echo.

:end
endlocal
pause
