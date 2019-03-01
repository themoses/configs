#/bin/sh

# Set CLI arguments
if [ -n "$1" ]; then
DISK=$1
fi

if [ -n "$2" ]; then
SWAP=$2
fi

# Make sure the tools are installed
pacman -S parted --noconfirm

# Create GPT partitions for UEFI install
parted /dev/sda mklabel GPT
parted /dev/sda mkpart primary fat32 1MiB 551MiB
parted /dev/sda set 1 esp on

# Create SWAP
#parted mkpart primary linux-swap 20.5GiB 24.5GiB

# Create ROOT
parted /dev/sda mkpart primary xfs 551MiB 100%

# Create filesystem
mkfs.fat -F 32 /dev/sda1
mkfs.xfs /dev/sda2
