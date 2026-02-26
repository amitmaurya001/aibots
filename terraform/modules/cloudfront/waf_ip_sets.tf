resource "aws_wafv2_ip_set" "ips_to_be_blocked" {
  provider = aws.nv

  name               = "ips-to-be-blocked"
  description        = "IPs to be blocked"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = []

  lifecycle {
    ignore_changes = [addresses]
  }
}

resource "aws_wafv2_ip_set" "ips6_to_be_blocked" {
  provider = aws.nv

  name               = "ips6-to-be-blocked"
  description        = "IPs6 to be blocked"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV6"
  addresses          = []

  lifecycle {
    ignore_changes = [addresses]
  }
}

resource "aws_wafv2_ip_set" "ips_to_be_allowed" {
  provider = aws.nv

  name               = "ips-to-be-allowed"
  description        = "IPs to be allowed"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.ips_to_be_allowed
}
