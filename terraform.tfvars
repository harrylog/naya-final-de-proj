# terraform.tfvars.example
# Copy this file to terraform.tfvars and update the values

aws_region = "us-east-1"
project_name = "naya-de-proj"
environment = "dev"

# Get your IP address by running: curl ifconfig.me
your_ip = "YOUR_PUBLIC_IP_HERE/32"

# RDS Configuration
db_instance_class = "db.t3.micro"  # Free tier eligible
allocated_storage = 20             # Free tier eligible


db_password = "naya-final"
