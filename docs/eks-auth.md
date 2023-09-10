# auth

EKS 클러스터에 대한 IAM 액세스 주체를 활성화 합니다.

## [Enabling IAM principal access to EKS](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html)

```hcl
module "auth" {
  source = "git::https://github.com/chiwooiac/tfmodule-aws-eks.git//modules/aws-auth"

  aws_auth_roles = [
    {
      rolearn  = module.eks.admin_role_arn
      username = "admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = module.eks.admin_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/alice.manager@symplesims.io"
      username = "alice"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_accounts = [
    "777777777777",
    "888888888888",
  ]
  
  depends_on = [module.eks]
}
```


### aws_auth_roles

EKS 클러스터를 액세스 할 수 있는 AWS IAM role을 매핑 합니다.

### aws_auth_users

EKS 클러스터를 액세스 할 수 있는 AWS IAM user을 매핑 합니다.

### aws_auth_accounts

EKS 클러스터를 액세스 할 수 있는 AWS 계정을 매핑 합니다.   



## 인증된 IAM 액세스 주체 확인을 위한 ConfigMap 조회

```
kubectl describe -n kube-system configmap/aws-auth
```