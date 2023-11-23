# VPC
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = var.vpc_cidr
  alltags = var.alltags
}

resource "aws_key_pair" "terraform-key" {
  key_name = "aws-key"
  public_key = "${file("../key_pair/aws-key.pub")}"
}

# Elastic IP
resource "aws_eip" "nat_eip" {
  depends_on = [ module.igw ]
  domain = "vpc"
}


# Public_subnet_rtb
module "pub_subnet_bastion" {
  source = "./modules/subnet"

  vpc_id = module.vpc.vpc_id
  subnet_cidr = var.pub_subnet_cidr
  subnet_az = data.aws_availability_zones.available.names["${var.subnet_az}"]
  is_public = true

  alltags = var.alltags
}

module "igw" {
  source = "./modules/igw"

  vpc_id = module.vpc.vpc_id

  alltags = var.alltags
}

module "nat_gateway" {
  source = "./modules/ng"

  eip_id = aws_eip.nat_eip.id
  pub_subnet_id = module.pub_subnet_bastion.subnet_id
}

module "pub_rtb" {
  source = "./modules/pub_rtb"

  vpc_id = module.vpc.vpc_id
  igw_id = module.igw.igw_id
  subnet_id = module.pub_subnet_bastion.subnet_id

  alltags = var.alltags
}

module "pub_sg_bastion" {
  source = "./modules/sg"
  name = "bastion"
  vpc_id = module.vpc.vpc_id
  
  # ingress
  in_from_port = 22
  in_to_port = 22
  in_protocol = "tcp"
  in_cidr_blocks = ["0.0.0.0/0"]

  # egress
  e_from_port = 0
  e_to_port = 0
  e_protocol = "-1"
  e_cidr_blocks = ["0.0.0.0/0"]
}


# Private_subnet_rtb
module "pri_subnet_web" {
  source = "./modules/subnet"

  vpc_id = module.vpc.vpc_id
  subnet_cidr = var.pri_subnet_cidr
  subnet_az = data.aws_availability_zones.available.names["${var.subnet_az}"]
  is_public = true

  alltags = var.alltags
}

module "network_interface" {
  source = "./modules/net_itf"

  subnet_id = module.pub_subnet_bastion.subnet_id
  sg_id = [module.pri_sg_web_http.sg_id, module.pri_sg_web_ssh.sg_id, module.pri_sg_web_https.sg_id]

  alltags = var.alltags
}

module "pri_rtb" {
  source = "./modules/pri_rtb"

  vpc_id = module.vpc.vpc_id
  network_interface_id = module.network_interface.network_interface_id
  subnet_id = module.pri_subnet_web.subnet_id
  nat_gateway_id = module.nat_gateway.nat_gateway_id

  alltags = var.alltags
}

module "pri_sg_web_http" {
  source = "./modules/sg"
  name = "web_http"
  vpc_id = module.vpc.vpc_id

  # ingress(https)
  in_from_port = 80
  in_to_port = 80
  in_protocol = "tcp"
  in_cidr_blocks = ["0.0.0.0/0"]

  # egress
  e_from_port = 0
  e_to_port = 0
  e_protocol = "-1"
  e_cidr_blocks = ["0.0.0.0/0"]
}

module "pri_sg_web_ssh" {
  source = "./modules/sg"
  name = "web_ssh"
  vpc_id = module.vpc.vpc_id
  
  # ingress(https)
  in_from_port = 22
  in_to_port = 22
  in_protocol = "tcp"
  in_cidr_blocks = ["${module.bastion_host.bastion_ip}/32"]

  # egress
  e_from_port = 0
  e_to_port = 0
  e_protocol = "-1"
  e_cidr_blocks = ["0.0.0.0/0"]
}

module "pri_sg_web_https" {
  source = "./modules/sg"
  name = "web_https"
  vpc_id = module.vpc.vpc_id

  # ingress(https)
  in_from_port = 443
  in_to_port = 443
  in_protocol = "tcp"
  in_cidr_blocks = ["0.0.0.0/0"]

  # egress
  e_from_port = 0
  e_to_port = 0
  e_protocol = "tcp"
  e_cidr_blocks = ["0.0.0.0/0"]
}


# ec2
module "web_server" {
  source = "./modules/ec2"

  ami = var.web_server_ami
  instance_type = var.web_instance_type
  security_groups = [module.pri_sg_web_ssh.sg_id, module.pri_sg_web_http.sg_id, module.pri_sg_web_https.sg_id]
  subnet_id = module.pri_subnet_web.subnet_id
  key_name = aws_key_pair.terraform-key.key_name

  name = var.web_name
}

module "bastion_host" {
  source = "./modules/ec2"

  ami = var.bastion_ami
  instance_type = var.bastion_instance_type
  security_groups = [module.pub_sg_bastion.sg_id]
  subnet_id = module.pub_subnet_bastion.subnet_id
  key_name = aws_key_pair.terraform-key.key_name

  name = var.bastion_name
}

