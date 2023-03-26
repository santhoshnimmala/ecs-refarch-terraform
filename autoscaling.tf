locals {

  name = "ecs-cluster"

  user_data = <<-EOT
    #!/bin/bash
    cat <<'EOF' >> /etc/ecs/ecs.config
    ECS_CLUSTER=${local.name}
    ECS_LOGLEVEL=debug
    EOF
  EOT

}


resource "aws_autoscaling_group" "ecs-auto" {
  name                      = "foobar3-terraform-test"
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = [aws_subnet.publicsub1.id, aws_subnet.publicsub2.id]
  protect_from_scale_in     = true

  timeouts {
    delete = "15m"
  }


}

 

resource "aws_launch_configuration" "as_conf" {
  name_prefix                 = "ecs-launch"
  image_id                    = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ecs_service_role.name
  user_data                   = base64encode(local.user_data)
  security_groups             = [aws_security_group.ec2-sg.id]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "ec2-sg" {
  name        = "allow-all-ec2"
  description = "allow all"
  vpc_id      = aws_vpc.ecs-vpc.id
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

  tags = {
    Name = "terraform-bot"
  }
}
