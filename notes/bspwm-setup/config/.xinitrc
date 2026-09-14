#!/bin/bash

# Spanish layout. If this is a leftover and you are on a US/en_IN keyboard,
# change it to `setxkbmap us` (the console keymap is set in /etc/vconsole.conf).
setxkbmap es

# NOTE: .xinitrc is only read by `startx`. install.sh enables lightdm, which
# launches bspwm via /usr/share/xsessions/bspwm.desktop and never sources this
# file -- so anything you add here must be duplicated in ~/.xprofile (lightdm
# does source that) or in bspwmrc.
xsetroot -cursor_name left_ptr

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xset +fp /usr/share/fonts/local &
xset fp rehash &
xrdb ~/.Xresources &
xsetroot -cursor_name left_ptr &
exec bspwm

#source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh
#eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
#export SSH_AUTH_SOCK
#export XDG_SESSION_TYPE=x11
#export GDK_BACKEND=x11
