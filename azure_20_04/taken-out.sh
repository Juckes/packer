
# # Ownership adjustment for pip cache directory - taken out as not installing pip...
# echo "Adjusting ownership of pip cache directory..."
# sudo chown -R packer:packer /home/packer/.cache || {
#   echo "Failed to adjust ownership of pip cache directory." >&2
#   exit 1
# }

# sudo rm -rf /var/lib/apt/lists/* taken out on most recent run but has failed
# sudo apt-get clean
# sudo apt-get update

# Define Python packages to install
# PYTHON_PACKAGES=(
  # "python${PYTHON_VERSION}"
  # "python${PYTHON_VERSION}-distutils" # This is included in both servers
  # "python3-pip"
# )

# echo "################################################################################## INSTALLING PYTHON PACKAGES..."
# install_packages "${PYTHON_PACKAGES[@]}"

# Upgrade setuptools and pip
# echo "Upgrading setuptools and pip..."
# python3 -m pip install --user -U setuptools pip

# Remove existing PyYAML installed via apt
# echo "Removing existing PyYAML..."
# sudo apt-get remove -y python3-yaml

# Upgrade or reinstall PyYAML
# echo "################################################################################## Upgrading PyYAML..."
# python3 -m pip install --force-reinstall pyyaml

# Install specific version of packaging library


# Install specific version of packaging library
# echo "################################################################################## Installing packaging library..."
# if sudo -H python3 -m pip install --force-reinstall packaging==21; then
#   echo "Packaging library installed successfully."
# else
#   echo "Failed to install packaging library." >&2
#   exit 1
# fi

# if sudo -H python3 -m pip install -U checkov==2.2.94; then
#   echo "Checkov installed successfully."
# else
#   echo "Failed to install Checkov." >&2
#   exit 1
# fi
