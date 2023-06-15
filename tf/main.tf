provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

provider "opensearch" {
  url                 = "https://${module.opensearch.opensearch_endpoint}"
  aws_region          = var.region
  aws_assume_role_arn = module.opensearch.opensearch_master_role_arn
}

module "opensearch" {
  source = "./modules/opensearch"

  domain_name = var.domain_name
  region      = var.region
  cognito_master_user_list = [{
    username = var.cognito_master_email
  }]
  cognito_limited_user_list = [{
    username = var.cognito_limited_email
  }]
}
