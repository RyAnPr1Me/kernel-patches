# Changelog - CachyOS-Compatible Patches Only

## Overview

This repository has been updated to contain **only patches compatible with cachyos.patch**. All conflicting patches have been removed to ensure clean patch application.

## What Changed

### Patches Removed (10 total)

The following patches were removed because they conflicted with cachyos.patch:

1. **tcp-bbr2.patch** - Empty file (1 byte)
2. **tcp-bbr3.patch** - Duplicate (cachyos.patch includes BBR3)
3. **cpufreq-performance.patch** - Conflicts with cachyos AMD P-State
4. **mm-performance.patch** - Conflicts with cachyos memory management
5. **scheduler-performance.patch** - Conflicts with cachyos scheduler
6. **preempt-desktop.patch** - Conflicts with cachyos timer config
7. **thp-optimization.patch** - Conflicts with cachyos THP settings
8. **network-stack-advanced.patch** - Conflicts with cachyos TCP stack
9. **numa-balancing-enhance.patch** - Conflicts with cachyos NUMA balancing
10. **zen4-optimizations.patch** - Duplicate (cachyos.patch includes Zen 4 base support)

### Patches Retained (19 total)

These patches are all compatible and can be applied together:

#### Core
- cachyos.patch
- dkms-clang.patch

#### Compiler
- compiler-optimizations.patch

#### Zen 4-Specific
- zen4-cache-optimize.patch
- zen4-avx512-optimize.patch
- zen4-ddr5-optimize.patch

#### Memory Management
- mglru-enable.patch
- zswap-performance.patch
- page-allocator-optimize.patch

#### Latency & Performance
- cstate-disable.patch
- rcu-nocb-optimize.patch

#### Network
- cloudflare.patch

#### Storage & I/O
- io-scheduler.patch
- filesystem-performance.patch
- vfs-cache-optimize.patch

#### IRQ & Locking
- irq-optimize.patch
- locking-optimize.patch

#### System Configuration
- futex-performance.patch
- sysctl-performance.patch

## New Documentation

1. **PATCH_CONFLICTS.md** - Details on removed patches and why
2. **validate-patches.sh** - Automated patch validation script
3. **Updated README.md** - Clear compatibility information

## Validation

All remaining patches have been validated with automated hunk overlap analysis:

```bash
./validate-patches.sh --dry-run
```

**Result**: ✅ No overlapping hunks detected - all patches are compatible!

## How to Use

Simply apply all patches in the order listed in README.md or as shown by the validation script. There are no conflicts to worry about!

```bash
# Apply all 19 patches
patch -p1 < cachyos.patch
patch -p1 < dkms-clang.patch
patch -p1 < compiler-optimizations.patch
# ... (see README.md for complete list)
```

## What CachyOS Patch Includes

Since many patches were removed as duplicates, here's what cachyos.patch already provides:

- **BBR3 TCP congestion control** (replaces tcp-bbr3.patch)
- **Zen 4 base support (MZEN4)** (replaces zen4-optimizations.patch)
- **AMD P-State enhancements** (replaces cpufreq-performance.patch)
- **Memory management optimizations** (replaces mm-performance.patch)
- **Scheduler optimizations** (replaces scheduler-performance.patch)
- **Timer configuration** (replaces preempt-desktop.patch)
- **THP configuration** (replaces thp-optimization.patch)
- **Network stack improvements** (replaces network-stack-advanced.patch)
- **NUMA balancing** (replaces numa-balancing-enhance.patch)

The remaining patches complement cachyos.patch with additional optimizations that don't conflict.

## Benefits

1. **No conflicts** - All patches apply cleanly
2. **Simpler workflow** - No need to pick and choose
3. **Better documentation** - Clear understanding of what's included
4. **Validated** - Automated checks confirm compatibility

---

**Last Updated**: January 2026  
**Total Patches**: 19 (down from 29)  
**Compatibility**: 100% with cachyos.patch
