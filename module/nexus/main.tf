# creating nexus server 
resource "aws_instance" "Nexus-server" {
  ami                       = var.ami
  vpc_security_group_ids    = var.vpc_security_group_ids
  instance_type             = var.instance_type
  key_name                  = var.key_name
  subnet_id                 = var.subnet_id
  associate_public_ip_address = true
  user_data = local.nexus_user_data

  tags = {
    Name = var.nexus-server
  }
}