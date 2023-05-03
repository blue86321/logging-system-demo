provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "opensearch" {
  source = "./modules/opensearch"

  domain_name = var.domain_name
  region      = var.region
}
