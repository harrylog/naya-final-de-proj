# modules/rds/main.tf

# DB Parameter Group
resource "aws_db_parameter_group" "mysql" {
  family = "mysql8.0"
  name   = "${var.project_name}-${var.environment}-db-pg"
  description = "Parameter group for MySQL config"

  parameter {
    name  = "binlog_format"
    value = "ROW"
  }

  parameter {
    name  = "binlog_row_image"
    value = "full"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-pg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "mysql" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Get the VPC security group from the VPC module
data "aws_security_group" "rds" {
  id = var.rds_security_group_id != "" ? var.rds_security_group_id : data.aws_security_groups.rds.ids[0]
}

data "aws_security_groups" "rds" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "group-name"
    values = ["${var.project_name}-${var.environment}-rds-*"]
  }
}

# Security Group Rules for RDS
resource "aws_security_group_rule" "rds_mysql_public" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Public access - NOT for production
  security_group_id = data.aws_security_group.rds.id
  description       = "Public MySQL access"
}

resource "aws_security_group_rule" "rds_mysql_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.rds.id
  security_group_id        = data.aws_security_group.rds.id
  description              = "Self referencing - all traffic"
}

resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.rds.id
  description       = "All outbound traffic"
}

# RDS Instance
resource "aws_db_instance" "mysql" {
  identifier = "${var.project_name}-${var.environment}-db"
  
  # Engine settings
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class
  
  # Storage settings
  allocated_storage     = var.allocated_storage
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true
  
  # Database settings
  db_name  = "dev"
  username = "admin"
  password = var.db_password
  
  # Parameter group
  parameter_group_name = aws_db_parameter_group.mysql.name
  
  # Network settings
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [data.aws_security_group.rds.id]
  publicly_accessible    = true  # For MySQL Workbench access
  
  # Backup settings
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Other settings
  skip_final_snapshot = true  # For dev environment
  deletion_protection = false # For dev environment
  
  # Enable automated backups and binary logging
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-db"
    Environment = var.environment
    Project     = var.project_name
  }
}