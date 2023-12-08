
output "AWS_REGION" {
  value = var.region
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
