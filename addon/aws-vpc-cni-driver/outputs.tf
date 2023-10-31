output "addon_version" {
  value       = try(local.addon_version, null)
}

output "create_irsa" {
  value       = try(local.create_irsa, null)
}