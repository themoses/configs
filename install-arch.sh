#/bin/sh
# This script bootstraps an Archlinux UEFI installation with MATE Desktop

# Set CLI arguments

if [[ "$@" == "efi" ]]
then
    MODE=efi
else
    MODE=bios
fi

if [[ "$@" == "ssd" ]]
then
    HARDDISK=ssd
else
    HARDDISK=hdd
fi

# Make sure the tools are installed
pacman -Sy parted reflector dosfstools --noconfirm

if [[ $MODE == "efi" ]]
then
# Create GPT partitions for UEFI install
parted --script /dev/sda mklabel GPT
parted --script /dev/sda mkpart primary fat32 1MiB 551MiB
parted --script /dev/sda set 1 esp on
else
# Create MBR partitions
parted --script /dev/sda mklabel msdos
parted --script /dev/sda mkpart primary xfs 1MiB 551MiB
parted --script /dev/sda set 1 esp on
fi

# Create SWAP
parted --script /dev/sda mkpart primary linux-swap 551MiB 2.5GiB

# Create ROOT
parted --script /dev/sda mkpart primary xfs 2.5GiB 100%

if [[ $MODE == "efi" ]]
then
# Create filesystem
mkfs.fat -F 32 /dev/sda1
fatlabel /dev/sda1 BOOT
else
mkfs.xfs -L BOOT /dev/sda1
mkswap -L SWAP /dev/sda2
mkfs.xfs -L ROOT /dev/sda3
fi

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
genfstab -Lp /mnt >> /mnt/etc/fstab

if [[ $HARDDSIKS == "ssd" ]]
then
# Set flags for SSD
awk '/defaults/ {gsub("defaults","defaults,noatime,discard")}' /mnt/etc/fstab >> /mnt/etc/fstab.ssd
mv /mnt/etc/fstab /mnt/etc/fstab.bck
mv /mnt/etc/fstab.ssd /mnt/etc/fstab
fi

# chroot into system
echo "ready for arch-chroot"
#arch-chroot mnt/ /root/config-arch.sh
