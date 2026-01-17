# Kernel Patch Conflicts and Compatibility

## Overview

This document details all known conflicts between patches in this repository. Understanding these conflicts is critical for successful patch application.

## Critical Conflicts (Cannot Be Applied Together)

### 1. cachyos.patch vs tcp-bbr3.patch ⛔ MAJOR CONFLICT

**Status**: CANNOT use both patches together

**Reason**: cachyos.patch already includes BBR3 implementation as part of its comprehensive patch set (PATCH 03/10). Applying tcp-bbr3.patch on top of cachyos.patch will result in massive conflicts.

**Conflicts**:
- 31 overlapping hunks in `net/ipv4/tcp_bbr.c` (complete file rewrite)
- 5 overlapping hunks in `net/ipv4/tcp_rate.c`
- 3 overlapping hunks in `include/net/tcp.h`
- 2 overlapping hunks in `net/ipv4/tcp_input.c`
- 1 overlapping hunk in each:
  - `net/ipv4/tcp_cong.c`
  - `net/ipv4/tcp_output.c`
  - `net/ipv4/Kconfig`
  - `include/net/inet_connection_sock.h`
  - `include/uapi/linux/rtnetlink.h`
  - `include/uapi/linux/inet_diag.h`

**Solution**: Use cachyos.patch only (BBR3 is already included).

---

### 2. cachyos.patch vs cpufreq-performance.patch ⚠️ HIGH CONFLICT

**Status**: HIGH conflict - patches modify the same code sections

**Reason**: Both patches modify AMD P-State driver functionality in the same locations.

**Conflicts**:
- 2 overlapping hunks in `drivers/cpufreq/amd-pstate.c`
  - Lines 64-70 (initialization code)
  - Lines 727-751 (performance scaling logic)

**Solution**: Use cachyos.patch only (includes AMD P-State enhancements).

---

### 3. cachyos.patch vs mm-performance.patch ⚠️ HIGH CONFLICT

**Status**: HIGH conflict - multiple overlapping memory management changes

**Conflicts**:
- 1 overlapping hunk in `mm/vmscan.c` (lines 185-192)
- 2 overlapping hunks in `mm/page-writeback.c` (lines 71-78, 99-106)

**Solution**: Use cachyos.patch only (includes memory management optimizations).

---

### 4. cachyos.patch vs scheduler-performance.patch ⚠️ MODERATE CONFLICT

**Status**: MODERATE conflict - scheduler tuning overlap

**Conflicts**:
- 1 overlapping hunk in `kernel/sched/fair.c` (lines 73-83 vs 75-82)

**Details**:
- cachyos.patch modifies `sysctl_sched_base_slice` (750us → 350us)
- scheduler-performance.patch modifies `sysctl_sched_latency` (6ms → 4ms)
- Different tunables but overlapping code sections

**Solution**: Use cachyos.patch only, or manually merge if you want both changes.

---

### 5. cachyos.patch vs preempt-desktop.patch ⚠️ MODERATE CONFLICT

**Status**: MODERATE conflict - timer frequency configuration

**Conflicts**:
- 1 overlapping hunk in `kernel/Kconfig.hz` (lines 40-46 vs 40-47)

**Details**: Both patches modify the same Kconfig section for timer frequency.

**Solution**: Use cachyos.patch and manually verify timer frequency settings.

---

### 6. cachyos.patch vs thp-optimization.patch ⚠️ MODERATE CONFLICT

**Status**: MODERATE conflict - THP configuration

**Conflicts**:
- 1 overlapping hunk in `mm/huge_memory.c` (lines 62-69 vs 64-81)

**Details**: Both patches modify transparent hugepage behavior.

**Solution**: Choose one patch or manually merge.

---

### 7. cachyos.patch vs network-stack-advanced.patch ⚠️ LOW CONFLICT

**Status**: LOW conflict - may apply with manual intervention

**Conflicts**:
- 1 overlapping hunk in `net/ipv4/tcp_input.c` (lines 375-382 vs 378-385)

**Solution**: Apply with caution, may need manual merge.

---

### 8. cachyos.patch vs zen4-optimizations.patch ⚠️ LOW CONFLICT

**Status**: LOW conflict - architecture configuration

**Conflicts**:
- 1 overlapping hunk in `arch/x86/Kconfig.cpu` (lines 294-300)

**Details**: Both patches add Zen 4 CPU support in the same Kconfig section.

**Solution**: Patches may apply cleanly if zen4-optimizations is applied after cachyos.

---

### 9. network-stack-advanced.patch vs sysctl-performance.patch ⚠️ LOW CONFLICT

**Status**: LOW conflict - sysctl configuration

**Conflicts**:
- 1 overlapping hunk in `net/ipv4/sysctl_net_ipv4.c` (lines 994-1001 vs 998-1005)

**Solution**: Apply in order: network-stack-advanced first, then sysctl-performance.

---

### 10. network-stack-advanced.patch vs tcp-bbr3.patch ⚠️ LOW CONFLICT

**Status**: LOW conflict

**Conflicts**:
- 1 overlapping hunk in `net/ipv4/tcp_input.c` (lines 378-385 vs 376-383)

**Solution**: Don't apply tcp-bbr3.patch (use cachyos.patch instead).

---

## Files Modified by Multiple Patches

The following files are modified by multiple patches. While not all modifications conflict, these are high-risk areas:

