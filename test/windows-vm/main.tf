terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.63.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" { type = string }
variable "use_scale_set" { type = bool }
variable "image_publisher" { type = string }
variable "image_offer" { type = string }
variable "image_sku" { type = string }
variable "image_version" { type = string }

locals {
  hasWindowsInOffer  = length(regexall("Windows*", var.image_offer)) > 0
  is_windows         = local.hasWindowsInOffer
  is_linux           = !local.is_windows
  windows_vm_count   = var.use_scale_set == false && local.is_windows ? 1 : 0
  windows_vmss_count = var.use_scale_set && local.is_windows ? 1 : 0
  linux_vm_count     = var.use_scale_set == false && local.is_linux ? 1 : 0
  linux_vmss_count   = var.use_scale_set && local.is_linux ? 1 : 0
}

data "azurerm_resource_group" "test" {
  name = var.resource_group_name
}

resource "random_string" "vm_name" {
  length  = 4
  special = false
  number  = false
  upper   = false
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-ci-test-windows-vm-policy-${random_string.vm_name.result}"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.test.location
  resource_group_name = data.azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test" {
  name                = "nic-test-${random_string.vm_name.result}"
  location            = data.azurerm_resource_group.test.location
  resource_group_name = data.azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "test" {
  count = local.windows_vm_count

  location              = data.azurerm_resource_group.test.location
  name                  = "vm-${random_string.vm_name.result}"
  network_interface_ids = [azurerm_network_interface.test.id]
  resource_group_name   = data.azurerm_resource_group.test.name
  size                  = "Standard_F2"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_password = "Pa$$@w0rd1234!"
  admin_username = "automated-test"

  source_image_reference {
    offer     = var.image_offer
    publisher = var.image_publisher
    sku       = var.image_sku
    version   = var.image_version
  }
}

resource "azurerm_windows_virtual_machine_scale_set" "test" {
  count = local.windows_vmss_count

  admin_password      = "Pa$$@w0rd1234!"
  admin_username      = "automated-test"
  instances           = 0
  location            = data.azurerm_resource_group.test.location
  name                = "vmss-${random_string.vm_name.result}"
  resource_group_name = data.azurerm_resource_group.test.name
  sku                 = "Standard_F2"

  network_interface {
    name    = "test"
    primary = true
    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.test.id
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer     = var.image_offer
    publisher = var.image_publisher
    sku       = var.image_sku
    version   = var.image_version
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  count = local.linux_vm_count

  admin_username                  = "automated-test"
  admin_password                  = "Pa$$@w0rd1234!"
  location                        = data.azurerm_resource_group.test.location
  name                            = "vm-${random_string.vm_name.result}"
  network_interface_ids           = [azurerm_network_interface.test.id]
  resource_group_name             = data.azurerm_resource_group.test.name
  size                            = "Standard_F2"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer     = var.image_offer
    publisher = var.image_publisher
    sku       = var.image_sku
    version   = var.image_version
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "test" {
  count = local.linux_vmss_count

  admin_username                  = "automated-test"
  admin_password                  = "Pa$$@w0rd1234!"
  instances                       = 0
  location                        = data.azurerm_resource_group.test.location
  name                            = "vmss-${random_string.vm_name.result}"
  resource_group_name             = data.azurerm_resource_group.test.name
  sku                             = "Standard_F2"
  disable_password_authentication = false

  network_interface {
    name    = "test"
    primary = true
    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.test.id

    }
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer     = var.image_offer
    publisher = var.image_publisher
    sku       = var.image_sku
    version   = var.image_version
  }
}
