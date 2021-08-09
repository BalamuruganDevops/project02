provider "azurerm" {
  features {}
}

#resource group creation 

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

#storage account and blob storage creation 

resource "azurerm_storage_account" "storage" {
  name                     = "${var.storage_name}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "${var.container_name}"
  storage_account_name  = "${var.storage_name}"
  container_access_type = "private"
}

resource "azurerm_storage_blob" "blob" {
  name                   = "${var.storage_blob}"
  storage_account_name   = "${var.storage_name}"
  storage_container_name = "${var.container_name}"
  type                   = "Block"
}
