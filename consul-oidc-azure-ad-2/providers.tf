terraform {
  required_version = ">= 1.0.8"  
  backend "local" {}

  required_providers {
    consul = {
      version = "~> 2.15.0"
    }
  }
}
provider "consul" {
  address    = var.consul_url
  datacenter = var.consul_datacenter
  token      = var.consul_token
}

provider "azuread" {}

provider "azurerm" {
  features {}
}
  
