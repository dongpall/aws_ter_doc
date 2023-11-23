resource "aws_nat_gateway" "ng" {
  allocation_id = var.eip_id
  subnet_id = var.pub_subnet_id
}