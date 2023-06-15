
# User pool
resource "aws_cognito_user_pool" "this" {
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

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.domain_name
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_managed_user_pool_client" "this" {
  name_prefix  = "AmazonOpenSearchService-${var.domain_name}"
  user_pool_id = aws_cognito_user_pool.this.id

  lifecycle {
    ignore_changes = [
      supported_identity_providers,
      callback_urls,
      logout_urls,
      allowed_oauth_flows,
      allowed_oauth_scopes,
      allowed_oauth_flows_user_pool_client
    ]
  }

  depends_on = [
    aws_opensearch_domain.this
  ]
}

# User group
resource "aws_cognito_user_group" "master" {
  name         = "master-group"
  user_pool_id = aws_cognito_user_pool.this.id
  role_arn     = aws_iam_role.auth_master.arn
}
resource "aws_cognito_user_group" "limited" {
  name         = "limited-group"
  user_pool_id = aws_cognito_user_pool.this.id
  role_arn     = aws_iam_role.auth_limited.arn
}


# Identity pool
resource "aws_cognito_identity_pool" "this" {
  identity_pool_name               = "${var.domain_name}-identity-pool"
  allow_unauthenticated_identities = false

  # AWS OpenSearch will maintain `cognito_identity_providers`, so ignore it
  # This part needs to wait until OpenSearch is created to proceed, so we cannot config here due to dependency
  # To be more specific, we need `aws_cognito_user_pool_client` id.
  # However, `aws_cognito_user_pool_client` need to set `callback_urls`, which is our OpenSearch dashboard endpoint.
  # The workaround is to use scripts or AWS CLI after terraform (provisioner).
  # Source: https://github.com/hashicorp/terraform-provider-aws/issues/5557
  lifecycle {
    ignore_changes = [cognito_identity_providers]
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "this" {
  identity_pool_id = aws_cognito_identity_pool.this.id

  roles = {
    "authenticated"   = aws_iam_role.auth_master.arn,
    "unauthenticated" = aws_iam_role.unauth.arn,
  }

  # Need to further configure with privisioner.
  # Due to the dependency of `cognito_identity_providers`, we cannot configure here.
  lifecycle {
    ignore_changes = [role_mapping]
  }
}



# Cognito users
resource "aws_cognito_user" "master" {
  for_each = {
    for user in var.cognito_master_user_list :
    # key => value
    user.username => user
  }
  user_pool_id             = aws_cognito_user_pool.this.id
  desired_delivery_mediums = ["EMAIL"]
  username                 = each.key
  attributes = {
    # auto added
    email = each.key
    # custom tag
    name = each.value.name
  }
}

resource "aws_cognito_user" "limited" {
  for_each = {
    for user in var.cognito_limited_user_list :
    # key => value
    user.username => user
  }
  user_pool_id             = aws_cognito_user_pool.this.id
  desired_delivery_mediums = ["EMAIL"]
  username                 = each.key
  attributes = {
    # auto added
    email = each.key
    # custom tag
    name = each.value.name
  }
}



# Add users to user group
resource "aws_cognito_user_in_group" "master" {
  for_each = {
    for user in var.cognito_master_user_list :
    # key => value
    user.username => user
  }
  user_pool_id = aws_cognito_user_pool.this.id
  group_name   = aws_cognito_user_group.master.name
  username     = each.key
}

resource "aws_cognito_user_in_group" "limited" {
  for_each = {
    for user in var.cognito_limited_user_list :
    # key => value
    user.username => user
  }
  user_pool_id = aws_cognito_user_pool.this.id
  group_name   = aws_cognito_user_group.limited.name
  username     = each.key
}
