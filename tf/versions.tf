terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.60"
    }

    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "1.0.0"
    }
  }
}
