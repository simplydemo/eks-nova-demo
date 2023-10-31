# aws-ebs-csi-driver

[aws-ebs-csi-driver](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html)
The EBS CSI driver provides a CSI interface used by container orchestrators to manage the lifecycle of Amazon EBS volumes. Availability in EKS add-ons in preview enables a simple experience for attaching persistent storage to an EKS cluster. The EBS CSI driver can now be installed, managed, and updated directly through the EKS console, CLI, and API

This addons supports managing AWS-EBS-CSI-DRIVER through either the EKS managed addon or a self-managed addon via Helm.

## Usage

```hcl
module "ebsCsi" {
  source                               = "./aws-ebs-csi-driver"
  count                                = local.enable_amazon_eks_aws_ebs_csi_driver ? 1 : 0
  enable_amazon_eks_aws_ebs_csi_driver = true
  context                              = module.ctx.context
  account_id                           = data.aws_caller_identity.current.account_id
  cluster_name                         = data.aws_eks_cluster.this.name
  cluster_version                      = local.cluster_version
  irsa_config                          = {
    cluster_oidc_provider_arn = local.cluster_oidc_provider_arn
  }
}
```