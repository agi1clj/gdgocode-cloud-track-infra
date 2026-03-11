# Security Policy

## Supported use

This repository is intended for workshops, demos, and learning environments.

It is not intended to be a full production security baseline.

## Current security model

- frontend service is public
- backend service is public
- Cloud SQL is intended to be accessed by the backend through connector-based access
- the database password is injected into Cloud Run from Secret Manager
- infrastructure defaults are optimized for simplicity and low cost

## Important limitations

- Public backend access means the deployed API can be called by anyone unless maintainers add authentication or additional controls.
- Cost-optimized infrastructure settings are not equivalent to production hardening.
- The database password still exists in OpenTofu inputs and state even though runtime delivery uses Secret Manager.
- Students should use local PostgreSQL for local development rather than opening the cloud database for direct access.

## Reporting a vulnerability

If you discover a security issue:

1. avoid posting sensitive exploit details publicly
2. contact the maintainers privately if possible
3. provide enough detail for reproduction and impact assessment
