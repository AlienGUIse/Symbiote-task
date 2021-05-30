variable storage_vpc_id {
  type        = string
  description = "Main VPC cidr"
}


variable network_private_subnets {
  type = list
  description = "RDS Subnets"
}


variable db_instance_type {
  type = string
  description = "RDS instance type"
}


variable db_storage {
  type = string
  description = "RDS instance storage"
}


variable db_username {
  type = string 
  description = "RDS database username"
}


variable db_password {
  type = string
  description = "RDS database password"
}