# aws-ebs-csi-driver

```hcl
  enable_amazon_eks_vpc_cni = true # default is false
  #Optional
  amazon_eks_vpc_cni_config = {
    addon_name               = "vpc-cni"
    addon_version            = "v1.11.2-eksbuild.1"
    service_account          = "aws-node"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    service_account_role_arn = null
    preserve                 = true
    additional_iam_policies  = []
    configuration_values = jsonencode({
      env = {
        ENABLE_PREFIX_DELEGATION = "true"
        WARM_PREFIX_TARGET       = "1"
      }
    })
    tags = {}
  }

```