#!/usr/bin/env bash
# =============================================================
# Build Script — Ginkgo Kernel
# KSUNext 1.1.1 + SUSFS 1.5.9 + Droidspaces Support
# Target: Redmi Note 8 (ginkgo)
# Host: Arch Linux
# =============================================================

set -e  # Exit on any error

# ============================================================
# KONFIGURASI — Sesuaikan path ini jika direktori berbeda
# ============================================================
KERNEL_DIR="$(cd "$(dirname "$0")/kernel" && pwd)"
CLANG_DIR="$(cd "$(dirname "$0")/toolchains/clang" && pwd)"
OUT_DIR="$(cd "$(dirname "$0")" && pwd)/out"
ANYKERNEL_DIR="$(cd "$(dirname "$0")/AnyKernel3" && pwd)"
DEFCONFIG="vendor/trinket-perf_defconfig"
EXTRA_CONFIG="vendor/ginkgo.config droidspaces.config"
KERNEL_IMAGE="arch/arm64/boot/Image.gz-dtb"
ZIPNAME="FloppyKernel-ginkgo-KSUNext-$(date +%Y%m%d-%H%M)"

# ============================================================
# WARNA UNTUK OUTPUT — biar enak dibaca
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERR]${NC}  $1"; exit 1; }
log_step()    { echo -e "\n${CYAN}====> $1${NC}\n"; }

# ============================================================
# CEK DEPENDENSI
# ============================================================
check_deps() {
    log_step "Memeriksa dependensi build"
    local deps=("clang" "make" "git" "python3" "bc" "flex" "bison")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            log_error "Dependensi tidak ditemukan: $dep"
        fi
        log_success "Found: $dep"
    done

    if [[ ! -f "$CLANG_DIR/bin/clang" ]]; then
        log_error "Clang toolchain tidak ditemukan di: $CLANG_DIR/bin/clang"
    fi
    log_success "Clang toolchain: $CLANG_DIR"
}

# ============================================================
# EXPORT PATH & VARIABEL LINGKUNGAN
# ============================================================
setup_env() {
    log_step "Setup environment variables"
    export PATH="$CLANG_DIR/bin:$PATH"
    export ARCH=arm64
    export SUBARCH=arm64
    export KBUILD_BUILD_USER="$(whoami)"
    export KBUILD_BUILD_HOST="$(hostname)"

    # ccache jika tersedia
    if command -v ccache &>/dev/null; then
        export CC="ccache clang"
        export CXX="ccache clang++"
        log_success "ccache aktif"
    else
        export CC="clang"
        export CXX="clang++"
    fi

    log_success "PATH sudah termasuk Clang toolchain"
    log_info "Clang version: $(clang --version | head -1)"
}

# ============================================================
# FLAGS UNTUK MAKE
# ============================================================
make_kernel() {
    local target="$1"
    make \
        -C "$KERNEL_DIR" \
        O="$OUT_DIR" \
        ARCH=arm64 \
        SUBARCH=arm64 \
        LLVM=1 \
        LLVM_IAS=1 \
        CC=clang \
        LD=ld.lld \
        AR=llvm-ar \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        -j"$(nproc --all)" \
        "$target"
}

# ============================================================
# CLEAN (opsional, jalankan dengan arg --clean)
# ============================================================
do_clean() {
    log_step "Membersihkan output sebelumnya"
    make_kernel mrproper
    rm -rf "$OUT_DIR"
    log_success "Direktori out dibersihkan"
}

# ============================================================
# GENERATE DEFCONFIG
# ============================================================
do_defconfig() {
    log_step "Generate defconfig"
    
    if [[ ! -f "$KERNEL_DIR/arch/arm64/configs/$DEFCONFIG" ]]; then
        log_error "Defconfig tidak ditemukan: arch/arm64/configs/$DEFCONFIG"
    fi
    
    log_info "Base defconfig: $DEFCONFIG"
    
    # Make sure output dir exists
    mkdir -p "$OUT_DIR"
    rm -f "$OUT_DIR/.config" "$OUT_DIR/.config.old"
    
    # Generate base defconfig
    make_kernel "$DEFCONFIG"
    
    # Merge extra configs
    for config_frag in $EXTRA_CONFIG; do
        if [[ -f "$KERNEL_DIR/arch/arm64/configs/$config_frag" ]]; then
            log_info "Merging: $config_frag"
            cat "$KERNEL_DIR/arch/arm64/configs/$config_frag" >> "$OUT_DIR/.config"
        fi
    done
    
    # Regenerate config with merged fragments
    make_kernel olddefconfig
    
    log_success "Defconfig dihasilkan dengan fragments"
}

# ============================================================
# BUILD KERNEL
# ============================================================
do_build() {
    log_step "Build kernel (Image.gz-dtb)"
    
    if [[ ! -f "$OUT_DIR/.config" ]]; then
        log_warn "File .config tidak ditemukan, generate defconfig dulu"
        do_defconfig
    fi
    
    log_info "Building dengan $(nproc --all) cores..."
    make_kernel Image.gz-dtb
    
    if [[ ! -f "$OUT_DIR/$KERNEL_IMAGE" ]]; then
        log_error "Build gagal — kernel image tidak ditemukan"
    fi
    
    log_success "Kernel image: $OUT_DIR/$KERNEL_IMAGE"
}

# ============================================================
# MAIN
# ============================================================
main() {
    case "${1:-build}" in
        clean)
            check_deps
            setup_env
            do_clean
            ;;
        defconfig)
            check_deps
            setup_env
            do_defconfig
            ;;
        build|"")
            check_deps
            setup_env
            do_defconfig
            do_build
            log_success "Build selesai!"
            ;;
        *)
            echo "Usage: $0 [clean|defconfig|build]"
            exit 1
            ;;
    esac
}

main "$@"
