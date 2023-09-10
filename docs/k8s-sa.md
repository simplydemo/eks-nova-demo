# Service Account 
Service Account는 Pod 와 같은 애플리케이션의 인증(Authentication) 및 권한(Authorization) 관리를 담당하는 객체입니다. 

쿠버네티스 클러스터 내에서 실행되는 애플리케이션은 기본적으로 API 서버와 상호 작용해야 하는데, 이 때 서비스 어카운트를 사용해 API에 접근 권한을 부여받습니다.

## Service Account 활용

- 권한 제어: Service Account를 사용하여 Pod에게 필요한 권한만 부여 하여 최소 권한 원칙을 준수하도록 보안을 강화할 수 있습니다.

- 인증: Pod는 Kubernetes API 사용을 위해 Service Account 토큰을 통해 API 서버로 인증할 수 있습니다. Pod는 인증을 통해 클러스터 내의 객체를 액세스할 수 있습니다.

- Secret 및 ConfigMap 액세스: Service Account를 통해 Pod는 Kubernetes Secret 및 ConfigMap에 대해 액세스 할 수 있습니다.

- Monitoring 및 Logging: Pod는 클러스터 모니터링 및 로깅 도구와 통합하여 로그 및 메트릭 데이터를 수집하고 보낼 수 있습니다.

- 외부 서비스와 통합: Service Account를 사용하여 Pod가 클러스터 외부의 다른 서비스, 데이터베이스 또는 API와 통합할 수 있습니다. 

- CI/CD 파이프라인: CI/CD 파이프라인에서 빌드 및 배포 작업을 실행하는 동안 Service Account를 사용하여 권한이 있는 리소스를 조작하거나 배포하도록 설정할 수 있습니다.

- 데이터베이스 액세스: Pod에서 데이터베이스와 같은 백엔드 서비스에 연결할 때 Service Account를 사용하여 인증 및 권한을 관리할 수 있습니다.

- 애플리케이션 서비스 디스커버리: Service Account 및 Kubernetes의 DNS 기능을 사용하여 서비스 디스커버리를 구현하고 클러스터 내의 다른 서비스와 통신할 수 있습니다.


## Service Account 생성 및 활용 


### Secrets 보안 문자열을 생성하고 인증된 Pod 만 액세스하는 시나리오

```yaml
# secret 생성 
---
apiVersion: v1
kind: Secret
metadata:
  name: myhello-secret
  namespace: default
type: Opaque
data:
  username: "YWxpY2U="
  password: "YWxpY2UxMjM0JA=="

# service-account 생성 
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: myhello-sa

# role 생성 
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: myhello-role
  namespace: default
rules:
  - apiGroups: [ "" ]
    resources: [ "secrets" ]
    verbs:
      - get
      - list

# role 바인딩 role - service-account
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: myhello-role-binding
  namespace: default
subjects:
  - kind: ServiceAccount
    name: myhello-sa
roleRef:
  kind: Role
  name: myhello-role
  apiGroup: rbac.authorization.k8s.io

---
apiVersion: v1
kind: Pod
metadata:
  name: myhello-busybox-po
  namespace: default
spec:
  serviceAccountName: myhello-sa
  containers:
    - name: myhello-busybox
      image: busybox:1.36
      args: [ "tail", "-f", "/dev/null" ]
      env:
        - name: HELLO_SECRETS_PASSWORD
          valueFrom:
            secretKeyRef:
              name: myhello-secret
              key: password

```
 
- 터미널을 통해 컨테이너 내부로 접속하여 `HELLO_SECRETS_PASSWORD` 환경 변수를 확인해 봅니다.
```
kubectl exec -it pod/myhello-busybox-po -- /bin/sh

# 터미널 내부에서 실행 
echo $HELLO_SECRETS_PASSWORD
```

#### ServiceAccount 토큰을 통한 Kubernetes 객체 액세스  

컨테이너 내부에서 TOKEN 값을 설정 하여 API 서버에 호출 하여 Kubernetes 객체를 액세스할 수 있습ㄴ다.

- ServiceAccount 토큰은 `/var/run/secrets/kubernetes.io/serviceaccount` 경로에 있습니다.

- 클러스터 API 서버 주소는 `kubectl cluster-info` 명령어로 `Kubernetes control plane` 주소를 확인할 수 있습니다. 

 
```
kubectl exec -it pod/myhello-busybox-po -- /bin/sh

# 컨테이너 내부에 curl 패키지 설치 - https://github.com/moparisthebest/static-curl/releases/tag/v8.2.1
wget -O /usr/bin/curl https://github.com/moparisthebest/static-curl/releases/download/v8.2.1/curl-aarch64
chmod +x /usr/bin/curl

# serviceaccount 경로 이동 
cd /var/run/secrets/kubernetes.io/serviceaccount

# CA_CERT 및 AUTH_TOKEN 환경변수 설정 및 확인  
CA_CERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
AUTH_TOKEN="Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"

echo $AUTH_TOKEN

# API 스팩 확인 
curl --cacert $CA_CERT -H "$AUTH_TOKEN" -X GET "https://kubernetes.default.svc.cluster.local/api/v1"

# Pods 확인 - RBAC 에 권한이 없습니다.  
curl --cacert $CA_CERT -H "$AUTH_TOKEN" -X GET "https://kubernetes.default.svc.cluster.local/api/v1/namespaces/default/pods"

# Secrets 확인 - RBAC 에 권한이 있습니다. 
curl --cacert $CA_CERT -H "$AUTH_TOKEN" -X GET "https://kubernetes.default.svc.cluster.local/api/v1/namespaces/default/secrets/myhello-secret"
```

- `kubernetes.default.svc.cluster.local` 내부 CoreDNS 는 Kubernetes control plane URI 로 호출할 수 있습니다.
`kubectl cluster-info` 명령어를 통해 API 서버 URL 을 확인할 수 있습니다. 

```
kubectl cluster-info
Kubernetes control plane is running at https://7BEA1182AF97E47A0F13869FF850B40F.gr7.ap-northeast-2.eks.amazonaws.com
CoreDNS is running at https://7BEA1182AF97E47A0F13869FF850B40F.gr7.ap-northeast-2.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

