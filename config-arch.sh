#!/bin/sh

# This script is part 2 of bootstrapping an Archlinux installation and will be run after the arch-chroot command.
# Part 1 can be found at install-arch.sh

# Set hostname
echo lolwut-arch > /etc/hostname

# Set language
echo LANG=en_US.UTF-8 > /etc/locale.conf

# Set keyboard binding
echo KEYMAP=de_CH-latin1 > /etc/vconsole.conf

# Set timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Enable multilib Support
sed '/s/#[multilib]/[multilib]' /etc/pacman.conf
sed '/s/#SigLevel = PackageRequired TrustedOnly/SigLevel = PackageRequired TrustedOnly' /etc/pacman.conf
sed '/s/#Include = /etc/pacman.d/mirrorlist/Include = /etc/pacman.d/mirrorlist' /etc/pacman.conf
pacman -Syu

# Generate initramfs
mkinitcpio -p linux

# Install bootloader
pacman -S grub --no-confirm
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

# Adding user
useradd -m -s /bin/zsh -U -g wheel, audio, video, games, power
 
# Adding sudo access
sed '/s/#%wheel  ALL=(ALL)       ALL/%wheel  ALL=(ALL)       ALL' /etc/sudoers

# Install tools
pacman -S acpid dbus avahi cups cronie pacaur networkmanager --no-confirm
systemctl enable acpid avahi-daemon cronie

# Install Xorg
pacman -S xorg-server xorg-xinit ttf-dejavu --no-confirm

# Set Keymapping for X Session
echo > Section "InputClass" /etc/X11/xorg.conf.d/20-keyboard.conf
echo >>      Identifier "keyboard" /etc/X11/xorg.conf.d/20-keyboard.conf
echo >>      MatchIsKeyboard "yes" /etc/X11/xorg.conf.d/20-keyboard.conf
echo >>      Option "XkbLayout" "ch" /etc/X11/xorg.conf.d/20-keyboard.conf
echo >>      Option "XkbModel" "pc105" /etc/X11/xorg.conf.d/20-keyboard.conf
echo >>      Option "XkbVariant" "nodeadkeys" /etc/X11/xorg.conf.d/20-keyboard.conf
echo >>EndSection /etc/X11/xorg.conf.d/20-keyboard.conf

# Install Video Driver
pacman -S nvidia --no-confirm

# Install MATE
pacman -S lightdm lightdm-gtk-greeter alsa pulseaudio-alsa mate network-manager-applet

systemctl enable lightdm networkmanager

# Install Steam
#pacaur -S ttf-ms-win10
