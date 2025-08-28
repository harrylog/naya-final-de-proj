# modules/iam/main.tf
# IAM module for managing policies and roles across the data pipeline

# S3 Data Lake Access Policy for DMS and Glue
resource "aws_iam_policy" "s3_data_lake_policy" {
  name        = var.s3_policy_name
  description = "Policy for DMS and Glue to access S3 data lake"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject", 
          "s3:PutObjectTagging",
           "s3:GetObject",  
           "s3:GetObjectVersion" 
        ]
        Resource = [
          "${var.s3_bucket_arn}/*"  # All objects in bucket
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.s3_bucket_arn  # The bucket itself
        ]
      }
    ]
  })

  tags = var.common_tags
}