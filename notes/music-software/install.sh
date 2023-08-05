#!/bin/sh

sudo usermod -G users,wheel,audio
sudo pacman -Syu helm-synth
git clone https://github.com/brummer10/pajackconnect.git
