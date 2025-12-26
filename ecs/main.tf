module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "app-cluster"

}


# IAM Roles for ECS

resource "aws_iam_role" "ecs_execution" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ALB SG

resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = module.networking.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ECS TASK SG

resource "aws_security_group" "ecs_task" {
  name   = "ecs-task-sg"
  vpc_id = module.networking.vpc.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Application LB


resource "aws_lb" "this" {
  name               = "app-alb"
  load_balancer_type = "application"
  subnets            = module.networking.vpc.public_subnets
  security_groups    = [aws_security_group.alb.id]
}

# Target Group on IP mode, port 8080

resource "aws_lb_target_group" "this" {
  name        = "app-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc.vpc_id
  target_type = "ip"

  health_check {
    path    = "/"
    port = 8080
    matcher = "200-399"
  }
}


# ALB Listner HTTP → HTTPS Redirect
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}




# test target group

resource "aws_lb_target_group" "test_tg" {
  name        = "test-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc.vpc_id
  target_type = "ip"

  health_check {
    path    = "/"
    port = 8080
    matcher = "200-399"
  }
}


# HTTPS → ECS

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn  = "arn:aws:acm:us-east-1:${var.accid}:certificate/af935db1-e93a-465e-9ca8-3668a70413a1"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}


# ECS Task Definition (Port 8080)

resource "aws_ecs_task_definition" "this" {
  family                   = "app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"] #
  cpu                      = "256"
  memory                   = "256"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "${var.accid}.dkr.ecr.us-east-1.amazonaws.com/aa-docker-images@sha256:f1acd7f10831badbc43fe0eee1e05a9d3b83006185e4a560a29e4c3b6e096461"

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
}


# ECS Service

resource "aws_ecs_service" "this" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 2

  network_configuration {
    subnets         = module.networking.vpc.private_subnets
    security_groups = [aws_security_group.ecs_task.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "app"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.https]
}


/*

service app-service was unable to place a task because no container instance met all of its requirements. The reason for failure is No Container Instances were found in your cluster. For more information, see the Troubleshooting section of the Amazon ECS Developer Guide

ECS tried to place your task, but:

❌ No EC2 instances are:

running and

joined to the ECS cluster and

marked as ACTIVE

An ECS cluster alone does nothing.
You must provide capacity.

*/

# Fetch the latest ECS-Optimized AMI
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
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

resource "aws_iam_role_policy_attachment" "ecs_managed_instances" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSInstanceRolePolicyForManagedInstances"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_container_service" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}



locals {
  ecs_cluster_name = "app-cluster"
  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${local.ecs_cluster_name} >> /etc/ecs/ecs.config
EOF
  )
}


# Launch template

resource "aws_launch_template" "ecs" {
  name_prefix   = "ecs-lt-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = "t3.micro"
  key_name = "ec2-user"

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = local.user_data

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp3"
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.alb.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-instance"
    }
  }
}

# ASG

resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = module.networking.vpc.private_subnets
  desired_capacity    = 3
  max_size            = 5
  min_size            = 1

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}
