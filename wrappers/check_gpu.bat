@echo off
echo Checking for NVIDIA GPU and driver information...

for /f "delims=" %%i in ('nvidia-smi --query-gpu=name --format=csv') do set "gpu_name=%%i"

for /f "delims=" %%i in ('nvidia-smi --query-gpu=driver_version --format=csv') do set "driver_version=%%i"

for /f "delims=" %%i in ('nvidia-smi --query-gpu=compute_cap --format=csv') do set "compute_cap=%%i"

echo GPU Name: %gpu_name%
echo Driver Version: %driver_version%
echo Compute Capability: %compute_cap%

:: return these three when called in a parent batch file as a package
set "gpu_info=%gpu_name%|%driver_version%|%compute_cap%"