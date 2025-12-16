variable "location" {
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "automation_account_name" {
    type = string
}