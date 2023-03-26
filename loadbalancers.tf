# This security group defines who/where is allowed to access the ECS hosts directly.
# By default we're just allowing access from the load balancer.  If you want to SSH
# into the hosts, or expose non-load balanced services you can open their ports here.


resource "aws_security_group" "lb" {
  name   = "allow-all-lb"
  vpc_id = aws_vpc.ecs-vpc.id
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
    "env"       = "dev"
    "created" = "terraform"
  }
}


resource "aws_lb" "ecs-lb" {
  name               = "ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [aws_subnet.privatesub1.id,aws_subnet.privatesub2.id]


  tags = {
    "env"       = "dev"
    "created" = "terraform"
  }
}



resource "aws_lb_target_group" "lb_target_group" {
  name        = "ecs-target-group"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.ecs-vpc.id
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }

}


resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_lb.ecs-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}


resource "aws_security_group" "ecs-sg" {
  name        = "allow_all_from_outside"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.ecs-vpc.id

  ingress {
    description      = "anyport form outside"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}