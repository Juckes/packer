export DEBIAN_FRONTEND=noninteractive

sudo echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
sudo echo 'APT::Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries
sudo echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

sudo add-apt-repository main
sudo add-apt-repository restricted
sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo add-apt-repository ppa:git-core/ppa
sudo add-apt-repository ppa:deadsnakes/ppa

sudo apt-get clean && apt-get update && apt-get upgrade
sudo apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  curl \
  gnupg \
  jq \
  libasound2 \
  libgbm-dev \
  libgconf-2-4 \
  libgtk2.0-0 \
  libgtk-3-0 \
  libnotify-dev \
  libnss3 \
  libxss1 \
  libxtst6 \
  lsb-release \
  software-properties-common \
  unzip \
  xauth \
  xvfb \
  zip

# Git
sudo apt-get install -y --no-install-recommends \
  git \
  git-lfs \
  git-ftp

# Python
sudo apt-get install -y --no-install-recommends \
  python3.7 \
  python3.7-distutils \
  python3-pip

# Docker Engine
sudo apt-get install -y docker.io

sudo usermod -aG docker $USER
newgrp docker

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Terraform 1.7.3
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get install -y terraform=1.7.3-1

# Terragrunt 0.55.1
sudo curl -s -L "https://github.com/gruntwork-io/terragrunt/releases/download/v0.55.1/terragrunt_linux_amd64" -o /usr/bin/terragrunt && chmod 777 /usr/bin/terragrunt

# Checkov
python3.7 -m pip install --force-reinstall packaging==21
python3.7 -m pip install -U checkov==2.2.94

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
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
export PATH="$PATH:$NVM_DIR"
EOT

nvm install 20
nvm install 18
nvm install 16
nvm install 15
nvm install 14

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

/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
