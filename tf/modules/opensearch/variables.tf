variable "region" {
  description = "AWS Region"
  type = string
}

variable "domain_name" {
  description = "OpenSearch domain name"
  type = string
}

variable "instance_type" {
  description = "OpenSearch instance type"
  type = string
  # default = "t3.small.search"   # free tier
  default = "c6g.large.search"  # min for production
}
