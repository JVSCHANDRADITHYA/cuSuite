# cuSuite - Install fast. Build faster.

![Logo](img/logo.png)


## _NOTE_ : This repository is _**NOT**_ affiliated with or sponsored by NVIDIA. _cuSuite_ is an independent, community project and is _**NOT**_ an official NVIDIA product


_cuSuite_ is an automated installer for CUDA and cuDNN on Windows. It detects GPU driver requirements, selects compatible CUDA/cuDNN versions, validates library linking, and safely manages PATH updates. The guided installation flow reduces setup errors and verifies that toolchains and DLLs are ready for build and runtime.

The script handles the following:

- Compatibility intelligence: checks GPU driver↔CUDA↔cuDNN requirements before install.

- Version alignment: selects known‑good combinations to avoid build/runtime mismatches.

- Linking verification: confirms headers, libs, and DLLs are discoverable by compilers and at runtime.

- PATH safety: adds only what’s needed, preserves existing settings, supports rollback.

- Guided install flow: step‑by‑step with dry‑run preview and detailed logs.

- Fast verification: runs nvcc checks and cuDNN presence tests post‑install.

## [Releases Page](https://github.com/JVSCHANDRADITHYA/cuSuite/releases)
Check the releases page to install the latest version of cuSuite : [Releases Page](https://github.com/JVSCHANDRADITHYA/cuSuite/releases).

If you prefer batch installation, you can use the provided .bat files and follow the given instructions in the repository's installation guide.

## Components of Original Packages

### 1. CUDA Toolkit
- Core development kit for GPU-accelerated computing.
- Provides:
  - **nvcc** compiler
  - **CUDA Runtime**
  - **Driver API**
  - **cuBLAS** (Basic Linear Algebra Subroutines)
  - **cuFFT** (Fast Fourier Transform library)
  - **cuRAND** (Random number generation)
  - **cuSPARSE** (Sparse matrix operations)
  - **cuSOLVER** (Dense and sparse direct solvers)

### 2. cuDNN (CUDA Deep Neural Network Library)
- GPU-accelerated library for deep learning primitives.
- Supports:
  - **Convolutions**
  - **Pooling**
  - **Normalization**
  - **Recurrent Neural Networks (RNNs)**
  - **Tensor Cores (FP16/INT8 acceleration)**



##  System Requirements

- **OS:** Windows 10 / 11 (64-bit)  
- **GPU:** NVIDIA GeForce, RTX, Quadro, or Tesla with CUDA Compute Capability ≥ 7.5
- **Drivers:** Latest Game Ready / Studio Drivers  
- **Languages Supported:** English (US by default, configurable)



## Compute Capability Chart

Refer to NVIDIA’s official compute capability chart:  
![Compute Capability](img/image.png)
![CC 2](img/image-2.png)
Each GPU family has a *Compute Capability* value (e.g., RTX 4090 = 8.9).  
This determines the maximum CUDA Toolkit & cuDNN versions supported.

---

## CUDA/cuDNN Support Matrix

The compatibility matrix for CUDA and cuDNN:  
![CuDNN Support Matrix](img/image-1.png)

- CUDA Toolkit versions map to supported cuDNN versions.  
- Ensure **cuDNN is matched with your installed CUDA version**.  

---
## Installation (cuSuite.exe)

1. Download the latest cuSuite installer from the [releases page](https://github.com/JVSCHANDRADITHYA/cuSuite/releases)

   - **Latest_Version [v1.13.9-12]** : [cuSUITE_v1.13.9-12.exe](https://github.com/JVSCHANDRADITHYA/cuSuite/releases/download/v1.13.9-12/cuSuite.EXE).

2. Run the installer (in Administrator mode) and follow the on-screen instructions.

## Installation (Using batch)

1. Clone this repository:
   ```bash
   git clone https://github.com/JVSCHANDRADITHYA/cuSuite.git
   cd cuSuite
   ```

2. Run the .bat:
   ```bash
   .\NVIDIA_MakeDL_Tools.bat
   ```

## Manual Verification

After installation, verify the setup:

1. Check CUDA installation:
   ```bash
   nvcc --version
   ```

2. Check GPU status:
   ```bash
   nvidia-smi
   ```
## Images of cuSuite
![alt text](img/scrnsht.png)