#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
   ______                                ________                __
  / ____/___  _________ ___  ____  _____/ ____/ /___  __  ______/ /
 / /   / __ \/ ___/ __ `__ \/ __ \/ ___/ /   / / __ \/ / / / __  / 
/ /___/ /_/ (__  ) / / / / / /_/ (__  ) /___/ / /_/ / /_/ / /_/ /  
\____/\____/____/_/ /_/ /_/\____/____/\____/_/\____/\__,_/\__,_/   
                                                                   
EOF
}

header_info
echo -e "Loading..."
APP="Cosmos-Cloud"
var_disk="10"
var_cpu="2"
var_ram="4096"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
header_info
if [[ ! -d /var ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
msg_info "Updating ${APP} LXC"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Updated ${APP} LXC"
exit
}

start
build_container
description

msg_info "Installing ${APP}"
apt-get update &>/dev/null
apt-get install -y curl &>/dev/null
curl -fsSL https://get.docker.com -o get-docker.sh &>/dev/null
sh get-docker.sh &>/dev/null
rm get-docker.sh
systemctl enable docker &>/dev/null
systemctl start docker &>/dev/null
docker pull azukaar/cosmos-server &>/dev/null
docker run -d --name cosmos-cloud \
  -p 80:80 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v cosmos-config:/app/config \
  ghcr.io/azukaar/cosmos-server:latest &>/dev/null
msg_ok "Installed ${APP}"

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP} ${CL} \n"
