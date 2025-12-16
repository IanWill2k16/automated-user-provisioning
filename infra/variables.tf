variable "location" {
  type        = string
  default     = "eastus"
}

variable "environment" {
  type        = string
  default     = "demo"
}

variable "name_prefix" {
  type        = string
  default     = "identity-automation"
}

variable "oidc_client_id" {
  type = string
}
variable "tenant_id" {
  type = string
}
variable "subscription_id" {
  type = string
}