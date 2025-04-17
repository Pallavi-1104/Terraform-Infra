resource "aws_ecs_task_definition" "app_task" {
  family                   = "node-mongo-task"
  network_mode            = "bridge"
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
}
qwertyu
  volume {
    name = "mongo-volume"
    host_path {
  path = "/ecs/mongo-data"
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

resource "aws_ecs_task_definition" "prometheus_grafana" {
  family                   = "prometheus-grafana"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "prometheus",
      image     = "prom/prometheus",
      essential = true,
      portMappings = [
        {
          containerPort = 9090,
          hostPort      = 9090
        }
      ],
      mountPoints = [
        {
          sourceVolume  = "prometheus_config",
          containerPath = "/etc/prometheus"
        }
      ]
    },
    {
      name      = "grafana",
      image     = "grafana/grafana",
      essential = true,
      portMappings = [
        {
          containerPort = 3000,
          hostPort      = 3001
        }
      ]
    }
  ])

  volume {
    name = "prometheus_config"
    host_path {
      path = "/ecs/prometheus" # EC2 instances must have config file here
    }
  }
}

resource "aws_ecs_service" "prometheus_grafana" {
  name            = "prometheus-grafana"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.prometheus_grafana.arn
  desired_count   = 1
  launch_type     = "EC2"

  # Add more configuration here (load balancer, network, etc.)
}


resource "aws_lb" "monitoring_alb" {
  name               = "monitoring-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [var.security_group_id]
}

resource "aws_lb_target_group" "nodejs" {
  name        = "nodejs-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health" # Or your actual health endpoint
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}


resource "aws_lb_target_group" "prometheus_tg" {
  name     = "prometheus-tg"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"

  health_check {
  path                = "/"
  interval            = 30
  timeout             = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  matcher             = "200-399"
  }

}

resource "aws_lb_target_group" "grafana_tg" {
  name     = "grafana-tg"
  port     = 3001
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"

  health_check {
  path                = "/"
  interval            = 30
  timeout             = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  matcher             = "200-399"
  }

}

resource "aws_lb_listener" "prometheus_listener" {
  load_balancer_arn = aws_lb.monitoring_alb.arn
  port              = 9090
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus_tg.arn
  }
}

resource "aws_lb_listener" "grafana_listener" {
  load_balancer_arn = aws_lb.monitoring_alb.arn
  port              = 3001
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}

data "aws_ami" "ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.cluster_name}-sg"
  description = "ECS security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
