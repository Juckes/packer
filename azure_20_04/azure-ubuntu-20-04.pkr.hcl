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

variable "client_id" {
  description = "The ID of the service principal used to build the image"
  type        = string
  default     = "761dc672-19c8-4ae4-84fb-e7de69436817"
}

variable "client_secret" {
  description = "The client secret of the service principal used to build the image"
  type        = string
  default     = "Was a secret here before"
}

variable "subscription_id" {
  description = "The ID of the subscription containing the service principal used to build the image"
  type        = string
  default     = "13e1ebd2-b4ab-48f5-ba4e-73d8e2db4f85"
}

variable "tenant_id" {
  description = "The ID of the tenant containing the service principal used to build the image"
  type        = string
  default     = "475c4944-9823-4fd8-bf80-01ac0fec39d4"
}
