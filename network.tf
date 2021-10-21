resource "azurerm_virtual_network" "rodrigo-vtn" {
  name                = "virtualNetwork1"
  location            = azurerm_resource_group.rodrigo.location
  resource_group_name = azurerm_resource_group.rodrigo.name
  address_space       = ["10.0.0.0/16"]
  
  tags = {
    environment = "Production"
    turma = "es22"
    faculdade = "impacta"
  }

depends_on = [azurerm_resource_group.rodrigo]

}

resource "azurerm_subnet" "rodrigo-sbn" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rodrigo.name
  virtual_network_name = azurerm_virtual_network.rodrigo-vtn.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [ azurerm_resource_group.rodrigo, azurerm_virtual_network.rodrigo-vtn]

}

resource "azurerm_public_ip" "rodrigo-ip" {
  name                = "publiIp1"
  resource_group_name = azurerm_resource_group.rodrigo.name
  location            = azurerm_resource_group.rodrigo.location
  allocation_method = "Static"

    tags = {
    environment = "Production"
  }

  depends_on = [ azurerm_resource_group.rodrigo]

}

resource "azurerm_network_security_group" "rodrigo-frw" {
  name                = "firewall"
  location            = azurerm_resource_group.rodrigo.location
  resource_group_name = azurerm_resource_group.rodrigo.name

  security_rule {
    name                       = "MYSQL"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    }
  

  tags = {
    environment = "Production"
  }

  depends_on = [ azurerm_resource_group.rodrigo]

}

resource "azurerm_network_interface" "rodrigo-int" {
  name                = "interface"
  location            = azurerm_resource_group.rodrigo.location
  resource_group_name = azurerm_resource_group.rodrigo.name

  ip_configuration {
    name                          = "interface-rodrigo"
    subnet_id                     = azurerm_subnet.rodrigo-sbn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rodrigo-ip.id
  }

  depends_on = [ azurerm_resource_group.rodrigo, azurerm_subnet.rodrigo-sbn]

}

resource "azurerm_network_interface_security_group_association" "rodrigo-ass" {
  network_interface_id      = azurerm_network_interface.rodrigo-int.id
  network_security_group_id = azurerm_network_security_group.rodrigo-frw.id

  depends_on = [ azurerm_network_interface.rodrigo-int, azurerm_network_security_group.rodrigo-frw ]

}

data "azurerm_public_ip" "rodrigo-ip-db" {
  name                = azurerm_public_ip.rodrigo-ip.name
  resource_group_name = azurerm_resource_group.rodrigo.name
}





