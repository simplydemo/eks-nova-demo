# hands-on helm

## aws-load-balancer-controller 플러그인을 설치 합니다.

```
helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=nova-an2d-demo-eks \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller 
```

```
kubectl logs -f deployment.apps/aws-load-balancer-controller -n kube-system

kubectl get deploy -n kube-system

kubectl describe deployment.apps/aws-load-balancer-controller -n kube-system


```

## Ingress

- [nova-demo-ingress-alb](./nova-demo-ingress-alb.yaml)를 보완하여 Ingress 를 구성합니다.

```
kubectl apply -f nova-demo-ingress-alb.yaml

kubectl logs -f deployment.apps/aws-load-balancer-controller -n kube-system
```

# Failed build model due to AccessDenied: User:
arn:aws:sts::779929131770:assumed-role/novaDemoArm64EksNodeRole/i-0aecc4e86ad18f865 is not authorized to 
perform: elasticloadbalancing:DescribeLoadBalancers because no identity-based policy allows the
elasticloadbalancing:DescribeLoadBalancers action

```
helm uninstall aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system 
```