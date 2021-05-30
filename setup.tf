#Deploy Network resoucese
module "Network" {
  source              = "./modules/Network"
  module_vpc_cidr     = "10.20.0.0/16"
  module_public_cidr  = ["10.20.1.0/24", "10.20.2.0/24"]
  module_private_cidr = ["10.20.11.0/24", "10.20.12.0/24"]
}

#Deploy Compute resoucese
module "Compute" {
  source                 = "./modules/Compute"
  module_ami_id          = "ami-0186908e2fdeea8f3"
  module_instance_type   = "t2.micro"
  asg_instance_min_size  = 1
  asg_instance_max_size  = 2
  asg_desired_size       = 2
  computer_vpc_id        = module.Network.module_vpc_id
  network_public_subnets = [module.Network.module_public_sb.0, module.Network.module_public_sb.1]
}

#Deploy Storage resoucese
module "Storage" {
  source                  = "./modules/Storage"
  storage_vpc_id          = module.Network.module_vpc_id
  network_private_subnets = [module.Network.module_private_sb.0, module.Network.module_private_sb.1]
  db_instance_type        = "db.t2.micro"
  db_storage              = "20"
  db_username             = "wwang"
  db_password             = "changeMe123!"
}