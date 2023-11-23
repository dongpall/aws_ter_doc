resource "aws_route53_zone" "dns_zone" {
  name = var.domain_name
  comment = "web Route53 Zone"
}

resource "aws_route53_record" "web_record" {
  zone_id = aws_route53_zone.dns_zone.zone_id
  name = "www"
  type = "A"
  ttl = "300"
  records = var.ip_addresses
}
