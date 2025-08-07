#!/bin/bash
# Simple deployment script for RDS infrastructure
# Usage: ./deploy.sh [vpc|rds|s3|iam|all]

PHASE=${1:-"help"}

case $PHASE in
    "vpc")
        echo "🚀 Deploying VPC..."
        terraform apply -target=module.vpc
        ;;
    "rds") 
        echo "🚀 Deploying RDS..."
        terraform apply -target=module.rds
        ;;
    "s3")
        echo "🚀 Deploying S3..."
        terraform apply -target=module.s3
        ;;
    "iam")
        echo "🚀 Deploying IAM..."
        terraform apply -target=module.iam
        ;;
    "infra")
        echo "🚀 Deploying all infrastructure..."
        terraform apply -target=module.vpc -target=module.rds -target=module.s3 -target=module.iam
        ;;
    "all")
        echo "🚀 Deploying everything..."
        terraform apply
        ;;
    *)
        echo "Usage: $0 [vpc|rds|s3|iam|infra|all]"
        echo ""
        echo "Modules:"
        echo "  vpc    - Deploy VPC and networking"
        echo "  rds    - Deploy RDS MySQL"  
        echo "  s3     - Deploy S3 data lake"
        echo "  iam    - Deploy IAM roles"
        echo "  infra  - Deploy all 4 modules"
        echo "  all    - Deploy everything"
        ;;
esac