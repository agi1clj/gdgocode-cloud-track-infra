# Contributing

## Scope

This repository contains infrastructure code for a student workshop.

Contributions should keep the infrastructure:

- understandable for students
- inexpensive
- safe for public open-source sharing
- aligned with the companion app repository

## Before opening a pull request

Run:

```bash
tofu fmt -recursive
cd environments/dev
tofu init -backend=false
tofu validate
```

## Contribution guidelines

- Prefer explicit infrastructure over advanced patterns.
- Avoid adding unnecessary networking complexity.
- Do not widen public access unless there is a strong workshop reason.
- Do not store secrets in committed files.
- Keep application deployment ownership in IaC instead of ad hoc manual drift.

## Pull request content

Please include:

- what changed
- why it changed
- how it affects student setup
- what commands you used to validate it

