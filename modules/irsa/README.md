# IRSA (IAM roles for Kubernetes Service Accounts)

IAM 역할과 Kubernetes Service Account 를 OIDC 를 통해 서로 연결 합니다.

Kubernetes Pod 는 Service Account -> OIDC -> Assume Role 을 통해 AWS 서비스를 액세스할 수 있습니다.

IAM 은 Federated 신뢰 관계인 EKS_OIDC_PROVIDER_ID OIDC 를 통해 audience 와 subject 를 서로 연결해 줍니다.

- aud (Audience):
aud 클레임은 ID 토큰 또는 액세스 토큰이 누가 발급 했는지 그 대상(Audience)을 식별합니다.
보통 aud 클레임에는 토큰의 수신자 또는 사용자 대상 서비스의 식별자가 포함됩니다.
aud 클레임을 통해 애플리케이션은 자신을 위한 토큰인지 확인할 수 있으며 다른 애플리케이션으로 전달되었는지 확인할 수 있습니다.

- sub (Subject):

sub 클레임은 인증된 클라이언트를 식별하는 값을 포함합니다.
이 값을 통해 클라이언트 애플리케이션은 인증된 사용자를 식별하고 해당 사용자에 대한 정보를 관리할 수 있습니다.
다른 클레임과 함께 sub를 사용하여 인증된 사용자의 프로필 정보를 조회하거나 액세스 권한을 부여 할 수 있습니다.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::1111222233334444:oidc-provider/oidc.eks.ap-northeast-2.amazonaws.com/id/<EKS_OIDC_PROVIDER_ID>"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "oidc.eks.ap-northeast-2.amazonaws.com/id/<EKS_OIDC_PROVIDER_ID>:aud": "sts.amazonaws.com",
                    "oidc.eks.ap-northeast-2.amazonaws.com/id/<EKS_OIDC_PROVIDER_ID>:sub": "system:serviceaccount:prometheus:prometheus-sa"
                }
            }
        }
    ]
}

```