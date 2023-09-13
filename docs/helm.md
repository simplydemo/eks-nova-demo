# Helm 가이드

## repo 등록 
```
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
```

## chart 버전 확인
```
helm search repo aws-ebs-csi-driver/aws-ebs-csi-driver --versions

helm search repo aws-ebs-csi-driver/aws-ebs-csi-driver --versions --version ^2.20
```