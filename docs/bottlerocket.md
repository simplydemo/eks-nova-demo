# Bottlerocket

[bottlerocket](https://www.youtube.com/watch?v=L33l7Yd8oZM) 철학은

# Docker 철학의 큰 부분은 API 추상화 계층이 컨테이너 이미지를 기본 구현에서 분리한다는 것입니다. Bottlerocket은 이 철학의 확장입니다.

### 장점

Bottlerocket은 Ubuntu, Red Hat 또는 기타 표준 Linux 플랫폼보다 더 일관된 호스트 배포 시스템을 제공합니다.
배포된 모든 인스턴스는 마지막 인스턴스와 동일합니다.
또한 사용 중인 버전에 관계없이 장기적으로 안정적인 릴리스를 약속합니다. (3년)

Bottlerocket의 차별화는 필수 설정 및 관리가 부족하다는 것입니다.
운영자는 호스트 OS를 관리하는 데 필요한 여러 업데이트, 패치 및 응용 프로그램 설치를 알고있습니다.
이를 위해 설치 구성된 패키지는 업스트림 문제이든 잘못된 업데이트이든 관계없이 잠재적인 문제 영역을 가지고 있습니다.

Bottlerocket은 소프트웨어를 컨테이너로만 실행하며 패키지 관리자가 없습니다.
AWS에 따르면 이는 관리자가 Bottlerocket 업데이트 및 롤백을 단일 단계로 적용하여 오류 위험을 최소화 한다고 합니다.
업그레이드는 모두 적용되거나 아니면 모두 적용되지 않는 수준으로 이루어집니다.
Bottlerocket은 필요한 경우 유용한 대체 기능인 파티션을 사용합니다.

Bottlerocket 호스트는 일회용으로 설계되었습니다. "실행 중인 업데이트"가 없습니다.
업그레이드는 오케스트레이터가 새 이미지를 다운로드하고 배포하는 이전 버전에서 새 버전으로 전환하는 것입니다.

Bottlerocket은 적절하게 배포, 실행 및 폐기되는 최소 계층입니다. 배포는 IT 팀이 Amazon Elastic Kubernetes Service와 같은 AWS 내의 기존 조정 도구를 사용하여 관리할 수
있도록 설계되었습니다.

또한 훨씬 더 안전한 환경을 조성합니다. Bottlerocket에는 설치된 애플리케이션 수가 적어 리소스를 절약하고 잠재적인 보안 문제를 줄입니다. 관리를 안전하게 수행할 수 있는 잘 정의된 API 세트가 있습니다.

Docker 철학의 큰 부분은 API 추상화 계층이 컨테이너 이미지를 기본 구현에서 분리한다는 것입니다. Bottlerocket은 이 철학의 확장입니다.

Bottlerocket에는 타사 플러그인, 레지스트리, 타사 앱이 없습니다.

전반적으로 Bottlerocket은 유지 관리 측면에서 매우 손이 많이 가지 않도록 설계되어 개발자를 기쁘게 할 것입니다.

Bottlerocket의 각 주요 릴리스는 Amazon에서 최소 3년 동안 지원됩니다.

Bottlerocket이 부족한 곳
Bottlerocket은 무료로 다운로드하여 사용할 수 있지만 모든 기능은 AWS 플랫폼에 맞게 조정되어 있습니다. 이는 도구를 AWS 환경으로 제한하며 변경될지는 불확실합니다.

주변의 모든 도구는 AWS와의 긴밀한 통합을 기반으로 합니다. Bottlerocket 시스템의 기본 코드와 구성은 GitHub 에 있습니다 .

Bottlerocket은 고도로 자동화되고 역동적인 대규모 환경을 위해 설계되었습니다. 소규모 환경에서는 관련 개조 및 테스트로 인해 Bottlerocket에서 많은 이점을 얻을 수 없습니다.

Bottlerocket은 대부분의 지역에서 사용할 수 있지만 전부는 아니며 AWS 정부 환경에서는 사용할 수 없습니다. GPU 지원 기능과 같은 Amazon Machine Image 인스턴스 의 일부 고급 항목은
현재 Bottlerocket과 호환되지 않습니다.

Bottlerocket과 Alpine Linux
Bottlerocket과 Alpine Linux는 모두 물리적 배포 크기와 소비되는 리소스 측면에서 매우 작습니다. 예를 들어 Alpine Linux는 32MB 미만의 RAM에서 설치 및 실행됩니다. 저장된 자원은
더 많은 컨테이너를 생산하는 데 사용될 수 있습니다 .

동시에 Alpine Linux는 매우 단순한 Linux 구현이며 필요할 때 고도로 구성 가능하지만 대부분의 다른 Linux 배포판과 함께 제공되는 서비스 관리의 복잡성은 없습니다. 이는 잘못될 가능성이 적고,
확보해야 할 항목이 적으며, 소비되는 리소스가 적다는 것을 의미합니다. Bottlerocket도 비슷한 원리로 작동합니다.

두 OS의 가장 큰 차이점은 유연성입니다. Alpine Linux는 모든 Linux 기반 컨테이너 환경에서 작동하도록 설계된 반면 Bottlerocket은 AWS에서만 사용하도록 제한됩니다.

```
# admin 모드 활성화 
enable-admin-container

# admin 로그인 
enter-admin-container


# admin 모드 비활성화
disable-admin-container


# configuration 조회 
apiclient -u /settings
```
