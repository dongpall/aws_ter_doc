resource "aws_security_group" "sg" {
  name        = "${var.name}-sg"
  vpc_id      = var.vpc_id
  description = "${var.name}_instance_sg"

  ingress {
    from_port   = var.in_from_port
    to_port     = var.in_to_port
    protocol    = var.in_protocol
    cidr_blocks = var.in_cidr_blocks
  }

  egress {
    from_port   = var.e_from_port
    to_port     = var.e_to_port
    protocol    = var.e_protocol
    cidr_blocks = var.e_cidr_blocks
  }
}