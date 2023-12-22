resource "aws_instance" "instance" {
  ami             = var.ami
  instance_type   = var.instance_type
  security_groups = var.security_groups
  subnet_id       = var.subnet_id
  monitoring      = false
  key_name        = var.key_name

  tags = {
    Name = "${var.name}_instance"
  }
}