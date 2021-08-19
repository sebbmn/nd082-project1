variable "prefix" {
  description = "The prefix which should be used for all resources in this project"
}

variable "location" {
  description = "The Azure Region in which all resources in this project should be created."
}

variable "instance_count" {
  type        = number
  default     = 2
  description = "Number of VM instances to be created"

  validation {
    condition     = var.instance_count >= 2 && var.instance_count <= 5
    error_message = "Number of VM instances MUST be between 2 and 5."
  }
}

variable "username" {
  description = "Enter the VM admin username"
}

variable "password" {
  description = "Enter the VM admin password"
}
