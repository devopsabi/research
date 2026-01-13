module "acm_backend" {
  source      = "terraform-aws-modules/acm/aws"
  version     = "4.0.1"
  domain_name = "*.MY_DOMAIN"
  subject_alternative_names = [
    "*.MY_DOMAIN"
  ]
  zone_id             = data.aws_route53_zone.main.id
  validation_method   = "DNS"
  wait_for_validation = true
  tags = {
    Name = "${local.project}-${local.environment}-backend-validation"
  }
}

data "aws_route53_zone" "main" {
  name = "MY_DOMAIN." # Ensure the domain name ends with a dot

}
