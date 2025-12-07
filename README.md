# ONNX Runtime GPU for SM_61 (Compute Capability 6.1)

## Description
This package contains ONNX Runtime optimized specifically for GPUs with Pascal architecture (SM_61).

## Compatible GPUs
The package is optimized for the following graphics cards:
- GeForce GTX 1060
- GeForce GTX 1070
- GeForce GTX 1080
- GeForce GTX 1080 Ti
- TITAN X (Pascal)
- TITAN Xp
- Tesla P40
- Tesla P4
- Quadro P5000
- Other GPUs with Compute Capability 6.1

## Package Files

### PKGBUILD
Main build file for CPU version with GPU support preparation.
Used when CUDA is not installed on the system.

### PKGBUILD.cuda
Full version with CUDA support and SM_61 optimization.
Use this file when CUDA is installed:
```bash
cp PKGBUILD.cuda PKGBUILD
makepkg -s
```

## Installation

### Option 1: CPU version (without CUDA)
```bash
makepkg -s
sudo pacman -U onnxruntime-gpu-sm61-*.pkg.tar.zst
```

### Option 2: GPU version with CUDA
1. Install CUDA and dependencies:
```bash
sudo pacman -S cuda-12.9 cudnn9.10-cuda12.9
```

2. Use PKGBUILD with CUDA support:
```bash
cp PKGBUILD.cuda PKGBUILD
makepkg -s
sudo pacman -U onnxruntime-gpu-sm61-*.pkg.tar.zst
```

## CUDA Configuration

### Verifying CUDA Installation
```bash
nvcc --version
nvidia-smi
```

### Configuring CUDA Paths
If CUDA is installed in a non-standard location, edit PKGBUILD:
```bash
--cuda_home /path/to/cuda
--cudnn_home /path/to/cudnn
```

## Python Usage

```python
import onnxruntime as ort

# Check available providers
print(ort.get_available_providers())

# Create session with GPU
session = ort.InferenceSession(
    "model.onnx",
    providers=['CUDAExecutionProvider', 'CPUExecutionProvider']
)

# Check used provider
print(session.get_providers())
```

## Verifying SM_61 Optimization

```python
import onnxruntime as ort

# Get CUDA information
cuda_provider_options = {
    'device_id': 0,
    'gpu_mem_limit': 2 * 1024 * 1024 * 1024,  # 2GB
    'cudnn_conv_algo_search': 'DEFAULT',
}

session = ort.InferenceSession(
    "model.onnx",
    providers=[
        ('CUDAExecutionProvider', cuda_provider_options),
        'CPUExecutionProvider'
    ]
)
```

## Troubleshooting

### CUDA Not Found
```bash
export PATH=/opt/cuda/bin:$PATH
export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH
```

### Compilation Error with sm_61
Make sure PKGBUILD has:
```bash
CMAKE_CUDA_ARCHITECTURES=61
```

### Check GPU Support
```bash
python -c "import onnxruntime; print(onnxruntime.get_device())"
```

## Performance

The package is optimized specifically for Pascal architecture (sm_61), providing:
- Minimal binary size
- Maximum performance on target GPUs
- No code for other architectures

## Build Features

This package includes:
- **GCC 15 compatibility patch**: Fixes missing `#include <cstdint>` in semver.h
- **Proper library symlinks**: Correct symlink chain to Python site-packages
- **CUDA 12.9 support**: Built with latest CUDA toolkit
- **cuDNN 9.10**: Deep neural network library integration
- **Flash Attention**: Enabled for transformer acceleration
- **FP8/FP4 support**: Low-precision compute capabilities

## License
MIT License (see LICENSE file in source code)

## Package Maintainer
Package created for ArchLinux with optimization for specific GPU architecture.
