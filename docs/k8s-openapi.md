# Kubernetes OpenAPI 

Kubernetes 의 `/openapi/v2` 리소스 URI 는 OpenAPI 를 확인할 수 있습니다. 

## EKS 클러스터 토큰 설정 및 API 스펙 확인 

- `aws eks describe-cluster --name <cluster_name>` 명령을 통해 클라이언트 cacert 값을 조회 할 수 있습니다. 
- `aws eks get-token --cluster-name <cluster_name>` 명령을 통해 클라이언트 Token 값을 조회 할 수 있습니다. 
- `kubectl cluster-info` 명령을 통해 Kubernetes API 서버 URL 을 확인할 수 있습니다. 

- `curl --cacert $CA_CERT -H "$AUTH_TOKEN" -X GET "{API_SERVER_URI}/openapi/v2"`명령을 통해 API 스펙을 확인합니다. 

```
aws eks describe-cluster --name nova-an2d-demo-eks --output=text --query 'cluster.{certificateAuthorityData: certificateAuthority.data}' | base64 -D > mycacert.crt
CA_CERT=${HOME}/mycacert.crt
AUTH_TOKEN="Authorization: Bearer $(aws eks get-token --cluster-name nova-an2d-demo-eks | jq .status.token --raw-output)"

curl --cacert $CA_CERT -H "$AUTH_TOKEN" -X GET "https://2F643B20FFE4ADA306D2D48F11CA25DD.gr7.ap-northeast-2.eks.amazonaws.com/openapi/v2"
# curl -k -H "$AUTH_TOKEN" -X GET "https://2F643B20FFE4ADA306D2D48F11CA25DD.gr7.ap-northeast-2.eks.amazonaws.com/openapi/v2"
```

## Docker 컨테이너를 통한 API 스펙 조회

- Dockerfile 구성 

```
mkdir /tmp/docker

curl --cacert $CA_CERT -H "$AUTH_TOKEN" -X GET "https://2F643B20FFE4ADA306D2D48F11CA25DD.gr7.ap-northeast-2.eks.amazonaws.com/openapi/v2" > /tmp/docker/swagger.json

cat <<'EOF' | > /tmp/docker/Dockerfile
FROM swaggerapi/swagger-ui:latest
COPY swagger.json /tmp/
ENV BASE_URL=/
ENV SWAGGER_JSON=/tmp/swagger.json
EXPOSE 8080
EOF
```

- Docker 컨테이너 이미지 빌드 
```
cd /tmp/docker/
docker build -t k8sapispec:1.0 -f /tmp/docker/Dockerfile .
```

- Docker 컨테이너 실행 
```
docker image ls
 
docker run --rm --name=k8sapispec -p 8080:8080 k8sapispec:1.0
```

[Kubernetes OpenAPI](http://localhost:8080/#/) 조회 

