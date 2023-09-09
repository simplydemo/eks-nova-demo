data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_vpc" "this" {
  default = false
  filter {
    name   = "tag:Name"
    values = [format("%s-vpc", local.name_prefix)]
  }
}

# Subnets
data "aws_subnets" "eks" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Name"
    values = [format("%s-eks*", local.name_prefix)]
  }
}



#data "aws_eks_cluster_auth" "this" {
#  name = module.eks.cluster_name
#}

# data "aws_ecr_authorization_token" "ecr" {}

# Subnets
data "aws_subnets" "eksmdapp" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = [format("%s-eksmdapp-*", local.name_prefix)]
  }
}

data "aws_subnets" "eksarapp" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = [format("%s-eksarapp-*", local.name_prefix)]
  }
}


# AMI

data "aws_ami" "amd64" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amazon-eks-node-1.27-*"]
  }
  owners      = ["amazon"]
}

data "aws_ami" "arm64" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amazon-eks-arm64-node-1.27-v20230825"]
  }
  owners      = ["amazon"]
}

data "aws_ami" "arm64br" {
  most_recent = true
  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-1.27-aarch64-v1.14.3*"]
  }
  owners      = ["630172235254"]
}

data "aws_ami" "amd64br" {
  most_recent = true
  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-1.27-x86_64-v1.14.3*"]
  }
  owners      = ["630172235254"]
}
