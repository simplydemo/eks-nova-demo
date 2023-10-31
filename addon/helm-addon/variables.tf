variable "helm_config" {
  description = "Helm chart config. Repository and version required. See https://registry.terraform.io/providers/hashicorp/helm/latest/docs"
  type        = any
}

variable "set_values" {
  description = "Forced set values"
  type        = any
  default     = []
}

variable "set_sensitive_values" {
  description = "Forced set_sensitive values"
  type        = any
  default     = []
}


variable "addon_context" {
  description = "Input configuration for the addon"
  type        = any
}
