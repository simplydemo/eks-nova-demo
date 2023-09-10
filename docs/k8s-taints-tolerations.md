# Kubernetes HandsOn

## Taints and Toleration 설정

[Taints](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/taint-and-toleration/) 는 Pod 가 toleration 이 없으면 스케줄링 되지 못하도록 컨트롤 합니다.

```
kubectl taint node <node_name> amd64=true:+NoSchedule
```

- NoExecute : Pod 에서 toleration 조건이 없으면 스케줄링 되지않으며 현재 스케줄링된 Pod는 즉시 destory 됩니다.
- NoSchedule : Pod 에서 toleration 조건이 없으면 스케줄링 되지않으며 현재 스케줄링된 Pod는 toleration 이 없더라도 유지됩니다.
- PreferNoSchedule : Pod 에서 toleration 조건이 없으면 스케줄링되지 않습니다. 하지만 클러스터 자원이 부족하면 toleration 이 없는 Pod 도 스케줄링 될 수 있씁니다.


#### Pod 배치

`amd64` Taints가 걸려있는 Node에 `tolerations` 설정으로 Pod 애플리케이션을 배포 합니다.

- Node에 Taints 설정
```hcl
  taints = [
    {
      key    = "amd64"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  ]
```

- Pod 배포 예시
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

- Pod 애플리케이션 배포상태 확인
```
kubectl get po -l "app=nginx-amd64" -o wide --show-labels
```
 