#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
echo "DEBIAN_FRONTEND is set to: $DEBIAN_FRONTEND"

source /tmp/config.sh

echo "APT_REPOSITORIES: ${APT_REPOSITORIES[@]}"
echo "COMMON_PACKAGES: ${COMMON_PACKAGES[@]}"

# FUNCTIONS
# Do we need these in here because if the script fails it will exit whereever it has failed anyway?
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

sudo apt-get clean && sudo apt-get update && sudo apt-get upgrade -y

for repo in "${APT_REPOSITORIES[@]}"; do
  add_apt_repository "$repo"
done

install_packages "${COMMON_PACKAGES[@]}"

# install_packages \
#   "python${PYTHON_VERSION}" \
#   "python${PYTHON_VERSION}-distutils" \ # Is this deprecated? https://docs.python.org/3.10/library/distutils.html
#   "python3-pip"

# # Install tfenv
# git clone https://github.com/tfutils/tfenv.git ~/.tfenv
# sudo ln -s ~/.tfenv/bin/* /usr/local/bin

# # Install and use multiple Terraform versions
# TERRAFORM_VERSIONS=("1.7.3" "1.9.0")
# for version in "${TERRAFORM_VERSIONS[@]}"; do
#   tfenv install "$version"
#   tfenv use "$version"
# done

# Clean up and deprovision
# sudo /usr/sbin/waagent -force -deprovision+user # waagent is azure linux agent used on Azure VMs
export HISTSIZE=0
sync
