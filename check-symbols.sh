#!/bin/bash
# Symbol validation for performance patches
# Checks that patches don't reference undefined symbols/MSRs

set -e

echo "=== Checking patches for undefined symbols ==="
echo

ERRORS=0

# The 5 patches we're validating (from task requirements)
PATCHES=(
    "zen4-cache-optimize.patch"
    "gpu-performance.patch"
    "compiler-optimizations.patch"
    "pcie-performance.patch"
    "cstate-disable.patch"
)

# Known good kernel symbols
KNOWN_MSRS=(
    "MSR_AMD_64_BU_CFG2"    # 0xC001102A - AMD BU_CFG2
    "MSR_K7_HWCR"           # 0xC0010015 - AMD HWCR
)

KNOWN_FUNCS=(
    "rdmsrl_safe"
    "wrmsrl_safe"
    "pcie_capability_read_word"
    "pcie_capability_write_word"
    "pcie_set_readrq"
    "set_user_nice"
    "set_cpus_allowed_ptr"
    "module_param"
    "MODULE_PARM_DESC"
    "pci_info"
)

# Check each patch
for patch in "${PATCHES[@]}"; do
    if [ ! -f "$patch" ]; then
        echo "ERROR: $patch not found!"
        ERRORS=$((ERRORS + 1))
        continue
    fi
    
    echo "Checking $patch..."
    
    # Extract added lines only
    ADDED=$(grep "^+" "$patch" | grep -v "^+++" || true)
    
    # Check for fake MSRs (common pattern: MSR_AMD_* or MSR_*_PREFETCH_CFG)
    FAKE_MSRS=$(echo "$ADDED" | grep -oE 'MSR_[A-Z0-9_]+' | sort -u || true)
    
    if [ -n "$FAKE_MSRS" ]; then
        echo "  Found MSR references:"
        for msr in $FAKE_MSRS; do
            # Check if it's a known good MSR
            if [[ " ${KNOWN_MSRS[@]} " =~ " ${msr} " ]]; then
                echo "    ✓ $msr (known kernel MSR)"
            else
                echo "    ✗ $msr (UNKNOWN - may not exist!)"
                ERRORS=$((ERRORS + 1))
            fi
        done
    fi
    
    # Check for undefined X86_FEATURE_* flags
    FEATURES=$(echo "$ADDED" | grep -oE 'X86_FEATURE_[A-Z0-9_]+' | sort -u || true)
    if [ -n "$FEATURES" ]; then
        echo "  Found feature flags:"
        for feat in $FEATURES; do
            # X86_FEATURE_ZEN is known, ZEN4 might not be
            if [ "$feat" = "X86_FEATURE_ZEN4" ]; then
                echo "    ? $feat (may need to be defined)"
            else
                echo "    ✓ $feat"
            fi
        done
    fi
    
    echo
done

echo "=== Patch Statistics ==="
for patch in "${PATCHES[@]}"; do
    if [ -f "$patch" ]; then
        LINES=$(wc -l < "$patch")
        ADDED=$(grep -c "^+" "$patch" || true)
        REMOVED=$(grep -c "^-" "$patch" || true)
        printf "%-30s: %3d lines (%3d added, %3d removed)\n" "$patch" "$LINES" "$ADDED" "$REMOVED"
    fi
done

echo
if [ $ERRORS -eq 0 ]; then
    echo "✓ All patches look good!"
    exit 0
else
    echo "✗ Found $ERRORS potential issues"
    exit 1
fi
