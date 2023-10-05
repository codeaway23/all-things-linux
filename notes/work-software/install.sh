#! /bin/sh

## work - dev tools
DL_DIR=/home/$USER/Downloads
SW_DIR=/home/$USER/software
mkdir -p $SW_DIR
mkdir -p $DL_DIR
cd $DL_DIR
## work miniconda setup
curl -L -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
## work - ELK stack
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.9.0-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.9.0-linux-x86_64.tar.gz.sha512
shasum -a 512 -c elasticsearch-8.9.0-linux-x86_64.tar.gz.sha512 
tar -xzf elasticsearch-8.9.0-linux-x86_64.tar.gz

curl -O https://artifacts.elastic.co/downloads/kibana/kibana-8.9.0-linux-x86_64.tar.gz
curl https://artifacts.elastic.co/downloads/kibana/kibana-8.9.0-linux-x86_64.tar.gz.sha512 | shasum -a 512 -c - 
tar -xzf kibana-8.9.0-linux-x86_64.tar.gz
cd kibana-8.9.0/ 

rm $DL_DIR/*
# work - databases, docker
sudo pacman -S --noconfirm postgresql mariadb \
                           rclone \
                           docker docker-compose
yay -S --noconfirm  postman-bin \
                    mongodb-bin
## work - vs-codium
yay -S --noconfirm vscodium
## work - R and RStudio
yay -S --noconfirm r rstudio-desktop
## work - slack, discord
yay -S --noconfirm slack-desktop discord
## work - configure git global
git config --global user.name "Anuj Sable"
git config --global user.email "anujsablework@gmail.com"
git config --global init.defaultBranch main


