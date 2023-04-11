#! /bin/sh

## work - dev tools
DL_DIR=/home/$USER/Downloads
mkdir -p $SW_DIR
mkdir -p $DL_DIR
cd $DL_DIR
## work miniconda setup
curl -L -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
## work - ELK stack
curl https://github.com/elastic/elasticsearch/archive/refs/tags/v8.6.2.tar.gz -o elasticsearch.tar.gz
curl https://github.com/elastic/kibana/archive/refs/tags/v8.6.2.tar.gz -o kibana.tar.gz
curl https://github.com/elastic/logstash/archive/refs/tags/v8.6.2.tar.gz -o logstash.tar.gz
tar -xvzf elasticsearch.tar.gz -C $SW_DIR
tar -xvzf kibana.tar.gz -C $SW_DIR
tar -xvzf logstash.tar.gz $SW_DIR
rm $DL_DIR/*
## work - databases, docker, fortclient vpn
sudo pacman -S --noconfirm postgresql mariadb \
                           rclone \
                           docker docker-compose \
			   openfortivpn
yay -S --noconfirm  postman-bin \
                    mongodb-bin
## work - vs-code-insiders - with extensions
yay -S --noconfirm visual-studio-code-insiders-bin
## work - configure git global
git config --global user.name "Anuj Sable"
git config --global user.email "anujsablework@gmail.com"
git config --global init.defaultBranch main


