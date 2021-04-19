#!/bin/bash

ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
hwclock --systohc
locale-gen

echo "LANG=it_IT.UTF-8" >> /etc/locale.conf
echo "KEYMAP=it" >> /etc/vconsole.conf

machine="ArchLinux"
echo "$machine" >> /etc/hostname

printf "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$machine.localdomain\t$machine" >> /etc/hosts

echo "Input root password..."
passwd

pacman -S grub efibootmgr
mkdir /boot/efi
mount "$efi_part" /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "INSTALLATION TERMINATED"

printf "Input username [Default user]: "
read username
username=${username:-"user"}

useradd -m -G wheel -s /bin/bash $username
echo "Input user password..."
passwd $username

pacman -S vim nano sudo
echo 'wheel ALL=(ALL:ALL) ALL' | sudo EDITOR='tee -a' visudo

pacman -S networkmanager

cp /root/after_reboot.sh /home/$username/.bashrc
