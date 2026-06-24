# Build Checklist for linux-vita

## Prerequisites
- [ ] Arch Linux system with up-to-date packages
- [ ] Sufficient disk space (10GB+ for build, 5GB+ for source)

## Build Steps

### 1. Install Dependencies
```bash
sudo pacman -Syu base-devel bc binutils cpio gettext libelf libgcc openssl pahole perl python rust rust-bindgen rust-src tar xxhash xz zlib zstd graphviz imagemagick python-sphinx python-yaml texlive-latexextra
```

### 2. Verify Source Files
```bash
# Check the kernel source exists
ls -la linux/

# Check patch is present
ls -la patches/bore.patch
```

### 3. Verify Configuration
```bash
# Check BORE is enabled
grep CONFIG_SCHED_BORE linux/config.x86_64

# Check MIN_BASE_SLICE is set
grep CONFIG_MIN_BASE_SLICE_NS linux/config.x86_64
```

### 4. Build Kernel
```bash
cd linux
makepkg -sf
```

**What happens:**
1. Downloads kernel source from kernel.org
2. Applies `patches/linux-v7.0.13-arch1.patch` (Arch Linux patch)
3. Applies `patches/bore.patch`
4. Enables `CONFIG_SCHED_BORE` via `scripts/config`
5. Runs `olddefconfig` to finalize config
6. Builds kernel and modules
7. Creates installable packages

### 5. Install Kernel
```bash
# Install main kernel package
sudo pacman -U linux-vita-*.pkg.tar.zst

# Install headers for building external modules
sudo pacman -U linux-vita-headers-*.pkg.tar.zst
```

### 6. Update Initramfs
```bash
sudo mkinitcpio -P
```

### 7. Update Bootloader
If using GRUB:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 8. Reboot and Verify
```bash
# Reboot to new kernel
sudo reboot

# After reboot, verify kernel version
uname -r

# Verify BORE is enabled
cat /proc/sys/kernel/sched_bore
```

## Post-Installation

### Build vhba-module
```bash
# Install vhba-module from AUR or build manually
# It will automatically rebuild against new kernel
```

### Test Virtual CD/DVD
```bash
# Test CDEmu if installed
cdemu --status
```

## Troubleshooting

### Build Fails
```bash
# Clean and rebuild
makepkg -scf

# Check disk space
df -h

# Check for missing dependencies
makepkg -p  # prints dependencies
```

### Kernel Doesn't Boot
- Boot from previous kernel
- Check `/boot` for missing files
- Verify GRUB configuration

### Modules Not Loading
```bash
# Verify headers installed
ls /usr/src/linux-vita

# Rebuild external modules
make clean && make
```

### BORE Not Active
```bash
# Check config
cat /proc/config.gz | gunzip | grep SCHED_BORE

# Check sysctl
cat /proc/sys/kernel/sched_bore
```

## Package Contents

| Package | Description |
|---------|-------------|
| `linux-vita` | Main kernel image and modules |
| `linux-vita-headers` | Headers for building external modules |
| `linux-vita-docs` | Kernel documentation |

## Files Created

| File/Path | Purpose |
|-----------|---------|
| `/boot/vmlinuz-linux-vita` | Kernel image |
| `/usr/lib/modules/7.0.12.arch1-*` | Kernel modules |
| `/usr/src/linux-vita` | Kernel headers source |

## Next Steps

After successful build:
1. Add more patches as needed
2. Configure additional scheduler options
3. Set up automatic module rebuilding
4. Consider adding hardware-specific optimizations
