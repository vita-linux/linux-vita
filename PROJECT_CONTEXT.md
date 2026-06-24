# linux-vita Project Context

## Project Overview

**linux-vita** is a custom Arch Linux kernel variant with the BORE scheduler and additional patches. This project aims to provide a personalized kernel build optimized for desktop responsiveness while maintaining compatibility with Arch Linux's packaging system.

## Current State (as of June 23, 2026)

### Project Structure
```
linux-vita/
├── linux/                    # Main build directory
│   ├── PKGBUILD             # Modified Arch Linux kernel build script
│   ├── config.x86_64        # Kernel configuration with BORE enabled
│   ├── linux-v7.0.13-arch1.patch  # Arch Linux patch for kernel 7.0.13
│   ├── bore.patch           # BORE scheduler patch
│   ├── .SRCINFO            # Package metadata
│   └── [other arch files...]
├── github-repo/             # GitHub repository structure
│   └── linux-vita/
│       ├── .gitignore
│       └── [other files...]
├── references/              # Reference materials
│   └── linux-cachyos/       # CachyOS kernel PKGBUILDs for reference
├── patches/                 # Original patches location (moved to linux/)
│   └── [empty now]
├── PROJECT_CONTEXT.md       # This file (AI context)
├── README.md               # User documentation
├── BUILD_CHECKLIST.md      # Build instructions
└── setup.sh               # Initial setup script
```

### Key Modifications from Original Arch Linux Kernel

#### 1. PKGBUILD Changes
- **Package name**: Changed from `linux` to `linux-vita`
- **Version**: Updated to `7.0.13.arch1` (from `7.0.12.arch1`)
- **Description**: Added "with BORE scheduler and custom patches"
- **Source array**: Modified to use local patch files instead of downloading from GitHub releases
- **Provides**: Added `VHBA-MODULE` support
- **BORE scheduler**: Added configuration step to enable `CONFIG_SCHED_BORE`

#### 2. Kernel Configuration Changes (`config.x86_64`)
- **BORE scheduler enabled**: `CONFIG_SCHED_BORE=y`
- **Minimum base slice**: `CONFIG_MIN_BASE_SLICE_NS=2000000` (2ms)
- **Tick rate**: `CONFIG_HZ_1000=y` for better responsiveness
- **External scheduler class**: `CONFIG_SCHED_CLASS_EXT=y`

#### 3. Patch Integration
- **Arch Linux patch**: `linux-v7.0.13-arch1.patch` - Contains Arch's modifications to vanilla kernel
- **BORE scheduler patch**: `bore.patch` - Implements Burst-Oriented Response Enhancer scheduler

## How linux-vita Differs from Original Arch Linux Kernel

### 1. BORE Scheduler Integration
- **Original**: Uses standard CFS (Completely Fair Scheduler)
- **linux-vita**: Includes BORE scheduler for improved desktop responsiveness
  - Tracks task burst times
  - Applies penalties based on burst behavior
  - Better handling of interactive workloads
  - Multiple tunable parameters via sysctl

### 2. Build Process Differences
- **Original**: Downloads patches from Arch Linux GitHub releases
- **linux-vita**: Uses local patch files to avoid dependency on external URLs
- **Original**: Standard kernel configuration
- **linux-vita**: Pre-configured with BORE scheduler and 1000Hz tick rate

### 3. Package Metadata
- **Package name**: `linux-vita` vs `linux`
- **Dependencies**: Added compatibility with `vhba-module`
- **Provides**: Extended module compatibility list

### 4. Performance Optimizations
- **BORE scheduler**: Better desktop responsiveness for interactive tasks
- **1000Hz tick rate**: Lower latency for time-sensitive operations
- **Custom configuration**: Tailored for desktop usage patterns

## Build System Details

### Dependencies Required
```bash
sudo pacman -Syu base-devel bc binutils cpio gettext libelf libgcc openssl pahole perl python rust rust-bindgen rust-src tar xxhash xz zlib zstd graphviz imagemagick python-sphinx python-yaml texlive-latexextra
```

### Build Command
```bash
cd linux
makepkg -sf
```

