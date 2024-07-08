#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo bash -c echo 'APT::Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries
sudo bash -c echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

sudo apt-get clean && apt-get update && apt-get upgrade -y

# Source the config file
if [ -f /tmp/config.sh ]; then
  echo "Sourcing /tmp/config.sh"
  source /tmp/config.sh
else
  echo "config.sh not found" >&2
  exit 1
fi

# # Ownership adjustment for pip cache directory - taken out as not installing pip...
# echo "Adjusting ownership of pip cache directory..."
# sudo chown -R packer:packer /home/packer/.cache || {
#   echo "Failed to adjust ownership of pip cache directory." >&2
#   exit 1
# }

# Debugging output for repositories and packages
echo "APT_REPOSITORIES: ${APT_REPOSITORIES[*]}"
echo "COMMON_PACKAGES: ${COMMON_PACKAGES[*]}"

add_apt_repository() {
  if sudo add-apt-repository -y "$1"; then
    echo "################################################################################## Added repository: $1"
  else
    echo "Failed to add repository: $1" >&2
    exit 1
  fi
}

install_packages() {
  if sudo apt-get install -y --no-install-recommends "$@"; then
    echo "################################################################################## Installed packages: $@"
  else
    echo "Failed to install packages: $@" >&2
    exit 1
  fi
}

for repo in "${APT_REPOSITORIES[@]}"; do
  echo "################################################################################## ADDING REPOSITORIES: $repo"
  add_apt_repository "$repo"
done

echo "################################################################################## INSTALLING COMMON PACKAGES..."
install_packages "${COMMON_PACKAGES[@]}"

sudo rm -rf /var/lib/apt/lists/*
sudo apt-get clean
sudo apt-get update

# Define Python packages to install
PYTHON_PACKAGES=(
  # "python${PYTHON_VERSION}"
  # "python${PYTHON_VERSION}-distutils" # This is included in both servers
  "python3-pip"
)

echo "################################################################################## INSTALLING PYTHON PACKAGES..."
install_packages "${PYTHON_PACKAGES[@]}"

# Upgrade setuptools and pip
echo "Upgrading setuptools and pip..."
python3 -m pip install --user -U setuptools pip

# Remove existing PyYAML installed via apt
# echo "Removing existing PyYAML..."
# sudo apt-get remove -y python3-yaml

# Upgrade or reinstall PyYAML
# echo "################################################################################## Upgrading PyYAML..."
# python3 -m pip install --force-reinstall pyyaml


# Install specific version of packaging library
echo "################################################################################## Installing packaging library..."
if sudo -H python3 -m pip install --force-reinstall packaging==21; then
  echo "Packaging library installed successfully."
else
  echo "Failed to install packaging library." >&2
  exit 1
fi

# Docker Engine
sudo apt-get install -y docker.io

sudo usermod -aG docker $USER
newgrp docker

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install tfenv
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
sudo ln -s ~/.tfenv/bin/* /usr/local/bin

# Terraform
for version in "${TERRAFORM_VERSIONS[@]}"; do
  tfenv install "$version"
  tfenv use 1.9.0
done

# Terragrunt 0.55.1
sudo curl -s -L "https://github.com/gruntwork-io/terragrunt/releases/download/v0.55.1/terragrunt_linux_amd64" -o /usr/bin/terragrunt && chmod 777 /usr/bin/terragrunt

# Install Checkov using pip
echo "################################################################################## Installing Checkov..."
if sudo -H python3 -m pip install -U checkov==2.2.94; then
  echo "Checkov installed successfully."
else
  echo "Failed to install Checkov." >&2
  exit 1
fi

# TFLint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Node / NVM
curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -

sudo apt-get install nodejs

sudo mkdir /usr/local/nvm && chmod -R 777 /usr/local/nvm
sudo curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | NVM_DIR=/usr/local/nvm bash

export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$PATH:$NVM_DIR"

sudo tee /etc/skel/.bashrc > /dev/null <<"EOT"
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$PATH:$NVM_DIR"
EOT

for version in 20 18 16 15 14; do
  nvm install "$version"
done

nvm alias default 16
nvm use default

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# .NET Core
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update && \
  sudo apt-get install -y aspnetcore-runtime-6.0

echo "Cleaning up..."
export HISTSIZE=0
sync


# Anything that can be installed via pip
# Perhaps we need to build a proper 'golden image'
