# Kernel Build Instructions

## Current Status
- ✅ Kernel source ready: `~/kernel-build/kernel/` (1.2 GB)
- ✅ Clang toolchain ready: `~/kernel-build/toolchains/clang/` (system symlinks)
- ✅ Droidspaces config ready: `arch/arm64/configs/droidspaces.config`
- ✅ Build script ready: `~/kernel-build/build.sh`

## Step 1: Verify Setup
```bash
cd ~/kernel-build

# Check clang
./toolchains/clang/bin/clang --version

# Check kernel source
ls -la kernel/arch/arm64/configs/vendor/ginkgo.config
ls -la kernel/arch/arm64/configs/droidspaces.config

# Check build script
ls -la build.sh
```

## Step 2: Run Build
```bash
cd ~/kernel-build
bash ./build.sh build
```

**Expected behavior:**
- First message: Checking dependencies ✓
- Setup environment variables ✓
- Generate defconfig
- Compile kernel (30-60 minutes)
- Final message: "Build selesai!" ✓

## Step 3: Verify Output
```bash
ls -lh ~/kernel-build/out/arch/arm64/boot/Image.gz-dtb
file ~/kernel-build/out/arch/arm64/boot/Image.gz-dtb
```

Should show:
- File size: 8-15 MB
- Type: gzip compressed data

## If Build Fails

### Check dependencies
```bash
which bc
which pahole
which flex bison

# Check Clang
clang --version
ld.lld --version
```

### Install missing deps (if needed)
```bash
sudo pacman -S --needed bc libelf pahole openssl perl zstd binutils ncurses
```

### Try clean rebuild
```bash
cd ~/kernel-build
bash ./build.sh clean
bash ./build.sh build
```

### Check build.sh is executable
```bash
chmod +x ~/kernel-build/build.sh
bash ~/kernel-build/build.sh build
```

## Build Output
Success indicators:
```
[OK] Clang toolchain: ~/kernel-build/toolchains/clang
[OK] Found: clang
[OK] PATH sudah termasuk Clang toolchain
====> Build kernel (Image.gz-dtb)
Building dengan 8 cores...
[OK] Kernel image: ~/kernel-build/out/arch/arm64/boot/Image.gz-dtb
[OK] Build selesai!
```

## Troubleshooting

### "cd: ./toolchains/clang: No such file or directory"
- Clang symlinks may not exist
- Solution: Run setup again:
  ```bash
  cd ~/kernel-build/toolchains
  mkdir -p clang/bin
  ln -sf /usr/bin/clang clang/bin/clang
  ln -sf /usr/bin/ld.lld clang/bin/ld.lld
  # etc...
  ```

### "command not found: bc, pahole, etc"
- Missing dependencies
- Solution: `sudo pacman -S --needed bc libelf pahole openssl perl zstd binutils ncurses`

### Build times out or hangs
- Normal for first build (30-60 min)
- For rebuilds with ccache: 5-10 min
- Check CPU usage: `top` or `htop`

### Kernel image not generated
- Check build errors above
- Try: `bash build.sh clean && bash build.sh build`
- Check disk space: `df -h ~/kernel-build/`

## Next Steps (After Successful Build)

Once kernel image is generated:

```bash
# 1. Verify kernel
file ~/kernel-build/out/arch/arm64/boot/Image.gz-dtb

# 2. Check size
ls -lh ~/kernel-build/out/arch/arm64/boot/Image.gz-dtb

# 3. Setup AnyKernel3 for flashing (next phase)
# Will be explained after build completes
```

---

**Ready?** Run: `cd ~/kernel-build && bash ./build.sh build`
