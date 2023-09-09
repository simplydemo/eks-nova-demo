# eks-nova-demo

EKS 클러스터를 프로비저닝 하는 테라폼 샘플 프로젝트 입니다.

## EKS 클러스터 구성

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


### Taints 설정 

Pod 스케줄링을 컨트롤 하기 위한 Taints 를 설정 합니다. 
```hcl
  taints = [
    {
      key    = "amd64"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  ]
```

- Pod 배치 

kubernetes 스케줄러는 `tolerations` 규칙으로 `amd64` 플랫폼인 노드 에만 애플리케이션을 배포 합니다. 

```
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-amd64
  namespace: default
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: nginx-amd64
  template:
    metadata:
      labels:
        app: nginx-amd64
      namespace: default
    spec:
      containers:
      - name: nginx-amd64
        image: nginx:alpine3.18 
      tolerations:
      - key: amd64
        operator: Equal
        value: "true"
        effect: NoSchedule
EOF
```

- 애플리케이션 배포상태 확인
```
kubectl get po -l "app=nginx-amd64" -o wide --show-labels
```


## Troubleshoot

- 보안 그룹 규칙 미적용으로 node 와 cluster 간의 통신이 단절 되었는지 확인 합니다.
- node 역할을 하기 위한 [EKS 노드 IAM 역할](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/create-node-role.html이 충분한지 확인
  합니다.
- Kubernetes 버전 / 플랫폼 등을 지원하는 적합한 AMI 를 사용했는지 확인 합니다.
- node 가 cluster 에 join 되지 않는다면 kubelet 상태와 로그를 확인 합니다.

```
# kubelet 데몬이 실행중인지 확인합니다.
sudo systemctl status kubelet

# kubelet 로그를 확인합니다.
tail -n 1000 /var/log/messages | grep kubelet
```

-

```
/var/lib/kubelet/kubeconfig
``` 

## Bottlerocket

[bottlerocket](https://www.youtube.com/watch?v=L33l7Yd8oZM) 철학은

# Docker 철학의 큰 부분은 API 추상화 계층이 컨테이너 이미지를 기본 구현에서 분리한다는 것입니다. Bottlerocket은 이 철학의 확장입니다.

### 장점

Bottlerocket은 Ubuntu, Red Hat 또는 기타 표준 Linux 플랫폼보다 더 일관된 호스트 배포 시스템을 제공합니다.
배포된 모든 인스턴스는 마지막 인스턴스와 동일합니다.
또한 사용 중인 버전에 관계없이 장기적으로 안정적인 릴리스를 약속합니다. (3년)

Bottlerocket의 차별화는 필수 설정 및 관리가 부족하다는 것입니다.
운영자는 호스트 OS를 관리하는 데 필요한 여러 업데이트, 패치 및 응용 프로그램 설치를 알고있습니다.
이를 위해 설치 구성된 패키지는 업스트림 문제이든 잘못된 업데이트이든 관계없이 잠재적인 문제 영역을 가지고 있습니다.

Bottlerocket은 소프트웨어를 컨테이너로만 실행하며 패키지 관리자가 없습니다.
AWS에 따르면 이는 관리자가 Bottlerocket 업데이트 및 롤백을 단일 단계로 적용하여 오류 위험을 최소화 한다고 합니다.
업그레이드는 모두 적용되거나 아니면 모두 적용되지 않는 수준으로 이루어집니다.
Bottlerocket은 필요한 경우 유용한 대체 기능인 파티션을 사용합니다.

Bottlerocket 호스트는 일회용으로 설계되었습니다. "실행 중인 업데이트"가 없습니다.
업그레이드는 오케스트레이터가 새 이미지를 다운로드하고 배포하는 이전 버전에서 새 버전으로 전환하는 것입니다.

Bottlerocket은 적절하게 배포, 실행 및 폐기되는 최소 계층입니다. 배포는 IT 팀이 Amazon Elastic Kubernetes Service와 같은 AWS 내의 기존 조정 도구를 사용하여 관리할 수
있도록 설계되었습니다.

또한 훨씬 더 안전한 환경을 조성합니다. Bottlerocket에는 설치된 애플리케이션 수가 적어 리소스를 절약하고 잠재적인 보안 문제를 줄입니다. 관리를 안전하게 수행할 수 있는 잘 정의된 API 세트가 있습니다.

Docker 철학의 큰 부분은 API 추상화 계층이 컨테이너 이미지를 기본 구현에서 분리한다는 것입니다. Bottlerocket은 이 철학의 확장입니다.

Bottlerocket에는 타사 플러그인, 레지스트리, 타사 앱이 없습니다.

전반적으로 Bottlerocket은 유지 관리 측면에서 매우 손이 많이 가지 않도록 설계되어 개발자를 기쁘게 할 것입니다.

Bottlerocket의 각 주요 릴리스는 Amazon에서 최소 3년 동안 지원됩니다.

Bottlerocket이 부족한 곳
Bottlerocket은 무료로 다운로드하여 사용할 수 있지만 모든 기능은 AWS 플랫폼에 맞게 조정되어 있습니다. 이는 도구를 AWS 환경으로 제한하며 변경될지는 불확실합니다.

주변의 모든 도구는 AWS와의 긴밀한 통합을 기반으로 합니다. Bottlerocket 시스템의 기본 코드와 구성은 GitHub 에 있습니다 .

Bottlerocket은 고도로 자동화되고 역동적인 대규모 환경을 위해 설계되었습니다. 소규모 환경에서는 관련 개조 및 테스트로 인해 Bottlerocket에서 많은 이점을 얻을 수 없습니다.

Bottlerocket은 대부분의 지역에서 사용할 수 있지만 전부는 아니며 AWS 정부 환경에서는 사용할 수 없습니다. GPU 지원 기능과 같은 Amazon Machine Image 인스턴스 의 일부 고급 항목은
현재 Bottlerocket과 호환되지 않습니다.

Bottlerocket과 Alpine Linux
Bottlerocket과 Alpine Linux는 모두 물리적 배포 크기와 소비되는 리소스 측면에서 매우 작습니다. 예를 들어 Alpine Linux는 32MB 미만의 RAM에서 설치 및 실행됩니다. 저장된 자원은
더 많은 컨테이너를 생산하는 데 사용될 수 있습니다 .

동시에 Alpine Linux는 매우 단순한 Linux 구현이며 필요할 때 고도로 구성 가능하지만 대부분의 다른 Linux 배포판과 함께 제공되는 서비스 관리의 복잡성은 없습니다. 이는 잘못될 가능성이 적고,
확보해야 할 항목이 적으며, 소비되는 리소스가 적다는 것을 의미합니다. Bottlerocket도 비슷한 원리로 작동합니다.

두 OS의 가장 큰 차이점은 유연성입니다. Alpine Linux는 모든 Linux 기반 컨테이너 환경에서 작동하도록 설계된 반면 Bottlerocket은 AWS에서만 사용하도록 제한됩니다.

```
# admin 모드 활성화 
enable-admin-container

# admin 로그인 
enter-admin-container


# admin 모드 비활성화
disable-admin-container


# configuration 조회 
apiclient -u /settings
```