data "aws_availability_zones" "available" {
    state = "available"
}

variable "vpc_cidr" {
  description = "VPC CIDR : x.x.x.x/x"
  default = "10.2.0.0/16"
}

variable "alltags" {
  description = "My_alltags"
  default = "Juhyeok"
}

variable "pub_subnet_cidr" {
  description = "Pub Subnet CIDR : x.x.x.x/x"
  default = "10.2.50.0/24"
}

variable "subnet_az" {
  description = "Public Subnet AZ : 0(A) ~ 3(D)"
  default = 0
}

variable "pri_subnet_cidr" {
  description = "Pri Subnet CIDR : x.x.x.x/x"
  default = "10.2.150.0/24"
}

variable "web_server_ami" {
  description = "AMI : Amazon Linux 2 AMI - Kernel 5.10, SSD Volume Type"
  default = "ami-0a0064415cdedc552"
}

variable "web_instance_type" {
  description = "Instance Type : t2.micro"
  default = "t2.micro"
}

variable "web_key_name" {
  description = "Key_name"
  default = "../key_pair/terraform_pjec_key.pem"
}

variable "web_name" {
  description = "This name"
  default = "web_ec2"
}

variable "bastion_name" {
  description = "This name"
  default = "bastion_ec2"
}

variable "bastion_ami" {
  description = "AMI : Amazon Linux 2 AMI - Kernel 5.10, SSD Volume Type"
  default = "ami-0a0064415cdedc552"
}

variable "bastion_instance_type" {
  description = "Instance Type : t2.micro"
  default = "t2.micro"
}

variable "bastion_key_name" {
  description = "key_name"
  default = "../key_pair/terraform_pjec_key.pem"
}

variable "domain_name" {
  description = "Domain name"
  default = "Hyeok26h314324342"
}