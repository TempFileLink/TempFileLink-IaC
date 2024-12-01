module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc.name
  cidr = var.vpc.cidr

  azs                     = ["us-east-1a", "us-east-1b"]
  public_subnets          = [cidrsubnet(var.vpc.cidr, 8, 1), cidrsubnet(var.vpc.cidr, 8, 2)]
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true

  database_subnets                       = [cidrsubnet(var.vpc.cidr, 8, 3), cidrsubnet(var.vpc.cidr, 8, 4)]
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_support = true

  tags = local.common_tags
}
