# linux-vita

Vita-OS custom Arch Linux kernel with the BORE scheduler and additional patches.

## Features

- **BORE Scheduler**: Burst-Oriented Response Enhancer for improved desktop responsiveness
- **vhba-module support**: Virtual SCSI host adapter module for CDEmu support
- **Customizable**: Easy to add your own patches and configuration

## Prerequisites

```bash
sudo pacman -Syu base-devel bc binutils cpio gettext libelf libgcc openssl pahole perl python rust rust-bindgen rust-src tar xxhash xz zlib zstd graphviz imagemagick python-sphinx python-yaml texlive-latexextra
```

## Building

```bash
cd linux
makepkg -sf
```

This will:
1. Download the Arch Linux kernel source
2. Apply the BORE scheduler patch
3. Build the kernel with the custom configuration
4. Create installable packages

## Installation

```bash
sudo pacman -U linux-vita-*.pkg.tar.zst
```

After installation, update your initramfs:

```bash
sudo mkinitcpio -P
```

## Adding More Patches

1. Place patch files in the `patches/` directory
2. Add them to the `source` array in `PKGBUILD`
3. They will be applied automatically during `prepare()`

## Adding More Modules (like vhba-module)

The `vhba-module` package can be built separately against this kernel:

```bash
# Install vhba-module from AUR or build manually
# It will automatically rebuild when you update this kernel
```

## Kernel Config Options

The kernel is configured with:
- `CONFIG_SCHED_BORE=y` - BORE scheduler enabled
- `CONFIG_MIN_BASE_SLICE_NS=2000000` - Minimum base slice for BORE
- `CONFIG_HZ_1000=y` - 1000Hz tick rate for better responsiveness

## Customizing Configuration

To customize the kernel config:

```bash
cd linux
make menuconfig
# or
make nconfig
# or
make xconfig
```

Then rebuild:

```bash
makepkg -sf
```

## BORE Scheduler Tuning

BORE has several tunable parameters accessible via sysctl:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `sched_bore` | 1 | Enable/disable BORE scheduler |
| `sched_burst_inherit_type` | 2 | Burst inheritance (0=off, 1=parent, 2=ancestor) |
| `sched_burst_smoothness` | 1 | Penalty smoothing factor |
| `sched_burst_penalty_offset` | 24 | Penalty offset threshold |
| `sched_burst_penalty_scale` | 1536 | Penalty scaling factor |
| `sched_burst_cache_lifetime` | 75000000 | Cache lifetime in nanoseconds |

## Troubleshooting

### Kernel doesn't boot
- Try booting with `init=/bin/bash` to debug
- Check `dmesg` for errors after boot
- Verify `config.x86_64` is correct

### Modules not loading
- Ensure `linux-vita-headers` is installed
- Rebuild external modules with `make clean && make`

### BORE not working
- Verify `CONFIG_SCHED_BORE=y` in `.config`
- Check `cat /proc/sys/kernel/sched_bore`

## Credits

- Arch Linux kernel maintainers
- BORE scheduler by Masahito Suzuki <firelzrd@gmail.com>
- CachyOS for the BORE patch implementation
