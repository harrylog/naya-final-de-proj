# modules/dms/main.tf
# DMS module for database migration and CDC

# Get default VPC (same as RDS)
data "aws_vpc" "default" {
  default = true
}

# Get all subnets across AZs in the default VPC
data "aws_subnets" "all_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create IAM role for DMS VPC management
resource "aws_iam_role" "dms_vpc_role" {
  name = var.dms_vpc_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# Attach AWS managed policy for DMS VPC management
resource "aws_iam_role_policy_attachment" "dms_vpc_management" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

# Create DMS subnet group across all AZs  
resource "aws_dms_replication_subnet_group" "dms_subnet_group" {
  replication_subnet_group_description = "DMS subnet group across all AZs"
  replication_subnet_group_id          = var.subnet_group_name
  subnet_ids                           = data.aws_subnets.all_subnets.ids

  tags = var.common_tags
}

# Create security group for DMS replication instance
resource "aws_security_group" "dms_sg" {
  name_prefix = "${var.replication_instance_id}-sg"
  description = "Security group for DMS replication instance"
  vpc_id      = data.aws_vpc.default.id

  # Inbound: Allow MySQL from RDS security group
  ingress {
    description = "MySQL access to RDS"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  # Outbound: Allow all (for S3 access and general connectivity)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.replication_instance_id}-security-group"
  })
}

# Create DMS replication instance
resource "aws_dms_replication_instance" "main" {
  allocated_storage            = var.allocated_storage
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  availability_zone          = null  # Single AZ, let AWS choose
  engine_version             = "3.5.3"
  multi_az                   = false
  publicly_accessible       = var.publicly_accessible
  replication_instance_class = var.instance_class
  replication_instance_id    = var.replication_instance_id
  
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_subnet_group.id
  vpc_security_group_ids      = [aws_security_group.dms_sg.id]

  tags = var.common_tags

  depends_on = [
    aws_dms_replication_subnet_group.dms_subnet_group,
    aws_iam_role_policy_attachment.dms_vpc_management
  ]
}