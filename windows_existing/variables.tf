# Declare TF variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "Your AWS Access Key ID"
  type        = string

}

variable "aws_secret_key" {
  description = "Your AWS Secret Key"
  type        = string

}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "eastus"
}

variable "resourceGroup" {
  description = "Azure resource group"
  type        = string
  default     = "arc_testing"
}

variable "subId" {
  description = "Azure subscription ID"
  type        = string

}

variable "servicePrincipalAppId" {
  description = "Azure service principal App ID"
  type        = string

}

variable "servicePrincipalSecret" {
  description = "Azure service principal App Password"
  type        = string

}

variable "servicePrincipalTenantId" {
  description = "Azure Tenant ID"
  type        = string

}

variable "admin_user" {
  description = "Guest OS Admin Username"
  type        = string
  default     = "Administrator"
}

variable "admin_password" {
  description = "Guest OS Admin Password"
  type        = string
}

variable "workspaceId" {
  
}

variable "workspaceKey" {
}

variable "public_ip" {
}
