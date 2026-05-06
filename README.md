# FlopKernel Ginkgo with Droidspaces Support

Custom Android kernel for Redmi Note 8 (ginkgo) based on FlopKernel-Series with Droidspaces Linux containerization support integrated.

LICENSE: GPL v2 (consistent with Linux kernel)

DISCLAIMER: This is a learning project. The author is a beginner in kernel compilation and this repository is created for educational study purposes only. Use at your own risk.

---

## Overview

This repository contains a custom-compiled Android kernel for the Redmi Note 8 (ginkgo) device. The kernel is built using FlopKernel-Series as the base source with the following integrated features:

Kernel Components:
- Base Kernel: 4.14.x (FlopKernel-Series)
- KernelSU Next: v1.1.1 (for root access)
- SUSFS: v1.5.9 (filesystem hiding)
- Droidspaces: Configuration for Linux containerization

## What is Droidspaces?

Droidspaces (https://github.com/ravindu644/Droidspaces-OSS) is a lightweight tool that allows running full Linux distributions directly on Android devices using Linux kernel namespaces.

Key features:
- Run complete Linux systems (Ubuntu, Debian, Alpine) on Android
- Support for systemd and other init systems
- Process isolation without Termux or chroot limitations
- Network isolation support (Host, NAT, None modes)
- Small binary size (under 300KB)
- Works on both Android and Linux desktop

This kernel is compiled with configuration options to support all Droidspaces features.

---

## Requirements

### Device Requirements

To flash this kernel, you need:
- Device: Xiaomi Redmi Note 8 (codename: ginkgo)
  Also compatible with: Mi A3 (laurel_sprout), Redmi Note 8T (willow)
- Unlocked bootloader
- Custom recovery (TWRP recommended)
- ADB and fastboot tools installed on your computer

### Build Requirements (if compiling from source)

If you want to compile the kernel yourself, you need to install build tools on your Linux system.

Ubuntu or Debian:
```
sudo apt-get install -y build-essential clang-14 lld make git python3 bc flex bison ccache libelf-dev pahole openssl libssl-dev perl zstd binutils ncurses-dev
```

Arch Linux:
```
sudo pacman -S --needed base-devel clang lld make git python3 bc flex bison ccache libelf pahole openssl perl zstd binutils ncurses
```

### Kernel Features for Droidspaces

This kernel is compiled with support for:
- Linux Namespaces (PID, MNT, UTS, IPC, CGROUP, NET)
- Cgroups v1 and v2
- OverlayFS
- SELinux
- User namespaces

To verify these features are present after flashing:
```
adb shell
cat /proc/config.gz | gunzip | grep -E "NAMESPACE|CGROUP|OVERLAY|SELINUX"
```

---

## Installation

### Flashing the Kernel to Your Device

The pre-compiled kernel is available as a flashable ZIP file (created using AnyKernel3 template).

Step 1: Download the kernel ZIP file
- Find Floppy_custom-ginkgo-*.zip in the Releases section

Step 2: Transfer to device
```
adb push Floppy_custom-ginkgo-*.zip /sdcard/
```

Step 3: Boot into TWRP recovery
```
adb reboot recovery
```

Step 4: Install via TWRP
- In TWRP recovery interface, select "Install"
- Navigate to the downloaded ZIP file
- Swipe to confirm installation
- Wait for completion
- Reboot system

### Verifying the Kernel is Installed

After rebooting, verify the kernel installed correctly:
```
adb shell
cat /proc/version
uname -a
```

The output should show version 4.14.x and device name ginkgo.

---

## Building the Kernel from Source

This section explains how to compile the kernel yourself. This is a learning exercise for understanding how Android kernels are built.

### Prerequisites

Before starting, ensure you have:
1. Linux system (Ubuntu, Arch, or similar)
2. All build dependencies installed (see Requirements section above)
3. At least 20 GB free disk space
4. Stable internet connection
5. About 1-2 hours for first build (subsequent builds are faster)

### Step 1: Clone the Repository

```
git clone https://github.com/YOUR_USERNAME/kernel-ginkgo-droidspaces.git
cd kernel-ginkgo-droidspaces
chmod +x build.sh
```

Replace YOUR_USERNAME with the actual GitHub username where this repo is hosted.

### Step 2: Install Dependencies

Follow the installation commands in the Requirements section for your Linux distribution.

After installation, verify your compiler works:
```
clang --version
make --version
```

### Step 3: Generate Device Configuration

This step creates the kernel configuration file by combining the device-specific settings with Droidspaces settings.

```
./build.sh defconfig
```

This will create a .config file in the out/ directory.

### Step 4: Compile the Kernel

Start the compilation. This takes time on first build.

```
./build.sh build
```

What happens during build:
- Compiler processes all kernel source files
- Progress shows which files are being compiled
- Build takes 30-60 minutes on first run
- Subsequent builds are faster due to caching (if ccache is installed)

When complete, you should see:
```
Build selesai!
```

And the final kernel image will be at:
```
out/arch/arm64/boot/Image.gz-dtb
```

### Step 5: Verify the Build Output

Check that the kernel image was created:
```
ls -lh out/arch/arm64/boot/Image.gz-dtb
file out/arch/arm64/boot/Image.gz-dtb
```

The file should be 8-15 MB in size and identified as a gzip compressed file.

### Step 6: Create Flashable ZIP

The AnyKernel3 directory contains the template for creating a flashable ZIP file.

```
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel3/kernel/
cd AnyKernel3
zip -r ../Floppy_custom-ginkgo.zip . -x "*.git*"
cd ..
```

This creates Floppy_custom-ginkgo.zip which can be flashed to the device using TWRP.

### Troubleshooting Build Issues

Problem: Command not found errors
Solution: Make sure all dependencies are installed. Re-run the pacman or apt-get commands from the Requirements section.

Problem: Build fails midway
Solution: Check disk space with: df -h
You need at least 20 GB free. If full, delete the out/ directory and try again: ./build.sh clean

Problem: Build takes very long
Solution: This is normal for first build (30-60 minutes). You can check if it is actually compiling by running: top
Look for clang or cc1plus processes.

Problem: Clang not found
Solution: Verify clang is installed: clang --version
If not found, ensure you installed build dependencies correctly.

Problem: Out of memory errors
Solution: Reduce parallel jobs. Edit the build.sh script and change the -j flag to a smaller number (e.g., -j4 instead of -j$(nproc)).

---

## File Structure

This section describes what each directory and important file contains.

kernel/ - Linux kernel source code (version 4.14.x from FlopKernel-Series)
  arch/arm64/ - ARM64 architecture specific code
    configs/ - Device configuration files
      vendor/ginkgo.config - Device specific settings for Redmi Note 8
      droidspaces.config - Kernel options for Droidspaces support
  fs/ - Filesystem code including SUSFS implementation
  drivers/ - Device drivers for various hardware
  
toolchains/ - Compiler tools for building the kernel
  clang/ - AOSP Clang compiler (not committed to this repo, only symlink)
  
patches/ - Patch files applied to kernel source
  droidspaces/ - Patches for Droidspaces support
  kernelsu/ - Patches for KernelSU integration
  susfs/ - Patches for SUSFS filesystem hiding
  
AnyKernel3/ - Template for creating flashable ZIP files
  kernel/ - Where compiled kernel image is copied
  ramdisk/ - Recovery ramdisk modifications
  anykernel.sh - Installation script
  
out/ - Build output directory (created after building)
  arch/arm64/boot/ - Final compiled kernel images
    Image - Uncompressed kernel (not used for this device)
    Image.gz - Compressed kernel
    Image.gz-dtb - Final kernel with device tree (this is what gets flashed)
  
build.sh - Build automation script
  Checks dependencies
  Generates configuration
  Compiles kernel
  Creates output

.gitignore - Specifies which files are not tracked by git
README.md - This file

---

## Using Droidspaces with This Kernel

After successfully flashing this kernel to your device, you can use Droidspaces to run Linux containers.

Step 1: Install Droidspaces
- Download the Droidspaces APK from: https://github.com/ravindu644/Droidspaces-OSS/releases
- Install the APK on your Android device
- Grant necessary permissions when prompted

Step 2: Verify Kernel Compatibility
- Open the Droidspaces app
- Go to Settings
- Select "Requirements checker"
- The checker will show which kernel features are present
- All checks should show supported for this kernel

Step 3: Create a Linux Container
Example: Creating an Ubuntu container

```
adb shell
droidspaces create ubuntu
```

Step 4: Start and Access the Container

```
droidspaces start ubuntu
droidspaces shell ubuntu
```

You should now have a shell prompt inside the Linux container. You can run Linux commands and install packages using apt or other package managers.

Note: First time container creation and startup takes time while it downloads and extracts the Linux filesystem. This can take 10-30 minutes depending on internet speed.

For detailed Droidspaces documentation and more advanced usage, see:
https://github.com/ravindu644/Droidspaces-OSS

---

## Troubleshooting

This section covers common problems and how to solve them.

### Kernel Will Not Boot

Symptom: Device boots to fastboot or recovery instead of Android
Solution steps:
1. Verify bootloader is unlocked: fastboot flashing get_unlock_ability
2. Try flashing the original kernel from Xiaomi to verify device hardware works
3. Check TWRP is compatible with ginkgo model
4. Ensure you are flashing Image.gz-dtb (not Image or Image.gz)
5. Check recovery.img is for the correct device

### Droidspaces Not Working

Symptom: Droidspaces app shows unsupported or requirements fail
Steps to check:
1. Connect device with adb
2. Run: adb shell cat /proc/config.gz | gunzip | grep "CONFIG_NAMESPACES"
3. Should show: CONFIG_NAMESPACES=y
4. Check SELinux mode: getenforce
5. May need: setenforce 0 (requires root)

### KernelSU Not Granting Root Access

Symptom: Applications cannot get root access, KernelSU app shows errors
Steps:
1. Check if KernelSU is installed: adb shell su -v
2. Verify KernelSU app is installed and updated
3. Clear app cache and data, then restart
4. Check device logs: adb logcat | grep -i kernelsu
5. Check if SELinux is blocking: getenforce
6. For debugging, set SELinux to permissive: setenforce 0

### Build Fails During Compilation

Symptom: Compilation errors, "command not found", or build stops with error
Solution:
1. Clean previous build: ./build.sh clean
2. Verify disk space: df -h (need at least 20 GB free)
3. Check Clang installation: toolchains/clang/bin/clang --version
4. Verify dependencies installed correctly
5. Check device logs: dmesg | tail -20 (on Linux build machine)
6. If still failing, try with fewer parallel jobs (edit build.sh, change -j$(nproc) to -j4)

### Kernel Build Takes Very Long

Symptom: Build progress is very slow, appears stuck
Normal behavior:
- First build typically takes 30-60 minutes
- This is expected, not an error
- Verify it is actually running: top command should show clang or cc1plus processes
- Subsequent builds are much faster (5-15 minutes) if ccache is enabled

If it appears completely stuck for more than 2 hours:
1. Check with top command if compiler is still running
2. Check disk activity with: iostat 1 10
3. If truly stuck, press Ctrl+C to stop and start over

### Cannot Find Clang Compiler

Symptom: "clang: command not found" or "No such file or directory"
Solution:
1. Check: toolchains/clang/bin/clang --version
2. If not found, verify symlink exists: ls -la toolchains/
3. If symlink broken, reinstall clang to correct location
4. Manually verify clang is on system: which clang
5. If nowhere, run: sudo pacman -S clang (Arch) or apt install clang-14 (Ubuntu)

### Device Runs Out of Storage

Symptom: Installation fails, "No space left on device"
Solution:
1. Check remaining space: adb shell df -h
2. Clear app caches: Settings > Apps > Storage > Clear Cache
3. Delete unnecessary files from device storage
4. Use TWRP to wipe cache partition (does not delete user data)
5. If still not enough, may need to uninstall some apps

---

## References and Sources

The following projects and resources were used in creating this kernel:

FlopKernel-Series - Base kernel source code
https://github.com/FlopKernel-Series/flop_trinket-mi_kernel

Droidspaces-OSS - Linux containerization tool and kernel requirements
https://github.com/ravindu644/Droidspaces-OSS

KernelSU-Next - Root management system
https://github.com/rifsxd/KernelSU-Next

SUSFS - Filesystem hiding module
https://github.com/zomasec/susfs

AOSP Kernel Documentation
https://android.googlesource.com/kernel/msm

Linux Kernel Documentation
https://www.kernel.org/doc/

Xiaomi Redmi Note 8 Device Information
https://www.mi.com/

---

## License

This kernel is licensed under GPL v2, consistent with the Linux kernel license.

When you modify and distribute this kernel, you must also distribute the source code under the same GPL v2 license.

The kernel is based on the Linux kernel which is licensed under GPL v2. See individual source files and components for their specific licenses.

---

## How to Use This Repository

This is a GitHub repository containing source code. To use it:

1. View the code online at GitHub (click on files to see their contents)
2. Clone locally to compile yourself
3. Check Releases section for pre-compiled kernel binaries
4. Follow the Installation section to flash to device

Changes and improvements can be submitted as pull requests if you modify the code.

---

## Contact and Support

This is a personal learning project. Support may be limited.

Issues can be reported on GitHub Issues section.

Questions about Droidspaces should be directed to the Droidspaces project.
Questions about FlopKernel should be directed to the FlopKernel-Series project.

---

Created: 2026-05-07
Kernel Version: 4.14.x (FlopKernel-Series)
Device: Xiaomi Redmi Note 8 (ginkgo)
Purpose: Educational learning project

This project is created for educational purposes to learn how Android kernels are compiled and modified. The author is a beginner in kernel development.

Important points:
- This is a learning exercise, not a production kernel
- Use at your own risk on your device
- May void device warranty
- Always backup important data before flashing custom kernels
- Some features may not work perfectly - this is expected in a learning project
- If something breaks, you can always flash the stock Xiaomi kernel back
- Community support for this specific build may be limited

What I learned from this project:
- How to obtain kernel source code
- Applying patches from multiple projects (FlopKernel, Droidspaces, KernelSU, SUSFS)
- Configuring kernel options for specific features
- Kernel compilation process with Clang compiler
- Creating flashable ZIP files with AnyKernel3
- Device tree concepts
- Some kernel configuration options for Linux namespaces

Recommended further learning:
- Read Linux kernel documentation
- Study kernel configuration options in detail
- Understand device tree files
- Learn about bootloaders and recovery systems
- Study how Android system integrates with the Linux kernel

This kernel is not recommended for devices you rely on daily. Use on a test device or secondary device.
