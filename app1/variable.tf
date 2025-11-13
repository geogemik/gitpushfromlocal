variable "location" {
  type = string
  default = "East US"
  description = "location details for all resources"
}

variable "vmsize" {
  type = string
  validation {
    condition = (var.vmsize == "Standard_b1ms")
    error_message = "VM size must be Standard_b1ms'."
  }
}

variable "adminpassword" {
  type = string
  description = "admin passsword for the azure vm"
  sensitive = true
}

variable "resource_group_name" {
  type = string
  description = "the azure rg name"
  default = "app1"
}

variable "adminuser" {
  description = "User name for the admin account on the VMs."
  type        = string
  default     = "azureuser" # Optional: set a default value
}

variable "vnetproduction" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "production"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnetname" {
  description = "Name of the subnet"
  type        = string
  default     = "subnet1"
}

variable "subnet_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

