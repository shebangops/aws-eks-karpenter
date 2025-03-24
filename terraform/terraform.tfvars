########################## General ##########################
region           = "eu-central-1"
environment      = "test"
aws_profile_name = "opsfleet"
cluster_name     = "test-karpenter"

########################## Network ##########################
cidr            = "172.21.0.0/16"
public_subnets  = ["172.21.0.0/24", "172.21.1.0/24", "172.21.2.0/24"]
private_subnets = ["172.21.3.0/24", "172.21.4.0/24", "172.21.5.0/24"]
azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

########################## Tags ##########################
default_tags = {
  Terraform   = "true"
  Environment = "test"
}
