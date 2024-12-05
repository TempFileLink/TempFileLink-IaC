resource "aws_acm_certificate" "cert" {
  count             = var.acm_certificate_domain_name != null ? 1 : 0
  domain_name       = var.acm_certificate_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}
