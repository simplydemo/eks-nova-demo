# eks-nova-demo

EKS 클러스터를 프로비저닝 하는 테라폼 샘플 프로젝트 입니다.

## Pre-requisite
Terraform 프로비저닝을 환경 설정이 필요 합니다.

- 프로비저닝을 위한 VPC 및 EC2를 [provisioner-service](https://github.com/chiwooiac/cloudformation-stacks/blob/main/src/service/provisioner/HELP.md) CloudFormation 스택으로 구성할 수 있습니다. 
- Github Actions 와 OIDC 통합을 위한 [github-actions-role](https://github.com/chiwooiac/cloudformation-stacks/blob/main/src/iam-role/github-actions-role/HELP.md) CloudFormation 스택으로 구성할 수 있습니다. 

CF 스택 진행중 service-linked role 관련 오류가 발생한다면 [delete-service-linked-role.sh](./docs/delete-service-linked-role.sh) 쉘을 실행하세요.


### Using service-linked roles

[service-linked roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/using-service-linked-roles.html)은 서비스 연결 역할은 AWS 서비스에 직접 연결되는 고유한 유형의 IAM 역할입니다.

서비스 연결 역할은 AWS가 사용자를 대신하여 관련서비스의 생성, 변경, 삭제에 관련된 모든 IAM 세트를 포함하고 있습니다. 또한 관련된 다른 AWS 서비스를 호출하는 데 필요한 모든 권한 역시 포함합니다.  
그러므로 사용자는 별도의 IAM 정책이나 역할을 생성할 필요가 없으므로 관리가 필요 없으며 쉽게 사용하게 됩니다.


## Git
```
git clone https://github.com/simplydemo/eks-nova-demo.git
```

## Build

```
sh deploy.sh
```

## Kubeconfig

```
aws eks update-kubeconfig --name "nova-an2d-demo-eks"
```


## Destroy
```
sh destroy.sh
```



### 클러스터 생성

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

### 관리형 노드 추가

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

### EBS 볼륨 마운트 추가

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

#### Pre-Defined group

[system:masters](https://github.com/kubernetes/kubernetes/blob/v1.28.0/cmd/kubeadm/app/constants/constants.go#L173)
