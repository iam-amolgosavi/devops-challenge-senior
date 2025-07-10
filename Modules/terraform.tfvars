# terraform.tfvars

# AWS Region to deploy resources in
aws_region = "eu-west-1"

# A unique name for your project, used as a prefix for resources
project_name = "my-eks-app"

# The CIDR block for the VPC
vpc_cidr_block = "10.0.0.0/16"

# The Kubernetes version for the EKS cluster
eks_kubernetes_version = "1.28"
