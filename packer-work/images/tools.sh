#!/bin/bash
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
  "jq"
  "unzip"
  "zip"
  "xvfb"
  "python3-pip"
)

DOCKER_COMPOSE_VERSION="1.29.2"

TFENV_VERSION="v3.0.0"

TERRAFORM_VERSIONS=("1.7.3" "1.9.1")
TERRAFORM_VERSION="1.9.1"

TERRAGRUNT_VERSION="0.55.1"

CHECKOV_VERSION="2.2.94"

NODE_VERSIONS=("20" "18")
DEFAULT_NODE_VERSION="18"

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Set APT options
sudo bash -c 'echo "APT::Acquire::Retries \"3\";" > /etc/apt/apt.conf.d/80-retries'
sudo bash -c 'echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes'

# Disable man-db service to prevent hang during Docker installation
sudo systemctl stop man-db.service

# Update and upgrade
sudo apt-get clean || { echo "apt-get clean failed"; exit 1; }
sudo apt-get update || { echo "apt-get update failed"; exit 1; }
sudo apt-get upgrade -y || { echo "apt-get upgrade failed"; exit 1; }

# Add repositories
for repo in "${APT_REPOSITORIES[@]}"; do
    echo "Adding repository: $repo"
    sudo add-apt-repository -y "$repo"
done

# Remove existing Docker installations
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $pkg
done

# Add Docker's official GPG key:
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker packages
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Re-enable man-db service after Docker installation
sudo systemctl start man-db.service

# Add user to Docker group and start services
sudo usermod -aG docker "$USER"
newgrp docker
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Restart services flagged by needrestart
sudo systemctl restart --no-block dbus.service packagekit.service php8.1-fpm.service

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install tfenv
TFENV_DIR="/usr/local/tfenv"
sudo mkdir -p "$TFENV_DIR"
sudo git clone https://github.com/tfutils/tfenv.git "$TFENV_DIR"
export PATH="$PATH:$TFENV_DIR/bin"
sudo ln -s "$TFENV_DIR/bin/*" /usr/local/bin

# Install Terraform versions
for version in "${TERRAFORM_VERSIONS[@]}"; do
    tfenv install "$version"
done
tfenv use "$TERRAFORM_VERSION"
export TERRAFORM_VERSION="$TERRAFORM_VERSION"

# Install Terragrunt
sudo curl -sL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" -o /usr/bin/terragrunt
sudo chmod 755 /usr/bin/terragrunt

# Install Checkov via pip
sudo -H python3 -m pip install -U checkov=="${CHECKOV_VERSION}"

# Install TFLint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Install Node.js via NVM
NVM_DIR="/usr/local/nvm"
sudo mkdir -p "$NVM_DIR"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | NVM_DIR="$NVM_DIR" bash
export NVM_DIR="$NVM_DIR"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$PATH:$NVM_DIR"

for version in "${NODE_VERSIONS[@]}"; do
    nvm install "$version"
done

nvm alias default "$DEFAULT_NODE_VERSION"
nvm use default

# Add nvm to profile for all users
sudo tee /etc/profile.d/custom_env.sh > /dev/null <<"EOT"
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$PATH:$NVM_DIR"
EOT

# Install Azure CLI
sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install .NET Core
sudo wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y apt-transport-https aspnetcore-runtime-6.0

# Clean up and deprovision
echo "Cleaning up..."
sudo /usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
