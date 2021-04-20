#!/bin/bash

check() {
	if [ $? != 0 ]
	then
		echo "Abort"
		exit
	fi
}

ls /sys/firmware/efi > /dev/null
check

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

var="/dev/$(lsblk -l | grep disk | head -n 1 | awk '{print $1}')"
printf "\nSelect disk where you want to install Arch Linux [Default $var]: "
read disk
disk=${disk:-"$var"}
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

# arch-chroot
cd /mnt
mount -t proc /proc proc/
check
mount -t sysfs /sys sys/
check
mount --rbind /dev dev/
check

mount --rbind /run run/
mount --rbind /sys/firmware/efi/efivars sys/firmware/efi/efivars/
check
cp /etc/resolv.conf etc/resolv.conf

install -Dm 766 ~/archinstall/part2.sh /mnt/root/part2.sh
install -Dm 766 ~/archinstall/after_reboot.sh /mnt/root/after_reboot.sh
install -Dm 766 ~/archinstall/.bashrc /mnt/root/.bashrc
cp ~/archinstall/gnome-packages.txt /mnt/root

# Calls the second script in chroot
efi_part="$efi_part" chroot /mnt /bin/bash /root/part2.sh

printf "[${bold}${yellow} ATTENTION ${reset}] LOG IN AS USER AFTER REBOOT! \n"
echo "Reboot in 3 seconds"

sleep 3
reboot
