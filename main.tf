# VPC
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = var.vpc_cidr
  alltags  = var.alltags
}

resource "aws_key_pair" "terraform-key" {
  key_name   = "aws-key"
  public_key = file("../key_pair/aws-key.pub")
}

# Elastic IP
resource "aws_eip" "nat_eip_a" {
  depends_on = [module.igw]
  domain     = "vpc"
}

resource "aws_eip" "nat_eip_c" {
  depends_on = [module.igw]
  domain     = "vpc"
}

module "igw" {
  source = "./modules/igw"

  vpc_id = module.vpc.vpc_id

  alltags = var.alltags
}

# Public_subnet_a_rtb
module "pub_subnet_bastion_a" {
  source = "./modules/subnet"

  vpc_id      = module.vpc.vpc_id
  subnet_cidr = var.pub_subnet_a_cidr
  subnet_az   = data.aws_availability_zones.available.names["${var.subnet_az_a}"]
  is_public   = true

  alltags = var.alltags
}

module "nat_gateway_a" {
  source = "./modules/ng"

  eip_id        = aws_eip.nat_eip_a.id
  pub_subnet_id = module.pub_subnet_bastion_a.subnet_id
}

module "pub_rtb_a" {
  source = "./modules/pub_rtb"

  vpc_id    = module.vpc.vpc_id
  igw_id    = module.igw.igw_id
  subnet_id = module.pub_subnet_bastion_a.subnet_id

  alltags = var.alltags
}

# Public_subnet_c_rtb
module "pub_subnet_bastion_c" {
  source = "./modules/subnet"

  vpc_id      = module.vpc.vpc_id
  subnet_cidr = var.pub_subnet_c_cidr
  subnet_az   = data.aws_availability_zones.available.names["${var.subnet_az_c}"]
  is_public   = true

  alltags = var.alltags
}

module "nat_gateway_c" {
  source = "./modules/ng"

  eip_id        = aws_eip.nat_eip_c.id
  pub_subnet_id = module.pub_subnet_bastion_c.subnet_id
}

module "pub_rtb_c" {
  source = "./modules/pub_rtb"

  vpc_id    = module.vpc.vpc_id
  igw_id    = module.igw.igw_id
  subnet_id = module.pub_subnet_bastion_c.subnet_id

  alltags = var.alltags
}

# Private_subnet_a_rtb
module "pri_subnet_web_a" {
  source = "./modules/subnet"

  vpc_id      = module.vpc.vpc_id
  subnet_cidr = var.pri_subnet_a_cidr
  subnet_az   = data.aws_availability_zones.available.names["${var.subnet_az_a}"]
  is_public   = false

  alltags = var.alltags
}

module "network_interface_a" {
  source = "./modules/net_itf"

  subnet_id = module.pub_subnet_bastion_a.subnet_id
  sg_id     = [module.pri_sg_web_http.sg_id, module.pri_sg_web_ssh_a.sg_id, module.pri_sg_web_https.sg_id]

  alltags = var.alltags
}

module "pri_rtb_a" {
  source = "./modules/pri_rtb"

  vpc_id               = module.vpc.vpc_id
  network_interface_id = module.network_interface_a.network_interface_id
  subnet_id            = module.pri_subnet_web_a.subnet_id
  nat_gateway_id       = module.nat_gateway_a.nat_gateway_id

  alltags = var.alltags
}

# Private_subnet_c_rtb
module "pri_subnet_web_c" {
  source = "./modules/subnet"

  vpc_id      = module.vpc.vpc_id
  subnet_cidr = var.pri_subnet_c_cidr
  subnet_az   = data.aws_availability_zones.available.names["${var.subnet_az_c}"]
  is_public   = false

  alltags = var.alltags
}

module "network_interface_c" {
  source = "./modules/net_itf"

  subnet_id = module.pub_subnet_bastion_c.subnet_id
  sg_id     = [module.pri_sg_web_http.sg_id, module.pri_sg_web_ssh_c.sg_id, module.pri_sg_web_https.sg_id]

  alltags = var.alltags
}

module "pri_rtb_c" {
  source = "./modules/pri_rtb"

  vpc_id               = module.vpc.vpc_id
  network_interface_id = module.network_interface_c.network_interface_id
  subnet_id            = module.pri_subnet_web_c.subnet_id
  nat_gateway_id       = module.nat_gateway_c.nat_gateway_id

  alltags = var.alltags
}

# Public_SG

module "pub_sg_bastion" {
  source = "./modules/sg"
  name   = "bastion"
  vpc_id = module.vpc.vpc_id

  # ingress
  in_from_port   = 22
  in_to_port     = 22
  in_protocol    = "tcp"
  in_cidr_blocks = ["0.0.0.0/0"]

  # egress
  e_from_port   = 0
  e_to_port     = 0
  e_protocol    = "-1"
  e_cidr_blocks = ["0.0.0.0/0"]
}


# Private_SG

module "pri_sg_web_http" {
  source = "./modules/sg"
  name   = "web_http"
  vpc_id = module.vpc.vpc_id

  # ingress(https)
  in_from_port   = 80
  in_to_port     = 80
  in_protocol    = "tcp"
  in_cidr_blocks = ["0.0.0.0/0"]

  # egress
  e_from_port   = 0
  e_to_port     = 0
  e_protocol    = "-1"
  e_cidr_blocks = ["0.0.0.0/0"]
}

