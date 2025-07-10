# outputs.tf

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.eks_vpc.id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets."
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets."
  value       = aws_subnet.private_subnets[*].id
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_endpoint" {
  description = "The endpoint URL for the EKS cluster."
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data required to communicate with your cluster."
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "alb_ingress_controller_iam_policy_arn" {
  description = "ARN of the IAM policy for the AWS Load Balancer Controller. Attach this to its service account."
  value       = aws_iam_policy.alb_ingress_controller_policy.arn
}

output "nginx_service_load_balancer_hostname" {
  description = "The hostname of the Load Balancer created for the Nginx service."
  value       = kubernetes_service.nginx_service.status[0].load_balancer[0].ingress[0].hostname
}
