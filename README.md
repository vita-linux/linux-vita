# linux-vita

A custom Linux kernel built from vanilla kernel.org source with BORE scheduler.

## Features

- **BORE Scheduler**: Burst-Oriented Response Enhancer for improved desktop responsiveness
- **Vanilla base**: Built directly from kernel.org source (7.1.1)
- **Clean approach**: Only BORE scheduler patch applied, no other modifications

## Download

Pre-built tarball: [linux-vita-7.1.1.tar.xz](releases/7.1.1/linux-vita-7.1.1.tar.xz)

## Build Instructions

### Using PKGBUILD (Arch Linux)

```bash
# Clone the repository
git clone https://github.com/yourusername/linux-vita.git
cd linux-vita

# Build the package
makepkg -si
```

### Manual Build

```bash
# Download the tarball
curl -LO https://github.com/yourusername/linux-vita/releases/download/v7.1.1/linux-vita-7.1.1.tar.xz

# Extract and build
tar -xf linux-vita-7.1.1.tar.xz
cd linux-7.1.1
make defconfig
./scripts/config -e SCHED_BORE
make -j$(nproc)
sudo make modules_install
sudo make install
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## Verify BORE Scheduler

After installing and rebooting:

```bash
# Check kernel version
uname -r

# Verify BORE is enabled
cat /proc/sys/kernel/sched_bore  # Should output 1

# Check BORE statistics
cat /proc/schedstat | grep -i bore
```

## Patch Details

The kernel includes the BORE scheduler patch with modifications:
- Replaced "cachy" references with "vita"
- Fixed compilation issues for kernel 7.1.1
- Clean integration with vanilla kernel source

## License

GPL-2.0 (same as Linux kernel)

## Credits

- Linux kernel maintainers
- BORE scheduler by Masahito Suzuki <firelzrd@gmail.com>
- CachyOS for patch reference