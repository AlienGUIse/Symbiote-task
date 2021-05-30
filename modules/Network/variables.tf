variable module_vpc_cidr {
  type        = string
  description = "Main VPC cidr"
}

variable module_public_cidr {
  type        = list
  description = "public cidr"
}

variable module_private_cidr {
  type        = list
  description = "private cidr"
}



