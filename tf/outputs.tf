
output "AWS_REGION" {
  value = var.region
}

# Only for demo, as an environment variable for fluent-bit
output "AWS_ACCESS_KEY_ID" {
  value = var.access_key
}

# Only for demo, as an environment variable for fluent-bit
output "AWS_SECRET_ACCESS_KEY" {
  value = var.secret_key
}

output "AWS_OPENSEARCH_HOST" {
  value = module.opensearch.opensearch_endpoint
}

output "AWS_OPENSEARCH_DASHBOARD" {
  value = module.opensearch.opensearch_dashboard_endpoint
}

output "AWS_OPENSEARCH_ROLE_ARN" {
  value = module.opensearch.opensearch_master_role_arn
}
