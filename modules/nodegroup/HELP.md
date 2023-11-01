# nodegroup

## Usage

```hcl
module "arm64" {
  source                       = "../modules/nodegroup/"
  create                       = true
  eks_context                  = module.eks.context
  name                         = "arm64"
  instance_types               = ["t4g.small"]
  ami_id                       = data.aws_ami.arm64.image_id
  ami_type                     = "AL2_ARM_64"
  subnet_ids                   = data.aws_subnets.eksarapp.ids
  desired_size                 = 1
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    CustomPolicy                 = aws_iam_policy.custom.arn
  }
  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      volume_type = "gp3"
      volume_size = 10
    },
    {
      device_name = "/dev/xvdb"
      volume_type = "gp3"
      volume_size = 100
    },
  ]
  taints = [
    {
      key    = "arm64"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  ]
  labels = {
    "kubernetes.io/role" = "Backend-Api on ARM64"
  }
  depends_on = [module.eks]
}
```

