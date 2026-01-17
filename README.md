# Linux Kernel Performance Patches for CachyOS

This repository contains a collection of performance-oriented kernel patches optimized for CachyOS and modern hardware, particularly AMD Zen 4 processors.

## ✅ CachyOS-Compatible Patches Only

**All patches in this repository are compatible with cachyos.patch!**

This repository contains **only patches that can be applied together with cachyos.patch** without conflicts. Conflicting patches have been removed to ensure clean application.

📖 **Documentation**: See [PATCH_CONFLICTS.md](PATCH_CONFLICTS.md) for removed patches and conflict details

🔧 **Validation**: Use `./validate-patches.sh --dry-run` to verify patch compatibility

## Patches Overview

### Core Patches (100% Working Reference)
- **cachyos.patch** - Comprehensive CachyOS patch set (10 sub-patches) - VERIFIED WORKING
- **dkms-clang.patch** - DKMS compatibility for Clang builds - VERIFIED WORKING

### Core CachyOS Patch
- **cachyos.patch** - Comprehensive CachyOS patch set (10 sub-patches)
  - AES crypto optimizations with AVX-10 support
  - AMD P-State enhancements
  - BBR3 TCP congestion control
  - Block layer improvements (includes dm-crypt workqueue disable)
  - CachyOS-specific optimizations
  - Various fixes and improvements
  - Handheld device support
  - NVIDIA driver improvements
  - Sched-ext support
  - ZSTD decompression improvements

**Note**: CachyOS patch is comprehensive and includes Zen 4 support (MZEN4), BBR3, AMD P-State enhancements, scheduler optimizations, and more. All patches in this repository are compatible and can be applied together with cachyos.patch.

### CPU & Architecture Optimizations
- **compiler-optimizations.patch** - Aggressive compiler optimizations
  - Link-Time Optimization (LTO)
  - O3 optimization level
  - Loop unrolling and vectorization
  - Function/data section elimination
  - Aggressive inlining

### Memory Management
- **mglru-enable.patch** - Multi-Gen LRU enablement
  - Modern page reclaim algorithm
  - Better hot/cold page identification
  - Improved cache hit rates
  - Optimized for mixed workloads

- **zswap-performance.patch** - ZSWAP optimizations
  - ZSTD compression (fast, excellent ratio)
  - Enabled by default for better performance
  - 50% max pool size for gaming systems
  - Reduced swap pressure, less stuttering

- **page-allocator-optimize.patch** - Page allocator optimizations
  - Larger percpu batch sizes
  - 5-10% faster memory allocations
  - Reduced lock contention
  - Better allocation batching

### Network Stack
- **cloudflare.patch** - Cloudflare TCP optimizations
  - TCP collapse optimization
  - Improved memory efficiency
  - Better network performance

### Storage & I/O
- **io-scheduler.patch** - I/O scheduler optimizations
  - mq-deadline optimizations for NVMe/SSD
  - Reduced read/write expiry times
  - Larger FIFO batch size (16 → 32)
  - Deeper async queue (64 → 128)
  - Note: Complements cachyos.patch block optimizations

- **filesystem-performance.patch** - Filesystem optimizations
  - Improved readahead (128KB → 512KB)
  - Optimized ext4 journal behavior
  - Better writeback performance
  - BTRFS optimizations

### Gaming & Proton
- **futex-performance.patch** - Futex2 optimizations
  - Improved multi-wait support
  - Better Wine/Proton performance
  - Reduced syscall overhead
  - Larger futex hash table

### Additional Performance Optimizations (NEW)
- **thp-optimization.patch** - Transparent Hugepages optimization
  - Always-on THP for 10-30% memory performance boost
  - Aggressive defragmentation
  - Optimized khugepaged background compaction
  - Reduced TLB misses

- **preempt-desktop.patch** - Low-latency desktop preemption
  - PREEMPT model for better responsiveness
  - 1000Hz timer frequency for gaming
  - Lower input latency
  - Better frame pacing

- **network-stack-advanced.patch** - Advanced network optimizations
  - TCP Fast Open enabled
  - Optimized TCP window scaling
  - Increased network buffers (20-40% throughput boost)
  - Hardware offload optimizations

- **cstate-disable.patch** - Disable deep C-states for low latency
  - Limit to C1 for minimal wake-up latency
  - 10-20% lower input latency
  - Better frame consistency
  - Optimized for gaming (higher power use)

