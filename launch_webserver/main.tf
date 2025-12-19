module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}


resource "aws_instance" "apache-instance" {
  count = 1
  ami   = "ami-0f9c27b471bdcd702"
  instance_type = "t2.micro"
  key_name = "my-ec2-key"
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.allow_ssh.id}","${aws_security_group.allow_443.id}"]
  subnet_id     = module.networking.vpc.public_subnets[0]
  user_data = file("cloud-init.yaml")
  tags = {
    Name = "Abhishek Alevoor"
    team = "dev"
    service = "Webserver"
  }
}


resource "aws_security_group" "allow_ssh" {
name = "allow-all-sg"
vpc_id = module.networking.vpc.vpc_id
ingress {
    cidr_blocks = [
      "${var.my_ip}"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }
// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

// SSM needs 443 to if I use private subnet
resource "aws_security_group" "allow_443" {
name = "allow-all-443-sg"
vpc_id = module.networking.vpc.vpc_id
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 443
    to_port = 443
    protocol = "tcp"
  }

  ingress {
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  from_port = 80
      to_port = 80
      protocol = "tcp"
  }

  ingress {
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  from_port = 8081
      to_port = 8081
      protocol = "tcp"
  }

// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}


### SETTING UP ALB


resource "aws_lb" "application-lb" {
    name            = "web-alb"
    internal        = false
    ip_address_type     = "ipv4"
    load_balancer_type = "application"
    security_groups = ["${aws_security_group.allow_443.id}"]
    subnets = [
          module.networking.vpc.public_subnets[0],
          module.networking.vpc.public_subnets[1],
                
                ]
    tags = {
        Name = "web-alb"
    }
}


resource "aws_lb_target_group" "target-group" {
    health_check {
        interval            = 10
        path                = "/"
        protocol            = "HTTP"
        timeout             = 5
        healthy_threshold   = 5
        unhealthy_threshold = 2
    }
    name          = "web-tg"
    port          = 80
    protocol      = "HTTP"
    target_type   = "instance"
    vpc_id = module.networking.vpc.vpc_id
}


resource "aws_lb_listener" "alb-listener" {
    load_balancer_arn          = aws_lb.application-lb.arn
    port                       = 80
    protocol                   = "HTTP"
    default_action {
        target_group_arn         = aws_lb_target_group.target-group.arn
        type                     = "forward"
    }
}



resource "aws_lb_target_group_attachment" "ec2_attach" {
    count = length(aws_instance.apache-instance)
    target_group_arn = aws_lb_target_group.target-group.arn
    target_id        = aws_instance.apache-instance[count.index].id
}
