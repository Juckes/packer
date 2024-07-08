#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Ensure apt retries and assume-yes settings
sudo echo 'APT::Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries
sudo echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

# Clean, update, and upgrade packages
sudo apt-get clean && apt-get update && apt-get upgrade -y

# Source the config file
if [ -f /tmp/config.sh ]; then
  echo "Sourcing /tmp/config.sh"
  source /tmp/config.sh
else
  echo "config.sh not found" >&2
  exit 1
fi

# Ownership adjustment for pip cache directory
echo "Adjusting ownership of pip cache directory..."
sudo chown -R packer:packer /home/packer/.cache || {
  echo "Failed to adjust ownership of pip cache directory." >&2
  exit 1
}

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

for repo in "${APT_REPOSITORIES[@]}"; do
  echo "Adding repository: $repo"
  add_apt_repository "$repo"
done

echo "Installing common packages..."
install_packages "${COMMON_PACKAGES[@]}"

# Clean up apt lists to avoid errors
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get clean
sudo apt-get update

# Define Python packages to install
PYTHON_PACKAGES=(
  "python${PYTHON_VERSION}"
  "python${PYTHON_VERSION}-distutils"
  # "python3-pip" Think it comes already installed?
)

echo "Installing Python packages..."
install_packages "${PYTHON_PACKAGES[@]}"

# Upgrade setuptools
echo "Upgrading setuptools..."
python${PYTHON_VERSION} -m pip install -U setuptools

# Install Checkov using pip
echo "Installing Checkov..."
if python${PYTHON_VERSION} -m pip install -U checkov; then
  echo "Checkov installed successfully."
else
  echo "Failed to install Checkov." >&2
  exit 1
fi

# Install specific version of packaging library
echo "Installing packaging library..."
if python${PYTHON_VERSION} -m pip install --force-reinstall packaging==21; then
  echo "Packaging library installed successfully."
else
  echo "Failed to install packaging library." >&2
  exit 1
fi

echo "Cleaning up..."
export HISTSIZE=0
sync
