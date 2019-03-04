#/bin/sh
# This script bootstraps an Archlinux UEFI installation with MATE Desktop

# Set CLI arguments
if [ -n "$1" ]; then
DISK=$1
fi

if [ -n "$2" ]; then
SWAP=$2
fi

# Make sure the tools are installed
pacman -S parted reflector --noconfirm

# Create GPT partitions for UEFI install
parted /dev/sda mklabel GPT
parted /dev/sda mkpart primary fat32 1MiB 551MiB
parted /dev/sda set 1 esp on

# Create SWAP
parted /dev/sda mkpart primary linux-swap 551MiB 2.5GiB

# Create ROOT
parted /dev/sda mkpart primary xfs 2.5GiB 100%

# Create filesystem
mkfs.fat -F 32 -L BOOT /dev/sda1
mkswap -L SWAP /dev/sda2
mkfs.xfs -L ROOT /dev/sda3

# Mount the partitions to /mnt
mount -L ROOT /mnt
mkdir -p /mnt/boot
mount -L BOOT /mnt/boot
swapon -L SWAP

# Create the Mirrorlist
reflector --verbose --country 'Germany' -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist

# Install the system
pacstrap /mnt base base-devel bash-completion dosfstools

# Generate fstab
genfstap -Lp /mnt >> /mnt/etc/fstab

# Set flags for SSD
awk '/defaults/ {gsub("defaults","defaults,noatime,discard")}' /mnt/etc/fstab >> /mnt/etc/fstab.ssd
mv /mnt/etc/fstab /mnt/etc/fstab.bck
mv /mnt/etc/fstab.ssd /mnt/etc/fstab

# Download the next script
git clone https://github.com/themoses/configs /mnt/root
# chroot into system
arch-chroot mnt/ /root/config-arch.sh
