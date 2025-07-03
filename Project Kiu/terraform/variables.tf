# main.tf

provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  type    = string
  default = "grupotestku-rg"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "aks_cluster_name" {
  type    = string
  default = "test-ku-aks"
}

variable "dns_prefix" {
  type    = string
  default = "test-ku-aks"
}

variable "postgres_server_name" {
  type    = string
  default = "test-ku-postgres"
}

variable "postgres_admin" {
  type    = string
  default = "pgadmin"
}

variable "postgres_password" {
  type      = string
  sensitive = true
  default   = "SuperSecretPassword123!"
}
