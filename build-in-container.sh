#!/bin/bash
# Build the package in the CachyOS container from ./Dockerfile. makepkg runs
# in this directory (mounted), so src/, pkg/ and the package file survive
# the container. Logs: build-image.log, build.log.
set -euo pipefail
cd "$(dirname "$0")"

docker build -t onnxruntime-gpu-sm61-build . 2>&1 | tee build-image.log

docker run --rm -v "$PWD:/pkg" -w /pkg onnxruntime-gpu-sm61-build \
    makepkg --noconfirm 2>&1 | tee build.log
