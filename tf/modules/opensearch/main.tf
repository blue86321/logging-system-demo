data "aws_caller_identity" "current" {}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "opensearchservice.amazonaws.com"
}

resource "aws_opensearch_domain" "this" {
  domain_name    = var.domain_name
  engine_version = "OpenSearch_2.9"

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

  # auto_tune_options {
  #   desired_state       = "ENABLED"
  #   rollback_on_disable = "NO_ROLLBACK"
  # }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  cognito_options {
    enabled          = true
    user_pool_id     = aws_cognito_user_pool.this.id
    identity_pool_id = aws_cognito_identity_pool.this.id
    role_arn         = aws_iam_role.cognito_es_role.arn
  }

  # configure with `aws_opensearch_domain_policy` to avoid regex pattern error
  # source: https://github.com/hashicorp/terraform-provider-aws/issues/26433#issuecomment-1464612165
  access_policies = null

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

data "aws_iam_policy_document" "es_access_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["es:*"]
    resources = ["arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"]
  }
}

resource "aws_opensearch_domain_policy" "this" {
  domain_name     = aws_opensearch_domain.this.domain_name
  access_policies = data.aws_iam_policy_document.es_access_policy.json

  # Setup identity pool permission via provisioner
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-COMMAND
      aws cognito-identity set-identity-pool-roles \
        --region ${var.region} \
        --identity-pool-id ${aws_cognito_identity_pool.this.id} \
        --roles authenticated=${aws_iam_role.auth_master.arn},unauthenticated=${aws_iam_role.unauth.arn} \
        --role-mappings '{"cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.this.id}:${aws_cognito_managed_user_pool_client.this.id}":{"Type": "Token", "AmbiguousRoleResolution": "Deny"}}'
    COMMAND
  }
}
