output "opensearch_endpoint" {
  value = aws_opensearch_domain.this.endpoint
}

output "opensearch_master_role_arn" {
  value = aws_iam_role.auth_master.arn
}

output "opensearch_dashboard_endpoint" {
  value = aws_opensearch_domain.this.dashboard_endpoint
}
