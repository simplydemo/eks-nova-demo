module "ctx" {
  source = "../context/"
}

locals {
  project         = module.ctx.project
  name_prefix     = module.ctx.name_prefix
  tags            = module.ctx.tags
  cluster_name    = module.ctx.cluster_name
  cluster_version = module.ctx.cluster_version
  vpc_id          = data.aws_vpc.this.id
  eks_subnet_ids  = data.aws_subnets.eks.ids
}

module "eks" {
  source          = "../modules/cluster/"
  context         = module.ctx.context
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version
  vpc_id          = local.vpc_id
  subnet_ids      = local.eks_subnet_ids

  cluster_role_additional_policies = {
    AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  }
}

# ~ nodes
module "amd64" {
  source                = "../modules/nodegroup/"
  create                = true
  eks_context           = module.eks.context
  name                  = "amd64"
  instance_types        = ["t3a.small"]
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
      volume_size = 2
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
  depends_on = [module.eks]
}

# amd -- Managed
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
  launch_template_tags         = {}
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
  depends_on = [module.eks]
}

# arm -- Managed
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
  desired_size                 = 1
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  depends_on = [module.eks]
}

module "arm64br" {
  source                = "../modules/nodegroup/"
  create                = true
  eks_context           = module.eks.context
  subnet_ids            = data.aws_subnets.eksarapp.ids
  ami_id                = data.aws_ami.arm64br.image_id
  name                  = "arm64br"
  ami_type              = "BOTTLEROCKET_ARM_64"
  instance_types        = ["t4g.small"]
  desired_size          = 2
  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      volume_type = "gp3"
      volume_size = 2
    },
    {
      device_name = "/dev/xvdb"
      volume_type = "gp3"
      volume_size = 100
    },
  ]
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  depends_on = [module.eks]
}

/*
module "amd64br" {
  source                       ="../modules/nodegroup/"
  create                = false
  eks_context                  = module.eks.context
  subnet_ids                   = data.aws_subnets.eksmdapp.ids
  name                         = "mdappbr"
  ami_id                       = data.aws_ami.amd64br.image_id
  ami_type                     = "BOTTLEROCKET_x86_64"
  instance_types               = ["t3a.small"]
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  depends_on = [module.eks]
}

*/
