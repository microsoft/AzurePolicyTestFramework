provider "azurerm" {
  version = "=2.39.0"
  features {}
}

provider "random" {
  version = "=3.0.0"
}

variable "resource_group_name" {}
variable "prefix" {}

data "azurerm_resource_group" "test" {
  name = var.resource_group_name
}

resource "random_string" "name" {
  length  = 4
  special = false
  number  = false
  upper   = false
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-ci-test-vmss-policy-${random_string.name.result}"
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

resource "azurerm_linux_virtual_machine_scale_set" "test" {
  admin_username                  = "automated-test"
  admin_password                  = "Pa$$@w0rd1234!"
  instances                       = 0
  location                        = data.azurerm_resource_group.test.location
  name                            = "${var.prefix}${random_string.name.result}"
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
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
