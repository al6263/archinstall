#!/bin/bash

# Ansi color code variables
red="\e[0;91m"
blue="\e[0;94m"
expand_bg="\e[K"
blue_bg="\e[0;104m${expand_bg}"
red_bg="\e[0;101m${expand_bg}"
green_bg="\e[0;102m${expand_bg}"
green="\e[0;92m"
yellow="\e[0;33m"
white="\e[0;97m"
bold="\e[1m"
uline="\e[4m"
reset="\e[0m"

alias pacman="pacman --noconfirm"

ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
hwclock --systohc
locale-gen

echo "LANG=it_IT.UTF-8" >> /etc/locale.conf
echo "KEYMAP=it" >> /etc/vconsole.conf

machine="ArchLinux"
echo "$machine" >> /etc/hostname

printf "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$machine.localdomain\t$machine" >> /etc/hosts

printf "${bold}${green}Input root password...${reset}\n"
passwd

pacman -S grub efibootmgr
mkdir /boot/efi
mount "$efi_part" /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "INSTALLATION TERMINATED"

pacman -S networkmanager

printf "Input username [Default user]: "
read username
username=${username:-"user"}

useradd -m -G wheel -s /bin/bash "$username"
printf "${bold}${green}Input user password...${reset}\n"
passwd "$username"

pacman -S vim nano sudo
echo '%wheel ALL=(ALL) ALL' | EDITOR='tee -a' visudo

mv /root/after_reboot.sh "/home/$username/.bashrc"

pacman -S gnome gnome-extra xorg gdm 

exit
