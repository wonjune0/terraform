resource "random_password" "jwt_secret" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name                    = "${var.pjt_name}-jwt-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = random_password.jwt_secret.result
}

# 결제 게이트웨이 시크릿 키.
# 지금은 모의 게이트웨이라 실제로 쓰이지 않지만, 실 PG로 교체할 때 애플리케이션과
# 인프라를 다시 손대지 않도록 주입 경로를 미리 만들어 둔다.
resource "random_password" "payment_secret" {
  length  = 48
  special = false
}

resource "aws_secretsmanager_secret" "payment_secret" {
  name                    = "${var.pjt_name}-payment-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "payment_secret" {
  secret_id     = aws_secretsmanager_secret.payment_secret.id
  secret_string = random_password.payment_secret.result

  # 실제 PG 키를 발급받으면 콘솔이나 CLI로 이 시크릿 값만 덮어쓰면 된다.
  # ignore_changes가 없으면 다음 apply 때 랜덤 값으로 되돌려 버린다.
  lifecycle {
    ignore_changes = [secret_string]
  }
}
