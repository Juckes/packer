#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Functions
add_apt_repository() {
  if sudo add-apt-repository -y "$1"; then
    echo "Added repository: $1"
  else
    echo "Failed to add repository: $1" >&2
    exit 1
  fi
}

install_packages() {
  if sudo apt-get install -y --no-install-recommends "$@"; then
    echo "Installed packages: $@"
  else
    echo "Failed to install packages: $@" >&2
    exit 1
  fi
}

# Set debconf to noninteractive
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
echo 'APT::Acquire::Retries "3";' | sudo tee /etc/apt/apt.conf.d/80-retries > /dev/null
echo 'APT::Get::Assume-Yes "true";' | sudo tee /etc/apt/apt.conf.d/90assumeyes > /dev/null

# Add necessary repositories
# add_apt_repository main
# add_apt_repository restricted
# add_apt_repository universe
# add_apt_repository multiverse
# add_apt_repository ppa:git-core/ppa
# add_apt_repository ppa:deadsnakes/ppa

# Update and upgrade system
sudo apt-get clean
sudo apt-get update
sudo apt-get upgrade -y

for repo in "${APT_REPOSITORIES[@]}"; do
  add_apt_repository "$repo"
done

APT_REPOSITORIES=(
  "main"
  "restricted"
  "universe"
  "multiverse"
  "ppa:deadsnakes/ppa"
)

install_packages "${COMMON_PACKAGES[@]}"

COMMON_PACKAGES=(
  "ca-certificates"
  "curl"
  "gnupg"
  "jq"
  "lsb-release"
  "software-properties-common"
  "unzip"
  "zip"
)

# Install common packages
# install_packages \
#   build-essential \
#   ca-certificates \
#   curl \
#   gnupg \
#   jq \
#   libasound2 \
#   libgbm-dev \
#   libgconf-2-4 \
#   libgtk2.0-0 \
#   libgtk-3-0 \
#   libnotify-dev \
#   libnss3 \
#   libxss1 \
#   libxtst6 \
#   lsb-release \
#   software-properties-common \
#   unzip \
#   xauth \
#   xvfb \
#   zip

# install_packages git git-lfs git-ftp

# install_packages python3.7 python3.7-distutils python3-pip

# install_packages docker.io
# sudo usermod -aG docker "$USER"
# newgrp docker
# sudo systemctl enable docker.service
# sudo systemctl enable containerd.service

# DOCKER_COMPOSE_VERSION="1.29.2"
# sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose

# Install tfenv
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
sudo ln -s ~/.tfenv/bin/* /usr/local/bin

# Install and use multiple Terraform versions
TERRAFORM_VERSIONS=("1.7.3" "1.9.0")
for version in "${TERRAFORM_VERSIONS[@]}"; do
  tfenv install "$version"
  tfenv use 1.9.0
done

# Install Terragrunt
# TERRAGRUNT_VERSION="0.55.1"
# sudo curl -sL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" -o /usr/bin/terragrunt
# sudo chmod +x /usr/bin/terragrunt

# Install Checkov
# python3.7 -m pip install --force-reinstall packaging==21
# python3.7 -m pip install -U checkov==2.2.94

# Install TFLint
# curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Install Node.js and NVM
# curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
# install_packages nodejs
# sudo mkdir -p /usr/local/nvm && sudo chmod -R 777 /usr/local/nvm
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | NVM_DIR=/usr/local/nvm bash

# export NVM_DIR="/usr/local/nvm"
# source "$NVM_DIR/nvm.sh"
# export PATH="$PATH:$NVM_DIR"

# sudo tee /etc/skel/.bashrc > /dev/null <<'EOT'
# export NVM_DIR="/usr/local/nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# export PATH="$PATH:$NVM_DIR"
# EOT

# for version in 20 18 16 15 14; do
#   nvm install "$version"
# done

# nvm alias default 16
# nvm use default

# Install Azure CLI
# curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install .NET Core
# wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
# sudo dpkg -i packages-microsoft-prod.deb
# rm packages-microsoft-prod.deb

# sudo apt-get update
# install_packages apt-transport-https
# sudo apt-get update
# install_packages aspnetcore-runtime-6.0

# Clean up and deprovision
sudo /usr/sbin/waagent -force -deprovision+user
export HISTSIZE=0
sync
