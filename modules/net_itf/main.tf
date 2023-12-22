resource "aws_network_interface" "network_interface" {
  subnet_id         = var.subnet_id
  source_dest_check = false
  security_groups   = var.sg_id

  tags = {
    Name = "${var.alltags}-net_interface"
  }
}