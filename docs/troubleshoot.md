# Troubleshoot

## Node 가 EKS Cluster 에 join 되지 않는 경우 
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

- kubeconfig 설정 정보를 살펴 봅니다.
```
/var/lib/kubelet/kubeconfig
``` 


## EKS 에서 CNI 플러그인 또는 kubelet 관련 오류가 발생한다면?

```
kubelet            Failed to create pod sandbox: rpc error: code = Unknown desc = failed to setup network for sandbox "705fa46ebdbafae7d22bd261e3fc1a1274ef4a16154445def21f00f663eb1d42": 
plugin type="aws-cni" name="aws-cni" failed (add): add cmd: failed to assign an IP address to container
```

- 각 노드의 `aws-node`가 Running 상태인지 체크
```
kubectl get pods -n kube-system -l k8s-app=aws-node -o wide
```

- 각 노드의 `kube-proxy`가 Running 상태인지 체크 

```
kubectl get pods -n kube-system -l k8s-app=kube-proxy -o wide
```


- 노드가 배치될 모든 서브넷의 할당 가능한 IP 갯수를 체크
```
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-05b9af020332f808d" | jq '.Subnets[] | .SubnetId + "=" + "\(.AvailableIpAddressCount)"'
```

- 노드의 ENI에 할당 가능한 최대 보안그룹을 초과했는지 체크 (기본 5개)
```
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-05b9af020332f808d" | jq '.Subnets[] | .SubnetId + "=" + "\(.AvailableIpAddressCount)"'
```



## EKS 인스턴스 타입을 지원하지 않는 가용영역이 있습니다.

`t3a.small` 타입의 경우 `ap-northeast-2b` 에서 지원되지 않습니다.

