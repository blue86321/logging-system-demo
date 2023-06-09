provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "opensearchservice.amazonaws.com"
}

resource "aws_opensearch_domain" "this" {
  domain_name    = var.domain_name
  engine_version = "OpenSearch_2.5"

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_password
    }
  }

  cluster_config {
    instance_type  = var.instance_type
    instance_count = 1
  }

  encrypt_at_rest {
    enabled = true
  }

  ebs_options {
    ebs_enabled = true
    iops        = 3000
    throughput  = 125
    volume_size = 30
    volume_type = "gp3"
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  # configure with `aws_opensearch_domain_policy` to avoid regex pattern error
  # source: https://github.com/hashicorp/terraform-provider-aws/issues/26433#issuecomment-1464612165
  access_policies = null

  depends_on = [aws_iam_service_linked_role.es]
}

data "aws_iam_policy_document" "es_access_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["es:*"]
    resources = ["arn:aws:es:${var.region}:${data.aws_caller_identity.current.id}:domain/${var.domain_name}/*"]
  }
}

resource "aws_opensearch_domain_policy" "this" {
  domain_name = aws_opensearch_domain.this.domain_name
  access_policies = data.aws_iam_policy_document.es_access_policy.json
}
