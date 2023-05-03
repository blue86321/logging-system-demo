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
  default = "c6g.large.search"
}
