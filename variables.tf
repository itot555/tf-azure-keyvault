variable "resource_group_name" {
  default = "itochu-rg-tokyo"
}

variable "location" {
  default = "japaneast"
}

variable "environment" {
  default = "vault-auto-unseal-test"
}

variable "azurerm_key_vault" {
  default = "itochu-vault-test-key"
}

variable "client_id" {}
variable "tenant_id" {}

variable "key_name" {
  default = "itochu-generated-key"
}
