module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier          = var.rds.database_identifier
  db_name             = var.rds.database_name
  engine              = "postgres"
  engine_version      = "16.3"
  family              = "postgres16"
  instance_class      = "db.t4g.micro"
  allocated_storage   = 20
  publicly_accessible = true

  username                    = var.rds.db_user
  password                    = var.rds.db_pass
  manage_master_user_password = false

  vpc_security_group_ids = [module.rds_sg.security_group_id]
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  multi_az               = false

  tags = local.common_tags
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.bucket_name

  lifecycle_rule = [
    {
      id      = "cleanup_rule"
      enabled = true

      expiration = {
        days = 1
      }

      tags = {
        expiry = "true"
      }
    }
  ]

  tags = local.common_tags
}

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.ecr_repository_name

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 5 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 5
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.common_tags
}
