#!/bin/bash
# Kernel Patch Repository Cleanup
# Removes non-functional patches and fixes repairable ones
#
# Based on comprehensive analysis in PATCH_ANALYSIS_REPORT.md

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

echo "=================================================="
echo "Kernel Patch Repository Cleanup"
echo "=================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Create backup directory
BACKUP_DIR="removed_patches_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

print_info "Backing up patches to: $BACKUP_DIR"
echo ""

# List of patches to REMOVE (non-functional/cosmetic)
PATCHES_TO_REMOVE=(
    "audio-latency.patch"
    "compiler-optimizations.patch"
    "cpu-wakeup-optimize.patch"
    "disk-readahead.patch"
    "filesystem-performance.patch"
    "futex-performance.patch"
    "gpu-performance.patch"
    "io-scheduler.patch"
    "irq-optimize.patch"
    "locking-optimize.patch"
    "mm-readahead.patch"
    "network-buffers.patch"
    "page-allocator-optimize.patch"
    "pcie-performance.patch"
    "rcu-nocb-optimize.patch"
    "sysctl-performance.patch"
    "usb-performance.patch"
    "vfs-cache-optimize.patch"
    "writeback-optimize.patch"
    "zen4-avx512-optimize.patch"
    "zen4-cache-optimize.patch"
    "zen4-ddr5-optimize.patch"
)

# List of patches to KEEP (reference examples)
PATCHES_TO_KEEP=(
    "cachyos.patch"
    "dkms-clang.patch"
)

# List of patches to FIX (repairable)
PATCHES_TO_FIX=(
    "tcp-westwood.patch"
    "cstate-disable.patch"
    "zswap-performance.patch"
)

echo "=================================================="
echo "CLEANUP PLAN"
echo "=================================================="
echo ""
print_success "KEEP (no changes): ${#PATCHES_TO_KEEP[@]} patches"
for patch in "${PATCHES_TO_KEEP[@]}"; do
    echo "  ✅ $patch"
done
echo ""

print_warning "FIX (regenerate): ${#PATCHES_TO_FIX[@]} patches"
for patch in "${PATCHES_TO_FIX[@]}"; do
    echo "  🔧 $patch"
done
echo ""

print_error "REMOVE (non-functional): ${#PATCHES_TO_REMOVE[@]} patches"
for patch in "${PATCHES_TO_REMOVE[@]}"; do
    echo "  ❌ $patch"
done
echo ""

# Confirm action
read -p "Proceed with cleanup? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    print_warning "Cleanup cancelled"
    exit 0
fi

echo "=================================================="
echo "EXECUTING CLEANUP"
echo "=================================================="
echo ""

# Remove non-functional patches
print_info "Removing non-functional patches..."
REMOVED_COUNT=0
for patch in "${PATCHES_TO_REMOVE[@]}"; do
    if [ -f "$patch" ]; then
        mv "$patch" "$BACKUP_DIR/"
        print_success "Removed: $patch"
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    else
        print_warning "Not found: $patch"
    fi
done
echo ""

# Mark patches that need fixing
print_info "Patches requiring manual fixes (flagged for review)..."
for patch in "${PATCHES_TO_FIX[@]}"; do
    if [ -f "$patch" ]; then
        print_warning "NEEDS FIX: $patch"
        echo "# TODO: Regenerate with proper git headers" > "${patch}.TODO"
    fi
done
echo ""

echo "=================================================="
echo "CLEANUP SUMMARY"
echo "=================================================="
echo ""
echo "Patches removed: $REMOVED_COUNT"
echo "Patches kept: ${#PATCHES_TO_KEEP[@]}"
echo "Patches needing fixes: ${#PATCHES_TO_FIX[@]}"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""

print_info "Next steps:"
echo "1. Review PATCH_ANALYSIS_REPORT.md for detailed analysis"
echo "2. Fix the 3 repairable patches:"
echo "   - tcp-westwood.patch (regenerate headers)"
echo "   - cstate-disable.patch (extract real changes, remove cosmetic)"
echo "   - zswap-performance.patch (keep settings, fix const removal)"
echo "3. Update README.md and validate-patches.sh"
echo ""

print_success "Cleanup complete!"
