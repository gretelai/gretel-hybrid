terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

resource "azurerm_network_security_group" "gretel_hybrid_nodes_and_pods_nsg" {
  name                = "${var.vnet_name}-nodes-pods-nsg"
  location            = var.existing_resource_group_region
  resource_group_name = var.existing_resource_group_name

  security_rule {
    name                       = "AllowSameVent"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.azure_tags
}

resource "azurerm_virtual_network" "gretel_hybrid_vnet" {
  name                = "${var.vnet_name}-vnet"
  location            = var.existing_resource_group_region
  resource_group_name = var.existing_resource_group_name
  address_space       = [var.vnet_cidr]
  # dns_servers         = ["10.0.0.4", "10.0.0.5"]
  tags = var.azure_tags
}

resource "azurerm_subnet" "node_subnet" {
  # Permissions are delegated when AKS starts using the subnet. TF will try and strip them.
  lifecycle {
    ignore_changes = [delegation]
  }
  name                 = "${var.vnet_name}-node-subnet"
  resource_group_name  = var.existing_resource_group_name
  virtual_network_name = azurerm_virtual_network.gretel_hybrid_vnet.name
  address_prefixes     = [var.node_subnet_cidr]
}

resource "azurerm_subnet_network_security_group_association" "node_subnet_assign_nsg" {
  subnet_id                 = azurerm_subnet.node_subnet.id
  network_security_group_id = azurerm_network_security_group.gretel_hybrid_nodes_and_pods_nsg.id
}

resource "azurerm_subnet" "pod_subnet" {
  # Permissions are delegated when AKS starts using the subnet. TF will try and strip them.
  lifecycle {
    ignore_changes = [delegation]
  }
  name                 = "${var.vnet_name}-pod-subnet"
  resource_group_name  = var.existing_resource_group_name
  virtual_network_name = azurerm_virtual_network.gretel_hybrid_vnet.name
  address_prefixes     = [var.pod_subnet_cidr]
}

resource "azurerm_subnet_network_security_group_association" "pod_subnet_assign_nsg" {
  subnet_id                 = azurerm_subnet.pod_subnet.id
  network_security_group_id = azurerm_network_security_group.gretel_hybrid_nodes_and_pods_nsg.id
}
