# tfmodule-aws-eks

tfmodule-aws-eks is terraform module which creates AWS EKS (Kubernetes) resources

## Git

```
git clone https://github.com/chiwooiac/tfmodule-aws-eks.git

cd tfmodule-aws-eks
```

## Build

```
cd example/simple
terraform init
terraform plan
terraform apply
```

## Usage

```

```

## Resources

EKS 모듈을 통해 프로비저닝 되는 주요 리소스는 다음과 같습니다.

### EKS Cluster (Kubernetes Control Plane)

- Amazon EKS Control Plane 은 etcd 및 Kubernetes API 서버와 같은 Kubernetes 소프트웨어를 실행하는 Control Plane 노드로 구성됩니다.
- Control Plane은 AWS에서 관리하는 계정에서 실행되며 Kubernetes API는 클러스터와 연결된 Amazon EKS 엔드포인트를 통해 노출됩니다.
- 각 Amazon EKS 클러스터 제어 플레인은 단일 테넌트이고 고유하며 자체 Amazon EC2 인스턴스 세트에서 실행됩니다.

#### VPC Configuration

- EKS Control Plane 및 Worker Node 가 배치되는 VPC 와 서브넷을 정의 합니다.
- EKS 클러스터를 위한 보안 그룹을 구성 합니다. 워커 노드가 Control Plane 과 통신 하는 cluster API 서버에 대한 인바운드 트래픽을 허용합니다.
- EKS 클러스터 액세스를 위한 프라이빗 API 와 퍼블릭 API 엔드포인트를 선택적으로 활성화 합니다.
- EKS 클러스터를 위한 퍼블릭 CIDR 네트워크 대역을 설정 합니다.

#### Security Group Configuration

- EKS 클러스터를 위한 보안 그룹이 구성 됩니다.
- 워커 노드가 Control Plane 과 통신 하는 cluster API 서버에 대한 인바운드 트래픽을 허용합니다.

#### Kubernetes 네트워크 Configuration

- EKS 클러스터 내부의 Kubernetes 네트워크를 구성 합니다.
- EKS 클러스터의 ipv4 또는 ipv6 에 대한 Kubernetes 네트워크를 구성하고 관련된 네트워크 CIDR 블럭을 설정합니다.

#### Encryption Configuration

- EKS 클러스터에서 데이터 암호화에 사용할 KMS 키를 설정합니다. 다음과 같이 Kubernetes secrets 암호화에 적용됩니다.

```shell
kubectl get secrets user-pass-secret -o yaml
``` 

#### CloudWatch 로그 그룹 Configuration

- "/aws/eks/{cluster_name}/cluster" 경로 이름으로 로그 그룹이 생성됩니다.
- `enabled_cluster_log_types` 속성에 의해 적재할 로그 유형을 컬렉션 세트로 설정 합니다. 
  합니다. ["api", "audit", "authenticator", "controllerManager", "scheduler"]
- [Amazon EKS Control Plane Logging](https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) 을 참조하세요.


#### IRSA (IAM Roles for Service Accounts) Configuration 
- IRSA 는 Amazon EKS 에서 Kubernetes Pods 및 컨테이너가 AWS Identity and Access Management (IAM) 역할을 할당하는 메커니즘을 제공합니다. 
- ServiceAccount 는 IAM 역할을 바인딩 할 수 있으며, EKS Pods 는 ServiceAccount 를 통해 IAM 역할을 할당 받습니다.

#### OIDC provider Configuration
- EKS 클러스터 내에서 OIDC 인증 및 권한 부여를 수행할 수 있도록 OIDC provider 를 추가 합니다.
- 아래와 같이 `sts.amazonaws.com` 를 OIDC provider 로 추가하면 AWS Security Token Service (STS)가 클러스터 내에서 OIDC 인증 및 권한 부여를 수행할 수 있게 됩니다.
```hcl
  cluster_identity_providers = {
    sts = {
      client_id = "sts.amazonaws.com"
    }
  }
```

#### Kubernetes ConfigMap for AWS Auth
- IAM 사용자 및 역할이 Namespace, Node, Ingress, Service, Pod, ConfigMap, PVC 등 주요 EKS 클러스터의 리소스를 액세스할 수 있도록 Kubernetes RBAC 에 매핑 합니다.
```yaml
mapAccounts: | 
  - "123456789012"
mapRoles: |
  - rolearn: arn:aws:iam::123456789012:role/eksctl-eks-cluster-nodegroup-ng-NodeInstanceRole-1TJ5ZGIRLZJX
    username: system:node:{{EC2PrivateDNSName}}
    groups:
      - system:bootstrappers
      - system:nodes
mapUsers: |
  - userarn: arn:aws:iam::123456789012:user/symplesims@github.io
    username: symplesims
    groups:
      - system:masters
```

