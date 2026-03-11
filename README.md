# GDGoCode Cloud Track Infra

OpenTofu infrastructure for the Cluj-Napoca AQI app.

This repo provisions the cloud resources used by the companion app repo [gdgocode-cloud-track-app](https://github.com/agi1clj/gdgocode-cloud-track-app).

The bootstrap module also enables the required Google Cloud APIs for the workshop environment.

## What this repo creates

- one frontend Cloud Run service
- one backend Cloud Run service
- one Cloud SQL for PostgreSQL instance
- one Cloud SQL database
- one Cloud SQL database user
- one Secret Manager secret for `DB_PASSWORD`

## Repository structure

```text
modules/
  backend_bootstrap/
  cloud_run_service/
  cloud_sql_postgres/
environments/
  dev/
```

## Deployment model

This workshop infra is intentionally simple:

- frontend is public
- backend is public
- Cloud SQL uses a public IP
- backend connects through the Cloud SQL socket mount
- only `DB_PASSWORD` is injected from Secret Manager

This is a workshop baseline, not a production-hardening template.

## Required image naming

The `dev` environment builds image URLs from:

- `frontend_image`
- `backend_image`

Expected format:

- `<dockerhub-username>/<frontend-repo>:<tag>`
- `<dockerhub-username>/<backend-repo>:<tag>`

For this workshop app, the default GitHub Actions workflow publishes:

- `<dockerhub-username>/gdgocode-cloud-track-frontend:sha-<first7commit>`
- `<dockerhub-username>/gdgocode-cloud-track-backend:sha-<first7commit>`

## Variables students provide

Main inputs:

- `project_id`
- `team_name`
- `frontend_image`
- `backend_image`
- `backend_read_only`
- `db_password` (optional)

Defaults live in:

- [terraform.tfvars.example](environments/dev/terraform.tfvars.example)
- [variables.tf](environments/dev/variables.tf)

## Environment workflow

From `environments/dev`:

```bash
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
tofu init -backend-config=backend.hcl
tofu validate
tofu plan
tofu apply
```

OpenTofu enables the required project services during `apply`, so students do not need to enable APIs manually first.

Cloud SQL creation can take longer than 10 minutes in some projects. This repo sets an explicit longer timeout on the Cloud SQL instance resource so `tofu apply` does not fail prematurely during normal provisioning.

State is stored in Google Cloud Storage through the `gcs` backend. Each student can create one bucket in their own project and point `backend.hcl` at it.

Suggested bucket pattern:

- `${team_name}-gdgocode-tfstate`
- if that name is already taken globally in GCS, add a project suffix such as `${team_name}-${project_id}-tfstate`

The remaining prerequisite is operator access: the identity running OpenTofu still needs project-level permissions that allow it to create Cloud SQL, Cloud Run, IAM, and Secret Manager resources.

Recommended workshop setup:

- students can use their own Google Cloud projects if their account has sufficient permissions
- if `tofu apply` fails with `403 notAuthorized`, an instructor or project admin should grant the missing IAM roles

Outputs include:

- frontend URL
- backend URL
- Cloud SQL connection name
- DB password secret name

Password behavior:

- if `db_password` is omitted, OpenTofu generates a password
- the generated password is stored in Secret Manager and injected into Cloud Run
- if you want to control the password value yourself, set `db_password` explicitly
- keep `backend_read_only = true` unless a live demo explicitly needs public seed and clear actions

## Full walkthrough

Use the app repo walkthrough for the end-to-end process:

- [gdgocode-cloud-track-app/docs/cloud-deploy-walkthrough.md](https://github.com/agi1clj/gdgocode-cloud-track-app/blob/main/docs/cloud-deploy-walkthrough.md)

That guide covers:

1. local app sanity checks
2. pushing code to GitHub
3. GitHub Actions image publishing
4. `terraform.tfvars` and `backend.hcl` setup
5. `tofu apply`
6. deployment verification
7. cleanup

For the fallback IAM grant commands, see the app repo guide:

- [gdgocode-cloud-track-app/docs/cloud-deploy-walkthrough.md](https://github.com/agi1clj/gdgocode-cloud-track-app/blob/main/docs/cloud-deploy-walkthrough.md)

Recommended reading order:

1. start in the app repo `README.md`
2. move to the app repo `docs/cloud-deploy-walkthrough.md`
3. come back here only when you are editing infra details directly

## Validation

Useful commands:

```bash
tofu fmt -check -recursive
cd environments/dev && tofu init -backend=false
cd environments/dev && tofu validate
```

## Cleanup

When the workshop is over:

```bash
cd environments/dev
tofu destroy
```
