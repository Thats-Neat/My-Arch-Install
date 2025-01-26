#!/bin/bash

# keyboard and time setup
loadkeys us
timedatectl set-timezone America/Los_Angeles

# partitions
echo -e "g\nn\n\n\n+4G\nn\n\n\n+8G\nn\n\n\n\nt\n2\n19\nt\n3\n23\nt\n1\n1\nw\n" | fdisk /dev/sda

# formatting new partitions
mkfs.ext4 /dev/sda3
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2

# mounting new partitions
mount /dev/sda3 /mnt
mount --mkdir /dev/sda1 /mnt/boot/efi
swapon /dev/sda2

# installing needed packages
pacstrap -i /mnt base

# generating ftab
genfstab -U -p /mnt >>/mnt/etc/fstab

# switch to chroot
arch-chroot /mnt /bin/bash <<EOF
# setting time
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc

# setting locale
echo "en_US.UTF-8 UTF-8" >/etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" >/etc/locale.conf
echo "KEYMAP=us" >/etc/vconsole.conf

# package install
pacman -S --noconfirm neovim hyprland base-devel grub networkmanager sudo man linux linux-headers linux-firmware

# install intel/nvidia stuff later

# linux kernel stuff
mkinitcpio -p linux

# grub install
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg

# start networkmanager
systemctl enable NetworkManager

# CREATE A NEW USER MANUALLY
# passwd
# useradd -m -g users -G wheel johnathon
# passwd johnathon
EOF

# umount -a
