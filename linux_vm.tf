locals {
  resource_group_name = "test"
  location            = "South India"
  virtual_network     = {
    name          = "test-vnet"
    address_space = "10.0.0.0/16"
  }
  subnet = [
    {
      name          = "subnet-A"
      address_space = "10.0.0.0/24"
    },
    {
      name          = "subnet-B"
      address_space = "10.0.1.0/24"
    }
  ]
}



resource "azurerm_resource_group" "test" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "test-vnet" {
  name                = local.virtual_network.name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = [local.virtual_network.address_space]
  dns_servers         = ["8.8.8.8", "4.2.2.2"]
  depends_on = [azurerm_resource_group.test]

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "subnet-A" {
  name                 = local.subnet[0].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = [local.subnet[0].address_space]
  depends_on = [azurerm_virtual_network.test-vnet]
}

resource "azurerm_network_interface" "internal" {
  name                = "internal-nic"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-A.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

//To get the output from azure
#output "subnetA-id" {
  #value = azurerm_subnet.subnet-A.id
#}

resource "azurerm_public_ip" "pip" {
  name                = "test-pip"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  depends_on = [azurerm_resource_group.test]
}

resource "azurerm_network_security_group" "NSG" {
  name                = "Subnet-A-NSG"
  location            = local.location
  resource_group_name = local.resource_group_name
  depends_on = [azurerm_resource_group.test]

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnetlink" {
  subnet_id                 = azurerm_subnet.subnet-A.id
  network_security_group_id = azurerm_network_security_group.NSG.id
  depends_on = [azurerm_network_security_group.NSG]
}

resource "tls_private_key" "linuxkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
  depends_on = [azurerm_resource_group.test]
}

resource "local_file" "linuxpemkey" {
  content  = tls_private_key.linuxkey.private_key_pem
  filename = "linuxkey.pem"
  depends_on = [tls_private_key.linuxkey]
}


resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                = "linuxvm"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_B2s"
  admin_username      = "adminuser123"
  network_interface_ids = [
    azurerm_network_interface.internal.id
  ]
  depends_on = [azurerm_resource_group.test,tls_private_key.linuxkey]

  admin_ssh_key {
    public_key = tls_private_key.linuxkey.public_key_openssh
    username   = "adminuser123"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

