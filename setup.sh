#!/bin/bash

# Root files
touch main.tf variables.tf outputs.tf terraform.tfvars

# Module directories
MODULES=(vpc rds s3 iam)
for module in "${MODULES[@]}"; do
    mkdir -p "modules/$module"
    touch "modules/$module/main.tf"
    touch "modules/$module/variables.tf"
    touch "modules/$module/outputs.tf"
done

echo "Terraform project structure created."
