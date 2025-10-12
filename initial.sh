#!/bin/bash

# Constants
# =========
STORAGE_DEVICE=/dev/sda # preform fdisk -l to see disks

# In GB
EFI_SIZE=2
SWAP_SIZE=8

SYSTEM_HOMENAME="archlinux"

# Initial Setup
loadkeys us > /dev/null

# Disk Setup
# ==========
parted -s $STORAGE_DEVICE mklabel gpt > /dev/null

# EFI System Partition
parted -s $STORAGE_DEVICE mkpart ESP fat32 1MiB ${EFI_SIZE}G > /dev/null
parted -s $STORAGE_DEVICE set 1 boot on > /dev/null
mkfs.fat -F32 ${STORAGE_DEVICE}1 > /dev/null

# Swap Partition
TOTAL_SIZE=$((EFI_SIZE + SWAP_SIZE)) &> /dev/null
parted -s $STORAGE_DEVICE mkpart primary linux-swap ${EFI_SIZE}G ${TOTAL_SIZE}G > /dev/null
mkswap ${STORAGE_DEVICE}2 > /dev/null
swapon ${STORAGE_DEVICE}2 > /dev/null

# Root Partition
parted -s $STORAGE_DEVICE mkpart primary btrfs ${TOTAL_SIZE}G 100% > /dev/null
mkfs.btrfs ${STORAGE_DEVICE}3 > /dev/null

# Mounting
mount ${STORAGE_DEVICE}3 /mnt > /dev/null
mount --mkdir ${STORAGE_DEVICE}1 /mnt/boot > /dev/null

# Kernel Install and System Configure
# ===================================
pacstrap -K /mnt base linux linux-firmware > /dev/null
genfstab -U /mnt >> /mnt/etc/fstab > /dev/null

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen > /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo $SYSTEM_HOMENAME > /etc/hostname



