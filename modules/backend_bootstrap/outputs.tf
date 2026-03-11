output "service_account_email" {
  value = google_service_account.backend.email
}

output "db_password_secret_id" {
  value = google_secret_manager_secret.db_password.secret_id
}

output "db_password_secret_name" {
  value = google_secret_manager_secret.db_password.name
}