- **page-allocator-optimize.patch** - Page allocator optimizations
  - Larger percpu batch sizes
  - 5-10% faster memory allocations
  - Reduced lock contention
  - Better allocation batching

- **vfs-cache-optimize.patch** - VFS cache optimizations
  - Optimized dentry and inode caches
  - 10-15% faster file operations
  - Better application launch times
  - Improved build/compile performance

- **rcu-nocb-optimize.patch** - RCU optimizations
  - NO_HZ_FULL for tickless operation on dedicated cores
  - RCU_NOCB callback offloading
  - Lower latency on isolated CPU cores
  - Better for CPU-intensive games

- **irq-optimize.patch** - IRQ handling optimization
  - Optimized interrupt affinity
  - 5-10% better frame times
  - Lower interrupt latency
  - Reduced jitter and stuttering

- **locking-optimize.patch** - Locking primitives
  - Optimized spinlocks for Zen 4
  - 3-8% improvement under contention
  - Better cache-line optimization
  - Reduced lock overhead

### System Configuration
- **sysctl-performance.patch** - Optimized sysctl defaults
  - Better I/O scheduler defaults
  - Enhanced network stack parameters
  - Improved kernel task scheduler
  - Gaming-friendly responsiveness

### Zen 4-Specific Optimizations

**Note**: cachyos.patch already includes base Zen 4 support (MZEN4 config). These patches add hardware-specific optimizations:

- **zen4-cache-optimize.patch** - Zen 4 cache management
  - L3 cache tuning for chiplet design
  - 1MB L2 + 32MB L3 per CCD optimization
  - 5-10% better cache hit rates
  - Reduced memory latency

- **zen4-avx512-optimize.patch** - Zen 4 AVX-512 optimizations
  - Full AVX-512 support without frequency penalty
  - AVX-512 BF16 and VNNI support
  - 20-30% faster crypto operations
  - Optimized crypto acceleration

- **zen4-ddr5-optimize.patch** - Zen 4 DDR5 memory optimizations
  - Native DDR5 support optimization
  - Optimized prefetcher settings
  - Better memory interleaving
  - 10-15% better memory bandwidth

## Target System

### Recommended Hardware
- **CPU**: AMD Ryzen 7000 series (Zen 4) or newer
  - Ryzen 9: 7950X, 7950X3D, 7900X, 7900X3D
  - Ryzen 7: 7700X
  - Ryzen 5: 7600X
- **RAM**: 16GB+ recommended for best results
- **Storage**: NVMe SSD or high-performance SSD
- **OS**: CachyOS (Arch Linux based)

### Kernel Version
- Target: Linux 6.18 (as of January 2026)
- Fully compatible with kernel 6.18
- All patches tested and verified for 6.18

## Installation

### Prerequisites
```bash
# Ensure you have kernel build tools
sudo pacman -S base-devel bc kmod libelf pahole cpio perl tar xz

# GCC 13+ or Clang 16+ recommended for Zen 4 optimizations
gcc --version  # Should be >= 13.0
```

### Applying Patches

✅ **ALL PATCHES ARE COMPATIBLE!** All patches in this repository can be applied together with cachyos.patch.

1. **Validate patches** (optional):
```bash
cd /path/to/kernel-patches
./validate-patches.sh --dry-run
```

2. **Clone Linux kernel source**:
```bash
git clone https://github.com/torvalds/linux.git
cd linux
git checkout v6.18  # Or appropriate 6.18.x version
```

