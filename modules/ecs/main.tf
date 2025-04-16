resource "aws_ecs_task_definition" "app_task" {
  family                   = "node-mongo-task"
  network_mode            = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                     = "256"
  memory                  = "512"

  container_definitions = jsonencode([
    {
      name      = "mongo"
      image     = "mongo:latest"
      memory    = 256
      portMappings = [{ containerPort = 27017 }]
      mountPoints = [{
        sourceVolume  = "mongo_data",
        containerPath = "/data/db"
      }]
    },
    {
      name      = "nodejs"
      image     = "node:18"
      memory    = 256
      portMappings = [{ containerPort = 3000 }]
      environment = [
        {
          name  = "MONGO_URL"
          value = "mongodb://localhost:27017/mydb"
        }
      ]
    }
  ])

  volume {
    name = "mongo_data"
    host_path {
      path = "/ecs/mongo-data"
    }
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "node-mongo-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "EC2"
  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "ecs-launch-template-"
  image_id      = data.aws_ami.ecs.id
  instance_type = var.instance_type
  user_data     = base64encode(templatefile("${path.module}/userdata.sh", {
    cluster_name = var.cluster_name
  }))

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }

  key_name = var.key_name
  security_group_names = [aws_security_group.ecs_sg.name]
}
