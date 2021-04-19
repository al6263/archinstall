#!/bin/bash

sudo systemctl enable NetworkManager.service
sudo systemctl start NetworkManager.service

sudo mv /root/.bashrc ~/.bashrc
sudo chown $(whoami) ~/.bashrc
source ~/.bashrc