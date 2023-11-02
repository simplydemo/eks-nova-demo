# ~ nodes

# node-01
module "amd64" {
  source                = "../modules/nodegroup/"
  create                = false
  eks_context           = module.eks.context
  name                  = "amd64"
  instance_types        = ["t3a.small"]
  desired_size          = 1
  ami_id                = data.aws_ami.amd64.image_id
  ami_type              = "AL2_x86_64"
  subnet_ids            = data.aws_subnets.eksmdapp.ids
  block_device_mappings = [
    {
      volume_type = "gp3"
      volume_size = 100
    }
  ]
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
  labels = {
    "node.role" = "backend"
  }
  /*
  taints = [
    {
      key    = "amd64"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  ]
  */
  depends_on = [module.eks]
}

# node-02
module "arm64" {
  source                       = "../modules/nodegroup/"
  create                       = true
  eks_context                  = module.eks.context
  name                         = "arm64"
  instance_types               = ["t4g.small"]
  desired_size                 = 3
  ami_id                       = data.aws_ami.arm64.image_id
  ami_type                     = "AL2_ARM_64"
  subnet_ids                   = data.aws_subnets.eksarapp.ids
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
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
  /*
    taints = [
      {
        key    = "arm64"
        value  = "true"
        effect = "NO_SCHEDULE"
      }
    ]
    */
  labels = {
    "node.role" = "backend"
  }
  depends_on = [module.eks]
}

# node-03 - amd -- Managed
module "amd64md" {
  source                       = "../modules/nodegroup/"
  create                       = false
  eks_context                  = module.eks.context
  name                         = "amd64md"
  instance_types               = ["t3a.small"]
  ami_type                     = "AL2_x86_64"
  subnet_ids                   = data.aws_subnets.eksmdapp.ids
  use_custom_launch_template   = false
  disk_size                    = 100
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
  labels = {
    "node.role" = "dataproc"
  }
  depends_on = [module.eks]
}

# node-04 - arm Managed
module "arm64md" {
  source                       = "../modules/nodegroup/"
  create                       = false
  eks_context                  = module.eks.context
  name                         = "arm64md"
  instance_types               = ["t4g.small"]
  ami_type                     = "AL2_ARM_64"
  subnet_ids                   = data.aws_subnets.eksarapp.ids
  use_custom_launch_template   = false
  disk_size                    = 100
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
  labels = {
    "node.role" = "dataproc"
  }
  depends_on = [module.eks]
}

# node-05
module "arm64br" {
  source                = "../modules/nodegroup/"
  create                = false
  eks_context           = module.eks.context
  name                  = "arm64br"
  instance_types        = ["t4g.small"]
  ami_type              = "BOTTLEROCKET_ARM_64"
  ami_id                = data.aws_ami.arm64br.image_id
  subnet_ids            = data.aws_subnets.eksarapp.ids
  desired_size          = 1
  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      volume_type = "100"
      volume_size = 10
    },
  ]
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
  labels = {
    "node.role" = "backend"
  }
  depends_on = [module.eks]
}

/*
module "amd64mbr" {
  source                       ="../modules/nodegroup/"
  create                       = false
  eks_context                  = module.eks.context
  name                         = "amd64mbr"
  instance_types               = ["t3a.small"]
  ami_id                       = data.aws_ami.amd64br.image_id
  ami_type                     = "BOTTLEROCKET_x86_64"
  subnet_ids                   = data.aws_subnets.eksmdapp.ids
  use_custom_launch_template   = false
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  depends_on = [module.eks]
}
*/
