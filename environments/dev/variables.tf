variable "project_id" {
  type = string
}

variable "team_name" {
  type    = string
  default = "team01"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,12}$", var.team_name))
    error_message = "team_name must be 3-12 characters and contain only lowercase letters, numbers, or hyphens."
  }
}

variable "region" {
  type    = string
  default = "europe-west3"
}

variable "frontend_image" {
  type = string
}

variable "backend_image" {
  type = string
}

variable "frontend_service_name" {
  type    = string
  default = null
}

variable "backend_service_name" {
  type    = string
  default = null
}

variable "db_instance_name" {
  type    = string
  default = null
}

variable "db_name" {
  type    = string
  default = "gdgocode_cloud_track"
}

variable "db_user" {
  type    = string
  default = "gdgocode_user"
}

variable "db_password" {
  type      = string
  default   = null
  nullable  = true
  sensitive = true
}

variable "frontend_event_name" {
  type    = string
  default = "GDGoCode 2026"
}

variable "backend_cors_origin" {
  type    = string
  default = "*"
}

variable "backend_read_only" {
  type    = bool
  default = true
}