## EKS Architecture

## Input Variables

### Input Variables for Cluster

<table>
<thead>
    <tr>
        <th>Name</th>
        <th>Description</th>
        <th>Type</th>
        <th>Example</th>
        <th>Required</th>
    </tr>
</thead>
<tbody>
    <tr>
        <td>cluster_name</td>
        <td>EKS 클러스터 이름을 정의 합니다. fullname 은 리소스 이름 규칙에 의해 완성 됩니다.</td>
        <td>string</td>
        <td>symple</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>cluster_version</td>
        <td>Kubernetes 클러스터 버전을 정의 합니다. 형식은  `<major>.<minor>` 입니다. </td>
        <td>string</td>
        <td>1.24</td>
        <td>no</td>
    </tr>
    <tr>
        <td>enabled_cluster_log_types</td>
        <td>control plane 에 대한 로그를 활성화 합니다. 가능한 옵션은 [api, audit, authenticator, controllerManager, scheduler] 입니다. <a href="Amazon EKS Control Plane Logging">https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html</a></td>
        <td>list(string)</td>
        <td>["audit", "api", "authenticator"]</td>
        <td>no</td>
    </tr>
    <tr>
        <td>endpoint_private_access</td>
        <td>EKS public API 서버용 앤드포인트 활성화 여부 입니다.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
    </tr>
    <tr>
        <td>endpoint_private_access</td>
        <td>EKS private API 서버용 앤드포인트 활성화 여부 입니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
    <tr>
        <td>public_access_cidrs</td>
        <td>CIDR 블록 목록. 활성화된 경우 어떤 CIDR 블록이 Amazon EKS 퍼블릭 API 서버 엔드포인트에 액세스할 수 있는지 나타냅니다. 기본값은 ["0.0.0.0/0"]입니다.</td>
        <td>list(string)</td>
        <td>["0.0.0.0/0"]</td>
        <td>no</td>
    </tr>
    <tr>
        <td>vpc_id</td>
        <td>EKS 클러스터가 프로비저닝 될 VPC_ID 를 정의 합니다. EKS 보안 그룹 생성에 참조 됩니다.</td>
        <td>string</td>
        <td>vpc13134</td>
        <td>no</td>
    </tr>
    <tr>
        <td>subnet_ids</td>
        <td>EKS Worker Node 및 Node Group 이 배치될 서브넷 ID 목록입니다.</td>
        <td>list(string)</td>
        <td><pre>
subnet_ids = [
  "subnet-0fff4a0268",
  "subnet-0acff0220a",
  "subnet-0a4c69b068",
  "subnet-0cee22bec2",
]
</pre></td>
        <td>no</td>
    </tr>
    <tr>
        <td>security_group_ids</td>
        <td>Worker Node 와 Kubernetes Control Plane 간의 통신을 허용하기 위해 사용자가 정의한 보안 그룹 ID 를 list 컬렉션으로 설정할 수 있습니다.</td>
        <td>list(string)</td>
        <td>["sg-197141sfd", "sg-sf98fc"]</td>
        <td>no</td>
    </tr>
    <tr>
        <td>ip_family</td>
        <td>Kubernetes 네트워크 설정에서 IP 타입을 정의 합니다. 유효한 값은 ipv4, ipv6 입니다.</td>
        <td>string</td>
        <td>ipv4</td>
        <td>no</td>
    </tr>
    <tr>
        <td>service_ipv4_cidr</td>
        <td>Kubernetes 네트워크 설정에 적용될 IPv4 형식의 CIDR 블럭 입니다. 값이 정의되지 않으면 10.100.0.0/16 또는 172.20.0.0/16 CIDR 블럭을 사용합니다. VPC 네트워크 대역과 겹치지 않게 주의하세요</td>
        <td>string</td>
        <td>172.20.0.0/16</td>
        <td>no</td>
    </tr>
    <tr>
        <td>service_ipv4_cidr</td>
        <td>클러스터가 생성될 때 `ipv6`이 지정된 경우 Kubernetes 포드 및 서비스 IP 주소를 할당하기 위한 CIDR 블록입니다. 클러스터를 생성할 때 사용자 지정 IPv6 CIDR 블록을 지정할 수 없기 때문에 Kubernetes는 고유한 로컬 주소 범위(fc00::/7)에서 서비스 주소를 할당합니다.</td>
        <td>string</td>
        <td></td>
        <td>no</td>
    </tr>
    <tr>
        <td>outpost_config</td>
        <td>AWS Outpost 를 위한 kubernetes 로컬 클러스터를 프로비저닝하기 위한 설정을 정의합니다.</td>
        <td>any</td>
        <td><pre>
