locals {
  default_tf_version = "1.6.6"
}

remote_state {
  backend = "gcs"
  config = {
    bucket  = get_env("TG_STATE_BUCKET", "REPLACE_ME-states")
    prefix  = "projet-demo/${path_relative_to_include()}"
    project = get_env("TG_STATE_PROJECT", "REPLACE_ME-project")
    location = "EU"
  }
}

# versions.tf
generate "versions" {
  path      = "versions.auto.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
  terraform {
    required_version = ">= ${local.default_tf_version}"
    required_providers {
      google = { source = "hashicorp/google", version = ">= 5.0" }
      random = { source = "hashicorp/random", version = ">= 3.5" }
    }
  }
  EOF
}

# provider.tf
generate "provider" {
  path      = "provider.auto.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
  provider "google" {
    project = var.project_id
    region  = var.region
  }
  EOF
}
