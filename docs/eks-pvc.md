
```
cat <<'EOF' | kubectl apply -f -
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gp2-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp2
  resources:
    requests:
      storage: 1Gi

---
apiVersion: v1
kind: Pod
metadata:
  name: busybox-app
spec:
  containers:
  - name: busybox-applog
    image: busybox:latest
    command:
    - sh
    - -c
    - while true; do (hostname; date) > /data/out.txt; sleep 10; done
    volumeMounts:
    - name: my-pvc
      mountPath: /data
  volumes:
  - name: my-pvc
    persistentVolumeClaim:
      claimName: gp2-pvc
EOF

```