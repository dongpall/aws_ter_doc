resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.alltags}-rtb-public"
  }
}

resource "aws_route" "Pub_route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
  }

resource "aws_route_table_association" "put_rtb_association" {
  subnet_id = var.subnet_id
  route_table_id = aws_route_table.route_table.id
}