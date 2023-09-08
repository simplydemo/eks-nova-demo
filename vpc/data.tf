data "aws_availability_zones" "this" {
  state = "available"
}


# Subnets
data "aws_subnets" "eksapp" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["${local.name_prefix}-eksapp*"]
  }
}

data "aws_ami" "arm64br" {
  most_recent = true
  owners      = ["630172235254"]

  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-1.27-aarch64-v1.14.3*"]
  }
}

data "aws_ami" "amd64br" {
  most_recent = true
  owners      = ["630172235254"]

  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-1.27-x86_64-v1.14.3*"]
  }
}

data "aws_ami" "amd64" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-1.27-v20230825"]
  }
}

data "aws_ami" "arm64" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-arm64-node-1.27-v20230825"]
  }
}
