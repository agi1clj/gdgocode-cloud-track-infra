resource "google_project_service" "required" {
  for_each = var.project_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_service_account" "backend" {
  account_id   = "gdg-${var.team_name}-api"
  display_name = "GDGoCode Cloud Track Backend"

  depends_on = [google_project_service.required["iam.googleapis.com"]]
}

resource "google_project_iam_member" "backend_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend.email}"

  depends_on = [google_project_service.required["sqladmin.googleapis.com"]]
}

resource "google_secret_manager_secret" "db_password" {
  project   = var.project_id
  secret_id = "${var.backend_service_name}-db-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.required["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.name
  secret_data = var.db_password
}

resource "google_secret_manager_secret_iam_member" "backend_db_password_accessor" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend.email}"
}
