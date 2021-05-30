variable module_ami_id {
  type        = string
  description = "AMI"
}

variable module_instance_type {
  type        = string
  description = "instance type"
}


variable computer_vpc_id {
  type        = string
  description = "Security Group VPC ID"
}


variable network_public_subnets {
  type        = list
  description = "ASG VPC Zones and ALB Target Group subnets"
}


variable asg_instance_min_size {
  type        = number
  description = "asg instance min size"
}

variable asg_instance_max_size {
  type        = number
  description = "asg instance max size"
}


variable asg_desired_size {
  type        = number
  description = "asg instance desired size"
}
