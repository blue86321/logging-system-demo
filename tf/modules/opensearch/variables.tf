variable "region" {
  description = "AWS Region"
  type        = string
}

variable "domain_name" {
  description = "OpenSearch domain name"
  type        = string
}

variable "instance_type" {
  description = "OpenSearch instance type"
  type        = string
  default     = "t3.small.search" # free tier
}

variable "cognito_master_user_list" {
  description = "Cognito master users with full access permission in OpenSearch"
  type = list(object({
    username = string
    # `name`: A tag for this user
    name = optional(string)
  }))
  default = []
}

variable "cognito_limited_user_list" {
  description = "Cognito limited users with dashboard permission and readall permission in OpenSearch"
  type = list(object({
    username = string
    # `name`: A tag for this user
    name = optional(string)
  }))
  default = []
}
