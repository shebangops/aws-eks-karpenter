This is a brief description on how to deploy Karpertner on AWS EKS using Terraform and test different configurations of Gavitron/x86 instances.

## Prerequisites
- terraform
- aws cli
- helm

## Install prerequisites

In order to install Terraform with Homebrew, run the following command:

```bash
brew install terraform
brew install helm
brew install awscli
```

## Configure AWS cli
```bash
aws configure --profile opsfleet
```
Output of this command is:

```
AWS Access Key ID [None]:<yourAccessKey>
AWS Secret Access Key [None]:<yourSecretKey>
Default region name [None]: eu-central-1
Default output format [None]: json
```

## Create S3 bucket to store Terraform state
```bash
aws s3api create-bucket --bucket karpertner-terraform-state --region eu-central-1 --profile opsfleet
```
## Directory Structure
```
.
├── README.md
├── pods
│   ├── amd64-pod.yaml
│   └── arm64-pod.yaml
└── terraform
    ├── eks-cluster-karpenter.tf
    ├── karpenter-helm-config.tf
    ├── providers.tf
    ├── terraform.tfvars
    ├── variables.tf
    └── vpc.tf
```

Populate in provider.tf with the following values:
```
terraform {
  backend "s3" {
    profile = "opsfleet"
    bucket = "karpertner-terraform-state"
    key    = "test"
    region = "eu-central-1"
    use_lockfile = true
  }
}
```
In the terraform directory of this repository, run the following command:

```
terraform init # Initialize Terraform
terraform plan # Plan the deployment
terraform apply # Apply the deployment
```

## Test different configurations of Gavitron/x86 instances

In order to test Gavitron Node type instance, run the following command:

```
kubectl apply -f pods/arm64-pod.yaml
```
In few seconds  Karpertner will start provisioning a Gavitron Node type instance.

Watch provisioning of a Gavitron Node type instance:
```
kubectl get nodes -l kubernetes.io/arch=arm64
```

In order to test x86 Node type instance, run the following command:

```
kubectl apply -f pods/amd64-pod.yaml
```
In few minutes  Karpertner will start provisioning an x86 Node type instance.

Watch provisioning of a x86 Node type instance:
```
kubectl get nodes -l kubernetes.io/arch=amd64
```

## Cleanup

Delete the pod and in after few minutes Karpertner will remove x86/Gavitron Node.
```
kubectl delete -f pods/arm64-pod.yaml
or
kubectl delete -f pods/amd64-pod.yaml
```
Run Terrafrom destroy
```bash
terraform destroy
```
