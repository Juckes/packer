packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = ">= 2.1.7"
    }
  }
}

source "azure-arm" "ubuntu" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  os_type                           = "Linux"
  managed_image_name                = "learn-packer-linux-azure-${formatdate("YYYY-MM-DD-hhmmss", timestamp())}"
  managed_image_resource_group_name = "packer"

  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_sku       = "20_04-lts"
  // image_version   = "20.04.202203220"

  location = "eastus2"
  vm_size  = "Standard_B1s"

  azure_tags = {
    environment = "dev"
    project     = "learn-packer"
  }
}

build {
  name    = "learn-packer"
  sources = ["source.azure-arm.ubuntu"]

  provisioner "file" {
    source      = "config.sh"
    destination = "/tmp/config.sh"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E bash -e '{{ .Path }}'"
    script          = "${path.cwd}/tools.sh"
  }
}

