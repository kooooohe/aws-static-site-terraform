resource "aws_acm_certificate" "acm_cert" {
  provider                  = aws.us-east-1
  domain_name               = var.root_domain
  subject_alternative_names = ["*.${var.root_domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    name = var.tag
  }
}

// resource "aws_route53_record" "acm_cert" {
//   # 2つを登録するのでcount=2
//   count   = 2
//   zone_id = data.aws_route53_zone.root_domain.id
//   name    = "${lookup(aws_acm_certificate.acm_cert.domain_validation_options[count.index], "resource_record_name")}"
//   type    = "${lookup(aws_acm_certificate.acm_cert.domain_validation_options[count.index], "resource_record_type")}"
//   records = ["${lookup(aws_acm_certificate.acm_cert.domain_validation_options[count.index], "resource_record_value")}"]
//   ttl     = 60
// }
resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.root_domain.id
  name    = aws_acm_certificate.acm_cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.acm_cert.domain_validation_options.0.resource_record_type
  records = [aws_acm_certificate.acm_cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_route53_record" "cert_validation_alt" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.root_domain.id
  name    = aws_acm_certificate.acm_cert.domain_validation_options.1.resource_record_name
  type    = aws_acm_certificate.acm_cert.domain_validation_options.1.resource_record_type
  records = [aws_acm_certificate.acm_cert.domain_validation_options.1.resource_record_value]
  ttl     = 60
}



resource "aws_acm_certificate_validation" "acm_cert" {
  //depends_on = [aws_acm_certificate.acm_cert]
  provider = aws.us-east-1
  certificate_arn         = aws_acm_certificate.acm_cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn, aws_route53_record.cert_validation_alt.fqdn]
}