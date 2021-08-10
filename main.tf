terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "my_rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    environment = var.environment
  }
}
resource "random_id" "keyvault" {
  byte_length = 4
}

data "azurerm_client_config" "current" {
}

data "azuread_service_principal" "vault" {
  application_id = var.client_id
}

resource "azurerm_key_vault" "vault" {
  name                = var.azurerm_key_vault
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  tenant_id           = var.tenant_id

  sku_name = "standard"

  tags = {
    environment = var.environment
  }

  # access policy for the hashicorp vault service principal.
  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azuread_service_principal.vault.object_id

    key_permissions = [
      "get",
      "wrapKey",
      "unwrapKey",
    ]
  }

  # access policy for the user that is currently running terraform.
  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
      "list",
      "create",
      "delete",
      "update",
    ]
  }

  # TODO does this really need to be so broad? can it be limited to the vault vm?
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

# TODO the "generated" resource name is not very descriptive; why not use "vault" instead?
# hashicorp vault will use this azurerm_key_vault_key to wrap/encrypt its master key.
resource "azurerm_key_vault_key" "generated" {
  name         = var.key_name
  key_vault_id = azurerm_key_vault.vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "wrapKey",
    "unwrapKey",
  ]
}
