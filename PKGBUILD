# Maintainer: Dmitry Mikushin <dmitry@kernelgen.org>
# PKGBUILD for onnxruntime-gpu with CUDA support for SM_61 only
# Use this file when CUDA is installed on your system

pkgname=onnxruntime-gpu-sm61
pkgver=1.23.2
pkgrel=1
pkgdesc="ONNX Runtime with GPU support for SM_61 architecture only"
arch=('x86_64')
url="https://github.com/microsoft/onnxruntime"
license=('MIT')
depends=('python' 'python-numpy' 'python-packaging'
         're2' 'abseil-cpp' 'cuda-12.9' 'cudnn9.10-cuda12.9')
makedepends=('cmake' 'git' 'pybind11' 'python-setuptools' 'python-wheel'
             'python-build' 'python-installer' 'gcc' 'ninja')
provides=('onnxruntime' 'onnxruntime-gpu')
conflicts=('onnxruntime' 'onnxruntime-gpu' 'onnxruntime-opt')
source=('fix-cstdint.patch')
sha256sums=('SKIP')

prepare() {
  # Copy existing onnxruntime repository
  if [ ! -d "${srcdir}/onnxruntime" ]; then
    cp -r /home/marcusmae/forge/onnxruntime "${srcdir}/"
  fi

  cd "${srcdir}/onnxruntime"

  # Apply patch
  patch -p1 < "${srcdir}/fix-cstdint.patch"

  # Initialize submodules
  git submodule update --init --recursive

  # Create build directory
  mkdir -p build
}

build() {
  cd "${srcdir}/onnxruntime"

  # Set CUDA architecture to sm_61 only
  export CMAKE_CUDA_ARCHITECTURES="61"
  export CUDACXX=/opt/cuda/bin/nvcc

  # Configure build for sm_61 only
  ./build.sh \
    --config RelWithDebInfo \
    --build_dir build \
    --parallel \
    --skip_tests \
    --compile_no_warning_as_error \
    --use_cuda \
    --cuda_home /opt/cuda \
    --cudnn_home /usr \
    --cmake_extra_defines \
      CMAKE_INSTALL_PREFIX=/usr \
      CMAKE_CUDA_ARCHITECTURES=61 \
      CMAKE_CUDA_COMPILER=/opt/cuda/bin/nvcc \
      onnxruntime_BUILD_UNIT_TESTS=OFF \
      onnxruntime_ENABLE_PYTHON=ON \
      onnxruntime_BUILD_SHARED_LIB=ON \
      onnxruntime_ENABLE_TRAINING=OFF \
      onnxruntime_ENABLE_TRAINING_OPS=OFF \
      onnxruntime_ENABLE_TRAINING_APIS=OFF \
      CMAKE_CXX_STANDARD=17 \
      CMAKE_CXX_FLAGS="-Wno-error=range-loop-construct" \
    --build_wheel \
    --update \
    --build
}

package() {
  cd "${srcdir}/onnxruntime/build/RelWithDebInfo"

  # Install providers (shared libs)
  install -Dm755 libonnxruntime_providers_shared.so "${pkgdir}/usr/lib/libonnxruntime_providers_shared.so"
  install -Dm755 libonnxruntime_providers_cuda.so "${pkgdir}/usr/lib/libonnxruntime_providers_cuda.so"

  # Install headers
  cd "${srcdir}/onnxruntime"
  install -d "${pkgdir}/usr/include/onnxruntime"
  cp -r include/onnxruntime/core "${pkgdir}/usr/include/onnxruntime/"

  # Install Python wheel
  cd "${srcdir}/onnxruntime/build/RelWithDebInfo/dist"
  python -m installer --destdir="$pkgdir" *.whl

  # Create symlinks in /usr/lib to the library in Python site-packages
  install -d "${pkgdir}/usr/lib"
  ln -sf ../lib/python3.13/site-packages/onnxruntime/capi/libonnxruntime.so.${pkgver} \
    "${pkgdir}/usr/lib/libonnxruntime.so.${pkgver}"
  ln -sf libonnxruntime.so.${pkgver} "${pkgdir}/usr/lib/libonnxruntime.so.1"
  ln -sf libonnxruntime.so.1 "${pkgdir}/usr/lib/libonnxruntime.so"

  # Install license
  install -Dm644 "${srcdir}/onnxruntime/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"

  # Create configuration file for sm_61
  mkdir -p "${pkgdir}/etc/onnxruntime"
  echo "# ONNX Runtime GPU Configuration" > "${pkgdir}/etc/onnxruntime/gpu.conf"
  echo "# Built specifically for CUDA Compute Capability 6.1 (sm_61)" >> "${pkgdir}/etc/onnxruntime/gpu.conf"
  echo "# Compatible GPUs: GTX 1060, 1070, 1080, Titan X (Pascal), Tesla P40, P4, etc." >> "${pkgdir}/etc/onnxruntime/gpu.conf"
  echo "CUDA_ARCH=sm_61" >> "${pkgdir}/etc/onnxruntime/gpu.conf"
}
