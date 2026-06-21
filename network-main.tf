####################
## Network - Main ##
####################

# Create a resource group for network
resource "azurerm_resource_group" "network-rg" {
  name     = "linux-${lower(replace(var.app_name, " ", "-"))}-${var.environment}-rg"
  location = var.location
  tags = {
    application = var.app_name
    environment = var.environment
  }
}

# Create the network VNET
# IMPORTANT: If you (or someone) manually create Azure services that attach to this VNet
# (e.g. Bastion, Azure Firewall, Private Link, Application Gateway, etc.), the VNet
# deletion during `terraform destroy` will fail with "InUseVirtualNetworkCannotBeDeleted".
# Always delete those external resources first, or manage them from this Terraform code.
resource "azurerm_virtual_network" "network-vnet" {
  name                = "linux-${lower(replace(var.app_name, " ", "-"))}-${var.environment}-vnet"
  address_space       = [var.network-vnet-cidr]
  resource_group_name = azurerm_resource_group.network-rg.name
  location            = azurerm_resource_group.network-rg.location
  tags = {
    application = var.app_name
    environment = var.environment
  }
}

# Create a subnet for Network
resource "azurerm_subnet" "network-subnet" {
  name                 = "linux-${lower(replace(var.app_name, " ", "-"))}-${var.environment}-subnet"
  address_prefixes     = [var.network-subnet-cidr]
  virtual_network_name = azurerm_virtual_network.network-vnet.name
  resource_group_name  = azurerm_resource_group.network-rg.name
}