### What Happens During Build
1. Downloads kernel source from kernel.org (7.0.13)
2. Applies Arch Linux patch (`linux-v7.0.13-arch1.patch`)
3. Applies BORE scheduler patch (`bore.patch`)
4. Enables `CONFIG_SCHED_BORE` via `scripts/config`
5. Runs `olddefconfig` to finalize configuration
6. Compiles kernel and modules
7. Creates installable `.pkg.tar.zst` packages

### Installation
```bash
sudo pacman -U linux-vita-*.pkg.tar.zst
sudo pacman -U linux-vita-headers-*.pkg.tar.zst
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## Technical Specifications

### BORE Scheduler Parameters
The kernel includes several BORE-specific sysctl tunables:
- `sched_bore`: Enable/disable BORE scheduler (default: 1)
- `sched_burst_inherit_type`: Burst inheritance type (0=off, 1=parent, 2=ancestor)
- `sched_burst_smoothness`: Penalty smoothing factor
- `sched_burst_penalty_offset`: Penalty offset threshold
- `sched_burst_penalty_scale`: Penalty scaling factor
- `sched_burst_cache_lifetime`: Cache lifetime in nanoseconds

### Compatibility
- **Arch Linux compatibility**: Maintains full compatibility with Arch Linux package management
- **Module support**: Provides `VHBA-MODULE` for CDEmu virtual SCSI support
- **Hardware support**: Inherits all hardware support from Arch Linux kernel
- **Security updates**: Can incorporate Arch Linux security patches

## Development History

### Issues Resolved
1. **Initial build failure**: PKGBUILD tried to download non-existent GitHub release
2. **Patch location**: Moved patches from `patches/` subdirectory to `linux/` directory
3. **Source array**: Fixed brace expansion formatting and patch paths
4. **Version mismatch**: Updated from 7.0.12 to 7.0.13 to match available patch

### Design Decisions
1. **Local patches**: Using local patch files instead of downloading for reliability
2. **Directory structure**: Keeping patches in build directory for makepkg compatibility
3. **Configuration approach**: Pre-enabling BORE scheduler rather than requiring manual config
4. **Package naming**: Clear distinction from official kernel with `-vita` suffix

## Future Directions

### Potential Enhancements
1. **Additional schedulers**: Consider adding other scheduler options
2. **Hardware-specific optimizations**: Add CPU microcode or architecture-specific tweaks
3. **Security hardening**: Enable additional security features
4. **ZEN kernel features**: Incorporate some ZEN kernel optimizations
5. **Automated testing**: Add CI/CD for build verification

### Integration Possibilities
1. **AUR package**: Publish to Arch User Repository
2. **Custom repository**: Create dedicated repository for linux-vita packages
3. **DKMS modules**: Build additional kernel modules
4. **Configuration tools**: Add utilities for BORE scheduler tuning

## For AI Agents Working on This Project

### Key Files to Understand
- `linux/PKGBUILD` - Main build script with all modifications
- `linux/config.x86_64` - Kernel configuration with BORE enabled
- `linux/bore.patch` - BORE scheduler implementation
- `README.md` - User-facing documentation
- `BUILD_CHECKLIST.md` - Step-by-step build instructions

### Common Issues to Watch For
1. **Patch compatibility**: Ensure patches match kernel version
2. **Makepkg quirks**: Understand makepkg's working directory behavior
3. **Dependency management**: Arch Linux build dependencies can be extensive
4. **Configuration conflicts**: When modifying config, watch for option conflicts

### Testing Considerations
1. **Build verification**: Test compilation on clean environment
2. **Boot testing**: Verify kernel boots successfully
3. **Scheduler functionality**: Test BORE scheduler activation
4. **Module compatibility**: Test with external modules like vhba

### Contribution Guidelines
1. **Patch management**: Keep patches in `linux/` directory for makepkg compatibility
2. **Version tracking**: Update all version references when changing kernel version
3. **Documentation**: Update all relevant documentation files
4. **Testing**: Always test build process end-to-end

This document provides comprehensive context for AI agents to understand, maintain, and extend the linux-vita project while preserving the modifications made to create this custom Arch Linux kernel variant.