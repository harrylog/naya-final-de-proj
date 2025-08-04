# modules/iam/main.tf

# IAM Policy for S3 access (for DMS and Glue jobs)
resource "aws_iam_policy" "s3_access" {
  name        = "${var.project_name}-${var.environment}-s3-policy"
  description = "Policy for S3 access for DMS and Glue jobs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:PutObjectTagging"
        ]
        Resource = [
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.s3_bucket_arn
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-policy"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM Role for DMS
resource "aws_iam_role" "dms_access_role" {
  name = "${var.project_name}-${var.environment}-dms-access-role"

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

  tags = {
    Name        = "${var.project_name}-${var.environment}-dms-access-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Attach S3 policy to DMS role
resource "aws_iam_role_policy_attachment" "dms_s3_access" {
  role       = aws_iam_role.dms_access_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# IAM Role for Glue
resource "aws_iam_role" "glue_service_role" {
  name = "${var.project_name}-${var.environment}-glue-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-glue-service-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Attach AWS managed Glue service role policy
resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Attach S3 policy to Glue role
resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# Additional policy for Glue to access more S3 operations
resource "aws_iam_policy" "glue_additional_s3" {
  name        = "${var.project_name}-${var.environment}-glue-additional-s3-policy"
  description = "Additional S3 permissions for Glue jobs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-glue-additional-s3-policy"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Attach additional S3 policy to Glue role
resource "aws_iam_role_policy_attachment" "glue_additional_s3" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.glue_additional_s3.arn
}