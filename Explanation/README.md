This task involves using Terraform to provision a complete cloud infrastructure on AWS for hosting a containerized web application.

Here's a breakdown of what the task entails:

Infrastructure Creation: You need to define and deploy the following AWS resources using Terraform:

VPC with Subnets: A Virtual Private Cloud (VPC) that acts as your isolated network in AWS. This VPC must have:

Two public subnets: These are accessible from the internet and are where your load balancer will reside.

Two private subnets: These are isolated from direct internet access and are where your containerized applications will run.

EKS Cluster: An Amazon Elastic Kubernetes Service (EKS) cluster. EKS is a managed Kubernetes service that simplifies running Kubernetes on AWS.

EKS Fargate Profile: This is crucial for running your containers. A Fargate profile tells EKS to launch your Kubernetes pods on AWS Fargate, which is a serverless compute engine for containers. The key requirement here is that these Fargate tasks/nodes (where your containers run) must be deployed only to the private subnets for security and isolation.

Load Balancer: An Application Load Balancer (ALB) deployed in your public subnets. This ALB will act as the entry point for external traffic, directing requests to your containerized application running within the EKS cluster.

Container Deployment: Beyond just the infrastructure, the task also requires that the Terraform setup includes the deployment of a sample container (like the Nginx web server I've included) into the EKS cluster. This demonstrates that the infrastructure is capable of hosting your application.

Automation and Simplicity: The core acceptance criteria emphasize that the entire process of creating the infrastructure and deploying the container should be achievable with just two commands: terraform plan and terraform apply. This means all necessary configurations, including Kubernetes deployments and services, must be managed by Terraform.

Best Practices and Documentation:

Code Quality: The Terraform code should be well-structured, readable, and properly commented.

Modularity: The Terraform configuration should be broken down into separate, logical .tf files (like vpc.tf, eks.tf, kubernetes.tf, etc.) for better organization.

Variables: Use variables in your Terraform root module for configurable parameters (e.g., AWS region, project name) and provide sensible default values in a terraform.tfvars file.

No Credentials in Git: Crucially, you must not commit any AWS credentials directly into the repository. Instead, provide clear instructions in a README.md file on how a user can authenticate to AWS to deploy the infrastructure.

In essence, the task is to provide a fully automated, secure, and easily deployable AWS infrastructure and a sample containerized application using Terraform, adhering to best practices for code organization and security. The README.md file serves as the primary guide for anyone wanting to deploy and understand this solution.