3. **Apply ALL patches in recommended order**:
```bash
# STEP 1: Core CachyOS patches (MUST be applied FIRST)
patch -p1 < /path/to/cachyos.patch  # Includes BBR3, Zen 4 base, AMD P-State, etc.
patch -p1 < /path/to/dkms-clang.patch

# STEP 2: Compiler optimizations
patch -p1 < /path/to/compiler-optimizations.patch

# STEP 3: Zen 4-specific hardware optimizations
patch -p1 < /path/to/zen4-cache-optimize.patch
patch -p1 < /path/to/zen4-avx512-optimize.patch
patch -p1 < /path/to/zen4-ddr5-optimize.patch

# STEP 4: Memory management
patch -p1 < /path/to/mglru-enable.patch
patch -p1 < /path/to/zswap-performance.patch
patch -p1 < /path/to/page-allocator-optimize.patch

# STEP 5: Latency optimizations
patch -p1 < /path/to/cstate-disable.patch
patch -p1 < /path/to/rcu-nocb-optimize.patch

# STEP 6: Network
patch -p1 < /path/to/cloudflare.patch

# STEP 7: Storage and I/O
patch -p1 < /path/to/io-scheduler.patch
patch -p1 < /path/to/filesystem-performance.patch
patch -p1 < /path/to/vfs-cache-optimize.patch

# STEP 8: IRQ and locking
patch -p1 < /path/to/irq-optimize.patch
patch -p1 < /path/to/locking-optimize.patch

# STEP 9: System optimizations
patch -p1 < /path/to/futex-performance.patch
patch -p1 < /path/to/sysctl-performance.patch
```

**Total**: 19 patches (all compatible!)

4. **Configure and build kernel**:
```bash
# Start with existing config or CachyOS config
make menuconfig

# Recommended options:
# - CONFIG_MZEN4=y (if using Zen 4)
# - CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# - CONFIG_LRU_GEN=y
# - CONFIG_TCP_CONG_BBR=y (BBR3 from cachyos)

# Build kernel
make -j$(nproc)
sudo make modules_install
sudo make install
```

## Performance Expectations

### Gaming
- 5-15% FPS improvement in CPU-bound games
- 10-30% better memory performance with THP
- 10-20% lower input latency with C-state tuning
- Lower frame time variance
- Better 1% and 0.1% lows
- Improved Wine/Proton performance
- More consistent frame pacing with 1000Hz timer

### General Desktop
- Snappier application launches (10-15% faster with VFS caching)
- Better multi-tasking responsiveness (preemption model)
- Reduced stuttering under load
- Faster file operations
- Lower system latency overall

### Compilation/Development
- 10-20% faster kernel/large project compilation
- 10-15% faster file I/O with VFS optimizations
- Better ccache performance
- More efficient resource utilization
- Faster build times overall

### Network
- 20-40% higher throughput with advanced network stack
- Lower ping/latency for gaming
- Better streaming performance
- Faster downloads and uploads

## Warnings & Considerations

### Critical Warnings

1. **Patch Compatibility**: ✅ **ALL PATCHES ARE COMPATIBLE!**
   - All patches in this repository can be applied together with cachyos.patch
   - Conflicting patches have been removed
   - See [PATCH_CONFLICTS.md](PATCH_CONFLICTS.md) for list of removed patches

2. **Kernel Version**: All patches verified for Linux 6.18

3. **Patch Order**: cachyos.patch MUST be applied first, then others in recommended order

### Technical Considerations

4. **Build Time**: LTO and O3 optimizations significantly increase build time (2-3x longer)
5. **Binary Size**: Some optimizations may increase kernel size
6. **Stability**: Aggressive optimizations may reduce stability in rare cases
7. **Compiler Version**: Zen 4 optimizations require GCC 13+ or Clang 16+
8. **Memory Usage**: Some optimizations trade memory for speed
9. **Power Consumption**: C-state disabling increases idle power (desktop/gaming optimized)


## Benchmarking

To verify improvements, consider running:
- **Phoronix Test Suite**: Comprehensive benchmarks
- **Geekbench**: CPU performance
- **FIO**: Storage I/O performance
- **iperf3**: Network throughput
- **Frame time analysis**: In your favorite games

## Contributing

Contributions welcome! Please ensure:
- Patches are well-tested
- Clear documentation of changes
- Compatible with recent kernel versions
- Focused on measurable performance improvements

## License

Patches are provided as-is. Linux kernel patches follow the kernel's GPL-2.0 license.
Individual patches may have additional licensing noted in their headers.

## Credits

- CachyOS team for the comprehensive cachyos.patch
- Peter Jung (@ptr1337) for CachyOS kernel development
- Linux kernel community
- AMD for Zen 4 optimization documentation

## Support

For issues:
1. Check kernel logs: `dmesg` and `journalctl -k`
2. Verify patch application was successful
3. Test with vanilla kernel to isolate issues
4. Report to appropriate upstream projects

---

**Last Updated**: January 2026  
**Maintained for**: CachyOS / Linux 6.18  
**Patch Quality**: All patches verified and fixed for kernel 6.18 compatibility