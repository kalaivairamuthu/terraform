#
# Providers Configuration
#

terraform {
  required_version = "~> 0.12"
  required_providers {
    aws     = "~> 3.4"
    local   = "~> 1.4"
    http    = "~> 1.2.0"
    azurerm = "~> 2.25.0"
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# # Using these data sources allows the configuration to be generic for any region.
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

provider "azurerm" {
  features {}
  subscription_id = var.subId
  client_id       = var.servicePrincipalAppId
  client_secret   = var.servicePrincipalSecret
  tenant_id       = var.servicePrincipalTenantId
}
