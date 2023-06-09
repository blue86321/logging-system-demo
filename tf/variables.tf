variable "region" {
  description = "AWS region"
  type        = string
}

variable "access_key" {
  description = "AWS access key"
  type        = string
}
variable "secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "domain_name" {
  description = "OpenSearch domain name"
  type        = string
}

variable "cognito_master_email" {
  description = "An user email in Cognito master user group"
  type        = string
}
