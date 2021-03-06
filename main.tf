provider "azurerm" {
  features {}
}

/* Create a ressource group */
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags = {
    project_name = var.prefix
  }
}

/* Create a virtual network */
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    project_name = var.prefix
  }
}

/* Create a subnet */
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

/* Create a security group */
resource "azurerm_network_security_group" "main" {
  name                = "nd082Project1Sg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allowAccessToVm"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = azurerm_subnet.internal.address_prefix
    destination_address_prefix = azurerm_subnet.internal.address_prefix
  }

  security_rule {
    name                       = "denyDirectAccess"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    project_name = var.prefix
  }
}

/* Create (instance_count) * network interfaces */
resource "azurerm_network_interface" "main" {
  count               = var.instance_count
  name                = "${var.prefix}-nic${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    project_name = var.prefix
  }
}

/* Create a public IP adress */
resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
  tags = {
    project_name = var.prefix
  }
}

/* Create a load balancer, a backend address pool and address pool association for the NIC & LB */
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  tags = {
    project_name = var.prefix
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id     = azurerm_lb.main.id
  name                = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.instance_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  ip_configuration_name   = "internal"
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
}

/* Create a VM availability set */
resource "azurerm_availability_set" "avset" {
  name                         = "${var.prefix}-avset"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = var.instance_count
  platform_update_domain_count = var.instance_count
  managed                      = true
  tags = {
    project_name = var.prefix
  }
}

/* Reference a packer image */
data "azurerm_image" "packer-image" {
  name                = "nd082Project1Image"
  resource_group_name = "nd082-project1-image-rg"
}

/* Create (instance_count) * VM */
resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.instance_count
  name                            = "${var.prefix}-vm${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  availability_set_id             = azurerm_availability_set.avset.id
  size                            = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  source_image_id = data.azurerm_image.packer-image.id
  
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  tags = {
    project_name = var.prefix
  }
}