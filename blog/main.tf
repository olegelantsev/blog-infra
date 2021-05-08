provider "azurerm" {
  features {}
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "resourcegroup" {
  name     = var.resource_group_name
  location = "West Europe"
}

resource "random_id" "random_name" {
  byte_length = 8
}

resource "azurerm_storage_account" "storageaccount" {
  name                     = "blog${lower(random_id.random_name.hex)}"
  resource_group_name      = azurerm_resource_group.resourcegroup.name
  location                 = azurerm_resource_group.resourcegroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  static_website {
    index_document = "index.html"
    error_404_document = "404.html"
  }
}

resource "azurerm_cdn_profile" "cdn" {
  name                = "blog${lower(random_id.random_name.hex)}"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  name                = "blog${lower(random_id.random_name.hex)}"
  profile_name        = azurerm_cdn_profile.cdn.name
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  origin_host_header  = azurerm_storage_account.storageaccount.primary_web_host
  is_http_allowed = false

  origin {
    name      = "web"
    # host_name = var.domain
    host_name = azurerm_storage_account.storageaccount.primary_web_host
  }
}

# resource "azurerm_management_lock" "rg" {
#   name       = "rg-lock"
#   scope      = azurerm_resource_group.resourcegroup.id
#   lock_level = "CanNotDelete"
#   notes      = "Do not delete"
# }
