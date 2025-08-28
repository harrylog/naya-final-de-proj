# modules/redshift/main.tf
# Redshift Serverless for data warehousing

# Create IAM role for Redshift
resource "aws_iam_role" "redshift_role" {
  name = var.redshift_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# Attach S3 read access policy to Redshift role
resource "aws_iam_role_policy_attachment" "redshift_s3_access" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = var.s3_policy_arn
}

# Get default VPC for networking
data "aws_vpc" "default" {
  default = true
}

# Get all subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create security group for Redshift
resource "aws_security_group" "redshift_sg" {
  name_prefix = "${var.workgroup_name}-sg"
  description = "Security group for Redshift serverless workgroup"
  vpc_id      = data.aws_vpc.default.id

  # Inbound rule for Redshift access
  ingress {
    description = "Redshift access"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.workgroup_name}-security-group"
  })
}

# Create Redshift serverless namespace
resource "aws_redshiftserverless_namespace" "namespace" {
  namespace_name      = var.namespace_name
  db_name            = var.database_name
  admin_username     = var.admin_username
  admin_user_password = var.admin_password
  
  # Associate IAM role
  iam_roles = [aws_iam_role.redshift_role.arn]

  tags = var.common_tags
}

# Create Redshift serverless workgroup
resource "aws_redshiftserverless_workgroup" "workgroup" {
  workgroup_name   = var.workgroup_name
  namespace_name   = aws_redshiftserverless_namespace.namespace.namespace_name
  base_capacity    = var.base_capacity
  publicly_accessible = var.publicly_accessible
  
  subnet_ids         = data.aws_subnets.default.ids
  security_group_ids = [aws_security_group.redshift_sg.id]

  tags = var.common_tags
}

# Store Redshift credentials in Secrets Manager
resource "aws_secretsmanager_secret" "redshift_credentials" {
  name        = var.redshift_secret_name
  description = "Redshift serverless admin credentials"

  tags = var.common_tags
}

resource "aws_secretsmanager_secret_version" "redshift_credentials" {
  secret_id = aws_secretsmanager_secret.redshift_credentials.id
  
  secret_string = jsonencode({
    username = var.admin_username
    password = var.admin_password
    engine   = "redshift"
    host     = aws_redshiftserverless_workgroup.workgroup.endpoint[0].address
    port     = 5439
    dbname   = var.database_name
  })
}

