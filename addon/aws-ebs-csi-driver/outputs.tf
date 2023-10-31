output "release_metadata" {
  description = "Map of attributes of the Helm release metadata"
  value       = try(helm_release.helm[0].metadata, null)
}

output "irsa_arn" {
  description = "IAM role ARN for the service account"
  value       = try(module.irsaAws[0].irsa_iam_role_arn, null)
}

output "irsa_name" {
  description = "IAM role name for the service account"
  value       = try(module.irsaAws[0].irsa_iam_role_name, null)
}

output "service_account" {
  description = "Name of Kubernetes service account"
  value       = try(module.irsaAws[0].service_account, null)
}
