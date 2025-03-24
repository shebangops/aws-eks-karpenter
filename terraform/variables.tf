######## General ########
variable "region" {
  type = string
  description = "AWS region"
}
variable "environment" {
  type = string
  description = "Environment name"
}
variable "aws_profile_name" {
  type = string
  description = "AWS profile name"
}
variable "cluster_name" {
  type = string
  description = "The name of the cluster"
}
######## Network ########
variable "cidr" {
  type = string
  description = "CIDR block for the VPC"
}
variable "private_subnets" {
  type = list(string)
  description = "Private subnets"
}
variable "public_subnets" {
  type = list(string)
  description = "Public subnets"
}
variable "azs" {
  type = list(string)
  description = "Availability zones"
}
######## Tags #########
variable "default_tags" {
  type = map(string)
  description = "Default tags"
}
