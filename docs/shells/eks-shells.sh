# see - https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands

# kubectl을 설치 하고 자동완성 기능을 활성화합니다.
# see - https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
# ses - https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-autocomplete


source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc


################################################################################
### 클러스터 관리
################################################################################

# EKS 클러스터 액세스를 위한 context를 설정 합니다. (AWS CLI가 설치되어 있어야 하며, IAM 액세스 정책이 구성되어 있어야 합니다.)
aws eks update-kubeconfig --kubeconfig /tmp/eks --name nova-an2d-demo-eks
cat /tmp/eks | base64

aws eks update-kubeconfig --name "nova-an2d-demo-eks"

# kubectl 설정에서 사용 가능한 컨텍스트 목록을 조회합니다.
kubectl config get-contexts

# 연결을 활성화 할 cluster 를 지정합니다.
kubectl config use-context <cluster_name>

# kubernetes context 정보를 조회 합니다. (실제 경로는 "$HOME/.kube/config" 입니다.)
kubectl config view

# 클러스터의 정보와 상태를 확인합니다.
kubectl cluster-info

# 클러스터 내의 노드들의 상태를 확인합니다.
kubectl get nodes

#
# kubectl label nodes "ip-10-76-113-238.ap-northeast-2.compute.internal" -l "kubernetes.io/role=worker"
# kubectl label --overwrite nodes "ip-10-76-113-238.ap-northeast-2.compute.internal" "kubernetes.io/role"-

# 특정 노드의 자세한 정보를 조회합니다.
kubectl describe node <node-name>

# 네임스페이스 목록을 조회합니다.
kubectl get namespaces

# 클러스터 이벤트를 확인합니다.
kubectl get events

################################################################################
### Pod 및 리소스 관리
################################################################################

# nginx 를 구동하는 Yaml 명세를 확인 합니다.
kubectl run nginx-01 --image=nginx:alpine3.18  --port=80 --dry-run client -o yaml

# nginx-01 컨테이너를 실행합니다.
kubectl run nginx-01 --image=nginx:alpine3.18  --port=80

# nginx-01 Pod 가 실행되는 내역을 확인 합니다.
kubectl describe po nginx-01

# Pod의 애플리케이션 처리 로그를 조회합니다.
kubectl logs nginx-01

# 터미널로 Pod 내부로 진입하고 내역을 살펴봅니다.
kubectl exec -it nginx-01 -- /bin/sh

# Pod를 삭제합니다.
kubectl delete po nginx-01

# 삭제되었는지 확인해 봅니다.
kubectl get po


