# ── 1. Tell Terraform which provider to use ──────────────────────────────
# The "provider" is the plugin that knows how to talk to Azure.
# version = "~> 3.0" means use version 3.x — anything from 3.0 upward.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# features {} is required by azurerm even when empty.
# It enables default behaviors that would otherwise need to be opted into.
provider "azurerm" {
  features {}
}

# ── 2. Resource Group ─────────────────────────────────────────────────────
# Every Azure resource must live inside a resource group.
resource "azurerm_resource_group" "rg" {
  name     = "rg-lab04-tf-gavinbarbee"
  location = "East US"
}

# ── 3. Virtual Network ────────────────────────────────────────────────────
# location and resource_group_name reference the resource group above.
# This creates a dependency — Terraform will create the RG first automatically.
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-terraform"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# ── 4. Subnet ─────────────────────────────────────────────────────────────
# 10.0.1.0/24 is a slice of the 10.0.0.0/16 VNet address space.
# A VNet can contain many subnets — each is a separate network segment.
resource "azurerm_subnet" "subnet" {
  name                 = "snet-backend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ── 5. Network Security Group ────────────────────────────────────────────
# An NSG is a set of firewall rules that controls inbound and outbound traffic.
# This creates an empty NSG — rules would be added in a real deployment.
# Added in Phase 5 to demonstrate Terraform updating a live environment
# without touching the Resource Group, VNet, or Subnet created above.
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
