# creating Ec2 for Ansible Server
resource "aws_instance" "Ansible_Host" {
  ami                         = var.ami 
  instance_type                = var.instance_type
  vpc_security_group_ids       = var.security-group
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true 
  user_data                   = local.ansible_user_data 
  
  tags = {
    Name = var.tags
  }
}