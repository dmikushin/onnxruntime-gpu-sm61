# Makefile for ONNX Runtime GPU SM_61 package
#
# This package is optimized for NVIDIA Pascal GPUs (SM_61 architecture)
# Default build includes CUDA support for maximum performance
#
# Targets:
#   make / make all - Build GPU version with CUDA support (default)
#   make install    - Build and install the package
#   make clean      - Remove all generated files
#   make help       - Show this help message

.PHONY: all build install clean help

# Package information
PKGNAME := onnxruntime-gpu-sm61
PKGFILE := $(shell ls -t $(PKGNAME)-*.pkg.tar.zst 2>/dev/null | head -1)

# Default target: build GPU version
all: build

# Build GPU version with CUDA support
build:
	@echo "Building $(PKGNAME) with CUDA support..."
	@echo "Target: SM_61 (GTX 1060/1070/1080, Pascal architecture)"
	makepkg --noconfirm

# Build and install
install: build
	@if [ -z "$(PKGFILE)" ]; then \
		echo "Error: No package file found!"; \
		exit 1; \
	fi
	@echo "Installing $(PKGFILE)..."
	sudo pacman -U $(PKGFILE)

# Clean all generated files
clean:
	@echo "Cleaning generated files..."
	rm -rf src/
	rm -rf pkg/
	rm -f *.pkg.tar.zst
	rm -f *.pkg.tar.xz
	rm -f *.log
	rm -f build_*.log
	@echo "Clean complete!"

# Show help
help:
	@echo "ONNX Runtime GPU SM_61 - Build System"
	@echo ""
	@echo "This package is optimized for NVIDIA Pascal GPUs (SM_61)"
	@echo "Compatible: GTX 1060/1070/1080, TITAN X Pascal, Tesla P40, etc."
	@echo ""
	@echo "Available targets:"
	@echo "  make / make all - Build GPU package with CUDA support (default)"
	@echo "  make install    - Build and install the package"
	@echo "  make clean      - Remove all generated files"
	@echo "  make help       - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make           # Build GPU version with CUDA 12.9"
	@echo "  make clean     # Clean all build artifacts"
	@echo "  make install   # Build and install in one step"
	@echo ""
	@echo "Requirements:"
	@echo "  - cuda-12.9"
	@echo "  - cudnn9.10-cuda12.9"
