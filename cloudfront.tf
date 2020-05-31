# CloudFrontの配信元の識別子
locals {
  s3_origin_id = "s3-origin-${var.site_domain}"
}

# PrivateなS3 Bucketにアクセスするためにオリジンアクセスアイデンティティを利用する
resource "aws_cloudfront_origin_access_identity" "site" {
  comment = var.site_domain
}

# CloudFrontのディストリビューション設定
resource "aws_cloudfront_distribution" "site" {
  tags = {
    name = var.tag
  }
  origin {

    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.site.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.site_domain
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_200"

  # とりあえずCloudFrontドメインの証明書を利用
  //viewer_certificate {
  //  cloudfront_default_certificate = true
  //}


  aliases = [var.site_domain]

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.acm_cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}