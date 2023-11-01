# Examples

## 클러스터 생성

- EKS Control Plane 를 구성 합니다.

```
module "eks" {
  source       = "git::https://github.com/chiwooiac/tfmodule-aws-eks.git"
  context      = module.ctx.context
  cluster_name = <cluster_name>
  vpc_id       = <vpc_id>
  subnet_ids   = <subnet_ids>
  cluster_role_additional_policies = {
    AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
}
```

## 관리형 노드 추가

- AmazonLinux2 OS 의 x86_64 플랫폼을 위한 워커 노드를 추가 합니다.

```
module "amd64" {
  source                = "git::https://github.com/chiwooiac/tfmodule-aws-eks.git//modules/node_group?ref=feature/LT101"
  eks_context           = module.eks.context
  subnet_ids            = data.aws_subnets.eksmdapp.ids
  name                  = "amd64"
  ami_type              = "AL2_x86_64"
  instance_types        = ["t3a.medium"]
}
```

- AmazonLinux2 OS 의 ARM 플랫폼을 위한 워커 노드를 추가 합니다.

```
module "arm64" {
  source                = "git::https://github.com/chiwooiac/tfmodule-aws-eks.git//modules/node_group?ref=feature/LT101"
  eks_context           = module.eks.context
  subnet_ids            = data.aws_subnets.eksmdapp.ids
  name                  = "arm64"
  ami_type              = "AL2_ARM_64"
  instance_types        = ["t4g.medium"]
}
```

## EBS 볼륨 마운트 추가

EBS 볼륨 크기 및 추가 볼륨을 마운트 합니다.

```hcl
block_device_mappings = [
  {
    device_name           = "/dev/xvda" 
    volume_type           = "gp3"
    volume_size           = 100
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = "<kms_key_id>"
    iops                  = 3000
    throughput            = 125
  },
  {
    device_name           = "/dev/xvdb"
    volume_type           = "gp3"
    volume_size           = 100
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = "<kms_key_id>"
    iops                  = 3000
    throughput            = 125
  },  
]
```

## Pre-Defined kubernetes group

[system:masters](https://github.com/kubernetes/kubernetes/blob/v1.28.0/cmd/kubeadm/app/constants/constants.go#L173)
