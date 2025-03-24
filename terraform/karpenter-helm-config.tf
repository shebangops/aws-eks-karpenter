resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "karpenter"
  create_namespace = true

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.3.3"

  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "replicas"
    value = 1
  }

  set {
    name  = "nodeSelector.karpenter\\.sh/controller"
    value = "true"
    type  = "string"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.iam_role_arn
  }

  set {
    name  = "settings.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "settings.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "settings.interruptionQueue"
    value = module.karpenter.queue_name
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "1Gi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "1Gi"
  }

  depends_on = [ module.eks, module.karpenter ]
}

resource "kubectl_manifest" "karpenter_nodepool" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: spot-ondemand
  annotations:
    kubernetes.io/description: "NodePool for provisioning spot/on-demand capacity"
spec:
  template:
    spec:
      requirements:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot", "on-demand"]
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64", "arm64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["t", "c"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["2"]
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default
YAML
depends_on = [ helm_release.karpenter ]
}

resource "kubectl_manifest" "karpenter_ec2_nodeclass" {
  yaml_body = <<YAML
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: default
  annotations:
    kubernetes.io/description: "General purpose EC2NodeClass for running Amazon Linux 2 nodes"
spec:
  role: ${var.cluster_name}
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery:  ${var.cluster_name}
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery:  ${var.cluster_name}
  amiSelectorTerms:
    - alias: al2023@latest
YAML
depends_on = [ helm_release.karpenter ]
}
