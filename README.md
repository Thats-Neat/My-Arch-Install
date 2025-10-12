<h1 align="center">
    <a style"font-size:large;">My Arch Install</a>
</h1>

This is currently being worked on. This setup will include all scripts and necessary files to create my Arch Linux setup.

## Script Explanation
`initial.sh`:

The script that installs necessary components when console access is given upon entering Arch Linux install medium

Contains:
- Keyboard layout setup
- Disk partitioning with btrfs

## Before Starting Any Scripts
1. Install git:
```bash
pacman -Sy git
```
2. Clone repo:
```bash
git clone https://github.com/Thats-Neat/My-Arch-Install.git
```
