
# User pool
resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.domain_name}-user-pool"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  mfa_configuration        = "OFF"
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  user_pool_add_ons {
    advanced_security_mode = "OFF"
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain       = var.domain_name
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

# User group
resource "aws_cognito_user_group" "master" {
  name         = "master-group"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  role_arn     = aws_iam_role.auth_master.arn
}
resource "aws_cognito_user_group" "limited" {
  name         = "limited-group"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  role_arn     = aws_iam_role.auth_limited.arn
}


# Identity pool
resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "${var.domain_name}-identity-pool"
  allow_unauthenticated_identities = false

  # AWS OpenSearch will maintain `cognito_identity_providers`, so ignore it
  lifecycle {
    ignore_changes = [cognito_identity_providers]
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "roles_attachment" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id

  roles = {
    "authenticated"   = aws_iam_role.auth_master.arn,
    "unauthenticated" = aws_iam_role.unauth.arn,
  }

  # Need to manually config, so ignore changes; otherwise, there is a dependency cycle
  lifecycle {
    ignore_changes = [role_mapping]
  }
}
