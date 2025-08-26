# modules/rds/main.tf
# This module creates RDS-related resources

# Create a DB parameter group for MySQL
# Parameter groups let you manage database engine configuration
resource "aws_db_parameter_group" "mysql_params" {
  family = "mysql8.0"
  name   = var.parameter_group_name
  description = var.parameter_group_description

  # These parameters are specifically configured for data engineering workflows
  # binlog_format = ROW: Ensures row-based binary logging for better replication
  parameter {
    name  = "binlog_format"
    value = "ROW"
  }

  # binlog_row_image = full: Captures complete row data for ETL processes
  parameter {
    name  = "binlog_row_image"
    value = "full"
  }

  tags = var.common_tags
}

# Create the RDS MySQL instance
# This is your actual database that applications will connect to
resource "aws_db_instance" "mysql_db" {
  # Basic instance configuration
  identifier     = var.db_identifier
  engine         = "mysql"
  engine_version = "8.0.37"
  instance_class = "db.t3.micro"  # Free tier eligible
  
  # Database configuration
  db_name  = var.db_name
  username = var.master_username
  password = var.master_password
  
  # Storage configuration (using defaults for simplicity)
  allocated_storage     = 20
  max_allocated_storage = 100  # Allows automatic scaling up to 100GB
  storage_type         = "gp2"
  storage_encrypted    = true
  
  # Network and security configuration
  publicly_accessible = true  # For educational purposes - NOT recommended for production
  skip_final_snapshot = true  # For easy cleanup during learning
  
  # Backup configuration
  backup_retention_period = 7    # Keep backups for 7 days
  backup_window          = "03:00-04:00"  # UTC time for backups
  maintenance_window     = "sun:04:00-sun:05:00"  # UTC time for maintenance
  
  # High availability configuration
  multi_az = false  # Single AZ for cost efficiency during learning
  
  # Associate the parameter group we created
  parameter_group_name = aws_db_parameter_group.mysql_params.name
  
  # Performance Insights (optional monitoring feature)
  performance_insights_enabled = false
  
  # Apply deletion protection for safety
  deletion_protection = false  # Set to false for easier cleanup during learning
  
  tags = var.common_tags
}