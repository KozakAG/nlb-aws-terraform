

provider "aws" {
  region = "eu-west-2"
}


data "aws_availability_zones" "available" {}

resource "aws_key_pair" "my_keypair" {
  key_name   = "my_keypair"
  public_key = file("C:/Users/Asgard/.aws/my_keypair.pub")

}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

output "vpc_id" {
  value       = aws_default_vpc.default.id
  description = "VPC id."
 
  sensitive = false
}

#--------------------------------------------------------------
resource "aws_security_group" "web" {
  name = "Dynamic Security Group"
  vpc_id      = aws_default_vpc.default.id
  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Dynamic SecurityGroup"
  }
}

output "aws_security_group" {
  value       = aws_security_group.web.id
  description = "aws_security_group id."
  # Setting an output value as sensitive prevents Terraform from showing its value in plan and apply.
  sensitive = false
}

#--------------------------------------------------------------

resource "aws_launch_configuration" "web" {

  name_prefix     = "WebServer-Highly-Available-LC-"
  key_name      = aws_key_pair.my_keypair.key_name
  image_id        = "ami-02d3bcccaacf4e182"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web.id]
  user_data       = file("user_data.ps1")

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "web" {
  name                 = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]

  target_group_arns = [aws_lb_target_group.web.arn]
  health_check_type = "ELB"



  lifecycle {
    create_before_destroy = true
  
  }
}



resource "aws_lb" "web" {
  name               = "WebServer-LB"
  
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]

  enable_cross_zone_load_balancing = true

  tags = {
    Environment = "production"
  }

}

resource "aws_lb_listener" "web" {

  load_balancer_arn = aws_lb.web.arn

  protocol = "TCP"
  port     = 80

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}


resource "aws_lb_target_group" "web" {
  name     = "tf-lb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id      = aws_default_vpc.default.id

  depends_on = [
    aws_lb.web
  ]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

#--------------------------------------------------
output "web_loadbalancer_url" {
  value = aws_lb.web.dns_name
}
