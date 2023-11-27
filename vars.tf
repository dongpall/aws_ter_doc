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

variable "pub_subnet_a_cidr" {
  description = "Pub Subnet CIDR : x.x.x.x/x"
  default = "10.2.50.0/24"
}

variable "pub_subnet_c_cidr" {
  description = "Pub Subnet CIDR : x.x.x.x/x"
  default = "10.2.100.0/24"
}

variable "subnet_az_a" {
  description = "Subnet AZ : 0(A) ~ 3(D)"
  default = 0
}

variable "subnet_az_c" {
  description = "Subnet AZ : 0(A) ~ 3(D)"
  default = 2
}

variable "pri_subnet_a_cidr" {
  description = "Pri Subnet CIDR : x.x.x.x/x"
  default = "10.2.75.0/24"
}

variable "pri_subnet_c_cidr" {
  description = "Pri Subnet CIDR : x.x.x.x/x"
  default = "10.2.125.0/24"
}

variable "web_server_ami" {
  description = "AMI : Amazon Linux 2 AMI - Kernel 5.10, SSD Volume Type"
  default = "ami-0a0064415cdedc552"
}

variable "web_instance_type" {
  description = "Instance Type : t2.nano"
  default = "t2.nano"
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
  description = "Instance Type : t2.nano"
  default = "t2.nano"
}

variable "bastion_key_name" {
  description = "key_name"
  default = "../key_pair/terraform_pjec_key.pem"
}
