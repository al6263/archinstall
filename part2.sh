#!/bin/bash

ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
hwclock --systohc
locale-gen

echo "LANG=it_IT.UTF-8" >> /etc/locale.conf
echo "KEYMAP=it" >> /etc/vconsole.conf

machine="ArchLinux"
echo "$machine" >> /etc/hostname

printf "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$machine.localdomain\t$machine" >> /etc/hosts

echo "\nNow choose your root password: "
passwd

pacman -S grub efibootmgr
mkdir /boot/efi
mount "$efi_part" /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

echo "INSTALLATION SCRIPT TERMINATED"

rm ~/.bashrc
