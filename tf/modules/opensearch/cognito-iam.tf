# OpenSearch Cognito IAM role name
data "aws_iam_policy_document" "es_assume_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cognito_es_role" {
  name               = "${replace(var.domain_name, "-", "")}_CognitoAccessForAmazonOpenSearch"
  assume_role_policy = data.aws_iam_policy_document.es_assume_policy.json
}


data "aws_iam_policy" "cognito_es_policy" {
  name = "AmazonOpenSearchServiceCognitoAccess"
}

resource "aws_iam_role_policy_attachment" "cognito_es_attach" {
  role       = aws_iam_role.cognito_es_role.name
  policy_arn = data.aws_iam_policy.cognito_es_policy.arn
}



# auth iam policies
data "aws_iam_policy" "es_full_access" {
  name = "AmazonOpenSearchServiceFullAccess"
}

resource "aws_iam_policy" "auth" {
  name = "Cognito_${replace(var.domain_name, "-", "")}_Auth"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "mobileanalytics:PutEvents",
          "cognito-sync:*",
          "cognito-identity:*"
        ]
        Resource = "*"
      },
    ]
  })
}



# auth master role
data "aws_iam_policy_document" "auth_master_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.identity_pool.id]
    }
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "auth_master" {
  name               = "Cognito_${replace(var.domain_name, "-", "")}_Auth_Master_Role"
  assume_role_policy = data.aws_iam_policy_document.auth_master_assume.json
}

resource "aws_iam_role_policy_attachment" "cognito_auth_master_1" {
  role       = aws_iam_role.auth_master.name
  policy_arn = aws_iam_policy.auth.arn
}

resource "aws_iam_role_policy_attachment" "cognito_auth_master_2" {
  role       = aws_iam_role.auth_master.name
  policy_arn = data.aws_iam_policy.es_full_access.arn
}



# auth limited role
data "aws_iam_policy_document" "auth_limited_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.identity_pool.id]
    }
  }
}

resource "aws_iam_role" "auth_limited" {
  name               = "Cognito_${replace(var.domain_name, "-", "")}_Auth_Limited_Role"
  assume_role_policy = data.aws_iam_policy_document.auth_limited_assume.json
}

resource "aws_iam_role_policy_attachment" "cognito_auth_limited_1" {
  role       = aws_iam_role.auth_limited.name
  policy_arn = aws_iam_policy.auth.arn
}



# unauth role
data "aws_iam_policy_document" "unauth_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.identity_pool.id]
    }
  }
}

resource "aws_iam_policy" "unauth" {
  name = "Cognito_${replace(var.domain_name, "-", "")}_Unauth"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "mobileanalytics:PutEvents",
          "cognito-sync:*",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "unauth" {
  name               = "Cognito_${replace(var.domain_name, "-", "")}_Unauth_Role"
  assume_role_policy = data.aws_iam_policy_document.unauth_assume.json
}

resource "aws_iam_role_policy_attachment" "cognito_unauth_1" {
  role       = aws_iam_role.unauth.name
  policy_arn = aws_iam_policy.unauth.arn
}