module "ecs_cluster" {
  source            = "./modules/ecs"
  cluster_name      = "my-ecs-cluster"
  nodejs_image      = "node:18"
  mongodb_image     = "mongo:5"
  instance_type     = "t2.micro"
  desired_capacity  = 1
  max_size          = 1
  min_size          = 1
  region            = "us-east-1"
}
