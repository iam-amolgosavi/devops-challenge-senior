### AWS EKS Infrastructure and Container Deployment with Terraform
This repository contains Terraform code to provision a robust Amazon Elastic Kubernetes Service (EKS) cluster with AWS Fargate, a well-structured Virtual Private Cloud (VPC) with segregated public and private subnets, and an Application Load Balancer (ALB) to expose a sample Nginx web application. This setup ensures your containerized applications run securely within private subnets while being publicly accessible through a load balancer.

### Table of Contents
Overview
Prerequisites
AWS Authentication
Deployment Steps
Verifying the Deployment
Cleanup
Terraform Best Practices
Code Structure
Troubleshooting
Contributing
License

### Overview
This Terraform project automates the creation of the following AWS resources:
#### Virtual Private Cloud (VPC): A dedicated, isolated virtual network.
#### Public Subnets (x2): For internet-facing resources like the ALB.
#### Private Subnets (x2): For EKS Fargate pods, ensuring application isolation.
#### Internet Gateway (IGW): Enables communication between the VPC and the internet.
#### NAT Gateway: Allows instances in private subnets to connect to the internet (e.g., for pulling Docker images, software updates).
#### Elastic Kubernetes Service (EKS) Cluster: A managed Kubernetes control plane.
#### EKS Fargate Profile: Configures EKS to run Kubernetes pods on AWS Fargate, abstracting away server management. Pods will exclusively run in the private subnets.
#### AWS Load Balancer Controller IAM Policy: An IAM policy required for the AWS Load Balancer Controller to manage ALBs within your EKS cluster.
#### Kubernetes Deployment (Nginx): A sample Nginx web server deployed as a container.
#### Kubernetes Service (LoadBalancer type): Exposes the Nginx deployment via an AWS Application Load Balancer provisioned by the AWS Load Balancer Controller.

### Prerequisites
Before deploying this infrastructure, ensure you have the following tools installed and configured on your local machine:

Terraform CLI: Version 1.0.0 or higher.

Install Terraform

AWS CLI: Configured with appropriate credentials.

Install AWS CLI

kubectl: The Kubernetes command-line tool.

Install kubectl

helm: The Kubernetes package manager (required for deploying the AWS Load Balancer Controller).

Install Helm

eksctl: A simple CLI for Amazon EKS (useful for creating IAM Service Accounts).

Install eksctl

AWS Authentication
IMPORTANT: Never commit your AWS credentials directly into this Git repository.

Terraform and the AWS CLI rely on standard AWS authentication mechanisms. Choose one of the following methods to authenticate to your AWS account:

Environment Variables (Recommended for CI/CD pipelines or temporary use):
Set your AWS access key, secret key, and optionally a session token as environment variables:

'''
export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"
export AWS_SESSION_TOKEN="YOUR_AWS_SESSION_TOKEN" # Only if using temporary credentials (e.g., from STS)
'''

AWS Configure (Recommended for local development):
Use the AWS CLI to configure your credentials, which will be stored in ~/.aws/credentials and ~/.aws/config:

aws configure
### Follow the prompts:
### AWS Access Key ID [None]: YOUR_AWS_ACCESS_KEY_ID
### AWS Secret Access Key [None]: YOUR_AWS_SECRET_ACCESS_KEY
### Default region name [None]: eu-west-1 (or your desired region)
### Default output format [None]: json

IAM Roles (Recommended for EC2 instances or EKS service accounts):
If you are deploying from an EC2 instance, ensure the instance profile attached to it has the necessary IAM permissions to create and manage the AWS resources defined in this project.

Ensure that the authenticated AWS user or role possesses the required permissions to create and manage VPCs, EKS clusters, IAM roles, and Elastic Load Balancers.

Deployment Steps
Follow these steps to deploy the infrastructure and the sample web application:

Clone the Repository:

git clone <your-repository-url>
cd <your-repository-directory>

Review Variables (Optional):
The terraform.tfvars file contains default values for the project's variables (e.g., aws_region, project_name, vpc_cidr_block, eks_kubernetes_version). You can modify these values directly in terraform.tfvars to customize your deployment. Alternatively, you can override them via command-line arguments (-var="key=value") or environment variables (TF_VAR_key=value).

Initialize Terraform:
Navigate to the root directory of the cloned repository (where versions.tf, variables.tf, etc., are located) and run:

terraform init

This command downloads the necessary AWS and Kubernetes provider plugins and initializes the backend.

Create an Execution Plan:
Generate and review a detailed plan of the infrastructure changes Terraform will make:

terraform plan

Carefully examine the output to ensure that the planned actions align with your expectations before proceeding.

Apply the Configuration:
If the plan is acceptable, apply the configuration to provision the AWS infrastructure and deploy the container:

terraform apply

Type yes when prompted to confirm the execution. This step will take a significant amount of time as it provisions the EKS cluster and associated resources.

Deploy AWS Load Balancer Controller (Crucial for ALB Integration):
The Kubernetes Service resource is annotated to instruct the AWS Load Balancer Controller to provision an ALB. This controller must be running in your EKS cluster for the ALB to be created and linked to your Nginx service.

a. Configure kubectl Context:
First, ensure your kubectl context is configured to point to your newly created EKS cluster:

aws eks update-kubeconfig --name $(terraform output -raw eks_cluster_name) --region $(terraform output -raw aws_region)

b. Create IAM Service Account (IRSA) for the Controller:
The Terraform output alb_ingress_controller_iam_policy_arn provides the ARN of the IAM policy required by the AWS Load Balancer Controller. You need to associate this policy with a Kubernetes Service Account using eksctl:

# Replace <YOUR_EKS_CLUSTER_NAME> with the actual EKS cluster name from 'terraform output -raw eks_cluster_name'
# Replace <YOUR_AWS_REGION> with your AWS region from 'terraform output -raw aws_region'
# Replace <YOUR_ACCOUNT_ID> with your AWS account ID (e.g., from 'aws sts get-caller-identity --query Account --output text')
eksctl create iamserviceaccount \
  --cluster $(terraform output -raw eks_cluster_name) \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn $(terraform output -raw alb_ingress_controller_iam_policy_arn) \
  --override-existing-serviceaccounts \
  --approve

c. Add EKS Charts Repo and Install Controller using Helm:

helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$(terraform output -raw eks_cluster_name) \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

Wait a few minutes for the controller pods to become ready. You can check their status:

kubectl get pods -n kube-system | grep aws-load-balancer-controller

Verifying the Deployment
After terraform apply completes and the AWS Load Balancer Controller is deployed, you can verify the application:

Check EKS Cluster Status:
Confirm that your EKS cluster is active:

aws eks describe-cluster --name $(terraform output -raw eks_cluster_name) --query "cluster.status" --output text

The output should be ACTIVE.

Check Kubernetes Pods:
Verify that your nginx-app pods are running in the default namespace:

kubectl get pods -n default

You should see output similar to nginx-app-xxxxxxxxxx-xxxxx   1/1     Running.

Check Kubernetes Service and ALB DNS:
The AWS Load Balancer Controller will provision an ALB. This process might take a few minutes. Check the status of your Nginx service to get the ALB's DNS name:

kubectl get svc -n default ${var.project_name}-nginx-service

Look for the EXTERNAL-IP field. This will be the DNS name of your ALB.
Alternatively, you can get it directly from Terraform outputs:

terraform output -raw nginx_service_load_balancer_hostname

Access the Web Application:
Open the EXTERNAL-IP (ALB DNS name) obtained in the previous step in your web browser. You should see the Nginx welcome page, confirming that your application is successfully deployed and accessible.

Cleanup
To destroy all the AWS resources created by this Terraform configuration, run the following command:

terraform destroy

Type yes when prompted to confirm the destruction. This command will meticulously tear down the VPC, EKS cluster, ALB, IAM roles, and all associated resources. This process can also take a significant amount of time.

Terraform Best Practices
This project adheres to several Terraform best practices:

Variables: All configurable values (e.g., region, project name, CIDR blocks) are parameterized using variables, with sensible defaults provided in terraform.tfvars. This enhances flexibility and reususability.

Outputs: Key resource attributes (like VPC ID, EKS cluster endpoint, ALB DNS name) are exposed as outputs, facilitating integration with other tools or for quick reference.

Modularity: The configuration is logically separated into multiple .tf files (versions.tf, variables.tf, outputs.tf, vpc.tf, eks.tf, kubernetes.tf) to improve readability, organization, and maintainability. For larger, more complex infrastructures, these could be further abstracted into reusable Terraform modules.

Tagging: All created AWS resources are consistently tagged with a Name based on the project_name variable, making them easily identifiable and manageable in the AWS console.

Explicit Dependencies (depends_on): Where implicit dependencies are not sufficient, explicit depends_on blocks are used to ensure resources are created or configured in the correct order (e.g., EKS cluster after NAT Gateway, Kubernetes resources after EKS cluster is active).

Provider Configuration: Providers are configured dynamically using outputs from created resources where necessary (e.g., Kubernetes provider using EKS cluster details).

Code Structure
The project is organized into the following files:

versions.tf: Defines the required Terraform version and provider versions (AWS, Kubernetes). Also configures the AWS and Kubernetes providers.

variables.tf: Declares all input variables used throughout the Terraform configuration.

outputs.tf: Defines all output values that are exposed after Terraform applies the configuration.

vpc.tf: Contains all resources related to the VPC, subnets, internet gateway, NAT gateway, and route tables.

eks.tf: Contains all resources related to the EKS cluster, IAM roles for EKS and Fargate, and the EKS Fargate profile.

kubernetes.tf: Contains the IAM policy for the AWS Load Balancer Controller, and the Kubernetes Deployment and Service definitions for the sample Nginx application.

terraform.tfvars: Provides default values for the variables defined in variables.tf, simplifying the terraform apply command.

README.md: This comprehensive guide for deployment, verification, and cleanup.

Troubleshooting
terraform init errors: Check your internet connection and ensure your Terraform version is compatible with the specified provider versions.

terraform apply hangs or fails:

EKS Cluster Creation: EKS cluster creation can take 15-20 minutes. Be patient. If it fails, check the AWS CloudFormation stack events for the EKS cluster.

IAM Permissions: Ensure your AWS credentials have sufficient permissions for all resources being created.

Resource Limits: Check if you've hit any AWS service limits in your region.

ALB not provisioned or Nginx not accessible:

AWS Load Balancer Controller: Verify that the AWS Load Balancer Controller pods are running correctly in the kube-system namespace (kubectl get pods -n kube-system | grep aws-load-balancer-controller).

IAM Service Account: Double-check that the IAM Service Account for the controller was created correctly and has the alb_ingress_controller_iam_policy_arn attached.

Service Annotations: Ensure the kubernetes_service for Nginx has the correct ALB annotations as specified in kubernetes.tf.

Security Groups: Verify that the security groups allow traffic on port 80 (or your application's port) from the ALB to the Fargate pods.

Contributing
Feel free to open issues or pull requests if you find any bugs or have suggestions for improvements.

License
This project is open-sourced under the MIT License. See the LICENSE file for more details.
