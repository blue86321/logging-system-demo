variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "domain_name" {}
variable "master_user_name" {}
variable "master_password" {}
variable "instance_type" {
  description = "OpenSearch instance type"
  type        = string
  default     = "t3.small.search" # free tier
}
