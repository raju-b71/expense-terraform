resource "aws_security_group" "main" {
  name = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"
  vpc_id = var.vpc_id


  ingress {                                          #one is inboundport/any sg wii have inbound rules and outbound rules
    from_port        = var.app_port
    to_port          = var.app_port                  #0 to 0 is whole range
    protocol         = "TCP"                          #this stands for all traffic(-1)
    cidr_blocks      = var.server_app_port_sg_cidr
  }

  ingress {
    from_port        = 22                             # 22 is for server port
    to_port          = 22
    protocol         = "TCP"                           #one is outboundport
    cidr_blocks      = var.bastion_nodes             #for bastian (workstation)only we allow ssh access
  }
  ingress {
    from_port        = 9100                        #same way for prometheus
    to_port          = 9100
    protocol         = "TCP"
    cidr_blocks      = var.prometheus_nodes
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
}


resource "aws_launch_template" "main" {
  name          = "${var.component}-${var.env}"
  image_id      = data.aws_ami.ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]
}
resource "aws_autoscaling_group" "main" {
  desired_capacity   = var.min_capacity
  max_size           = var.max_capacity
  min_size           = var.min_capacity
  vpc_zone_identifier = var.subnets
  target_group_arns = [aws_lb_target_group.main.arn]

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "main" {
  name                   = "target-cpu"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}


resource "aws_lb_target_group" "main" {                                  #this is target group before giving listener
  name     = "${var.env}-${var.component}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  deregistration_delay = 15

  health_check {
    healthy_threshold = 2
    interval = 5
    path = "/health"
    port = var.app_port
    timeout = 2
    unhealthy_threshold = 2


  }
}

