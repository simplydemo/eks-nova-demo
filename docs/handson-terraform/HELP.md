# handson-terraform

하루 사이에 `aws-ebs-csi-driver` 드라이버 버전이 새로 출시되었다.

`terraform plan` 을 실행하니 결과가 다음과 같습니다. 


```
  # module.ebsCsi[0].aws_eks_addon.addon[0] will be updated in-place
  ~ resource "aws_eks_addon" "addon" {
      ~ addon_version               = "v1.24.0-eksbuild.1" -> "v1.24.1-eksbuild.1"
        id                          = "nova-an2d-demo-eks:aws-ebs-csi-driver"
        tags                        = {
            "Environment" = "Development"
            "Owner"       = "owener@symplesims.github.io"
            "Project"     = "nova"
            "Team"        = "DevOps"
        }
        # (10 unchanged attributes hidden)
    }
```

`terraform apply` 를 주저 없이 실행 하였습니다.

```
Type    Reason     Age    From               Message
----    ------     ----   ----               -------
Normal  Scheduled  3m8s   default-scheduler  Successfully assigned kube-system/ebs-csi-controller-5b44fd749-dtlkx to ip-10-76-110-214.ap-northeast-2.compute.internal
Normal  Pulling    3m7s   kubelet            Pulling image "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/eks/aws-ebs-csi-driver:v1.24.1"
Normal  Pulled     3m5s   kubelet            Successfully pulled image "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/eks/aws-ebs-csi-driver:v1.24.1" in 1.576s (1.576s including waiting)
Normal  Created    3m5s   kubelet            Created container ebs-plugin
Normal  Started    3m5s   kubelet            Started container ebs-plugin
```