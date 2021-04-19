#!/bin/bash

echo "STARTING INSTALLATION SCRIPT"
echo "We really dislike people who install arch command after command. That's why we thought of a script: to allow you not to think. Happy installation!"
printf "Are you sure you want to continue with this script? [y/N] "
read var

if [ $var != "y" ]
then
	echo "Goodbye!"
	exit
fi

timedatectl set-ntp true

disk="/dev/$(lsblk -l | grep disk | head -n 1 | awk '{print $1}')"
printf "\nSelect disk where you want to install Arch Linux [Default $disk]: "
read disk
disk=${disk:-"/dev/$(lsblk -l | grep disk | head -n 1 | awk '{print $1}')"}
echo "Using $disk"

parted -s "$disk" -- mklabel gpt
parted -s "$disk" -- mkpart primary fat32 0 512MiB
parted -s "$disk" -- mkpart primary linux-swap 512MiB 2560MiB
parted -s "$disk" -- mkpart primary ext4 2560MiB 100%

root_part=$(printf "%s3" "$disk")
swap_part=$(printf "%s2" "$disk")
efi_part=$(printf "%s1" "$disk")

mkfs.fat -F32 "$efi_part"
mkfs.ext4 "$root_part"
mkswap "$swap_part"

mount "$root_part" /mnt
swapon "$swap_part"

pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

echo "END PART ONE"

echo "export efi_part=$efi_part" >> /mnt/root/.bashrc 
cat part2.sh >> /mnt/root/.bashrc

arch-chroot /mnt