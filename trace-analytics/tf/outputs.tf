
output "AWS_OPENSEARCH_HOST" {
  value = aws_opensearch_domain.this.endpoint
}

output "AWS_OPENSEARCH_DASHBOARD" {
  value = aws_opensearch_domain.this.dashboard_endpoint
}

output "AWS_OPENSEARCH_MASTER_USER_NAME" {
  value = var.master_user_name
}

output "AWS_OPENSEARCH_MASTER_PASSWORD" {
  value = var.master_password
}
