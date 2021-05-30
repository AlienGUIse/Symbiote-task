terraform {
    required_version = ">= 0.12"
}


resource "aws_key_pair" "instance_key" {
    key_name = "instance_key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqQ5Qtip0UYCmj6DRnyxDiVseslZzS8N6bapgEg08FLVIpl3ZeUPMePQgmOltMMSqvsfVyxgeACD8FPSymfp63B6ZBA9R/+0XhlVKVVUeJ/mqrEjzvcQMKfxHK2Je3L0Opk4uotVAzSHb1O2nfE/reiDyis+i+NNBRyM9I02z0iUH5QZezjhsMtSEv+2TGlpsBukRv4aQoef5e7d0CnrnHy8U511hoqS9xorUN/Fy28eUFoH0pP4OazySczZ9L1hlarAMualeDpied3Zxizan3XPgEtgXkp4S8yIAcEvbZ8fAxW3JRuaVp70CUFjAhwbtS8L85ArdwMMd26xJxGcYH5LvgF6tWnOcwLeQ3EmGhXWRN8pRehrPU2KyB1yDud560q7AfK44Wu4b/iEVZ2jmww6rLkhi3aIY6h1p474+kwqxhCHmZMS4JytRynGPbSF0qkAB2SN160epWaqmZgl517F9839q2wKfoNj98dlcP3zJRIoSLDM8yMVr6h3YOnfk= weiwang@wei"
}


resource "aws_launch_template" "asg_launch_temp" {
    name = "ASG-launch-template"
    image_id          = var.module_ami_id
    instance_type = var.module_instance_type
    #security_group_names = [aws_security_group.instance_sg.id]
    network_interfaces {
        associate_public_ip_address = true
        security_groups = [aws_security_group.instance_sg.id]
    }
    monitoring {
        enabled = true
    }
    key_name = aws_key_pair.instance_key.id
    user_data = filebase64("././config/user_data.sh")
    tag_specifications {
        resource_type = "instance"

        tags = {
            Name = "Symbiote"
            Env = "Prod"
        }
    }
}


resource "aws_security_group" "instance_sg" {
    name        = "ASG_instance_sg"
    description = "ASG launch config SG"
    vpc_id      = var.computer_vpc_id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "instance SG"
    }
}




resource "aws_autoscaling_group" "asg" {
    name = "instance_asg"
    launch_template {
        id      = aws_launch_template.asg_launch_temp.id
        version = "$Latest"
    }
    min_size = var.asg_instance_min_size
    max_size = var.asg_instance_max_size
    desired_capacity = var.asg_desired_size
    health_check_type = "ELB"
    health_check_grace_period = 60
    force_delete              = true
    vpc_zone_identifier = var.network_public_subnets
}



resource "aws_autoscaling_attachment" "asg_attachment_elb" {
    autoscaling_group_name = aws_autoscaling_group.asg.id
    alb_target_group_arn = aws_alb_target_group.alb_target_group.arn
}



resource "aws_alb_target_group" "alb_target_group" {
    name                 = "alb-target-group"
    port                 = 80
    protocol             = "HTTP"
    vpc_id               = var.computer_vpc_id
    target_type          = "instance"

    health_check {
        healthy_threshold   = "3"
        interval            = "5"
        protocol            = "HTTP"
        matcher             = "200"
        timeout             = "3"
        path                = "/index.html"
        unhealthy_threshold = "3"
    }

    tags = {
        Name = "Target Group for ALB"
    }
}

data "aws_instances" "asg_instance" {
    filter {
        name = "tag:Name"
        values = ["Symbiote"]
    }

    instance_state_names = ["running"]
    depends_on = [aws_autoscaling_group.asg]
}


resource "aws_alb_target_group_attachment" "alb_tg_attachment" {
  count = var.asg_desired_size
  target_group_arn = aws_alb_target_group.alb_target_group.arn
  target_id        = data.aws_instances.asg_instance.ids[count.index]
  port             = 80
  depends_on = [aws_autoscaling_group.asg]
}



resource "aws_security_group" "alb_sg" {
    name        = "alb_sg"
    description = "ALB SG"
    vpc_id      = var.computer_vpc_id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "ALB SG"
    }
}



resource "aws_alb" "alb" {
    name            = "alb"
    idle_timeout    = 120
    internal        = false
    security_groups = [aws_security_group.alb_sg.id]
    subnets = var.network_public_subnets
    enable_deletion_protection = false

    tags = {
        Name = "Application Load Balancer"
    }
}


resource "aws_alb_listener" "alb_listen_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    type             = "forward"
  }
}


resource "aws_cloudwatch_log_group" "ec2_log_group" {
  name              = "/ec2/Symbiote"
  retention_in_days = "1"

  tags = {
    Name = "EC2 Log Group"
  }
}