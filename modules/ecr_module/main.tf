resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.pjt_name}-app-repo" # 리포지토리 이름 (소문자, 하이픈 권장)
  image_tag_mutability = "IMMUTABLE"                # 태그 덮어쓰기 방지 (보안 및 롤백 안전성 확보)
  # MUTABLE : 동일한 태그로 푸시하면 기존 이미지를 덮어씀(default)

  # 이미지 푸시 시 취약점 자동 스캔 활성화
  image_scanning_configuration {
    scan_on_push = true
  }

  # 저장소 암호화 설정 (AWS 관리형 KMS 키 사용)
  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    Name = "${var.pjt_name}_app_repo"
  }
}

# 오래된 이미지가 쌓여 S3/ECR 저장 비용이 커지는 것을 방지합니다.
resource "aws_ecr_lifecycle_policy" "app_repo_policy" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "최근 10개의 이미지 생성본만 유지하고 이전 버전 자동 삭제"
        selection = {
          tagStatus = "any"
          # tagged 특정 패턴을 가진 이미지만 적용 
          # untagged 태그가 없는 이미지에만 적용
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
