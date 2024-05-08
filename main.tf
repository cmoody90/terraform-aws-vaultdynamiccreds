provider "aws" {
  region = "us-west-2"
}

# Create a new VPC
resource "aws_vpc" "new_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyNewVPC"
  }
}

# Internet Gateway for the new VPC
resource "aws_internet_gateway" "new_igw" {
  vpc_id = aws_vpc.new_vpc.id
}

# Route Table for the new VPC
resource "aws_route_table" "new_rt" {
  vpc_id = aws_vpc.new_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new_igw.id
  }
}

# Create Subnets
resource "aws_subnet" "new_subnet_1" {
  vpc_id            = aws_vpc.new_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "MyNewSubnet1"
  }
}

resource "aws_subnet" "new_subnet_2" {
  vpc_id            = aws_vpc.new_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "MyNewSubnet2"
  }
}

# Associate Subnets with Route Table
resource "aws_route_table_association" "new_rta1" {
  subnet_id      = aws_subnet.new_subnet_1.id
  route_table_id = aws_route_table.new_rt.id
}

resource "aws_route_table_association" "new_rta2" {
  subnet_id      = aws_subnet.new_subnet_2.id
  route_table_id = aws_route_table.new_rt.id
}

# Security Group for RDS
resource "aws_security_group" "new_sg" {
  name        = "new_rds_sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.new_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance
resource "aws_db_instance" "new_rds_instance" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.36"
  instance_class       = "db.t3.micro"
  db_name              = "mydatabase"
  username             = "dbuser"
  password             = "dbpassword"
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.new_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.new_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = true
}

# DB Subnet Group
resource "aws_db_subnet_group" "new_db_subnet_group" {
  name       = "my-new-db-subnet-group"
  subnet_ids = [aws_subnet.new_subnet_1.id, aws_subnet.new_subnet_2.id]
  tags = {
    Name = "MyDBSubnetGroup"
  }
}
