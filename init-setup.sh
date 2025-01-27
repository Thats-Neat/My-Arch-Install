#!/bin/bash

# keyboard and time setup
echo "Setting keyboard and timedate..."
loadkeys us &>/dev/null
timedatectl set-timezone America/Los_Angeles &>/dev/null

# partitions
echo "Partitioning Drive..."
parted -s /dev/sda \
  mklabel gpt \
  mkpart ESP fat32 1MiB 4096MiB \
  set 1 esp on \
  mkpart primary linux-swap 4096MiB 12288MiB \
  mkpart primary ext4 12288MiB 100% \  &>/dev/null

# formatting new partitions
echo "Formatting Drive..."
mkfs.fat -F32 /dev/sda1 &>/dev/null
mkswap /dev/sda2 && swapon /dev/sda2 &>/dev/null
mkfs.ext4 /dev/sda3 &>/dev/null

# mounting new partitions
echo "Mounting New Partitions..."
umount /mnt
mount /dev/sda3 /mnt
mount --mkdir /dev/sda1 /mnt/boot/efi

# installing needed packages
echo "Installing Base Packages" &>/dev/null
pacstrap -i /mnt base

# generating ftab
echo "Generating fstab"
genfstab -U -p /mnt >>/mnt/etc/fstab

# system configure
echo "Configuring System..."
arch-chroot /mnt /bin/bash <<EOF
  # setting time
  ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime &> /dev/null
  hwclock --systohc &> /dev/null

  # setting locale
  echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
  locale-gen &> /dev/null

  echo "LANG=en_US.UTF-8" > /etc/locale.conf
  echo "KEYMAP=us" > /etc/vconsole.conf

  # package install
  pacman -S --noconfirm neovim hyprland base-devel grub networkmanager sudo man linux linux-headers linux-firmware

  # grub install
  grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck &> /dev/null
  grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null
EOF
