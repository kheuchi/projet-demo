include "root" { path = find_in_parent_folders("terragrunt.hcl") }

locals {
  env     = read_terragrunt_config(find_in_parent_folders("prod/env.hcl"))
  common  = read_terragrunt_config(find_in_parent_folders("common/modules.pins.hcl"))
  shared  = read_terragrunt_config(find_in_parent_folders("common/env.hcl"))
}

terraform {
  source = local.common.locals.module_cloudsql_postgres_source
}

inputs = {
  project_id       = local.env.locals.project_id
  region           = local.env.locals.region
  name             = "demo-db-prd"
  database_version = "POSTGRES_16"
  tier             = "db-custom-8-30720"

  enable_public_ip   = false
  enable_private_ip  = true
  private_network    = local.env.locals.private_network

  database_name = "demo"
  app_user      = "demo_user"

  backup_enabled     = true
  pitr_enabled       = true
  availability_type  = "REGIONAL"
  deletion_protection = true
  disk_type          = "PD_SSD"
  disk_size          = 100

  labels = merge(local.shared.locals.labels, local.env.locals.labels, { critical = "true" })
}
