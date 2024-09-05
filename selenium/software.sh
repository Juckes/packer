#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Function to set APT options
set_apt_options() {
  echo 'APT::Acquire::Retries "3";' | sudo tee /etc/apt/apt.conf.d/80-retries
  echo 'APT::Get::Assume-Yes "true";' | sudo tee /etc/apt/apt.conf.d/90assumeyes
}

# Function to update and upgrade system
update_system() {
  sudo apt-get clean
  sudo apt-get update
  sudo apt-get upgrade
}

# Function to source config file
source_config() {
  local config_file="/tmp/config.sh"
  if [[ -f "$config_file" ]]; then
    echo "Sourcing $config_file"
    source "$config_file"
  else
    echo "config.sh not found" >&2
    exit 1
  fi
}

# Function to add APT repository
add_apt_repository() {
  local repo="$1"
  if sudo add-apt-repository -y "$repo"; then
    echo "Added repository: $repo"
  else
    echo "Failed to add repository: $repo" >&2
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

# Set APT options
set_apt_options

# Update and upgrade system
update_system

# Source the config file
source_config

# Debugging output for repositories and packages
echo "APT_REPOSITORIES: ${APT_REPOSITORIES[*]}"
echo "COMMON_PACKAGES: ${COMMON_PACKAGES[*]}"

# Add repositories
for repo in "${APT_REPOSITORIES[@]}"; do
  echo "Adding repository: $repo"
  add_apt_repository "$repo"
done

# Install essential packages
install_packages python3-pip

# Install common packages
echo "Installing common packages..."
install_packages "${COMMON_PACKAGES[@]}"

# Install Selenium
sudo python3 -m pip install selenium

# Clean up
echo "Cleaning up..."
sudo /usr/sbin/waagent -force -deprovision+user
export HISTSIZE=0
sync
