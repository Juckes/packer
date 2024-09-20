#!/bin/bash

set -euo pipefail

# Debugging output to check if config.sh is available
echo "Checking for config.sh in the current directory: $(pwd)"
ls -l

# Source config.sh from the current directory
# source "./config.sh"  # Use relative path


if [ -f "$(dirname "$0")/config.sh" ]; then
    echo "config.sh found, sourcing it..."
    source "$(dirname "$0")/config.sh"
else
    echo "config.sh not found!" >&2
    exit 1
fi


source "$(dirname "$0")/config.sh"


export DEBIAN_FRONTEND=noninteractive

# Set default for DEFAULT_NODE_VERSION if not set
DEFAULT_NODE_VERSION="${DEFAULT_NODE_VERSION:-14}"  # Change 14 to your preferred default version

# Function to ensure directory exists and has correct permissions
ensure_directory() {
    local dir="$1"
    sudo mkdir -p "$dir"
    sudo chmod 755 "$dir"
}

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
