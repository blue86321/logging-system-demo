output "opensearch_endpoint" {
  value = aws_opensearch_domain.opensearch.endpoint
}

output "opensearch_master_role_arn" {
  value = aws_iam_role.auth_master.arn
}
