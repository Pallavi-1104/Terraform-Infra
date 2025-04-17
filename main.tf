terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

module "network" {
  source = "./modules/network"
  # Add any required network module input variables here, e.g.:
  # cidr_block = var.vpc_cidr
}

module "iam" {
  source = "./modules/iam"
  # Add IAM-specific input variables if needed
}

module "ecs_cluster" {
  source       = "./modules/ecs"
  cluster_name = "my-ecs-cluster"

  nodejs_image       = var.nodejs_image
  mongodb_image      = var.mongodb_image
  instance_type      = var.instance_type
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_id             = module.network.vpc_id
  subnet_ids         = [module.network.subnet_public_1_id, module.network.subnet_public_2_id]
  security_group_id  = module.network.ecs_instance_sg_id
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn
  key_name           = var.key_name
  region             = var.region
}



