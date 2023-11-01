kubectl get pods                        # 모든 Pod의 목록을 조회합니다.
kubectl describe pod <pod-name>         # 특정 Pod의 자세한 정보를 조회합니다.
kubectl logs <pod-name>                 # Pod의 로그를 조회합니다.
kubectl exec -it <pod-name> -- /bin/sh  # Pod 내부로 들어가 터미널로 작업할 수 있습니다.
kubectl delete pod <pod-name>           # Pod를 삭제합니다.


#
kubectl create pod nginx222 --image=nginx

kubectl create deployment nginx --image=nginx
