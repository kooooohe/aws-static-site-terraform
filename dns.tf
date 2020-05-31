data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}

resource "aws_route53_zone" "sub_domain" {
  name = var.site_domain
  tags = {
    name = var.tag
  }
}

resource "aws_route53_record" "root_domain" {
  depends_on      = [aws_route53_zone.sub_domain]
  allow_overwrite = true
  name            = var.site_domain
  ttl             = 30
  type            = "NS"
  zone_id         = data.aws_route53_zone.root_domain.zone_id

  records = [
    aws_route53_zone.sub_domain.name_servers.0,
    aws_route53_zone.sub_domain.name_servers.1,
    aws_route53_zone.sub_domain.name_servers.2,
    aws_route53_zone.sub_domain.name_servers.3,
  ]
}

resource "aws_route53_record" "sub_domain" {
  zone_id = aws_route53_zone.sub_domain.zone_id
  name    = aws_route53_zone.sub_domain.name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
