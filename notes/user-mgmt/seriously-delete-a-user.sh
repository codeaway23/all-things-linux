#!/bin/sh

DYING_USER=anuj

sudo passwd -l $DYING_USER
sudo pkill -KILL -u $DYING_USER

sudo mkdir $HOME/dead_users
sudo tar cfjv "$HOME/dead_users/$DYING_USER.tar.bz" /home/$DYING_USER

sudo crontab -r -u $DYING_USER

lprm -U $DYING_USER

sudo userdel --rmeove $DYING_USER