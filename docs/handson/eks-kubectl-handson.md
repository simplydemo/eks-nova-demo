# kubectl

## Deployment 컨트롤러

### nginx pod 를 원하는 갯수만큼 배포합니다.

```
kubectl create deployment nginx-deploy --image=nginx:stable --namespace=default --port=80 --replicas=4 --dry-run=client -o yaml > nginx-deploy.yaml

kubectl create deployment nginx-deploy --image=nginx:stable --namespace=default --port=80 --replicas=4

kubectl delete deployment nginx-deploy -n default
```

### nginx pod를 지정된 node 에만 배포합니다.

```
cat <<EOF > nginx-deploy-to-arm64.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deploy-arm
  name: nginx-deploy-arm
  namespace: default
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx-deploy-arm
  template:
    metadata:
      labels:
        app: nginx-deploy-arm
    spec:
      nodeSelector:
        "kubernetes.io/arch": arm64
      containers:
      - image: nginx:stable
        name: nginx
        ports:
        - containerPort: 80

EOF

kubectl apply -f nginx-deploy-to-arm64.yaml

kubectl delete -f nginx-deploy-to-arm64.yaml
```

### nginx pod의 가용 리소스를 제한합니다.

```
cat <<EOF > nginx-deploy-limit.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deploy-limit
  name: nginx-deploy-limit
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-deploy-limit
  template:
    metadata:
      labels:
        app: nginx-deploy-limit
    spec:
      containers:
      - image: nginx:stable
        name: nginx
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 64m
            memory: 128Mi
          requests:
            cpu: 64m
            memory: 128Mi
        env:
          - name: PROFILE
            value: dev

EOF

kubectl apply -f nginx-deploy-limit.yaml

kubectl delete -f nginx-deploy-limit.yaml
```

### deploy 스케일을 조정 합니다.

```
kubectl scale deployment nginx-deploy-limit --replicas=4
```

