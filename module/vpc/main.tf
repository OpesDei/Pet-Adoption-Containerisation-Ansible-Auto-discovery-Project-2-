# Create Custom vpc
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.tag-vpc
  }
}

# Creating public subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = var.az_1
  tags = {
    Name = var.tag-Public_subnet_1
  }
}

# Creating public subnet 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_2_cidr
  availability_zone = var.az_2
  tags = {
    Name = var.tag-Public_subnet_2
  }
}

# Creating private subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.az_1

  tags = {
    Name = var.tag-Private_subnet_1
  }
}

# Creating private subnet 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.az_2

  tags = {
    Name = var.tag-Private_subnet_2
  }
}

# Creating internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.tag-igw
  }
}

# keypair
resource "aws_key_pair" "keypair" {
  key_name   = var.key_name
  public_key = file(var.keypair_path)
}

#elastic IP
resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.igw]
  domain      = "vpc"
}

# create the NAT Gateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.public_subnet_2.id

  tags = {
    Name = var.tag-natgw
  }
}

#create public route table
resource "aws_route_table" "public-RT" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.RT_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.tag-public_RT
  }
}

#create private route table
resource "aws_route_table" "private_RT" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.RT_cidr
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = var.tag-private_RT
  }
}

#create public_subnet_1_association
resource "aws_route_table_association" "public_subnet_1_Asso" {
  route_table_id = aws_route_table.public-RT.id
  subnet_id = aws_subnet.public_subnet_1.id
}

#create public_subnet_2_association
resource "aws_route_table_association" "public_subnet_2_Asso" {
  route_table_id = aws_route_table.public-RT.id
  subnet_id = aws_subnet.public_subnet_2.id
}

#create private_subnet_1_association
resource "aws_route_table_association" "private-subnet-1-Asso" {
  route_table_id = aws_route_table.private_RT.id
  subnet_id = aws_subnet.private_subnet_1.id
}

#create private_subnet_2_association
resource "aws_route_table_association" "private-subnet-2-Asso" {
  route_table_id = aws_route_table.private_RT.id
  subnet_id = aws_subnet.private_subnet_2.id
}

# Security Group for Bastion Host and Ansible Server
resource "aws_security_group" "Bastion_Ansible_SG" {
  name        = "Bastion_Ansible"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow ssh access"
    from_port        = var.port_ssh
    to_port          = var.port_ssh
    protocol         = "tcp"
    cidr_blocks      = [var.RT_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.RT_cidr]
  }

  tags = {
    Name = var.tag-Bastion-Ansible_SG
  }
}

# Security Group for Docker Server
resource "aws_security_group" "Docker_SG" {
  name        = "Docker"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow ssh access"
    from_port        = var.port_ssh
    to_port          = var.port_ssh
    protocol         = "tcp"
    cidr_blocks      = [var.RT_cidr]
  }

  ingress {
    description      = "Allow proxy access"
    from_port        = var.port_proxy
    to_port          = var.port_proxy
    protocol         = "tcp"
    cidr_blocks      = [var.RT_cidr]
  }

  ingress {
    description      = "Allow http access"
    from_port        = var.port_http
    to_port          = var.port_http
    protocol         = "tcp"
    cidr_blocks      = [var.RT_cidr]
  }

  ingress {
    description      = "Allow https access"
    from_port        = var.port_https
    to_port          = var.port_https
    protocol         = "tcp"
    cidr_blocks      = [var.RT_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.RT_cidr]
  }

  tags = {
    Name = var.tag-Docker-SG
  }
}

# Security Group for Jenkins Server
resource "aws_security_group" "Jenkins_SG" {
  name        = "Jenkins"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow ssh access"
    from_port        = var.port_ssh
    to_port          = var.port_ssh
    protocol         = "tcp"
    cidr_blocks      = [var.RT_cidr]
  }

  ingress {
    description      = "Allow proxy access"
    from_port        = var.port_proxy
    to_port          = var.port_proxy
    protocol         = "tcp"
    cidr_blocks      = [var.RT_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.RT_cidr]
  }

  tags = {
    Name = var.tag-Jenkins_SG
  }
}

# Security Group for Sonarqube Server
resource "aws_security_group" "Sonarqube_SG" {
  name        = "Sonarqube"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow ssh access"
    from_port        = var.port_ssh
    to_port          = var.port_ssh
    protocol         = "tcp"
    cidr_blocks      = [var.RT_cidr]
  }

  ingress {
    description      = "Allow sonarqube access"
    from_port        = var.port_sonar
    to_port          = var.port_sonar
    protocol         = "tcp"
    cidr_blocks      = [var.RT_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.RT_cidr]
  }

  tags = {
    Name = var.tag-Sonarqube_SG
  }
}

# Security Group for Nexus Server
resource "aws_security_group" "Nexus_SG" {
  name        = "Nexus"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow ssh access"
    from_port        = var.port_ssh
    to_port          = var.port_ssh
    protocol         = "tcp"
    cidr_blocks      = [var.RT_cidr]
  }

  ingress {
    description      = "Allow nexus access"
    from_port        = var.port_proxy_nex
    to_port          = var.port_proxy_nex
    protocol         = "tcp"
    cidr_blocks      = [var.RT_cidr]
  }

   ingress {
    description      = "Allow nexus access"
    from_port        = var.port_proxy_nex_2
    to_port          = var.port_proxy_nex_2
    protocol         = "tcp"
    cidr_blocks      = [var.RT_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.RT_cidr]
  }

  tags = {
    Name = var.tag-Nexus_SG
  }
}

# Security Group for MySQL RDS Database
resource "aws_security_group" "MySQL_RDS_SG" {
  name        = "MySQL_RDS"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow MySQL access"
    from_port        = var.port_mysql
    to_port          = var.port_mysql
    protocol         = "tcp"
    cidr_blocks      = var.RT_cidr_2
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.RT_cidr]
  }

  tags = {
    Name = var.tag-MySQL-SG
  }
}