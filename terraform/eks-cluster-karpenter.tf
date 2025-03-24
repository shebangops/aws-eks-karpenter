########################## EKS Cluster ##########################
module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "20.34.0"
  cluster_name                             = var.cluster_name
  cluster_version                          = "1.31"
  vpc_id                                   = module.vpc.vpc_id
  enable_irsa                              = true
  subnet_ids                               = module.vpc.private_subnets
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API"
  tags                                     = var.default_tags
  create_cloudwatch_log_group              = false
  cluster_enabled_log_types                = []

  eks_managed_node_groups = {
    karpenter = {
      ami_type       = "AL2_x86_64"
      instance_types = ["t2.medium"]

      min_size     = 1
      max_size     = 1
      desired_size = 1
      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
      }
    }
  }
  node_security_group_tags = merge(var.default_tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.cluster_name
  })
}



module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name          = module.eks.cluster_name
  enable_v1_permissions = true

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix = false
  node_iam_role_name            = var.cluster_name
  enable_pod_identity           = false
  enable_irsa                   = true
  irsa_oidc_provider_arn        = module.eks.oidc_provider_arn
  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  tags = var.default_tags
}
