resource "aws_db_subnet_group" "tf_db_subnet_group" {
  name       = "${var.pjt_name}-db-subnet-group"
  subnet_ids = var.dbsubnet_ids

  tags = {
    Name = "${var.pjt_name}_db_subnet_group"
  }
}

resource "aws_security_group" "tf_db_sg" {
  name   = "${var.pjt_name}-db-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ecs_sg_id]
  }

  tags = {
    Name = "${var.pjt_name}_db_sg"
  }
}

resource "aws_rds_cluster_parameter_group" "tf_aurora_pg" {
  name   = "${var.pjt_name}-aurora-mysql80-pg"
  family = "aurora-mysql8.0"

  parameter {
    name  = "time_zone"
    value = "Asia/Seoul"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
}

resource "aws_rds_cluster" "tf_aurora_cluster" {
  cluster_identifier              = "${var.pjt_name}-aurora-cluster"
  engine                          = "aurora-mysql"
  engine_version                  = "8.0.mysql_aurora.3.04.0"
  database_name                   = var.db_name
  master_username                 = var.db_admin_user
  manage_master_user_password     = true
  db_subnet_group_name            = aws_db_subnet_group.tf_db_subnet_group.name
  vpc_security_group_ids          = [aws_security_group.tf_db_sg.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.tf_aurora_pg.name

  storage_encrypted   = true
  skip_final_snapshot = false # 실제 배포 시에는 snapshot 남겨야 하므로 true

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 16.0
  }

  tags = {
    Name = "${var.pjt_name}_aurora_cluster"
  }
}

resource "aws_rds_cluster_instance" "tf_aurora_instances" {
  count              = 2
  identifier         = "${var.pjt_name}-aurora-node-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.tf_aurora_cluster.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.tf_aurora_cluster.engine
  engine_version     = aws_rds_cluster.tf_aurora_cluster.engine_version

  publicly_accessible = false

  tags = {
    Name = "${var.pjt_name}_aurora_node_${count.index + 1}"
  }
}
