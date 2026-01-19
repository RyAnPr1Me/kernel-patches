# Removed Patches Documentation
**Date**: January 19, 2026  
**Action**: Cleanup of non-functional kernel patches  
**Location**: removed_patches_backup/

---

## Summary

**22 patches removed** from the repository due to non-functional or broken implementations.

**Reason for removal**: These patches declared performance optimizations but did not actually implement them. They consisted primarily of:
- Unused module parameters/sysctls
- Cosmetic whitespace changes  
- Fake git commit headers (0000000000000000)
- Comments describing functionality that doesn't exist in code

---

## Removed Patches by Category

### Category A: Unused Tunables (No Implementation)

These patches added sysctl or module_param declarations but never used them in any code path.

#### 1. **cpu-wakeup-optimize.patch** ❌
**Claimed**: "3-8% better task wakeup latency"  
**Reality**: Added 3 variables to kernel/sched/*.c but no code reads them  
**Example**:
```c
+unsigned int sysctl_sched_wakeup_preemption_delay_ns = 1000000;
// But no code like: if (delay < sysctl_sched_wakeup_preemption_delay_ns) ...
```
**Why removed**: Zero functional changes

---

#### 2. **mm-readahead.patch** ❌  
**Claimed**: "20-40% faster sequential reads"  
**Reality**: Added readahead tunables but mm/readahead.c logic unchanged  
**Why removed**: Declarations without usage

---

#### 3. **page-allocator-optimize.patch** ❌
**Claimed**: "5-10% faster memory allocations"  
**Reality**: Added batch size variables but mm/page_alloc.c doesn't reference them  
**Why removed**: No actual allocator changes

---

#### 4. **vfs-cache-optimize.patch** ❌
**Claimed**: "10-15% faster file operations"  
**Reality**: Added dentry/inode cache params, fs/*.c unchanged  
**Why removed**: Cache logic not modified

---

#### 5. **writeback-optimize.patch** ❌
**Claimed**: "Reduced stuttering during heavy writes"  
**Reality**: Added dirty ratio tunables, mm/page-writeback.c logic same  
**Why removed**: Writeback path unmodified

---

#### 6. **irq-optimize.patch** ❌
**Claimed**: "5-10% better frame times"  
**Reality**: Added IRQ affinity params, kernel/irq/*.c logic unchanged  
**Why removed**: No interrupt handling changes

---

#### 7. **locking-optimize.patch** ❌
**Claimed**: "3-8% improvement under contention"  
**Reality**: Added spinlock tunables, kernel/locking/*.c same  
**Why removed**: Lock primitives not touched

---

#### 8. **rcu-nocb-optimize.patch** ❌
**Claimed**: "Lower latency on isolated CPU cores"  
**Reality**: Changed Kconfig help text, no RCU callback changes  
**Why removed**: Mostly documentation, minimal functional change

---

#### 9. **io-scheduler.patch** ❌
**Claimed**: "mq-deadline optimizations for NVMe/SSD"  
**Reality**: Added I/O scheduler params, block/*.c logic identical  
**Why removed**: No block layer modifications

---

#### 10. **pcie-performance.patch** ❌
**Claimed**: "5-10% better PCIe device performance"  
**Reality**: Added PCIe tunables, drivers/pci/*.c unchanged  
**Why removed**: No PCIe logic changes

---

#### 11. **gpu-performance.patch** ❌
**Claimed**: "5-15% better frame pacing"  
**Reality**: Added vblank tunables, drivers/gpu/drm/*.c unchanged  
**Why removed**: No GPU scheduler modifications

---

#### 12. **usb-performance.patch** ❌
**Claimed**: "2-5ms lower input latency"  
**Reality**: Added USB tunables, drivers/usb/*.c logic same  
**Why removed**: No USB stack changes

---

#### 13. **audio-latency.patch** ❌
**Claimed**: "5-20ms lower audio latency"  
**Reality**: Added ALSA tunables, sound/core/*.c unchanged  
**Why removed**: No audio subsystem modifications

---

#### 14. **disk-readahead.patch** ❌
**Claimed**: "15-30% faster sequential reads"  
**Reality**: Same as mm-readahead (duplicated tunables)  
**Why removed**: Duplicate + no implementation

---

#### 15. **sysctl-performance.patch** ❌
**Claimed**: "Optimized sysctl defaults"  
**Reality**: Added sysctl declarations, no kernel logic changes  
**Why removed**: Just variable declarations

---

#### 16. **futex-performance.patch** ❌
**Claimed**: "Improved Wine/Proton performance"  
**Reality**: Added futex tunables, kernel/futex/*.c unchanged  
**Why removed**: No futex logic modifications

---

### Category B: Risky Generic Tuning (Removed for Safety)

These patches made real changes but with questionable benefit/risk trade-offs.

#### 17. **filesystem-performance.patch** ⚠️
**Changes**: Increased readahead 128KB → 512KB, ext4 journal tuning  
**Risk**: May harm slow storage, waste RAM on small files  
**Why removed**: Too generic (not hardware-specific), unvalidated

---

#### 18. **network-buffers.patch** ⚠️
**Changes**: 2-4x larger socket buffers  
**Risk**: Wastes RAM on low-memory systems, TCP autotuning may be better  
**Why removed**: Aggressive tuning not appropriate for all systems

---

### Category C: Broken Implementations

These patches had incomplete or non-functional code.

#### 19. **zen4-avx512-optimize.patch** ❌
**Intent**: Enable AVX-512 for Zen 4  
**Reality**: CPU detection code runs but does nothing:
```c
+if (zen4_detected) {
+    mask |= XFEATURE_MASK_AVX512;  // ← NO-OP: already in mask!
+}
```
**Why removed**: Broken logic, no actual AVX-512 usage, references non-existent CONFIG_MZEN4

---

#### 20. **zen4-cache-optimize.patch** ❌
**Intent**: L2/L3 cache optimization for Zen 4  
**Reality**: Adds CPU detection, sets variables that aren't used  
**Why removed**: Incomplete stub, no cache management changes

---

#### 21. **zen4-ddr5-optimize.patch** ❌
**Intent**: DDR5 memory optimization for Zen 4  
**Reality**: CPU detection + comments, no memory controller changes  
**Why removed**: No actual DDR5-specific code

---

### Category D: Questionable Effectiveness

#### 22. **compiler-optimizations.patch** ⚠️
**Changes**: Adds -O3, -flto, function sections to Makefile  
**Concern**: 
- Longer build time (2-3x)
- Potentially larger binaries  
- Optimization may not help kernel (already uses -O2 carefully)
- Risk of compiler bugs with aggressive opts
**Why removed**: Questionable benefit, high cost, already covered by cachyos.patch Kconfig

---

## What Remains (5 Patches)

### Production Ready (2)
1. **cachyos.patch** - Comprehensive CachyOS optimizations (kept)
2. **dkms-clang.patch** - DKMS/Clang compatibility (kept)

### Needs Minor Fixes (3)
3. **tcp-westwood.patch** - Fix headers, keep Kconfig change (repairable)
4. **cstate-disable.patch** - Extract real C-state changes, remove cosmetic (repairable)
5. **zswap-performance.patch** - Fix headers, clarify const removal (repairable)

---

## Justification for Removal

### Why are unused tunables a problem?

**1. Misleading**
```c
// This code claims to optimize wakeup latency:
unsigned int sysctl_sched_wakeup_preemption_delay_ns = 1000000;
// But no scheduler code actually reads this variable!
// Users think they're getting optimization, but get nothing.
```

**2. Maintenance burden**
- Unused variables waste memory (minor)
- Create confusion for future developers
- Suggest functionality that doesn't exist

**3. False performance claims**
Patches claim "3-8% improvement" but:
- No benchmarks provided
- No code changes to produce improvement
- Impossible to achieve claimed gains with declarations alone

---

### Why not just implement the tunables properly?

**Required effort per patch**: 200-500 lines of actual kernel code
**Example** (cpu-wakeup-optimize):
- Would need changes to `check_preempt_wakeup()`, `select_idle_sibling()`, migration logic
- Extensive testing required
- Potential regressions
- Not appropriate for this cleanup task

**Better approach**:
- Start with reference patches (cachyos, dkms-clang)
- Add new patches only when:
  - Real code changes exist
  - Benchmarks prove performance gains
  - Changes target actual hot paths
  - Suitable for upstream submission

---

## Recovery

If you need any removed patch:
```bash
# All removed patches are in backup:
ls removed_patches_backup/

# To restore a specific patch:
cp removed_patches_backup/PATCH_NAME.patch ./
```

---

## Recommendations for Future Patches

### ✅ Good Patch Checklist
- [ ] Real git commit (no 0000000000000000)
- [ ] Modifies actual kernel source files
- [ ] Changes are in hot paths (proven with perf/ftrace)
- [ ] Benchmarks showing improvement
- [ ] No unused variables/parameters
- [ ] Upstream-appropriate code style
- [ ] Specific hardware target (Zen 4) clearly documented
- [ ] Can build with Clang

### ❌ Anti-Patterns to Avoid
- Fake commit hashes
- Adding module_param() without using the variable
- Mixing cosmetic changes with functional changes
- Claims without benchmarks
- Comments describing non-existent functionality
- Whitespace-only modifications

---

## References

- Full analysis: PATCH_ANALYSIS_REPORT.md
- Good examples: cachyos.patch, dkms-clang.patch
- Kernel docs: Documentation/process/submitting-patches.rst
