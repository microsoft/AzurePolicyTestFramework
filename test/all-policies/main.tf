variable "resource_group_name" { type = string }

## Location

variable "location" { type = string }

module "location" {
  source = "git::https://github.com/microsoft/AzurePolicyTestFramework.git//test/location"

  resource_group_name = var.resource_group_name
  location            = var.location
}

## Windows VM

variable "use_scale_set" { type = bool }
variable "image_publisher" { type = string }
variable "image_offer" { type = string }
variable "image_sku" { type = string }
variable "image_version" { type = string }

module "windows-vm" {
  source = "git::https://github.com/microsoft/AzurePolicyTestFramework.git//test/windows-vm"

  resource_group_name = var.resource_group_name
  use_scale_set       = var.use_scale_set
  image_publisher     = var.image_publisher
  image_offer         = var.image_offer
  image_sku           = var.image_sku
  image_version       = var.image_version
}

## Storage Account

variable "allow_blob_public_access" { type = bool }

module "storageaccount-forbid-blob-public-access" {
  source = "git::https://github.com/microsoft/AzurePolicyTestFramework.git//test/storageaccount-forbid-blob-public-access"

  resource_group_name      = var.resource_group_name
  allow_blob_public_access = var.allow_blob_public_access
}

## RG naming

variable "prefix" { type = string }

module "resourcegroup-naming" {
  source = "git::https://github.com/microsoft/AzurePolicyTestFramework.git//test/resource-group-naming"

  prefix = var.prefix
}
