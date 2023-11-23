resource "aws_subnet" "subnet" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet_cidr
  availability_zone = var.subnet_az
  map_public_ip_on_launch = var.is_public

  tags = {
    Name = "${var.alltags}-subnet-${var.private_or_public[var.is_public]}"
  }
}