resource "aws_ecs_task_definition" "app_task" {
  family                   = "my-app-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "mongodb"
      image     = var.mongodb_image
      essential = true
      portMappings = [
        {
          containerPort = 27017
          hostPort      = 27017
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "mongo-volume"
          containerPath = "/data/db"
        }
      ]
    },
    {
      name      = "nodejs"
      image     = var.nodejs_image
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])

  volume {
    name      = "mongo-volume"
    host_path = "/ecs/mongo-data"
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "node-mongo-service"
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "EC2"
  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
   # assign_public_ip = true
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
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
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
}

resource "aws_ecs_task_definition" "prometheus_grafana" {
  family                   = "monitoring-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
  {
    name      = "prometheus"
    image     = "prom/prometheus:latest"
    essential = true
    portMappings = [
      {
        containerPort = 9090
        hostPort      = 9090
        protocol      = "tcp"
      }
    ]
  },
  {
    name      = "grafana"
    image     = "grafana/grafana:latest"
    essential = true
    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }
    ]
  }
])


  volume {
    name      = "prometheus-data"
    host_path = "/ecs/prometheus-data"
  }
}

resource "aws_ecs_service" "prometheus_grafana" {
  name            = "prometheus-grafana"
  cluster         = var.cluster_name
  launch_type     = "EC2"
  task_definition = aws_ecs_task_definition.prometheus_grafana.arn
  desired_count   = 1

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    # assign_public_ip is only for FARGATE, omit for EC2
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.prometheus_tg.arn
    container_name   = "prometheus"
    container_port   = 9090
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana_tg.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener.prometheus_listener,
    aws_lb_listener.grafana_listener
  ]
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
  target_type = "ip"
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
  target_type = "ip"

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
  target_type = "ip"

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

resource "aws_autoscaling_group" "ecs" {
  desired_capacity     = 1
  max_size             = 2
  min_size             = 1
  vpc_zone_identifier  = var.private_subnet_ids
  target_group_arns    = var.target_group_arns
  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "ecs-instance"
    propagate_at_launch = true
  }
}
