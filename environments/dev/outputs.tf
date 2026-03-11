output "frontend_url" {
  value = module.frontend.service_uri
}

output "backend_url" {
  value = module.backend.service_uri
}

output "cloudsql_connection_name" {
  value = module.database.connection_name
}

output "db_password_secret_name" {
  value = module.backend_bootstrap.db_password_secret_id
}
