resource "aws_key_pair" "developer" {
  key_name   = "developer-key"
  public_key = file("${path.module}/misc/kowan.pub")
}

resource "aws_launch_template" "ecs_lt" {
  name_prefix   = var.ec2.instance_name
  image_id      = var.ec2.ami
  instance_type = var.ec2.instance_type

  key_name = aws_key_pair.developer.key_name

  vpc_security_group_ids = [module.web_server_sg.security_group_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_lt_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = "my-ecs-instance"
      },
      local.common_tags
    )
  }

  tags = local.common_tags

  user_data = base64encode(templatefile("${path.module}/misc/ecs.sh", { ecs_cluster_name = var.ecs_cluster_name }))
}

resource "aws_iam_instance_profile" "ecs_lt_instance_profile" {
  name = "my-ecs-lt-instance-profile"
  role = aws_iam_role.ec2role.name
}

resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = aws_launch_template.ecs_lt.latest_version
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}
