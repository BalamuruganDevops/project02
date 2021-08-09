provider "azurerm" {
  features {}
}

# MySQL Database azure Database service

resource "azurerm_mysql_server" "mysql" {
  name                = "${var.mysqlserver}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  administrator_login          = "vmadmin"
  administrator_login_password = "April@123456789"

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_database" "Database" {
  name                = "fitness"
  resource_group_name = "${var.resource_group_name}"
  server_name         = "${var.mysqlserver}"
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

