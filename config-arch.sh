#!/bin/sh

# This script is part 2 of bootstrapping an Archlinux installation and will be run after the arch-chroot command.
# Part 1 can be found at install-arch.sh

# Install tools
pacman -Sy reflector --noconfirm
reflector --verbose --country 'Germany' -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy vim zsh grub git --noconfirm

# Set hostname
echo lolwut-arch > /etc/hostname

# Set language
echo LANG=en_US.UTF-8 > /etc/locale.conf
sed -i '/s/#en_US ISO-8859-1/en_US ISO-8859-1/g' /etc/locale.gen
sed -i '/s/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen

# Set keyboard binding
echo KEYMAP=de_CH-latin1 > /etc/vconsole.conf

# Set timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Enable multilib Support
sed -i '/s/#[multilib]/[multilib]/g' /etc/pacman.conf
sed -i '/s/#SigLevel = PackageRequired TrustedOnly/SigLevel = PackageRequired TrustedOnly/g' /etc/pacman.conf
sed -i '/s/#Include = /etc/pacman.d/mirrorlist/Include = /etc/pacman.d/mirrorlist/g' /etc/pacman.conf

# Generate initramfs
mkinitcpio -p linux

# Install bootloader
#grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-install /dev/sda1
grub-mkconfig -o /boot/grub/grub.cfg

# Adding user
useradd -m -s /bin/zsh -U moses
usermod -g wheel moses
 
# Adding sudo access
sed -i '/s/#%wheel  ALL=(ALL)       ALL/%wheel  ALL=(ALL)       ALL/g' /etc/sudoers

# Install tools
pacman -S acpid dbus avahi cups cronie networkmanager --noconfirm
systemctl enable acpid avahi-daemon cronie

# Install Xorg
pacman -S xorg-server xorg-xinit ttf-dejavu --noconfirm

# Set Keymapping for X Session
echo > Section "InputClass" /etc/X11/xorg.conf.d/20-keyboard.conf
echo >>      Identifier "keyboard" /etc/X11/xorg.conf.d/20-keyboard.conf
echo >>      MatchIsKeyboard "yes" /etc/X11/xorg.conf.d/20-keyboard.conf
echo >>      Option "XkbLayout" "ch" /etc/X11/xorg.conf.d/20-keyboard.conf
echo >>      Option "XkbModel" "pc105" /etc/X11/xorg.conf.d/20-keyboard.conf
echo >>      Option "XkbVariant" "nodeadkeys" /etc/X11/xorg.conf.d/20-keyboard.conf
echo >>EndSection /etc/X11/xorg.conf.d/20-keyboard.conf

# Install Video Driver
#pacman -S nvidia --no-confirm

# Install MATE
pacman -S lightdm lightdm-gtk-greeter alsa pulseaudio-alsa mate network-manager-applet firefox --noconfirm

systemctl enable lightdm NetworkManager

# Install Steam
#pacaur -S ttf-ms-win10