module "pri_sg_web_ssh_a" {
  source = "./modules/sg"
  name   = "web_a_ssh"
  vpc_id = module.vpc.vpc_id

  # ingress(https)
  in_from_port   = 22
  in_to_port     = 22
  in_protocol    = "tcp"
  in_cidr_blocks = ["${module.bastion_host_a.bastion_ip}/32"]

  # egress
  e_from_port   = 0
  e_to_port     = 0
  e_protocol    = "-1"
  e_cidr_blocks = ["0.0.0.0/0"]
}

module "pri_sg_web_ssh_c" {
  source = "./modules/sg"
  name   = "web_ssh_c"
  vpc_id = module.vpc.vpc_id

  # ingress(https)
  in_from_port   = 22
  in_to_port     = 22
  in_protocol    = "tcp"
  in_cidr_blocks = ["${module.bastion_host_c.bastion_ip}/32"]

  # egress
  e_from_port   = 0
  e_to_port     = 0
  e_protocol    = "-1"
  e_cidr_blocks = ["0.0.0.0/0"]
}

module "pri_sg_web_https" {
  source = "./modules/sg"
  name   = "web_https"
  vpc_id = module.vpc.vpc_id

  # ingress(https)
  in_from_port   = 443
  in_to_port     = 443
  in_protocol    = "tcp"
  in_cidr_blocks = ["0.0.0.0/0"]

  # egress
  e_from_port   = 0
  e_to_port     = 0
  e_protocol    = "-1"
  e_cidr_blocks = ["0.0.0.0/0"]
}


# ec2
module "web_server_a" {
  source = "./modules/ec2"

  ami             = var.web_server_ami
  instance_type   = var.web_instance_type
  security_groups = [module.pri_sg_web_ssh_a.sg_id, module.pri_sg_web_http.sg_id, module.pri_sg_web_https.sg_id]
  subnet_id       = module.pri_subnet_web_a.subnet_id
  key_name        = aws_key_pair.terraform-key.key_name

  name = "${var.web_name}-a"
}

module "bastion_host_a" {
  source = "./modules/ec2"

  ami             = var.bastion_ami
  instance_type   = var.bastion_instance_type
  security_groups = [module.pub_sg_bastion.sg_id]
  subnet_id       = module.pub_subnet_bastion_a.subnet_id
  key_name        = aws_key_pair.terraform-key.key_name

  name = "${var.bastion_name}-a"
}

module "web_server_c" {
  source = "./modules/ec2"

  ami             = var.web_server_ami
  instance_type   = var.web_instance_type
  security_groups = [module.pri_sg_web_ssh_c.sg_id, module.pri_sg_web_http.sg_id, module.pri_sg_web_https.sg_id]
  subnet_id       = module.pri_subnet_web_c.subnet_id
  key_name        = aws_key_pair.terraform-key.key_name

  name = "${var.web_name}-c"
}

module "bastion_host_c" {
  source = "./modules/ec2"

  ami             = var.bastion_ami
  instance_type   = var.bastion_instance_type
  security_groups = [module.pub_sg_bastion.sg_id]
  subnet_id       = module.pub_subnet_bastion_c.subnet_id
  key_name        = aws_key_pair.terraform-key.key_name

  name = "${var.bastion_name}-c"
}

# route53
data "aws_route53_zone" "my_domain" {
  name         = "juhyeok.net"
  private_zone = false
}


resource "aws_route53_record" "my_domain_alias" {
  zone_id = data.aws_route53_zone.my_domain.zone_id
  name    = "www.juhyeok.net"
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = false
  }
}




# ACM
resource "aws_acm_certificate" "web_acm_certificate" {
  domain_name       = "www.juhyeok.net"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "WebCertificate"
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.web_acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.my_domain.zone_id
}

resource "aws_acm_certificate_validation" "web_acm_validation" {
  certificate_arn         = aws_acm_certificate.web_acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

# application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.lb_sg.sg_id]
  subnets            = [module.pub_subnet_bastion_a.subnet_id, module.pub_subnet_bastion_c.subnet_id]

  depends_on = [aws_acm_certificate.web_acm_certificate]

  tags = {
    Name = "app_lb"
  }
}

resource "aws_lb_target_group" "alb_target" {
  name        = "alb-target"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  tags = {
    Name = "alb_target"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate_validation.web_acm_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target.arn
  }

}

resource "aws_lb_target_group_attachment" "alb_target_attach_a" {
  target_group_arn = aws_lb_target_group.alb_target.arn
  target_id        = module.web_server_a.instance_id
  port             = 80
  depends_on       = [aws_lb_listener.alb_listener]
}

resource "aws_lb_target_group_attachment" "alb_target_attach_c" {
  target_group_arn = aws_lb_target_group.alb_target.arn
  target_id        = module.web_server_c.instance_id
  port             = 80
  depends_on       = [aws_lb_listener.alb_listener]
}

module "lb_sg" {
  source = "./modules/sg"
  name   = "lb-sg"
  vpc_id = module.vpc.vpc_id

  # ingress(http)
  in_from_port   = 0
  in_to_port     = 0
  in_protocol    = "-1"
  in_cidr_blocks = ["0.0.0.0/0"]

  # egress
  e_from_port   = 0
  e_to_port     = 0
  e_protocol    = "-1"
  e_cidr_blocks = ["0.0.0.0/0"]
}