#!/bin/bash

set -euo pipefail

# Debugging output to check if config.sh is available
echo "Checking for config.sh in the current directory: $(pwd)"
ls -l

# Source config.sh from the specified path
CONFIG_PATH="/home/vsts/work/1/s/packer-work/images/config.sh"
if [ -f "$CONFIG_PATH" ]; then
    echo "config.sh found, sourcing it..."
    source "$CONFIG_PATH"
else
    echo "config.sh not found at $CONFIG_PATH!" >&2
    exit 1
fi

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
sudo chown "$USER:$USER" "$NV"
