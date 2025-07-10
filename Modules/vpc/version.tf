# versions.tf

# Define required Terraform version and provider versions
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use a compatible version for EKS and ALB
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23" # Use a compatible version for Kubernetes resources
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Configure the Kubernetes provider
# This provider needs to be configured dynamically after the EKS cluster is created
# It uses the output from the EKS cluster resource.
provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
  # Ensure the Kubernetes provider waits for the EKS cluster to be active
  # and for the Fargate profile to be ready before attempting to deploy K8s resources.
  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_fargate_profile.eks_fargate_profile
  ]
}

# Data source to get EKS cluster authentication token for Kubernetes provider
data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.eks_cluster.name
}
