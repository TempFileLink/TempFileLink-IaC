module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = var.ecs_cluster_name

  tags = local.common_tags
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = var.ecs_capacity_provider_name

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = module.ecs_cluster.cluster_name

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family             = var.task.name
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_execution_task_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  cpu                = 256

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = var.task.container_name
      image     = var.task.image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_service_name
  cluster         = module.ecs_cluster.cluster_id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1

  network_configuration {
    subnets         = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
    security_groups = [module.service_sg.security_group_id]
  }

  force_new_deployment = true

  placement_constraints {
    type = "distinctInstance"
  }

  triggers = {
    redeployment = timestamp()
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = var.task.container_name
    container_port   = 80
  }

  depends_on = [aws_autoscaling_group.ecs_asg]
}
