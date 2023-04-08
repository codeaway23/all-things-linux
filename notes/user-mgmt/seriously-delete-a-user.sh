#!/bin/sh

sudo passwd -l $1
sudo pkill -KILL -u $1

sudo mkdir $HOME/dead_users
sudo tar cfjv "$HOME/dead_users/$1.tar.bz" /home/$1

sudo crontab -r -u $1

lprm -U $1

sudo userdel --remove $1
