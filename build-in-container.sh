#!/bin/bash
# Build the package in the CachyOS container from ./Dockerfile; the package
# file lands in this directory. Logs: build-image.log, build.log.
set -euo pipefail
cd "$(dirname "$0")"

docker build -t onnxruntime-gpu-sm61-build . 2>&1 | tee build-image.log

docker run --rm \
    -v "$PWD:/pkg" -w /home/builder \
    onnxruntime-gpu-sm61-build \
    bash -c 'set -e
             cp /pkg/PKGBUILD /pkg/fix-cstdint.patch .
             makepkg --noconfirm
             pacman -Q protobuf abseil-cpp re2 python
             cp ./*.pkg.tar.zst /pkg/' \
    2>&1 | tee build.log
