locals {
  project_id      = "acme-dev-1234"
  region          = "europe-west1"
  private_network = "projects/acme-net/global/networks/shared-vpc"
  labels          = { env = "dev" }
}
