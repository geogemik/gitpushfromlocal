
resource "azurerm_resource_group" "app1" {
  name     = "app1"
  location = var.location
}

resource "azurerm_resource_group" "app2" {
  name     = "app2"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "production"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.app1.name
  depends_on = [ azurerm_resource_group.app1 ]
 }

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.app1.name
  virtual_network_name = var.vnetproduction
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [azurerm_virtual_network.example]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.app1.name
  virtual_network_name = var.vnetproduction
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [azurerm_virtual_network.example]
  
}

resource "azurerm_network_interface" "app1" {
  name                = "app1-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.app1.name

  ip_configuration {
    name                          = "subnet1"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip1.id
  }
}

resource "azurerm_network_interface" "app2" {
  name                = "app2-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.app2.name

  ip_configuration {
    name                          = "subnet2"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip2.id
  }
}
resource "azurerm_windows_virtual_machine" "app1" {
  name                = "demovm1"
  resource_group_name = azurerm_resource_group.app1.name
  location            = var.location
  size                = var.vmsize
  admin_username      = var.adminuser
  admin_password      = var.adminpassword
  network_interface_ids = [
    azurerm_network_interface.app1.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}


resource "azurerm_public_ip" "public_ip1" {
  name                = "app1publicip"
  resource_group_name = azurerm_resource_group.app1.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard" # Use Standard SKU for production workloads
  depends_on = [ azurerm_resource_group.app1]
}

resource "azurerm_windows_virtual_machine" "app2" {
  name                = "demovm2"
  resource_group_name = azurerm_resource_group.app2.name
  location            = var.location
  size                = var.vmsize
  admin_username      = var.adminuser
  admin_password      = var.adminpassword
  network_interface_ids = [
    azurerm_network_interface.app2.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_public_ip" "public_ip2" {
  name                = "app2publicip"
  resource_group_name = azurerm_resource_group.app2.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard" # Use Standard SKU for production workloads
  depends_on = [ azurerm_resource_group.app2]
}

terraform {
  backend "azurerm" {
    resource_group_name  = "demo"
    storage_account_name = "mydemostgact"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    #use_azuread_auth     = true
  }
}
