#!/bin/bash

# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -

# Add HashiCorp repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Set the Terraform version
TERRAFORM_VERSION="1.9.0"

# Install Terraform
sudo apt-get update && sudo apt-get install -y "terraform=$TERRAFORM_VERSION"

# Export the Terraform version as a pipeline variable
echo "##vso[task.setvariable variable=TERRAFORM_VERSION]$TERRAFORM_VERSION"
