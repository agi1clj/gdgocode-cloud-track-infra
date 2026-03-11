variable "project_id" {
  type = string
}

variable "team_name" {
  type = string
}

variable "backend_service_name" {
  type = string
}

variable "db_password" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "project_services" {
  type = set(string)

  default = [
    "iam.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
  ]
}
