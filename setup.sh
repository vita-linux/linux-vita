#!/bin/bash
# linux-vita setup script

set -e

echo "=== linux-vita Setup Script ==="
echo

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as regular user
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}This script should not be run as root${NC}"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${GREEN}Setup directory: $SCRIPT_DIR${NC}"
echo

# Verify required files exist
echo "=== Checking Required Files ==="

if [ ! -d "linux" ]; then
    echo -e "${RED}ERROR: linux/ directory not found${NC}"
    echo "The linux directory should contain the Arch kernel source with PKGBUILD"
    exit 1
fi

if [ ! -f "linux/PKGBUILD" ]; then
    echo -e "${RED}ERROR: linux/PKGBUILD not found${NC}"
    exit 1
fi

if [ ! -d "patches" ]; then
    echo -e "${YELLOW}Creating patches directory...${NC}"
    mkdir -p patches
fi

# Check for bore patch
if [ ! -f "patches/bore.patch" ]; then
    echo -e "${YELLOW}BORE patch not found in patches/bore.patch${NC}"
    echo "Please copy the bore patch to patches/bore.patch"
    echo "The patch is typically located at:"
    echo "  references/linux-cachyos/linux-cachyos-bore/0001-bore-cachy.patch"
    exit 1
fi

echo -e "${GREEN}✓ All required files found${NC}"
echo

# Verify configuration
echo "=== Verifying Configuration ==="

# Check BORE in config
if grep -q "CONFIG_SCHED_BORE=y" linux/config.x86_64; then
    echo -e "${GREEN}✓ BORE scheduler enabled in config${NC}"
else
    echo -e "${YELLOW}BORE scheduler not enabled in config${NC}"
    echo "Adding CONFIG_SCHED_BORE=y to config..."
    scripts/config --file linux/config.x86_64 -e SCHED_BORE
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ BORE scheduler enabled${NC}"
    else
        echo -e "${RED}Failed to enable BORE scheduler${NC}"
        exit 1
    fi
fi

# Check MIN_BASE_SLICE
if grep -q "CONFIG_MIN_BASE_SLICE_NS=" linux/config.x86_64; then
    echo -e "${GREEN}✓ MIN_BASE_SLICE_NS configured${NC}"
else
    echo -e "${YELLOW}MIN_BASE_SLICE_NS not configured${NC}"
    scripts/config --file linux/config.x86_64 --set-val MIN_BASE_SLICE_NS 2000000
    echo -e "${GREEN}✓ MIN_BASE_SLICE_NS set to 2000000${NC}"
fi

# Check localversion in PKGBUILD
if grep -q "linux-vita" linux/PKGBUILD; then
    echo -e "${GREEN}✓ PKGBUILD configured for linux-vita${NC}"
else
    echo -e "${YELLOW}PKGBUILD may not be properly configured${NC}"
fi

echo

# Show build information
echo "=== Build Information ==="
echo "Kernel version: $(grep "^pkgver=" linux/PKGBUILD | cut -d= -f2)"
echo "Package base: $(grep "^pkgbase=" linux/PKGBUILD | cut -d= -f2)"
echo "BORE patch: patches/bore.patch"
echo

# Display next steps
echo "=== Next Steps ==="
echo
echo "1. Install build dependencies:"
echo "   sudo pacman -Syu base-devel bc binutils cpio gettext libelf libgcc openssl pahole perl python rust rust-bindgen rust-src tar xxhash xz zlib zstd graphviz imagemagick python-sphinx python-yaml texlive-latexextra"
echo
echo "2. Build the kernel:"
echo "   cd linux && makepkg -sf"
echo
echo "3. Install the kernel packages:"
echo "   sudo pacman -U linux-vita-*.pkg.tar.zst linux-vita-headers-*.pkg.tar.zst"
echo
echo "4. Update initramfs:"
echo "   sudo mkinitcpio -P"
echo
echo "5. Update bootloader (GRUB):"
echo "   sudo grub-mkconfig -o /boot/grub/grub.cfg"
echo

echo -e "${GREEN}=== Setup Complete ===${NC}"
echo "You can now proceed with building the kernel."
