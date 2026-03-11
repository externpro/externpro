#!/usr/bin/env bash
if [[ -f /etc/resolv.conf ]]; then
  sudo chattr -i /etc/resolv.conf
  sudo rm /etc/resolv.conf
fi
if [[ -f /etc/wsl.conf ]]; then
  sudo rm /etc/wsl.conf
fi
sudo bash -c 'echo -e "nameserver 172.31.35.2\nnameserver 172.31.35.5\nsearch usurf.usu.edu" > /etc/resolv.conf'
sudo bash -c 'echo -e "[network]\ngenerateResolvConf = false" > /etc/wsl.conf'
sudo chattr +i /etc/resolv.conf
