resource "opensearch_roles_mapping" "limited_user_dashboard" {
  role_name   = "opensearch_dashboards_user"
  backend_roles = [
    aws_iam_role.auth_limited.arn
  ]
}

resource "opensearch_roles_mapping" "limited_user_readall" {
  role_name   = "readall"
  backend_roles = [
    aws_iam_role.auth_limited.arn
  ]
}
