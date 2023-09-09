locals {
  os = "linux"
  # ami_type = "BOTTLEROCKET_x86_64"
  ami_type = "BOTTLEROCKET_ARM_x86_64"
  platform = startswith(local.ami_type, "BOTTLEROCKET") ? "bottlerocket" : local.os

}


output "platform" {
  value = local.platform
}