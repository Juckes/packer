# # data "azurerm_resource_group" "template_rg" {
# #   name = "pins-rg-template-dev"
# # }

# locals {
#   target_tag   = "TerraformVersion"
#   target_value = "1.9.1"
# }

# output "image_tags" {
#   value = data.azurerm_image.packer_images.tags
# }

# # output "image_tag" {
# #   value = contains(keys(data.azurerm_image.packer_images.tags), local.target_tag) && data.azurerm_image.packer_images.tags[local.target_tag] == local.target_value
# # }

# data "azurerm_image" "packer_images" {
#   name_regex          = "packer-image-"
#   resource_group_name = "pins-rg-template-dev"
#   sort_descending     = true
# }
