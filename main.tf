resource "azurerm_resource_group" "NS-RG" {
  name     = "ns-rg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "NS-VNET" {
  name                = "ns-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.NS-RG.location
  resource_group_name = azurerm_resource_group.NS-RG.name
}

resource "azurerm_subnet" "NS-SUBNET" {
  name                 = "ns-subnet"
  resource_group_name  = azurerm_resource_group.NS-RG.name
  virtual_network_name = azurerm_virtual_network.NS-VNET.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "NS-NIC" {
  name                = "ns-nic"
  location            = azurerm_resource_group.NS-RG.location
  resource_group_name = azurerm_resource_group.NS-RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.NS-SUBNET.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "NS-VM" {
  name                = "ns-vm"
  resource_group_name = azurerm_resource_group.NS-RG.name
  location            = azurerm_resource_group.NS-RG.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "King123456789"
  disable_password_authentication  = "false"
  network_interface_ids = [
    azurerm_network_interface.NS-NIC.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "NS-PIP" {
  name                = "ns-pip"
  resource_group_name = azurerm_resource_group.NS-RG.name
  location            = azurerm_resource_group.NS-RG.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}