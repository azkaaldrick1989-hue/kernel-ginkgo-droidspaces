# MODIFICATIONS FROM FLOPKERNEL ORIGINAL

This document describes modifications made to FlopKernel-Series for Droidspaces integration on Redmi Note 8 (ginkgo).

## Base Source

Original FlopKernel-Series: https://github.com/FlopKernel-Series/flop_trinket-mi_kernel
Branch: floppy-new
Version: 4.14.x

## Modifications Made

### 1. Droidspaces Configuration

Added kernel configuration options to support Droidspaces Linux containerization:

- Location: kernel/arch/arm64/configs/droidspaces.config
- Includes: Linux namespaces (PID, MNT, UTS, IPC, CGROUP, NET)
- Includes: Cgroups v1 and v2 support
- Includes: OverlayFS support
- Includes: SELinux support

These configurations are merged with vendor ginkgo defconfig during build.

### 2. Build System Files

Added custom build automation:

- build.sh - Automated kernel compilation script
  * Handles defconfig generation
  * Compiles with all CPU cores
  * Uses Clang compiler
  * Produces flashable kernel image

### 3. Flashable ZIP Template

AnyKernel3/ directory:
- Standard AnyKernel3 template for creating flashable ZIPs
- Modified for ginkgo device
- Includes post-installation verification

### 4. Documentation

Added comprehensive documentation:
- README.md - Complete build and usage guide
- This file - Modification documentation

## Components Integrated

The following security/root components were already integrated into FlopKernel-Series base:
- KernelSU Next v1.1.1
- SUSFS v1.5.9

Droidspaces integration only required kernel configuration options to be enabled.

## Files Not Modified

The following are from original FlopKernel-Series without modification:
- kernel/ - Complete kernel source (only configuration merged)
- COPYING - Original GPL v2 license
- CREDITS - Original credits
- MAINTAINERS - Original maintainers list
- All kernel core files and drivers

## Build Configuration

Device defconfig used:
- arch/arm64/configs/vendor/ginkgo.config (device specific)
- arch/arm64/configs/droidspaces.config (merged for features)

## No Breaking Changes

- All modifications are backward compatible
- No removal of FlopKernel features
- Only additions/enhancements

## License

All modifications inherit GPL v2 license from original Linux kernel.
See COPYING file for full license text.

---

Created: 2026-05-07
For: Learning/Educational Purpose
Device: Redmi Note 8 (ginkgo)
