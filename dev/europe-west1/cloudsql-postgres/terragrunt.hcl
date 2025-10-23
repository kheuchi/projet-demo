include "root" { path = find_in_parent_folders("terragrunt.hcl") }

locals {
  env     = read_terragrunt_config(find_in_parent_folders("dev/env.hcl"))
  common  = read_terragrunt_config(find_in_parent_folders("common/modules.pins.hcl"))
  shared  = read_terragrunt_config(find_in_parent_folders("common/env.hcl"))
}

terraform {
  source = local.common.locals.module_cloudsql_postgres_source
}

inputs = {
  project_id       = local.env.locals.project_id
  region           = local.env.locals.region
  name             = "demo-db-dev"
  database_version = "POSTGRES_16"
  tier             = "db-custom-2-7680"

  enable_public_ip   = true
  authorized_networks = [{ name = "office", value = "203.0.113.0/24" }]
  enable_private_ip  = false

  database_name = "demo"
  app_user      = "demo_user"

  backup_enabled     = true
  pitr_enabled       = true
  availability_type  = "ZONAL"
  labels             = merge(local.shared.locals.labels, local.env.locals.labels)
}
