#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Debugging output to verify DEBIAN_FRONTEND is set
echo "DEBIAN_FRONTEND is set to: $DEBIAN_FRONTEND"

# Source the config file
if [ -f /tmp/config.sh ]; then
  echo "Sourcing /tmp/config.sh"
  source /tmp/config.sh
else
  echo "config.sh not found" >&2
  exit 1
fi

# Debugging output for repositories and packages
echo "APT_REPOSITORIES: ${APT_REPOSITORIES[*]}"
echo "COMMON_PACKAGES: ${COMMON_PACKAGES[*]}"

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

echo "Cleaning and updating package lists..."
sudo apt-get clean
sudo apt-get update

echo "Upgrading existing packages..."
sudo apt-get upgrade -y

# Add APT repositories
for repo in "${APT_REPOSITORIES[@]}"; do
  echo "Adding repository: $repo"
  add_apt_repository "$repo"
done

# Install common packages
echo "Installing common packages..."
install_packages "${COMMON_PACKAGES[@]}"

# Clean up and deprovision
echo "Cleaning up..."
export HISTSIZE=0
sync

echo "Provisioning complete!"

# the runner already has most of the packages installed and some of the software too
# testing locally with packer currently
# I think i have tfenv installed, but not 100% in my head how it will work on the pipelines