outpost_config = {
  control_plane_instance_type = "m5.large"
  outpost_arns                = ["arn:aws:outposts:ap-northeast-2:123456789012:outpost/op-12345678901234567"]
}
</pre>
</td>
        <td>no</td>
    </tr>
    <tr>
        <td>kms_key_arn</td>
        <td>EKS 클러스터의 암호화를 위해 사용되는 KMS 키의 ARN 을 설정 합니다. CMK는 클러스터와 동일한 리전에서 생성된 대칭이어야 하며, CMK가 다른 계정에서 생성된 경우 사용자에게 CMK에 대한 액세스 권한이 있어야 합니다</td>
        <td>string</td>
        <td></td>
        <td>no</td>
    </tr>
    <tr>
        <td>cluster_timeouts</td>
        <td>EKS 클러스터의 생성, 수정, 삭제에 소요되는 timeout 시간을 설정 합니다.</td>
        <td>map(string)</td>
        <td><pre>
cluster_timeouts = {
  create = "60m"
  update = "60m"
  delete = "60m"
}
</pre></td>
        <td>no</td>
    </tr>
    <tr>
        <td>cluster_tags</td>
        <td>EKS 클러스터를 위한 추가적인 태그 속성을 정의 합니다.</td>
        <td>map(string)</td>
        <td><pre>
cluster_tags = {
  Team = "DevOps"
}
</pre></td>
        <td>no</td>
    </tr>
    <tr>
        <td>create_cloudwatch_log_group</td>
        <td>EKS 클러스터의 cloudwatch 로그 그룹 생성 여부를 설정 합니다.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
    </tr>
    <tr>
        <td>cloudwatch_log_group_retention_in_days</td>
        <td>EKS 클러스터의 cloudwatch 로그 그룹에 적재된 로그의 보관 주기를 설정 합니다.</td>
        <td>number</td>
        <td>90</td>
        <td>no</td>
    </tr>
    <tr>
        <td>cloudwatch_log_group_kms_key_id</td>
        <td>KMS 키 ARN 이 설정된 경우 이 키는 해당 로그 그룹을 암호화하는 데 사용됩니다. KMS 키에 적절한 키 정책이 있는지 확인하십시오</td>
        <td>string</td>
        <td></td>
        <td>no</td>
    </tr>
    <tr>
        <td>enable_irsa</td>
        <td>IRSA를 활성화하기 위해 EKS용 OpenID Connect 공급자를 생성할지 여부를 결정합니다.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
    </tr>
    <tr>
        <td>openid_connect_audiences</td>
        <td>IRSA 공급자에 추가할 OpenID Connect 대상 클라이언트 ID 를 설정 합니다.</td>
        <td>list(string)</td>
        <td></td>
        <td>no</td>
    </tr>
    <tr>
        <td>custom_oidc_thumbprints</td>
        <td>OIDC(OpenID Connect) ID 공급자의 서버 인증서에 대한 추가 서버 인증서 지문을 설정합니다.</td>
        <td>list(string)</td>
        <td></td>
        <td>no</td>
    </tr>
    <tr>
        <td>cluster_identity_providers</td>
        <td>클러스터에 대해 활성화할 클러스터 OIDC provider 구성을 위한 컬렉션 세트입니다.</td>
        <td>any</td>
        <td><pre>
cluster_identity_providers = {
  sts = {
    client_id = "sts.amazonaws.com"
  }

  keycloak = {
    client_id                     = "<keycloak_client_id>"
    identity_provider_config_name = "Keycloak"
    issuer_url                    = "https://<keycloak_url>/auth/realms/<realm_name>"
    groups_claim                  = "groups"
  }
}
</pre></td>
        <td>no</td>
    </tr>
</tbody>
</table>


### Input Variables for Worker Nodes

<table>
<thead>
    <tr>
        <th>Name</th>
        <th>Description</th>
        <th>Type</th>
        <th>Example</th>
        <th>Required</th>
    </tr>
</thead>
<tbody>
    <tr>
        <td>enabled_node_security_group_rules</td>
        <td>생성된 노드 보안 그룹에 대해 권장 하는 보안 그룹 규칙을 활성화할지 여부를 결정합니다. 여기에는 임시 포트의 노드 간 TCP 수신이 포함되며 모든 Outbound 송신 트래픽을 허용합니다.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
    </tr>
</tbody>
</table>

## Output Values



## Hands-on

### EKS Cluster 컨텍스트 설정

```
aws eks update-kubeconfig --name <eks_cluster_name> --region <aws_region_name>
```

### Kubectl 명령어를 통한 EKS Cluster 정보 확인

- 워커노드 확인 
```
kubectl get nodes -o wide
```

- Pods 확인 
```
kubectl get po -a -o wide
```

