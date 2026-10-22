# Build environment for onnxruntime-gpu-sm61: CachyOS x86-64-v3 (the
# repositories of the machines it is installed on, for the same Python and
# glibc), plus CUDA 12.9 - the last CUDA that compiles for Pascal (sm_61) -
# and its cuDNN, both from the AUR. protobuf, abseil and re2 are deliberately
# absent: onnxruntime builds its own copies into the library.
FROM cachyos/cachyos-v3:latest

RUN pacman -Syu --noconfirm --needed \
        base-devel git sudo cmake ninja gcc14 \
        pybind11 python-setuptools python-wheel python-build python-installer \
        python-numpy python-packaging \
        opencl-nvidia nvidia-utils \
    && pacman -Scc --noconfirm

RUN useradd -m builder \
    && echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder
USER builder
WORKDIR /home/builder

RUN for pkg in cuda-12.9 cudnn9.10-cuda12.9; do \
        git clone --depth 1 "https://aur.archlinux.org/${pkg}.git" \
        && (cd "$pkg" && makepkg -si --noconfirm) \
        && rm -rf "$pkg" || exit 1; \
    done \
    && sudo pacman -Scc --noconfirm
