# Kernel Build Setup Checklist

## Progress Tracker

- [ ] 1. Install dependencies
  - [x] clang (v22.1.1)
  - [x] make (v4.4.1)
  - [x] git (v2.53.0)
  - [x] python3 (v3.14.3)
  - [ ] bc
  - [x] flex (v2.6.4)
  - [x] bison (v3.8.2)
  - [x] ccache (v4.12.3)
  - [ ] libelf, pahole, openssl, perl, zstd, binutils, ncurses
  - [ ] cross-compile toolchain (aarch64-linux-gnu-gcc, arm-none-eabi-gcc)

- [ ] 2. Clone kernel source
  - Status: CLONING (large repo ~2-3 GB)
  - Source: https://github.com/FlopKernel-Series/flop_trinket-mi_kernel
  - Branch: floppy-new
  - Target: ~/kernel-build/kernel

- [ ] 3. Download Clang toolchain
  - Status: PENDING
  - Options:
    a. AOSP Clang r563880 (GitLab)
    b. ZyC Clang (GitHub releases) - not found

- [ ] 4. Setup directory structure
  - [x] ~/kernel-build/kernel
  - [x] ~/kernel-build/toolchains
  - [x] ~/kernel-build/out
  - [x] ~/kernel-build/AnyKernel3
  - [x] ~/kernel-build/patches

- [ ] 5. Verify KernelSU Next & SUSFS
  - Check KSU version (target: 1.1.1)
  - Check SUSFS version (target: 1.5.9)
  - Verify integration in source

- [ ] 6. Add Droidspaces config
  - Create: ~/kernel-build/kernel/arch/arm64/configs/droidspaces.config
  - Configure namespaces, cgroups, networking

- [ ] 7. Apply kernel patches
  - Clone Droidspaces-OSS repo
  - Apply patches to kernel source
  - Check for conflicts (.rej files)

- [ ] 8. Create build script
  - Path: ~/kernel-build/build.sh
  - Configure toolchain path
  - Setup environment variables
  - Define build flags

- [ ] 9. Ready for build (will ask before proceeding)

## Notes
- Working directory: ~/kernel-build/
- Device: Redmi Note 8 (ginkgo)
- Kernel: 4.14.x (Non-GKI)
- KernelSU Next: v1.1.1
- SUSFS: v1.5.9
- Droidspaces: namespace & container support

