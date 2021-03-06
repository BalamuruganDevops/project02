provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.0.0/24" 
}

resource "azurerm_public_ip" "pip" {
  name                         = var.public_ip_name
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  public_ip_address_allocation = "Static"
}
resource "azurerm_network_security_group" "SGterraform" {
  name = "${var.network_security_group_name}"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "AllowSshInBound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                      = "${var.network_interface_name}"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.allows.id}"

  ip_configuration {
    name                          = "${var.network_interface_name}-configuration"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }
}


### Virtual Machine

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.virtual_machine_name}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "${var.virtual_machine_size}"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.virtual_machine_osdisk_name}"
    create_option     = "FromImage"
    managed_disk_type = "${var.virtual_machine_osdisk_type}"
  }

  os_profile {
    computer_name  = "${var.virtual_machine_computer_name}"
    admin_username = "${var.admin_username}"
    admin_password = "April@123456789"
    disable_password_authentication = false
  }

  provisioner "remote-exec" {
    inline = [
      # Build Essentials
      "sudo apt-get update",
      "sudo apt-get install build-essential -y",
      "sudo apt-get install unzip -y",
      "sudo apt-get install make -y",

      # Go (put in PATH) & Terraform (not put in PATH)
      "wget -q -O - https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz | sudo tar -C /usr/local -xz",
      "wget -q -O terraform_linux_amd64.zip https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip",
      "sudo unzip -d /usr/local/terraform terraform_linux_amd64.zip",
      "sudo sh -c 'echo \"PATH=\\$PATH:/usr/local/go/bin\" >> /etc/profile'",

      # Azure CLI
      "sudo sh -c 'echo \"deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main\" > /etc/apt/sources.list.d/azure-cli.list'",
      "sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893",
      "sudo apt-get install apt-transport-https",
      "sudo apt-get update && sudo apt-get install azure-cli",

      # Jenkins
      "wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -",
      "sudo sh -c 'echo \"deb http://pkg.jenkins.io/debian-stable binary/\" > /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt-get update",
      "sudo apt-get install jenkins -y",

      # Add jenkins group to sudoers
      "sudo sh -c 'echo \"jenkins ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers'",

      "sudo reboot",
    ]
  }
}