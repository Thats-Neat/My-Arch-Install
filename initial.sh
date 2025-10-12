#!/bin/bash

# Constants
# =========
STORAGE_DEVICE=/dev/sda # preform fdisk -l to see disks

# In GB
EFI_SIZE=2
SWAP_SIZE=8

# Initial Setup
loadkeys us &> /dev/null

# Disk Setup
# ==========
parted -s $STORAGE_DEVICE mklabel gpt

# EFI System Partition
parted -s $STORAGE_DEVICE mkpart ESP fat32 1MiB $EFI_SIZE
parted -s $STORAGE_DEVICE set 1 boot on
mkfs.fat -F32 ${STORAGE_DEVICE}1

# Swap Partition
TOTAL_SIZE=$((EFI_SIZE + SWAP_SIZE))
parted -s $STORAGE_DEVICE mkpart primary linux-swap ${EFI_SIZE}G ${TOTAL_SIZE}G
mkswap ${STORAGE_DEVICE}2
swapon ${STORAGE_DEVICE}2

# Root Partition
parted -s $STORAGE_DEVICE mkpart primary btrfs ${TOTAL_SIZE}G 100%
mkfs.btrfs ${STORAGE_DEVICE}3

# Mounting
mount /dev/${STORAGE_DEVICE}3 /mnt
mount --mkdir /dev/${STORAGE_DEVICE}1 /mnt/boot

