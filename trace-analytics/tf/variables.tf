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

variable "master_user_name" {
  description = "OpenSearch master username"
  type        = string
}

variable "master_password" {
  description = "OpenSearch master password"
  type        = string
}

variable "instance_type" {
  description = "OpenSearch instance type"
  type        = string
  default     = "t3.small.search" # free tier
}
