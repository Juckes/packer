#!/bin/bash

set -euo pipefail

# source /tmp/config.sh

export DEBIAN_FRONTEND=noninteractive

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

# Install tfenv
TFENV_DIR="/usr/local/tfenv"
ensure_directory "$TFENV_DIR"
sudo git clone --depth 1 --branch "$TFENV_VERSION" https://github.com/tfutils/tfenv.git "$TFENV_DIR"
export PATH="$PATH:$TFENV_DIR/bin"
sudo ln -sf "$TFENV_DIR/bin/tfenv" /usr/local/bin/tfenv

# Terraform
for version in "${TERRAFORM_VERSIONS[@]}"; do
  sudo tfenv install "$version"
done
sudo tfenv use "$TERRAFORM_VERSION"
echo "##vso[task.setvariable variable=TERRAFORM_VERSION]$TERRAFORM_VERSION"
export TERRAFORM_VERSION=$TERRAFORM_VERSION

# Terragrunt
sudo curl -sL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" -o /usr/bin/terragrunt
sudo chmod 755 /usr/bin/terragrunt

# Checkov via pip
sudo -H python3 -m pip install -U checkov=="${CHECKOV_VERSION}"

# TFLint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Node / NVM
NVM_DIR="/usr/local/nvm"
ensure_directory "$NVM_DIR"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | NVM_DIR="$NVM_DIR" bash

export NVM_DIR="$NVM_DIR"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$PATH:$NVM_DIR"

# Add nvm and tfenv to path for all users
sudo tee /etc/profile.d/custom_env.sh > /dev/null <<"EOT"
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$PATH:/usr/local/tfenv/bin:$NVM_DIR"
EOT

for version in "${NODE_VERSIONS[@]}"; do
  nvm install "$version"
done

nvm alias default "$DEFAULT_NODE_VERSION"
nvm use default

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
