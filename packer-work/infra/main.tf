# module "primary_region" {
#   source  = "claranet/regions/azurerm"
#   version = "7.1.1"

#   azure_region = local.primary_location
# }

# locals {
#   org              = "pins"
#   service_name     = "template-packer"
#   primary_location = "uksouth"

#   resource_suffix = "${local.service_name}-${local.tags.Environment}"

#   tags = merge(
#     var.tags,
#     {
#       CreatedBy   = "Terraform"
#       Environment = "packer"
#       location    = local.primary_location
#       Owner       = "DevOps"
#       ServiceName = local.service_name
#     }
#   )
# }

# resource "azurerm_resource_group" "packer" {
#   name     = "packer"
#   location = local.primary_location
# }

# resource "azurerm_virtual_network" "packer" {
#   name                = "packer-vnet"
#   address_space       = ["10.0.0.0/24"]
#   location            = azurerm_resource_group.packer.location
#   resource_group_name = azurerm_resource_group.packer.name
# }

# resource "azurerm_subnet" "packer" {
#   name                 = "subnet-packer"
#   resource_group_name  = azurerm_resource_group.packer.name
#   virtual_network_name = azurerm_virtual_network.packer.name
#   address_prefixes     = ["10.0.0.0/28"]
# }

# resource "azurerm_network_interface" "packer" {
#   name                = "packer-nic"
#   location            = azurerm_resource_group.packer.location
#   resource_group_name = azurerm_resource_group.packer.name

#   ip_configuration {
#     name                          = "packer"
#     subnet_id                     = azurerm_subnet.packer.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_virtual_machine" "main" {
#   name                  = "packer"
#   location              = azurerm_resource_group.packer.location
#   resource_group_name   = azurerm_resource_group.packer.name
#   network_interface_ids = [azurerm_network_interface.packer.id]
#   vm_size               = "Standard_DS1_v2"

#   delete_os_disk_on_termination = true

#   delete_data_disks_on_termination = true

#   storage_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "20_04-lts"
#     version   = "latest"
#   }
#   storage_os_disk {
#     name              = "myosdisk1"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }
#   os_profile {
#     computer_name  = "hostname"
#     admin_username = "testadmin"
#     admin_password = "Password1234!"
#   }
#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
#   tags = local.tags
# }
