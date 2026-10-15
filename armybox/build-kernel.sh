#!/usr/bin/env bash
set -e

KERNEL_VERSION="6.1.68"
KERNEL_ARCHIVE="linux-${KERNEL_VERSION}.tar.xz"
if [ ! -f "$KERNEL_ARCHIVE" ]; then
	wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/${KERNEL_ARCHIVE}"
fi
if [ ! -d "linux-${KERNEL_VERSION}" ]; then
	tar -xf "$KERNEL_ARCHIVE"
fi
cd "linux-${KERNEL_VERSION}"
export ARCH=x86_64

# Start with a minimal baseline configuration
make tinyconfig
./scripts/config --enable CONFIG_64BIT

# Mandatory Armybox virtualization flags
./scripts/config --enable CONFIG_HYPERVISOR_GUEST
./scripts/config --enable CONFIG_KVM_GUEST
./scripts/config --enable CONFIG_SERIAL_8250_CONSOLE
./scripts/config --enable CONFIG_BLK_DEV_NVME
./scripts/config --enable CONFIG_EXT4_FS
./scripts/config --enable CONFIG_BLK_DEV_INITRD
./scripts/config --enable CONFIG_RD_GZIP

# Enforce uncompressed kernel execution
./scripts/config --enable CONFIG_KERNEL_UNCOMPRESSED
./scripts/config --disable CONFIG_KERNEL_GZIP
./scripts/config --disable CONFIG_KERNEL_XZ
./scripts/config --disable CONFIG_KERNEL_ZSTD

# Extreme RAM-saving flags for <32MB footprint
./scripts/config --enable CONFIG_SLUB_TINY
./scripts/config --enable CONFIG_SLOB
./scripts/config --set-val CONFIG_BASE_SMALL 1
./scripts/config --disable CONFIG_SMP
./scripts/config --disable CONFIG_HOTPLUG_CPU
./scripts/config --disable CONFIG_BUG
./scripts/config --disable CONFIG_SWAP
./scripts/config --disable CONFIG_AIO
./scripts/config --disable CONFIG_BTRFS_FS
./scripts/config --disable CONFIG_SOUND
./scripts/config --disable CONFIG_WLAN

make olddefconfig
make -j"$(nproc)" vmlinux

cp vmlinux ../../vmlinux-uncompressed
echo "Kernel built: vmlinux-uncompressed"