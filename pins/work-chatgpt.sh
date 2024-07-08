#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

APT_REPOSITORIES=(
  "main"
  "restricted"
  "universe"
  "multiverse"
  "ppa:git-core/ppa"
  "ppa:deadsnakes/ppa"
)

COMMON_PACKAGES=(
  "build-essential"
  "ca-certificates"
  "curl"
  "gnupg"
  "jq"
  "libasound2"
  "libgbm-dev"
  "libgconf-2-4"
  "libgtk2.0-0"
  "libgtk-3-0"
  "libnotify-dev"
  "libnss3"
  "libxss1"
  "libxtst6"
  "lsb-release"
  "software-properties-common"
  "unzip"
  "xauth"
  "xvfb"
  "zip"
)

PYTHON_PACKAGES=(
  "python3.7"
  "python3.7-distutils"
  "python3-pip"
  "python3-venv"
)

install_packages() {
  if sudo apt-get install -y --no-install-recommends "$@"; then
    echo "Installed packages: $@"
  else
    echo "Failed to install packages: $@" >&2
    exit 1
  fi
}

setup_virtualenv() {
  echo "Setting up virtual environment..."
  python3.7 -m venv /home/packer/checkov_env
  source /home/packer/checkov_env/bin/activate
  echo "Upgrading setuptools and pip in virtual environment..."
  pip install --upgrade setuptools pip
}

sudo echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
sudo echo 'APT::Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries
sudo echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

sudo apt-get clean && sudo apt-get update && sudo apt-get upgrade -y

for repo in "${APT_REPOSITORIES[@]}"; do
  echo "Adding repository: $repo"
  sudo add-apt-repository -y "$repo"
done

sudo apt-get update

install_packages "${COMMON_PACKAGES[@]}"

# Git
install_packages git git-lfs git-ftp

# Python
install_packages "${PYTHON_PACKAGES[@]}"

# Docker Engine
install_packages docker.io
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Terraform 1.7.3
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
install_packages terraform=1.7.3-1

# Terragrunt 0.55.1
sudo curl -s -L "https://github.com/gruntwork-io/terragrunt/releases/download/v0.55.1/terragrunt_linux_amd64" -o /usr/bin/terragrunt && sudo chmod 777 /usr/bin/terragrunt

# Checkov setup in virtual environment
setup_virtualenv
pip install --force-reinstall packaging==21
pip install -U checkov==2.2.94

# TFLint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Node / NVM
curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
install_packages nodejs
sudo mkdir /usr/local/nvm && sudo chmod -R 777 /usr/local/nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | NVM_DIR=/usr/local/nvm bash

export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$PATH:$NVM_DIR"

sudo tee /etc/skel/.bashrc > /dev/null <<"EOT"
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
export PATH="$PATH:$NVM_DIR"
EOT

nvm install 20
nvm install 18
nvm install 16
nvm install 15
nvm install 14
nvm alias default 16
nvm use default

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# .NET Core
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
install_packages apt-transport-https
sudo apt-get update
install_packages aspnetcore-runtime-6.0

/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
