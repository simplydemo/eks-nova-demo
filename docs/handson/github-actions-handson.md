# Github Actions

[Github Actions 가이드](https://docs.github.com/ko/actions) 문서를 참조합니다.

## Workflow 파일

- Github Actions 에서 CICD 워크플로우의 실행은 `ProjectHome/.github/workflows/` 디렉토리 하위의 Yaml 파일에 의해 실행 됩니다.


## 워크플로우 트리거

[워크플로우 트리거](https://docs.github.com/ko/actions/using-workflows/triggering-a-workflow) 방식에 의해 자동 또는 수동을 정의할 수 있습니다.

- `on: push`으로 정의하면 브랜치에 변경 내역이 push 되면 자동으로 트리거 됩니다.

```yaml
name: deploy symple application by automatically
on: push
```

- 브랜치를 지정할 수 있습니다.
```yaml
name: deploy symple application by automatically
on:
  push:
    branches:
      - main
      - develop 
```


### 수동으로 워크플로우 실행

[수동으로 워크플로우 실행](https://docs.github.com/ko/actions/using-workflows/manually-running-a-workflow)은 `on: workflow_dispatch`으로 정의합니다.

```yaml
name: deploy symple application by manually
on:
  workflow_dispatch
```

## 사용자 입력 파라미터 설정

Workflow를 위한 입력파라미터를 설정할 수 있습니다.

```yaml
name: deploy symple application by manually with input parameters
on:
  workflow_dispatch:
    inputs:
      profile:
        description: input profile for build and runtime
        type: string
        default: "dev"
        required: true
      app-version:
        description: input application version
        type: integer
        default: 1
        required: true
      cpu-architecture:
        description: select cpu architecture which is ARM64 or AMD64
        type: choice
        default: "AMD64"
        options:
          - "AMD64"
          - "ARM64"
```

## 작업 사용

체크아웃 / 빌드 / 코드 감사 / 업로드 / 통보 등의 [작업 사용](https://docs.github.com/ko/actions/using-jobs)은 `jobs` 를 통해 정의 합니다.


```yaml
jobs:
  스테이지1:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Hello, Giihub Actions!"
  스테이지2:
    name: "pwd and ls"
    runs-on: ubuntu-latest
    steps:
      - name: Print working directory
        run: pwd
      - name: List files
        run: ls -al
```


## Actions 실행기

Github에서 제공하는 [actions 실행기](https://docs.github.com/ko/actions/learn-github-actions/essential-features-of-github-actions)의 필수 기능으로 github 에서 소스 코드를 `checkout` 하고 아티팩트를 `upload` 및 `download` 할 수 있습니다.

actions 의 사용은 `uses` 키워드로 하며 `actions/<커멘드>`를 통해 명령이 실행됩니다. `<커멘드>`를 실행할때 버전을 선택하기 위해 `@<버전>` 을 사용니다.

```
steps:
  - uses: actions/checkout@v4
```
위 명령은 버전 4의 checkout 실행기를 사용하는 것을 의미 합니다.

### Github provider actions
- [actions](https://github.com/orgs/actions/repositories)
- [checkout](https://github.com/actions/checkout)
- [setup-java](https://github.com/actions/setup-java)
- [upload-artifact](https://github.com/actions/upload-artifact)
- [download-artifact](https://github.com/actions/download-artifact)

### AWS provider actions
- [aws-actions](https://github.com/aws-actions)



### Maven 빌드 예제

[Maven 빌드](https://docs.github.com/ko/actions/automating-builds-and-tests/building-and-testing-java-with-maven) 를 참조합니다.

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: actions/setup-java@v3
    with:
      java-version: '17'
      distribution: 'temurin'
  - name: Run the Maven verify phase
    run: mvn --batch-mode --update-snapshots verify
```

## 환경 변수

```yaml
env:
  AWS_REGION: ap-northeast-2
  AWS_ROLE_ARN: "aaa"
  s3_bucket: symple-s3 
```

## 기본 환경 변수

Github Actions 에서 제공하는 [기본 환경 변수](https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables)를 활용하면 CICD를 세밀하게 제어할 수 있습니다.


## EKS를 액세스 하기위해 KUBE_CONFIG_DATA 비밀키 저장 

```
aws eks update-kubeconfig --name "nova-an2d-demo-eks" --kubeconfig /tmp/ekstemp
```

`/tmp/ekstemp` 파일에서 파일 하단에 AWS 환경변수 관련 설정이 있으면 제거 후 저장

```yaml
      env:
      - name: AWS_PROFILE
        value: mypoc
```

`/tmp/ekstemp` 파일 내용을 Base64로 인코딩합니다.

```
cat /tmp/ekstemp | base64 | pbcopy
```

Base64로 인코딩된 값을 `KUBE_CONFIG_DATA` 이름으로 Github 저장소의 비밀키에 저장합니다. 


