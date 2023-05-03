data "aws_caller_identity" "current" {}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "opensearchservice.amazonaws.com"
}

resource "aws_opensearch_domain" "opensearch" {
  domain_name    = var.domain_name
  engine_version = "OpenSearch_2.5"

  advanced_security_options {
    enabled = true
    master_user_options {
      master_user_arn = aws_iam_role.auth_master.arn
    }
  }

  cluster_config {
    instance_type          = var.instance_type
    instance_count         = 2
    zone_awareness_enabled = true

    dedicated_master_enabled = true
    dedicated_master_count   = 3
    dedicated_master_type    = "m6g.large.search"

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

  auto_tune_options {
    desired_state       = "ENABLED"
    rollback_on_disable = "NO_ROLLBACK"
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  cognito_options {
    enabled          = true
    user_pool_id     = aws_cognito_user_pool.user_pool.id
    identity_pool_id = aws_cognito_identity_pool.identity_pool.id
    role_arn         = aws_iam_role.cognito_es_role.arn
  }

  access_policies = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": "es:*",
        "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"
      }
    ]
  }
  EOF

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.search_slow.arn
    enabled                  = true
    log_type                 = "SEARCH_SLOW_LOGS"
  }
  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.index_solw.arn
    enabled                  = true
    log_type                 = "INDEX_SLOW_LOGS"
  }
  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.error.arn
    enabled                  = true
    log_type                 = "ES_APPLICATION_LOGS"
  }

  depends_on = [aws_iam_service_linked_role.es]
}
