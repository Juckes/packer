#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Set APT options
sudo bash -c 'echo "APT::Acquire::Retries \"3\";" > /etc/apt/apt.conf.d/80-retries'
sudo bash -c 'echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes'

sudo apt-get clean && apt-get update && apt-get upgrade

# Source the config file
CONFIG_FILE="/tmp/config.sh"
if [ -f "$CONFIG_FILE" ]; then
  echo "Sourcing $CONFIG_FILE"
  source "$CONFIG_FILE"
else
  echo "config.sh not found" >&2
  exit 1
fi

# Debugging output for repositories and packages
echo "APT_REPOSITORIES: ${APT_REPOSITORIES[*]}"
echo "COMMON_PACKAGES: ${COMMON_PACKAGES[*]}"

# Function to add APT repository
add_apt_repository() {
  if sudo add-apt-repository -y "$1"; then
    echo "Added repository: $1"
  else
    echo "Failed to add repository: $1" >&2
    exit 1
  fi
}

# Function to install packages
install_packages() {
  if sudo apt-get install -y --no-install-recommends "$@"; then
    echo "Installed packages: $@"
  else
    echo "Failed to install packages: $@" >&2
    exit 1
  fi
}

# Add repositories
for repo in "${APT_REPOSITORIES[@]}"; do
  echo "Adding repository: $repo"
  add_apt_repository "$repo"
done

# Install common packages
echo "Installing common packages..."
install_packages "${COMMON_PACKAGES[@]}"

# Docker Engine
echo "Installing Docker Engine..."
sudo apt-get install -y docker.io
sudo usermod -aG docker "$USER"
newgrp docker

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install tfenv
echo "Installing tfenv..."
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
sudo ln -s ~/.tfenv/bin/* /usr/local/bin

# Terraform
echo "Installing Terraform versions..."
for version in "${TERRAFORM_VERSIONS[@]}"; do
  tfenv install "$version"
  tfenv use "$version"
done

# Terragrunt
echo "Installing Terragrunt..."
sudo curl -sL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" -o /usr/bin/terragrunt
sudo chmod 755 /usr/bin/terragrunt

# Checkov via pip
echo "Installing Checkov..."
sudo -H python3 -m pip install -U checkov=="${CHECKOV_VERSION}"

# TFLint
echo "Installing TFLint..."
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Node / NVM
echo "Installing Node.js and NVM..."
curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

NVM_DIR="/usr/local/nvm"
sudo mkdir -p "$NVM_DIR" && sudo chmod -R 777 "$NVM_DIR"
curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | NVM_DIR="$NVM_DIR" bash

export NVM_DIR="$NVM_DIR"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$PATH:$NVM_DIR"

sudo tee /etc/skel/.bashrc > /dev/null <<"EOT"
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$PATH:$NVM_DIR"
EOT

for version in "${NODE_VERSIONS[@]}"; do
  nvm install "$version"
done

nvm alias default "$DEFAULT_NODE_VERSION"
nvm use default

# Azure CLI
echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# .NET Core
echo "Installing .NET Core..."
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y apt-transport-https
sudo apt-get update
sudo apt-get install -y aspnetcore-runtime-6.0

# Clean up
echo "Cleaning up..."
sudo /usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
