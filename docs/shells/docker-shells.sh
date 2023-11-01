################################################################################
### Docker Just
################################################################################

# 도커 버전을 확인해 봅니다.
docker version

# 상세한 도커 정보를 확인 합니다.
docker info


################################################################################
### Docker Basic Commands
################################################################################

# 컨테이너 이미지를 확인합니다.
docker image ls

docker image ls -a

# 실행중인 컨테이너를 확인합니다.
docker container ls

# 모든 컨테이너 상태를 확인 합니다.
docker container ls -a

# 볼륨 마운트를 확인합니다.
docker volume ls

# 네트워킹을 확인합니다.
docker network ls

# docker0 네트워크 인터페이스가 있는지 확인합니다.
ip a

ifconfig docker0


################################################################################
### Docker Run
################################################################################

# nginx 를 실행합니다.
docker run -d --name nginx -p "80:80" nginx:alpine3.18

# 미리 이미지를 내려받을 수 있습니다.
# docker pull nginx:alpine3.18

# 로그를 확인합니다.
docker container logs nginx
# docker container logs -f nginx

# 호스트와 매핑된 포트를 확이합니다.
docker container port nginx

# nginx 네트워크를 확인 합니다.
docker container inspect --format='{{json .NetworkSettings.Networks}}' nginx

# NetworkID 를 확인합니다.
docker container inspect --format='{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}' nginx

# nginx 가 bridge 네트워크를 사용하고 있나요?
docker network inspect --format "{{.Id}}" bridge

################################################################################
### Docker Bridge Network
################################################################################

# mynginx 를 mybridge 네트워크로 실행합니다. (80 host 포트는 이미 점유하고 있습니다.)
docker run -d --name mynginx -p "8081:80" --network mybridge nginx:alpine3.18

docker container inspect --format='{{json .NetworkSettings.Networks}}' mynginx

# 브리지 네트워크를 확인할 수 있습니다.
ip a

# 각각의 네트워크에 구동된 nginx IP 주소를 확인합니다.
# bridge
docker container inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx

# mybridge
docker container inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mynginx


# 기본 bridge 네트워크에 network-tools 컨테이너를 올립니다.
docker run --rm --name nettools -it jonlabelle/network-tools

# nettools 컨테이너 내부에서 양쪽의 nginx IP 주소로 ping 과 curl 을 체크합니다.
ping 172.17.0.2
curl -X GET http://172.17.0.2:80

# mynginx 는 액세스 되지 않는걸 확인 할 수 있습니다.
ping 172.18.0.2

# network connect 명령으로 bridge 네트워크와 컨테이너 연결자(vETH)를 추가합니다.
docker network connect mybridge nettools


################################################################################
### Docker Volume Mount
################################################################################
mkdir -p /tmp/nginx

cat <<EOF >/tmp/nginx/index.html
<!DOCTYPE html>
<html lang="en">
<header>
    <title>SymplyDemo</title>
</header>
<style>
    body {
        display: table-cell;
        vertical-align: middle;
        background-color: black;
        text-align: center;
    }

    h1 {
        color: white;
    }
</style>
<body><h1>Hello, World!</h1></body>
</html>

EOF

docker run -d --name nginx-mt -p 8088:80 -v /tmp/nginx:/usr/share/nginx/html:ro nginx:alpine3.18


curl -X get http://localhost:8088

# 볼륨을 생성하고 마운트합니다.
docker volume create simplydemo

# 생성된 볼륨을 확인 합니다.
docker volume ls

# host 파일파티션을 직접 마운트하지 않고, volume 을 마운트 합니다.
docker run -d --name nginx-mt2 -p 8091:80 -v simplydemo:/usr/share/nginx/html:rw nginx:alpine3.18


# 볼륨 경로를 확인 합니다.
docker volume inspect simplydemo

# simplydemo Mountpoint 경로로 이동하여 index.html 파일을 편집후에 확인해 봅시다.
curl -X GET http://localhost:8091

# 볼륨을 삭제 합니다.
docker volume rm simplydemo


################################################################################
### Docker Troubleshooting
################################################################################

# 로그 확인
docker logs nginx

# 터미널로 컨테이너 접속 후 앱 설치내역 및 환경변수 등을 확인
docker exec -it nginx -- /bin/sh

# 만약 컨테이너나 실행되지 못하거나 짧게 실행되는 BatchJob 인경우 제대로 동작하지 않는다면
docker run --name busybox 'busybox:latest'

# sleep을 걸고 터미널에 접속하여 확인합니다.
docker run --rm --name busybox-bad 'busybox:latest' sleep 3600


# nginx로 시작하는 이름의 container를 모두 중지/삭제 합니다.
docker container ls --filter NAME=nginx -a | sed '1 d' | awk '{print $1}' | xargs -I {} docker stop {}
docker container ls --filter NAME=nginx -a | sed '1 d' | awk '{print $1}' | xargs -I {} docker rm {}

# 사용된 자원을 모두 제거합니다.
docker container prune
docker image prune
docker volume prune


################################################################################
### Docker Compose
################################################################################
sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose version
