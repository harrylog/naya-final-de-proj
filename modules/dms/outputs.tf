# modules/dms/outputs.tf
# Output values from the DMS module

output "replication_instance_arn" {
  description = "ARN of the DMS replication instance"
  value       = aws_dms_replication_instance.main.replication_instance_arn
}

output "replication_instance_id" {
  description = "ID of the DMS replication instance"
  value       = aws_dms_replication_instance.main.replication_instance_id
}

output "subnet_group_id" {
  description = "ID of the DMS subnet group"
  value       = aws_dms_replication_subnet_group.dms_subnet_group.id
}

output "dms_vpc_role_arn" {
  description = "ARN of the DMS VPC management role"
  value       = aws_iam_role.dms_vpc_role.arn
}

output "dms_security_group_id" {
  description = "ID of the DMS security group"
  value       = aws_security_group.dms_sg.id
}