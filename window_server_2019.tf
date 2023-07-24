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

resource "azurerm_subnet" "subnet-B" {
  name                 = local.subnet[1].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = [local.subnet[1].address_space]
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

resource "azurerm_network_interface" "backup" {
  name                = "backup-nic"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "backup"
    subnet_id                     = azurerm_subnet.subnet-B.id
    private_ip_address_allocation = "Dynamic"
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
    name                       = "Allow-RDP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnetlink" {
  subnet_id                 = azurerm_subnet.subnet-A.id
  network_security_group_id = azurerm_network_security_group.NSG.id
  depends_on = [azurerm_network_security_group.NSG]
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "test-vm"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_B2s"
  admin_username      = "adminuser123"
  admin_password      = "9bA2$0zW2nyZa*xL!@#"
  network_interface_ids = [
    azurerm_network_interface.internal.id,
    azurerm_network_interface.backup.id
  ]
  depends_on = [azurerm_resource_group.test]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "datadisk" {
  name                 = "datadisk"
  location             = local.location
  resource_group_name  = local.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "5"
  depends_on = [azurerm_resource_group.test,azurerm_windows_virtual_machine.vm]

}

resource "azurerm_virtual_machine_data_disk_attachment" "diskattach" {
  managed_disk_id    = azurerm_managed_disk.datadisk.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "0"
  caching            = "ReadWrite"
  depends_on = [azurerm_resource_group.test,azurerm_windows_virtual_machine.vm]
}
