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

variable "storage_account_id" {
    type = string
}

variable "log_analytics_workspace_id" {
    type = string
}

variable "queue_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}