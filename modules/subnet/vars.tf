variable "vpc_id" {}
variable "subnet_cidr" {}
variable "subnet_az" {}
variable "is_public" {}
variable "alltags" {}

variable "private_or_public" {
  type = map(any)
  default = {
    true  = "public"
    false = "private"
  }
}

