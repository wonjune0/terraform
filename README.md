# seoul — AWS 이커머스 인프라 (Terraform)

전자상거래 웹 서비스를 위한 AWS 인프라를 Terraform으로 정의한 리포지토리입니다.
콘솔 클릭 없이 `terraform apply` 한 번으로 네트워크부터 배포 파이프라인 연동까지
전체 환경이 재현됩니다.

**목표**: 대용량 트래픽에도 안전하게 서비스할 수 있는 구조를 코드로 관리한다.

| 항목 | 값 |
|---|---|
| 리전 | 서울 `ap-northeast-2` (백업 복제: 오사카 `ap-northeast-3`) |
| 도메인 | `app.wonjune.cloud` |
| Terraform | `>= 1.15.0`, AWS Provider `6.53.0` |
| 상태 저장 | S3 원격 백엔드 + S3 네이티브 잠금(`use_lockfile`) |

관련 리포지토리
- 백엔드 (Spring Boot): [`wonjune0/back_web`](https://github.com/wonjune0/back_web)
- 프론트엔드 (정적 웹): [`wonjune0/front_web`](https://github.com/wonjune0/front_web)

---

## 아키텍처

```
                          사용자
                            │ HTTPS
                            ▼
                    ┌───────────────┐
                    │   Route 53    │  app.wonjune.cloud (A/ALIAS)
                    └───────┬───────┘
                            ▼
                    ┌───────────────┐
                    │  CloudFront   │  ACM 인증서(us-east-1), TLS 종료
                    └───┬───────┬───┘
              기본 경로 │       │ /api/*
                        ▼       ▼
              ┌──────────┐   ┌──────────────────┐
              │ S3 (OAC) │   │ ALB (public sub) │
              │  정적 웹 │   └────────┬─────────┘
              └──────────┘            │  X-Custom-Header 검증
                                      ▼
                          ┌────────────────────────┐
                          │ ECS Fargate (priv sub) │  2~10 태스크
                          │  Spring Boot :80       │  CPU 70% 오토스케일
                          └───────────┬────────────┘
                                      ▼
                          ┌────────────────────────┐
                          │  Aurora MySQL          │  Serverless v2
                          │  Serverless v2 × 2 AZ  │  0.5~16 ACU, 암호화
                          └────────────────────────┘
```

### 단일 도메인 경로 라우팅

CloudFront 하나가 정적 페이지와 API를 모두 서비스합니다.

| 경로 | 오리진 | 캐시 정책 |
|---|---|---|
| `/api/*` | ALB | CachingDisabled |
| 그 외 | S3 (OAC) | CachingOptimized |

프론트와 API가 **같은 도메인**이므로 브라우저 입장에서 동일 출처입니다.
그 결과 **CORS 설정이 운영 환경에 존재하지 않습니다.** (로컬 개발에서만 백엔드의
`local` 프로필이 CORS를 허용합니다.)

### ALB 직접 접근 차단 (이중 방어)

퍼블릭 서브넷의 ALB로 우회 접근하는 것을 두 겹으로 막습니다.

1. **보안 그룹** — AWS 관리형 접두사 목록 `com.amazonaws.global.cloudfront.origin-facing`
   에서 오는 트래픽만 80 포트 허용
2. **리스너 규칙** — CloudFront가 주입하는 `X-Custom-Header` 시크릿 값이 일치할 때만
   대상 그룹으로 전달. 기본 동작은 `403 고정 응답`

헤더 값은 `random_password`로 생성되어 CloudFront와 ALB 규칙에 동시에 주입되므로
코드나 저장소 어디에도 평문으로 남지 않습니다.

---

## 모듈 구성

`main.tf`가 아래 모듈을 조합합니다. 도메인별로 파일을 나누고 각 모듈은
`main.tf` / `variables.tf` / `outputs.tf` 3파일 구조를 따릅니다.

| 모듈 | 생성하는 리소스 |
|---|---|
| `vpc_module` | VPC, 인터넷 게이트웨이 |
| `subnet_module` | 퍼블릭 / 프라이빗 / DB 서브넷 각 2 AZ |
| `route_table_module` | 라우팅 테이블, NAT 게이트웨이 + EIP (AZ별) |
| `vpc_endpoint_module` | S3 게이트웨이, ECR api/dkr 인터페이스 엔드포인트 |
| `security_group_module` | ALB / ECS / VPC 엔드포인트 보안 그룹 |
| `alb_module` | ALB, 대상 그룹, 리스너, 헤더 검증 규칙 |
| `ecr_module` | ECR 리포지토리 (IMMUTABLE 태그, 푸시 스캔, 수명주기 정책) |
| `ecs_module` | ECS 클러스터/태스크 정의/서비스, Application Auto Scaling, 로그 그룹 |
| `db_module` | Aurora MySQL Serverless v2 클러스터 + 인스턴스 2대, 파라미터 그룹 |
| `s3_module` | 프론트엔드 정적 호스팅 버킷 (퍼블릭 차단 + OAC 전용 정책) |
| `cloudfront_module` | 배포, OAC, 경로 기반 동작 |
| `acm_module` | ACM 인증서 + DNS 검증 (us-east-1 별칭 프로바이더) |
| `route53_module` | CloudFront ALIAS 레코드 |
| `backend_secrets_module` | JWT 서명 키 생성 및 Secrets Manager 저장 |
| `iam_module` | ECS 태스크 실행 역할, 시크릿 접근 정책, 백업 역할, 프론트 배포자 정책 |
| `cloudwatch_module` | ALB 5XX / ECS CPU / RDS 커넥션 경보 |
| `notification_module` | SNS 토픽 + 이메일 구독 |
| `backup_module` | AWS Backup 볼트(서울·오사카), 일일 계획, 교차 리전 복사 |
| `ssm_module` | 프론트 CI/CD가 읽어갈 배포 대상 파라미터 |

---

## 설계 판단

### 시크릿을 코드에 두지 않는다

| 값 | 관리 방식 |
|---|---|
| DB 마스터 비밀번호 | Aurora `manage_master_user_password = true` → RDS가 Secrets Manager에 자동 생성·회전 |
| JWT 서명 키 | `random_password` → Secrets Manager 저장 |
| CloudFront↔ALB 공유 헤더 | `random_password` → 두 리소스에 동시 주입 |

ECS 태스크 정의에는 **값이 아니라 ARN만** 들어갑니다. 컨테이너 기동 시 실행 역할이
Secrets Manager에서 값을 읽어 환경 변수로 주입합니다.

```hcl
secrets = [
  { name = "DB_PASSWORD", valueFrom = "${var.db_master_secret_arn}:password::" },
  { name = "JWT_SECRET",  valueFrom = var.jwt_secret_arn }
]
```

### 이미지 배포는 애플리케이션 CI/CD가 소유한다

인프라 코드가 컨테이너 이미지 태그까지 관리하면, 애플리케이션 코드를 고칠 때마다
인프라 리포에 커밋해야 합니다. 그래서 소유권을 나눴습니다.

```hcl
resource "aws_ecs_task_definition" "tf_ecs_task_definition" {
  lifecycle { ignore_changes = [container_definitions] }
}

resource "aws_ecs_service" "tf_service" {
  lifecycle { ignore_changes = [desired_count, task_definition] }
}
```

- **Terraform**: 태스크 정의의 최초 형태(환경 변수, 시크릿 ARN, 로그 설정)를 정의
- **백엔드 CI/CD**: 기존 태스크 정의를 받아 `image` 필드만 교체해 새 리비전 등록 후 배포
- `desired_count`는 오토스케일링이 조정하므로 Terraform이 덮어쓰지 않음

`ignore_changes = [task_definition]`이 없으면 인프라 apply 때마다 서비스가
Terraform이 만든 최초 리비전으로 되돌아갑니다.

**트레이드오프**: 같은 블록 안의 시크릿 ARN과 DB 엔드포인트도 함께 동결됩니다.
DB를 단독으로 재생성하면 태스크 정의가 옛 ARN을 들고 있게 되므로,
`terraform apply -replace=module.ecs.aws_ecs_task_definition.tf_ecs_task_definition`
로 리비전을 다시 만들어야 합니다.

### Terraform과 CI/CD 사이의 값 전달

CloudFront 배포판 ID는 인프라를 재구축할 때마다 새로 발급됩니다. 이 값을 GitHub
Secret에 손으로 넣으면 재구축마다 수동 갱신이 필요합니다. SSM Parameter Store를
전달 통로로 사용해 이 단계를 없앴습니다.

```
terraform apply → SSM 파라미터 기록 → 프론트 CI/CD가 실행 시점에 조회
```

| 파라미터 | 용도 |
|---|---|
| `/seoul/frontend/distribution_id` | CloudFront 캐시 무효화 대상 |
| `/seoul/frontend/bucket_name` | S3 동기화 대상 |

ECS 클러스터/서비스/태스크 패밀리와 ECR 리포지토리 이름은 `pjt_name` 기반으로
결정되므로 재구축해도 변하지 않아 워크플로에 상수로 둡니다.

### 리스트 대신 맵

서브넷을 `count`로 만들면 중간 항목을 제거할 때 인덱스가 밀려 무관한 리소스까지
재생성됩니다. CIDR을 키로 하는 맵과 `for_each`를 사용합니다.

```hcl
pub_subnets = {
  "10.0.1.0/24" = "ap-northeast-2a"
  "10.0.2.0/24" = "ap-northeast-2c"
}
```

NAT 게이트웨이와 프라이빗 라우트를 **가용 영역 키로 짝지어** 각 AZ의 트래픽이
같은 AZ의 NAT를 통과하도록 했습니다.

---

## 사용법

### 사전 준비

1. 상태 저장용 S3 버킷 생성 (**버전 관리 활성화 필수**) — 이 버킷은 Terraform이
   관리하지 않습니다. 상태 파일 자체를 담는 곳이라 수명주기가 다릅니다.
2. Route 53 퍼블릭 호스팅 영역 등록 (`wonjune.cloud`) — `acm_module`이 데이터 소스로 조회
3. CI/CD용 IAM 사용자 생성 (`frontend-developer` 등)

### 실행

```bash
terraform init
terraform plan  -var-file="seoul.tfvars"
terraform apply -var-file="seoul.tfvars"
```

`main` 브랜치에 푸시하면 GitHub Actions가 `fmt` → `validate` → `plan` → `apply`를
자동 실행합니다.

### 배포 순서

인프라만 만들면 서비스가 뜨지 않습니다. `image_tag` 기본값 `initial`에 해당하는
이미지가 ECR에 없기 때문입니다. **apply 직후 ECS가 실패 상태인 것은 정상입니다.**

```
1. terraform apply          인프라 생성
2. back_web  CI/CD 실행     이미지 빌드 → ECR 푸시 → ECS 배포
3. front_web CI/CD 실행     S3 동기화 → CloudFront 무효화
4. SNS 확인 메일 클릭       알람 수신 활성화
```

### 재구축 시 주의

| 항목 | 내용 |
|---|---|
| 동시 실행 | `destroy`/`apply` 중 이 리포에 푸시하지 말 것. CI가 `-auto-approve`로 끼어들어 상태 잠금이 충돌 |
| 중단 금지 | 진행 중인 작업을 강제 종료하면 S3에 잠금이 남음. 필요하면 `Ctrl+C` **한 번만** (정상 종료 경로로 잠금 해제) |
| 소요 시간 | destroy·apply 각각 25~40분. CloudFront 배포 삭제/생성이 가장 오래 걸림 |
| S3 / ECR | 내용물이 있으면 삭제가 실패. `force_destroy` / `force_delete`를 켜거나 미리 비울 것 |
| SNS 구독 | 재생성 시 확인 메일이 다시 발송됨. 클릭 전에는 알람이 전달되지 않음 |
| DB 데이터 | 클러스터가 새로 만들어짐. Flyway가 스키마와 상품 시드를 재생성하지만 가입 계정·주문 이력은 사라짐 |

상태 잠금이 남았을 때:

```bash
terraform force-unlock <에러에 표시된 ID>
```

---

## 운영

### 모니터링

| 경보 | 조건 |
|---|---|
| `seoul-alb-5XX` | 대상 그룹 5XX 1분간 5건 이상 |
| `seoul-ecs-high-cpu` | ECS 서비스 평균 CPU 80% 초과 2회 연속 |
| `seoul-rds-*-high-connections` | 인스턴스별 DB 커넥션 80 이상 |

경보는 SNS 토픽을 통해 이메일로 전달됩니다. ECS 클러스터는 Container Insights가
활성화되어 있고, 애플리케이션 로그는 `/ecs/seoul` 로그 그룹에 7일 보관됩니다.

> CloudWatch의 ALB 메트릭 디멘션은 전체 ARN이 아니라 `arn_suffix`
> (`app/seoul-alb/...`, `targetgroup/seoul-ecs-tg/...`)를 요구합니다. 전체 ARN을 넣으면
> 경보가 생성은 되지만 매칭되는 메트릭이 없어 영원히 `INSUFFICIENT_DATA`에 머뭅니다.

### 백업

AWS Backup이 매일 새벽(KST 00:00) Aurora 클러스터를 백업하고, 오사카 리전 볼트로
복사합니다. 양쪽 모두 30일 후 만료됩니다.

### 확장

ECS 서비스는 평균 CPU 70%를 목표로 2~10 태스크 사이에서 조정됩니다.
스케일 아웃 쿨다운 60초, 스케일 인 쿨다운 300초로 축소보다 확장을 빠르게 했습니다.
Aurora Serverless v2는 0.5~16 ACU 범위에서 자동 조절됩니다.

ECS 서비스에는 배포 안전장치가 걸려 있습니다.

- `health_check_grace_period_seconds = 120` — Spring Boot 기동 + Flyway 마이그레이션이
  끝나기 전에 ALB 헬스 체크가 태스크를 죽이는 것을 방지
- `deployment_circuit_breaker` (rollback) — 실패한 배포를 감지해 자동 롤백

---

## 알려진 한계

포트폴리오 범위에서 의도적으로 남겨둔 부분입니다.

- **CloudFront ↔ ALB 구간이 HTTP** — 뷰어 구간은 HTTPS로 종료되지만 오리진 통신은
  평문입니다. ALB에 인증서를 붙이고 `origin_protocol_policy`를 `https-only`로
  바꾸면 해결됩니다.
- **`skip_final_snapshot = true`** — 개발 중 반복 재구축을 위해 최종 스냅샷을
  건너뜁니다. 운영 전환 시 `false` + `final_snapshot_identifier` 지정,
  `deletion_protection = true`가 필요합니다.
- **AWS 액세스 키 기반 CI/CD** — GitHub OIDC로 전환하면 영구 자격 증명을 없앨 수
  있습니다. 워크플로에 `id-token: write` 권한은 이미 선언되어 있습니다.
- **WAF 미적용** — CloudFront에 `web_acl_id`를 연결하면 L7 방어를 추가할 수 있습니다.
- **CI/CD IAM 사용자가 코드 밖에 있음** — 콘솔에서 생성한 사용자를
  `data "aws_iam_user"`로 참조합니다. 정책은 Terraform이 관리합니다.
- **ECR / 프론트 S3의 수명주기 분리** — 두 리소스는 인프라를 재구축해도 유지하고
  싶지만 현재는 같은 상태 파일에 있습니다. 별도 구성(별도 state)으로 분리하면
  `destroy` 대상에서 자연스럽게 제외됩니다.
