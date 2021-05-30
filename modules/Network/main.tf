terraform {
    required_version = ">= 0.12"
}

data "aws_availability_zones" "available_zone" {
  state = "available"
}


resource "aws_vpc" "main_vpc" {
    cidr_block = var.module_vpc_cidr
    tags = {
        Name = "main"
    }
}


resource "aws_subnet" "public_sb" {
    count = 2
    vpc_id = aws_vpc.main_vpc.id 
    cidr_block = var.module_public_cidr[count.index]
    availability_zone = data.aws_availability_zones.available_zone.names[count.index]

    tags = {
        Name = "public_sb${count.index + 1}"
    }
}

resource "aws_subnet" "private_sb" {
    count = 2
    vpc_id = aws_vpc.main_vpc.id 
    cidr_block = var.module_private_cidr[count.index]
    availability_zone = data.aws_availability_zones.available_zone.names[count.index]

    tags = {
        Name = "private_sb${count.index + 1}"
    }
}


resource "aws_internet_gateway" "vpc_igw" {
    vpc_id = aws_vpc.main_vpc.id 

    tags = {
        Name = "VPC Internet Gateway"
    }
}


resource "aws_eip" "ng_eip" {
    vpc = true
}


resource "aws_nat_gateway" "vpc_ng" {
    allocation_id = aws_eip.ng_eip.id
    subnet_id     = aws_subnet.public_sb.0.id

    tags = {
        Name = "NAT Gateway"
    }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.vpc_igw.id
  }

  tags = {
      Name = "Public Route Table"
  }
}


resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main_vpc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.vpc_ng.id
    }
   
   tags = {
       Name = "Private Route Table"
   }
}


resource "aws_route_table_association" "public_assoc" {
    count = 2
    subnet_id = aws_subnet.public_sb.*.id[count.index]
    route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table_association" "private_assoc" {
    count = 2
    subnet_id = aws_subnet.private_sb.*.id[count.index]
    route_table_id = aws_route_table.private_rt.id
}


