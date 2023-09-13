variable "enable_amazon_prometheus" {
  description = "Enabled AWS Managed Prometheus"
  type    = bool
  default = false
}

variable "account_id" {
  type    = string
}

variable "cluster_name" {
  type    = string
}

variable "cluster_version" {
  type    = string
}

variable "set_values" {
  description =<<EOF
Helm set values

set_values = [
    {
      name  = "serviceAccounts.server.create"
      value = false
    },
    {
      name  = "server.remoteWrite[0].sigv4.region"
      value = "ap-northeast-2"
    }
  ]
EOF
  type        = any
  default     = []
}

variable "amazon_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus Workspace Endpoint"
  type        = string
  default     = null
}

variable "irsa_iam_policies" {
  type        = list(string)
  description = "IAM Policies for IRSA IAM role"
  default     = []
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
