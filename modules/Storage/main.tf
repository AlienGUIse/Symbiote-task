resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "rds-sg"
  vpc_id      = var.storage_vpc_id

  ingress {
    from_port   = 3306  
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.20.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS SG"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "rds-subnet-group"
  description = "rds-subnet-gropu"
  subnet_ids = var.network_private_subnets
}



resource "aws_db_instance" "postgres_database" {
  instance_class                        = var.db_instance_type
  allocated_storage                     = var.db_storage
  multi_az                              = false
  storage_type                          = "gp2"
  db_subnet_group_name                  = aws_db_subnet_group.db_subnet_group.name
  publicly_accessible                   = false
  vpc_security_group_ids                = [aws_security_group.rds_sg.id]
  storage_encrypted                     = false
  engine                                = "mysql"
  engine_version                        = "5.7"
  identifier                            = "test-database"
  name                                  = "Symbiote"
  username                              = var.db_username
  password                              = var.db_password
  deletion_protection                   = false
  skip_final_snapshot                   = true

  tags = {
    Name = "RDS"
  }
}


resource "aws_cloudwatch_log_group" "rds_log_group" {
  name              = "/rds/Symbiote"
  retention_in_days = "1"

  tags = {
    Name = "RDS Log Group"
  }
}