locals {
  resource_prefix = "gdg-${var.team_name}"
  frontend_name   = coalesce(var.frontend_service_name, "${local.resource_prefix}-frontend")
  backend_name    = coalesce(var.backend_service_name, "${local.resource_prefix}-backend")
  db_instance     = coalesce(var.db_instance_name, "${local.resource_prefix}-db")
}

resource "random_password" "db_password" {
  count   = var.db_password == null ? 1 : 0
  length  = 24
  special = true
}

locals {
  effective_db_password = coalesce(
    var.db_password,
    one(random_password.db_password[*].result)
  )
}

module "backend_bootstrap" {
  source = "../../modules/backend_bootstrap"

  project_id           = var.project_id
  backend_service_name = local.backend_name
  team_name            = var.team_name
  db_password          = local.effective_db_password
}

module "database" {
  source = "../../modules/cloud_sql_postgres"

  project_id        = var.project_id
  region            = var.region
  instance_name     = local.db_instance
  database_name     = var.db_name
  database_user     = var.db_user
  database_password = local.effective_db_password

  depends_on = [module.backend_bootstrap]
}

module "backend" {
  source = "../../modules/cloud_run_service"

  project_id = var.project_id
  region     = var.region
  name       = local.backend_name
  image      = var.backend_image

  cpu    = "1"
  memory = "512Mi"

  service_account = module.backend_bootstrap.service_account_email
  # Cloud Run mounts the Cloud SQL Unix socket into /cloudsql for the backend.
  cloudsql_instances = [module.database.connection_name]

  env_vars = {
    # The pg client treats this as a Unix socket directory in Cloud Run.
    DB_HOST                 = "/cloudsql/${module.database.connection_name}"
    DB_PORT                 = "5432"
    DB_NAME                 = module.database.database_name
    DB_USER                 = module.database.database_user
    DB_SSL                  = "false"
    CORS_ORIGIN             = var.backend_cors_origin
    BACKEND_READ_ONLY       = var.backend_read_only ? "true" : "false"
    RATE_LIMIT_WINDOW_MS    = "60000"
    RATE_LIMIT_MAX_REQUESTS = "120"
  }

  secret_env_vars = {
    DB_PASSWORD = {
      secret  = module.backend_bootstrap.db_password_secret_id
      version = "latest"
    }
  }

  depends_on = [module.backend_bootstrap, module.database]
}

module "frontend" {
  source = "../../modules/cloud_run_service"

  project_id         = var.project_id
  region             = var.region
  name               = local.frontend_name
  image              = var.frontend_image
  container_port     = 80
  cpu                = "1"
  memory             = "512Mi"
  max_instance_count = 2

  env_vars = {
    VITE_API_BASE_URL = module.backend.service_uri
    VITE_EVENT_NAME   = var.frontend_event_name
  }

  depends_on = [module.backend_bootstrap, module.backend]
}
