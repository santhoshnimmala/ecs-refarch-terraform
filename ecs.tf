resource "aws_ecs_cluster" "ecs-sample" {
  name = local.name
 
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.ecs-sample.name

  capacity_providers = [aws_ecs_capacity_provider.example.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.example.name
  }
}


resource "aws_ecs_capacity_provider" "example" {
  name = "capacity-provider-test"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs-auto.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 85
    }
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/frontend-container"
  tags = {
    "env"       = "ecs"
    
  }
}


resource "aws_ecs_task_definition" "service" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "public.ecr.aws/ubuntu/nginx:1.18-20.04_beta"
     cpu: 10,
      memory: 256,
      essential: true,
      portMappings: [
        {
          containerPort: 80
        }
      ],
      logConfiguration: {
        logDriver: "awslogs",
        options: { 
          awslogs-group : "/ecs/frontend-container",
          awslogs-region: "us-east-1"
        }
      }
     
    }])
}

resource "aws_ecs_service" "service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.ecs-sample.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = "first"
    container_port   = 80
  }
  # Optional: Allow external changes without Terraform plan difference(for example ASG)
  lifecycle {
    ignore_changes = [desired_count]
  }
  launch_type = "EC2"
  depends_on  = [aws_lb_listener.web-listener]
}


