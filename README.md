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

<br>

## Git

```
git clone https://github.com/simplydemo/eks-nova-demo.git
```

<br>

## Build

```
cd eks-nova-demo

sh deploy.sh
```

<br>

## Kubeconfig

```
aws eks update-kubeconfig --name "nova-an2d-demo-eks"
```

<br>

## Destroy

```
sh destroy.sh
```

<br>

## Appendix

- [examples](./docs/example.md)
- [handson-docker](./docs/handson/docker-handson.md)
- [handson-kubectl](./docs/handson/eks-kubectl-handson.md)