output "cloud_front_destribution_domain_name" {
  value = aws_cloudfront_distribution.site.domain_name
}

output "domain_name" {
  value = aws_route53_record.sub_domain.name
}
