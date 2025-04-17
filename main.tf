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

#module "ecs_cluster" {
 # source             = "./modules/ecs"
  #ecs_cluster_id    = var.ecs_cluster_id

module "ecs_cluster" {
  source       = "./modules/ecs"
  cluster_name = "my-ecs-cluster" 
}

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

module "network" {
  source = "./modules/network" # adjust path as needed
  # include variables like cidr_block, etc., if needed
}

module "iam" {
  source = "./modules/iam"
  # include role configuration vars here
}




