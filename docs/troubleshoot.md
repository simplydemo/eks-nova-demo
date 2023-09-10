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
 