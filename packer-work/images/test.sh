#!/bin/bash

# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add HashiCorp repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Set the Terraform version
TERRAFORM_VERSION="1.9.5-1"

# Update package lists and install Terraform
sudo apt-get update
if apt-cache madison terraform | grep "$TERRAFORM_VERSION"; then
    sudo apt-get install -y "terraform=$TERRAFORM_VERSION"
else
    echo "Terraform version $TERRAFORM_VERSION not found. Available versions:"
    apt-cache madison terraform
    exit 1
fi

# Export the Terraform version as a pipeline variable
echo "##vso[task.setvariable variable=TERRAFORM_VERSION]$TERRAFORM_VERSION"
