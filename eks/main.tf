module "ctx" {
  source = "../context/"
}

locals {
  project        = module.ctx.project
  name_prefix    = module.ctx.name_prefix
  tags           = module.ctx.tags
  cluster_name   = "demo"
  vpc_id         = data.aws_vpc.this.id
  eks_subnet_ids = data.aws_subnets.eks.ids
}

module "eks" {
  source       = "git::https://github.com/chiwooiac/tfmodule-aws-eks.git"
  context      = module.ctx.context
  cluster_name = local.cluster_name
  vpc_id       = local.vpc_id
  subnet_ids   = local.eks_subnet_ids

  cluster_role_additional_policies = {
    AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  }

  depends_on = [
  ]
}

# ~ managed nodes
module "amd64" {
  source                = "git::https://github.com/chiwooiac/tfmodule-aws-eks.git//modules/node_group?ref=feature/LT101"
  eks_context           = module.eks.context
  subnet_ids            = data.aws_subnets.eksmdapp.ids
  name                  = "amd64"
  ami_id                = data.aws_ami.amd64.image_id
  ami_type              = "AL2_x86_64"
  instance_types        = ["t3a.medium"]
  block_device_mappings = [
    {
      volume_size = 100
    }
  ]
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  taints = [
    {
      key    = "amd64"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  ]
  depends_on = [module.eks]
}

module "arm64" {
  source                       = "git::https://github.com/chiwooiac/tfmodule-aws-eks.git//modules/node_group?ref=feature/LT101"
  eks_context                  = module.eks.context
  subnet_ids                   = data.aws_subnets.eksmdapp.ids
  name                         = "arm64"
  ami_id                       = data.aws_ami.arm64.image_id
  ami_type                     = "AL2_ARM_64"
  instance_types               = ["t4g.medium"]
  desired_size                 = 2
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    CustomPolicy                 = aws_iam_policy.custom.arn
  }
  taints = [
    {
      key    = "arm64"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  ]
  depends_on = [module.eks]
}

/*
module "arm64br" {
  source                = "git::https://github.com/chiwooiac/tfmodule-aws-eks.git//modules/node_group?ref=feature/LT101"
  eks_context           = module.eks.context
  subnet_ids            = data.aws_subnets.eksarapp.ids
  ami_id                = data.aws_ami.arm64br.image_id
  name                  = "arm64br"
  ami_type              = "BOTTLEROCKET_ARM_64"
  instance_types        = ["t4g.medium"]
  desired_size          = 2
  block_device_mappings = [
    {
      volume_size = 100
    }
  ]
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  depends_on = [module.eks]
}


module "amd64br" {
  source                       = "git::https://github.com/chiwooiac/tfmodule-aws-eks.git//modules/node_group"
  eks_context                  = module.eks.context
  subnet_ids                   = data.aws_subnets.eksmdapp.ids
  name                         = "mdappbr"
  ami_id                       = data.aws_ami.amd64br.image_id
  ami_type                     = "BOTTLEROCKET_x86_64"
  instance_types               = ["t3a.medium"]
  iam_role_additional_policies = {
    AmazonSsmManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  depends_on = [module.eks]
}

**/