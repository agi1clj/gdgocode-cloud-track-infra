resource "google_sql_database_instance" "this" {
  name                = var.instance_name
  project             = var.project_id
  region              = var.region
  database_version    = var.database_version
  deletion_protection = false

  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }

  settings {
    connector_enforcement = "REQUIRED"
    edition               = var.edition
    tier                  = var.tier
    availability_type     = "ZONAL"
    disk_autoresize       = true
    disk_size             = var.disk_size_gb

    backup_configuration {
      enabled = false
    }

    ip_configuration {
      ipv4_enabled = true
      ssl_mode     = "ENCRYPTED_ONLY"
    }
  }
}

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.this.name
  project  = var.project_id
}

resource "google_sql_user" "user" {
  name     = var.database_user
  instance = google_sql_database_instance.this.name
  project  = var.project_id
  password = var.database_password
}
