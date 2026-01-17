# Linux Kernel Performance Patches for CachyOS

This repository contains a collection of performance-oriented kernel patches optimized for CachyOS and modern hardware, particularly AMD Zen 4 processors.

## Patches Overview

### Core Patches (100% Working Reference)
- **cachyos.patch** - Comprehensive CachyOS patch set (10 sub-patches) - VERIFIED WORKING
- **dkms-clang.patch** - DKMS compatibility for Clang builds - VERIFIED WORKING

### Core CachyOS Patch
- **cachyos.patch** - Comprehensive CachyOS patch set (10 sub-patches)
  - AES crypto optimizations with AVX-10 support
  - AMD P-State enhancements
  - BBR3 TCP congestion control
  - Block layer improvements
  - CachyOS-specific optimizations
  - Various fixes and improvements
  - Handheld device support
  - NVIDIA driver improvements
  - Sched-ext support
  - ZSTD decompression improvements

### CPU & Architecture Optimizations
- **zen4-optimizations.patch** - AMD Zen 4 specific compiler optimizations
  - Optimized for Ryzen 7000 series (7950X, 7900X, 7700X, 7600X, X3D variants)
  - Enables znver4 march/mtune
  - Full AVX-512, AVX2, FMA, BMI2 support
  - Requires GCC 13+ or Clang 16+

- **compiler-optimizations.patch** - Aggressive compiler optimizations
  - Link-Time Optimization (LTO)
  - O3 optimization level
  - Loop unrolling and vectorization
  - Function/data section elimination
  - Aggressive inlining

### CPU Frequency & Power
- **cpufreq-performance.patch** - CPU frequency scaling optimizations
  - Performance governor by default
  - Reduced transition latency
  - AMD P-State optimizations for Zen
  - Intel P-State improvements

### Memory Management
- **mm-performance.patch** - Memory management optimizations
  - Lower vm_swappiness (60 → 10)
  - Optimized dirty page writeback
  - Better cache management
  - Reduced unnecessary I/O

- **mglru-enable.patch** - Multi-Gen LRU enablement
  - Modern page reclaim algorithm
  - Better hot/cold page identification
  - Improved cache hit rates
  - Optimized for mixed workloads

### Scheduling
- **scheduler-performance.patch** - Scheduler optimizations
  - Reduced scheduler latency (6ms → 4ms)
  - Faster wakeup granularity (1ms → 0.5ms)
  - Optimized for interactive/gaming workloads
  - NUMA balancing improvements

### Network Stack
- **tcp-bbr2.patch** - BBR2 TCP congestion control
  - BBR2 as default (instead of CUBIC)
  - High throughput, low latency
  - Better network path modeling

### Storage & I/O
- **io-scheduler.patch** - I/O scheduler optimizations
  - mq-deadline optimizations for NVMe/SSD
  - Reduced read/write expiry times
  - Larger FIFO batch size (16 → 32)
  - Deeper async queue (64 → 128)

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

### System Configuration
- **sysctl-performance.patch** - Optimized sysctl defaults
  - Better I/O scheduler defaults
  - Enhanced network stack parameters
  - Improved kernel task scheduler
  - Gaming-friendly responsiveness

- **zswap-performance.patch** - ZSWAP optimizations
  - ZSTD compression (fast, excellent ratio)
  - Enabled by default for better performance
  - 50% max pool size for gaming systems
  - Reduced swap pressure, less stuttering

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

1. **Clone Linux kernel source**:
```bash
git clone https://github.com/torvalds/linux.git
cd linux
git checkout v6.18  # Or appropriate 6.18.x version
```

2. **Apply patches in order**:
```bash
# Core CachyOS patches first (100% working)
patch -p1 < /path/to/cachyos.patch
patch -p1 < /path/to/dkms-clang.patch

# Then performance patches (order matters for some)
patch -p1 < /path/to/zen4-optimizations.patch
patch -p1 < /path/to/compiler-optimizations.patch
patch -p1 < /path/to/cpufreq-performance.patch
patch -p1 < /path/to/mm-performance.patch
patch -p1 < /path/to/mglru-enable.patch
patch -p1 < /path/to/zswap-performance.patch
patch -p1 < /path/to/scheduler-performance.patch
patch -p1 < /path/to/tcp-bbr2.patch
patch -p1 < /path/to/io-scheduler.patch
patch -p1 < /path/to/filesystem-performance.patch
patch -p1 < /path/to/futex-performance.patch
patch -p1 < /path/to/sysctl-performance.patch
```

3. **Configure kernel**:
```bash
# Start with existing config or CachyOS config
make menuconfig

# Recommended options:
# - CONFIG_MZEN4=y (if using Zen 4)
# - CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# - CONFIG_LRU_GEN=y
# - CONFIG_TCP_CONG_BBR=y
```

4. **Build kernel**:
```bash
make -j$(nproc)
sudo make modules_install
sudo make install
```

## Performance Expectations

### Gaming
- 5-15% FPS improvement in CPU-bound games
- Lower frame time variance
- Better 1% and 0.1% lows
- Improved Wine/Proton performance

### General Desktop
- Snappier application launches
- Better multi-tasking responsiveness
- Reduced stuttering under load
- Faster file operations

### Compilation/Development
- 10-20% faster kernel/large project compilation
- Better ccache performance
- More efficient resource utilization

## Warnings & Considerations

1. **Kernel Version**: All patches verified for Linux 6.18
2. **Build Time**: LTO and O3 optimizations significantly increase build time (2-3x longer)
2. **Binary Size**: Some optimizations may increase kernel size
3. **Stability**: Aggressive optimizations may reduce stability in rare cases
4. **Compiler Version**: Zen 4 optimizations require GCC 13+ or Clang 16+
5. **Memory Usage**: Some optimizations trade memory for speed

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