@echo off
setlocal enabledelayedexpansion

echo Checking for NVIDIA GPU and driver information...
echo.

for /f "skip=1 delims=" %%i in ('nvidia-smi --query-gpu=name --format=csv') do set "gpu_name=%%i"
for /f "skip=1 delims=" %%i in ('nvidia-smi --query-gpu=driver_version --format=csv') do set "driver_version=%%i"
for /f "skip=1 delims=" %%i in ('nvidia-smi --query-gpu=compute_cap --format=csv') do set "compute_cap=%%i"

echo GPU Name: %gpu_name%
echo Driver Version: %driver_version%
echo Compute Capability: %compute_cap%
echo.
echo.

set "min_comp=7.5"

if "%compute_cap%" LSS "%min_comp%" (
    echo SORRY YOUR DEVICE IS NOT CUDA COMPATIBLE...
    exit /b
) else (
    echo Your device is CUDA compatible.
    echo.
)

set "gpu_info=%gpu_name%|%driver_version%|%compute_cap%"

echo Checking latest NVIDIA Studio Driver version online...
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

echo Latest Available Driver Version: !latest_version!
echo Installed Driver Version: !driver_version!
echo.
echo.

if "%latest_version%" NEQ "%driver_version%" (
    echo Installed driver %driver_version% is older than latest %latest_version%.
    echo.
    if exist NVIDIA_Driver.exe (
        echo Found existing NVIDIA_Driver.exe, running installer...
        echo.
        start /wait NVIDIA_Driver.exe
        echo Installer finished. Path: %cd%\NVIDIA_Driver.exe
        echo Exit code: !errorlevel!
        goto :end

    ) else (
        echo Downloading and installing latest driver...
        echo.

        set "dl_url=https://us.download.nvidia.com/Windows/%latest_version%/%latest_version%-desktop-win10-win11-64bit-international-dch-whql.exe"

        echo Downloading from !dl_url!
        curl -L -# -o NVIDIA_Driver.exe "!dl_url!"

        echo Starting installer...
        start /wait NVIDIA_Driver.exe
        echo Exit code: !errorlevel!
    )

) else (
    echo Your driver is already up to date.
)

:end
endlocal
pause
