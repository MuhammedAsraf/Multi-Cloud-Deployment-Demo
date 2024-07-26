resource "azurerm_resource_group" "demo" {
    name = "demo-resources"
    location = "East US" 
}

resource "azurerm_virtual_network" "demo" {
    name = "demo-network"
    address_space  = ["10.0.0.0/16"]
    location = azurerm_resource_group.demo.location
    resource_group_name = azurerm_resource_group.demo.name
}

resource "azurerm_subnet" "demo" {
    name = "internal"
    resource_group_name = azurerm_resource_group.demo.name
    virtual_network_name = azurerm_virtual_network.demo.name
    address_prefixes = [ "10.0.1.0/24" ]
}

resource "azurerm_network_interface" "demo" {
    name = "demo-nic"
    location = azurerm_resource_group.demo.location
    resource_group_name = azurerm_resource_group.demo.name

    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.demo.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.demo.id
    }
}

resource "azurerm_public_ip" "demo" {
    name = "demo-public-ip"
    location = azurerm_resource_group.demo.location
    resource_group_name = azurerm_resource_group.demo.name
    allocation_method = "Dynamic"
}

resource "azurerm_linux_virtual_machine" "demo" {
    name = "demovm"
    location = azurerm_resource_group.demo.location
    resource_group_name = azurerm_resource_group.demo.name
    network_interface_ids = azurerm_network_interface.demo.private_ip_addresses
    size = "Standard_B1s"


    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Debian"
      offer = "Debian 11"
      sku = "Bullseye"
      version = "latest"
    }

    computer_name = "demovm"
    admin_username = "adminuser"

    admin_ssh_key {
      username = "adminuser"
      public_key = file("~/.ssh/id_rsa.pub")
    }

    disable_password_authentication = true
  
}
