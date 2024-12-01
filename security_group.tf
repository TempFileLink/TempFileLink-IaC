module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.web_server_sg_name
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.service_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]

  tags = local.common_tags
}

module "service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.service_sg_name
  description = "Security group for ECS service"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]

  tags = local.common_tags
}

module "alb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.alb_sg_name
  description = "Security group for application load balancer with HTTP and HTTPS ports open to the internet"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]

  egress_rules = ["all-all"]

  tags = local.common_tags
}

module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.rds_sg_name
  description = "Security group for database"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]

  tags = local.common_tags
}