### High-Risk Files (Modified by 3+ patches)

1. **kernel/sched/fair.c** - Modified by:
   - cachyos.patch
   - numa-balancing-enhance.patch
   - scheduler-performance.patch
   - **Risk**: HIGH - scheduler tuning overlaps

2. **mm/Kconfig** - Modified by:
   - cachyos.patch
   - mglru-enable.patch
   - thp-optimization.patch
   - zswap-performance.patch
   - **Risk**: MODERATE - different config sections

3. **mm/vmscan.c** - Modified by:
   - cachyos.patch
   - mglru-enable.patch
   - mm-performance.patch
   - **Risk**: HIGH - memory management overlaps

4. **net/ipv4/sysctl_net_ipv4.c** - Modified by:
   - cloudflare.patch
   - network-stack-advanced.patch
   - sysctl-performance.patch
   - **Risk**: MODERATE - different sysctls

5. **net/ipv4/tcp_input.c** - Modified by:
   - cachyos.patch
   - cloudflare.patch
   - network-stack-advanced.patch
   - tcp-bbr3.patch
   - **Risk**: HIGH - BBR and TCP stack overlaps

6. **net/ipv4/tcp.c** - Modified by:
   - cachyos.patch
   - network-stack-advanced.patch
   - tcp-bbr3.patch
   - **Risk**: HIGH - TCP implementation overlaps

7. **net/ipv4/tcp_output.c** - Modified by:
   - cachyos.patch
   - network-stack-advanced.patch
   - tcp-bbr3.patch
   - **Risk**: HIGH - TCP output overlaps

## Removed Patches

### tcp-bbr2.patch

**Status**: REMOVED (empty file)

**Reason**: File contained only a newline character (1 byte). No actual patch content.

## Recommended Patch Combinations

### Option 1: Maximum Compatibility (Recommended)

Apply these patches in order for maximum compatibility:

```bash
# Core (MUST be first)
patch -p1 < cachyos.patch
patch -p1 < dkms-clang.patch

# Architecture
patch -p1 < zen4-optimizations.patch
patch -p1 < zen4-cache-optimize.patch
patch -p1 < zen4-avx512-optimize.patch
patch -p1 < zen4-ddr5-optimize.patch
patch -p1 < compiler-optimizations.patch

# Memory (non-conflicting)
patch -p1 < mglru-enable.patch
patch -p1 < zswap-performance.patch
patch -p1 < page-allocator-optimize.patch

# Latency
patch -p1 < cstate-disable.patch
patch -p1 < rcu-nocb-optimize.patch

# Network (minimal)
patch -p1 < cloudflare.patch

# Storage
patch -p1 < io-scheduler.patch
patch -p1 < filesystem-performance.patch
patch -p1 < vfs-cache-optimize.patch

# IRQ and locking
patch -p1 < irq-optimize.patch
patch -p1 < locking-optimize.patch

# System
patch -p1 < futex-performance.patch
patch -p1 < sysctl-performance.patch
```

**Total**: 20 patches (safe combination)

---

### Option 2: CachyOS Base Only

If you want minimal risk, use only the core CachyOS patches:

```bash
patch -p1 < cachyos.patch
patch -p1 < dkms-clang.patch
```

**Total**: 2 patches (lowest risk, includes BBR3, AMD P-State, etc.)

---

### Option 3: Maximum Performance (High Risk)

For maximum performance with higher conflict risk:

```bash
# Apply Option 1 patches, then manually resolve conflicts for:
# - scheduler-performance.patch (manual merge with cachyos)
# - thp-optimization.patch (manual merge with cachyos)
# - network-stack-advanced.patch (manual merge with cachyos)
```

**Warning**: Requires manual conflict resolution and testing.

---

## Validation

Use the provided validation script to check for conflicts:

```bash
./validate-patches.sh --dry-run
```

This will analyze all patches and identify conflicts without applying them.

---

## Testing Patch Application

Before applying patches to your production kernel:

1. Clone Linux kernel source:
   ```bash
   git clone https://github.com/torvalds/linux.git
   cd linux
   git checkout v6.18
   ```

2. Test patch application with dry-run:
   ```bash
   patch -p1 --dry-run < /path/to/patch.patch
   ```

3. Check for failures:
   - `succeeded` = patch applies cleanly
   - `FAILED` = conflict detected, manual intervention required
   - `Hunk #N succeeded at X with fuzz Y` = patch applied but with offset

4. If patch fails, examine the `.rej` files to see rejected hunks

---

## Conflict Resolution Strategy

If you need to apply conflicting patches:

1. **Identify the conflict**: Use the validation script
2. **Examine both patches**: Understand what each patch changes
3. **Choose one or merge manually**: 
   - Pick the patch that provides the functionality you need, OR
   - Manually merge both patches using a text editor
4. **Test thoroughly**: Build and test the kernel
5. **Document your changes**: Keep notes on manual merges

---

## Summary Statistics

- **Total patches**: 28 (after removing tcp-bbr2.patch)
- **Safe to apply together**: 20 patches
- **Conflicting with cachyos.patch**: 8 patches
- **Files modified by multiple patches**: 34 files
- **Critical conflicts**: 10 conflict pairs

---

**Last Updated**: January 2026  
**Validation Method**: Automated hunk overlap analysis  
**Kernel Version**: Linux 6.18
