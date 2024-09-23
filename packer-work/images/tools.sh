#!/bin/bash

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

# # Debugging output to check if config.sh is available
# echo "Checking for config.sh in the current directory: $(pwd)"
# ls -l

# # Source config.sh from the specified path
# CONFIG_PATH="/home/vsts/work/1/s/home/packer/config.sh"

# if [ -f "$CONFIG_PATH" ]; then
#     echo "config.sh found, sourcing it..."
#     source "$CONFIG_PATH"
# else
#     echo "config.sh not found at $CONFIG_PATH!" >&2
#     exit 1
# fi

export DEBIAN_FRONTEND=noninteractive

# Set default for DEFAULT_NODE_VERSION if not set
# DEFAULT_NODE_VERSION="${DEFAULT_NODE_VERSION:-14}"  # Change 14 to your preferred default version

# # Function to ensure directory exists and has correct permissions
# ensure_directory() {
#     local dir="$1"
#     sudo mkdir -p "$dir"
#     sudo chmod 755 "$dir"
# }

# Set APT options
sudo bash -c 'echo "APT::Acquire::Retries \"3\";" > /etc/apt/apt.conf.d/80-retries'
sudo bash -c 'echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes'

# Update and upgrade
sudo apt-get clean || { echo "apt-get clean failed"; exit 1; }
sudo apt-get update || { echo "apt-get update failed"; exit 1; }
sudo apt-get upgrade -y || { echo "apt-get upgrade failed"; exit 1; }

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
install_packages "${COMMON_PACKAGES[@]}"

######################################
# Remove any old versions of Docker
sudo apt-get remove -y docker docker-engine docker.io containerd runc

# Install necessary prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package index
sudo apt-get update

# Install Docker and containerd.io
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
########################################
sudo usermod -aG docker "$USER"
newgrp docker

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install tfenv
TFENV_DIR="/usr/local/tfenv"

# Ensure the directory exists and set correct permissions
sudo mkdir -p "$TFENV_DIR"
sudo chown "$USER:$USER" "$TFENV_DIR"

# Clone tfenv repository using sudo for permissions
sudo git clone https://github.com/tfutils/tfenv.git "$TFENV_DIR"

# Make tfenv bin available in this shell and for future use by creating symlinks
export PATH="$PATH:$TFENV_DIR/bin"
sudo ln -s "$TFENV_DIR/bin/*" /usr/local/bin

# Install Terraform versions specified in TERRAFORM_VERSIONS
for version in "${TERRAFORM_VERSIONS[@]}"; do
    tfenv install "$version"
done

# Use the specified Terraform version
tfenv use "$TERRAFORM_VERSION"
echo "##vso[task.setvariable variable=TERRAFORM_VERSION]$TERRAFORM_VERSION"
export TERRAFORM_VERSION="$TERRAFORM_VERSION"

# Terragrunt
sudo curl -sL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" -o /usr/bin/terragrunt
sudo chmod 755 /usr/bin/terragrunt

# Checkov via pip
sudo -H python3 -m pip install -U checkov=="${CHECKOV_VERSION}"

# TFLint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Node / NVM
NVM_DIR="/usr/local/nvm"

# Ensure directory exists and set permissions
sudo mkdir -p "$NVM_DIR"
sudo chown "$USER:$USER" "$NVM_DIR"

# Install NVM as the current user
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | NVM_DIR="$NVM_DIR" bash

# Source NVM
export NVM_DIR="$NVM_DIR"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$PATH:$NVM_DIR"

# Install Node versions
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

# Azure CLI
sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# .NET Core
sudo wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo rm packages-microsoft-prod.deb
sudo apt-get update || { echo "apt-get update after .NET Core install failed"; exit 1; }
sudo apt-get install -y apt-transport-https || { echo "apt-get install apt-transport-https failed"; exit 1; }
sudo apt-get update || { echo "Second apt-get update failed"; exit 1; }
sudo apt-get install -y aspnetcore-runtime-6.0 || { echo "apt-get install aspnetcore-runtime-6.0 failed"; exit 1; }

# Clean up
echo "Cleaning up..."
sudo /usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
