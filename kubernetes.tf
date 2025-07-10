# kubernetes.tf

# -----------------------------------------------------------------------------
# Application Load Balancer (ALB) Setup (Managed by AWS Load Balancer Controller)
# -----------------------------------------------------------------------------
# Note: The ALB itself will be provisioned by the AWS Load Balancer Controller
# running in your EKS cluster, based on Kubernetes Service/Ingress annotations.
# We are providing the IAM policy required for the controller.

# IAM Policy for AWS Load Balancer Controller
resource "aws_iam_policy" "alb_ingress_controller_policy" {
  name        = "${var.project_name}-aws-lb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:GetCertificate",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags",
          "ec2:DescribeVpcs",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:UnassignPrivateIpAddresses",
          "ec2:AssignPrivateIpAddresses",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:SetWebAcl",
          "iam:CreateServiceLinkedRole",
          "iam:GetServerCertificate",
          "iam:ListServerCertificates",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:ListWebACLs",
          "wafv2:LockResource",
          "wafv2:UnlockResource",
          "tag:GetResources",
          "tag:TagResources",
          "tag:UntagResources"
        ],
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Kubernetes Deployment and Service for your container
# This will deploy a simple Nginx web server as an example.
# -----------------------------------------------------------------------------

resource "kubernetes_deployment" "nginx_app" {
  metadata {
    name      = "${var.project_name}-nginx-deployment"
    namespace = "default" # Fargate profile applies to 'default' namespace
    labels = {
      app = "nginx-app"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "nginx-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx-app"
        }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }

  # Ensure deployment happens after EKS cluster and Fargate profile are ready
  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_fargate_profile.eks_fargate_profile
  ]
}

resource "kubernetes_service" "nginx_service" {
  metadata {
    name      = "${var.project_name}-nginx-service"
    namespace = "default" # Fargate profile applies to 'default' namespace
    annotations = {
      # This annotation tells the AWS Load Balancer Controller to provision an ALB
      # and associate it with this service.
      # Ensure the AWS Load Balancer Controller is deployed in your EKS cluster.
      "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
      "service.beta.kubernetes.io/aws-load-balancer-type"   = "external"
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip" # For Fargate
      "service.beta.kubernetes.io/aws-load-balancer-subnets" = join(",", aws_subnet.public_subnets[*].id) # ALB in public subnets
      "service.beta.kubernetes.io/aws-load-balancer-target-group-attributes" = "stickiness.enabled=true,stickiness.type=lb_cookie" # Example attribute
    }
    labels = {
      app = "nginx-app"
    }
  }
  spec {
    selector = {
      app = "nginx-app"
    }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "LoadBalancer" # This type will trigger ALB creation via the controller
  }

  # Ensure service creation happens after deployment
  depends_on = [
    kubernetes_deployment.nginx_app
  ]
}
