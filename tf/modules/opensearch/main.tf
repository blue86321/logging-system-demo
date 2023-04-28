data "aws_caller_identity" "current" {}

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
    instance_type  = var.instance_type
    instance_count = 1

    # TODO, wait for further research
    dedicated_master_enabled = false
    dedicated_master_count   = 0
    dedicated_master_type    = "t2.small.elasticsearch"
    zone_awareness_enabled = false
  }

  encrypt_at_rest {
    enabled = true
  }

  ebs_options {
    ebs_enabled = true
    iops        = 3000
    throughput  = 125
    volume_size = 10
    volume_type = "gp3"
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_options = {
    "indices.fielddata.cache.size" : "20",
    "indices.query.bool.max_clause_count" : "1024",
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
}
