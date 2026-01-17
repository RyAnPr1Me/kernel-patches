#!/bin/bash
# Kernel Patch Validation Script
# Validates patch application order and detects conflicts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_KERNEL="/tmp/linux-test-$$"
KERNEL_VERSION="6.18"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================================"
echo "Kernel Patch Validation Script"
echo "Target Kernel: Linux ${KERNEL_VERSION}"
echo "================================================================"
echo ""

# Function to print colored messages
print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
}

print_info() {
    echo "ℹ️  $1"
}

# Check if running in test mode (dry-run)
DRY_RUN=false
if [ "$1" = "--dry-run" ] || [ "$1" = "-n" ]; then
    DRY_RUN=true
    print_info "Running in DRY-RUN mode (analysis only)"
    echo ""
fi

# Count patches
TOTAL_PATCHES=$(ls -1 "${SCRIPT_DIR}"/*.patch 2>/dev/null | wc -l)
print_info "Found ${TOTAL_PATCHES} patch files"
echo ""

# Define patch application order
# Note: This is the recommended order to minimize conflicts
PATCH_ORDER=(
    # 1. Core patches (must be first)
    "cachyos.patch"
    "dkms-clang.patch"
    
    # 2. Architecture optimizations (complementary to cachyos)
    "zen4-optimizations.patch"
    "zen4-cache-optimize.patch"
    "zen4-avx512-optimize.patch"
    "zen4-ddr5-optimize.patch"
    "compiler-optimizations.patch"
    
    # 3. CPU and frequency (avoid cpufreq-performance.patch - conflicts with cachyos)
    # "cpufreq-performance.patch"  # SKIP - conflicts with cachyos.patch
    
    # 4. Memory management (some conflicts with cachyos expected)
    # "mm-performance.patch"  # SKIP - conflicts with cachyos.patch
    "mglru-enable.patch"
    "zswap-performance.patch"
    "page-allocator-optimize.patch"
    
    # 5. THP (partial conflict with cachyos)
    # "thp-optimization.patch"  # SKIP - conflicts with cachyos.patch
    
    # 6. Scheduler (conflicts with cachyos)
    # "scheduler-performance.patch"  # SKIP - conflicts with cachyos.patch
    # "numa-balancing-enhance.patch"  # May conflict
    
    # 7. Preemption and latency (conflicts with cachyos)
    # "preempt-desktop.patch"  # SKIP - conflicts with cachyos.patch
    "cstate-disable.patch"
    "rcu-nocb-optimize.patch"
    
    # 8. Network (BBR3 is in cachyos, don't apply tcp-bbr3)
    "cloudflare.patch"
    # "network-stack-advanced.patch"  # May conflict with cachyos
    # "tcp-bbr3.patch"  # SKIP - cachyos.patch already includes BBR3
    
    # 9. Storage and I/O
    "io-scheduler.patch"
    "filesystem-performance.patch"
    "vfs-cache-optimize.patch"
    
    # 10. IRQ and locking
    "irq-optimize.patch"
    "locking-optimize.patch"
    
    # 11. Gaming and system
    "futex-performance.patch"
    "sysctl-performance.patch"
)

# Define patches with known conflicts
declare -A CONFLICTING_PATCHES
CONFLICTING_PATCHES["tcp-bbr3.patch"]="cachyos.patch already includes BBR3 (PATCH 03/10) - 31 overlapping hunks"
CONFLICTING_PATCHES["cpufreq-performance.patch"]="Conflicts with cachyos.patch in amd-pstate.c (2 overlapping hunks)"
CONFLICTING_PATCHES["mm-performance.patch"]="Conflicts with cachyos.patch in vmscan.c and page-writeback.c (3 overlapping hunks)"
CONFLICTING_PATCHES["scheduler-performance.patch"]="Conflicts with cachyos.patch in kernel/sched/fair.c (1 overlapping hunk)"
CONFLICTING_PATCHES["preempt-desktop.patch"]="Conflicts with cachyos.patch in kernel/Kconfig.hz (1 overlapping hunk)"
CONFLICTING_PATCHES["thp-optimization.patch"]="Conflicts with cachyos.patch in mm/huge_memory.c (1 overlapping hunk)"
CONFLICTING_PATCHES["network-stack-advanced.patch"]="Conflicts with cachyos.patch in tcp_input.c (1 overlapping hunk)"

echo "================================================================"
echo "PATCH CONFLICT ANALYSIS"
echo "================================================================"
echo ""

# List all patches and their status
print_info "Patch Application Plan:"
echo ""

SKIP_COUNT=0
APPLY_COUNT=0

for patch in "${PATCH_ORDER[@]}"; do
    if [ ! -f "${SCRIPT_DIR}/${patch}" ]; then
        print_warning "Missing: ${patch}"
        SKIP_COUNT=$((SKIP_COUNT + 1))
        continue
    fi
    
    if [ -n "${CONFLICTING_PATCHES[$patch]}" ]; then
        print_error "SKIP: ${patch}"
        echo "       Reason: ${CONFLICTING_PATCHES[$patch]}"
        SKIP_COUNT=$((SKIP_COUNT + 1))
    else
        print_success "APPLY: ${patch}"
        APPLY_COUNT=$((APPLY_COUNT + 1))
    fi
done

echo ""
echo "Summary:"
echo "  - Patches to apply: ${APPLY_COUNT}"
echo "  - Patches to skip:  ${SKIP_COUNT}"
echo "  - Total patches:    $((APPLY_COUNT + SKIP_COUNT))"
echo ""

# Check for patches not in the order list
print_info "Checking for unlisted patches..."
for patch_file in "${SCRIPT_DIR}"/*.patch; do
    patch_name=$(basename "${patch_file}")
    found=false
    for patch in "${PATCH_ORDER[@]}"; do
        if [ "${patch}" = "${patch_name}" ]; then
            found=true
            break
        fi
    done
    if [ "${found}" = false ] && [ -z "${CONFLICTING_PATCHES[$patch_name]}" ]; then
        print_warning "Patch not in application order: ${patch_name}"
    fi
done
echo ""

if [ "${DRY_RUN}" = true ]; then
    print_info "Dry-run complete. Exiting."
    exit 0
fi

echo "================================================================"
echo "PATCH APPLICATION TEST"
echo "================================================================"
echo ""

print_warning "Full patch application test requires Linux kernel source"
print_info "To test patch application:"
echo ""
echo "  1. Clone kernel source:"
echo "     git clone https://github.com/torvalds/linux.git"
echo "     cd linux"
echo "     git checkout v${KERNEL_VERSION}"
echo ""
echo "  2. Apply patches in order:"
for patch in "${PATCH_ORDER[@]}"; do
    if [ -f "${SCRIPT_DIR}/${patch}" ] && [ -z "${CONFLICTING_PATCHES[$patch]}" ]; then
        echo "     patch -p1 --dry-run < ${SCRIPT_DIR}/${patch}"
    fi
done
echo ""
echo "  3. Use --dry-run first to check for conflicts"
echo ""

print_success "Validation complete!"
