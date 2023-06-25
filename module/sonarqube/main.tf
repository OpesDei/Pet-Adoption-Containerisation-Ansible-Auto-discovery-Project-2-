# creating sonarqube server for ec2 instance 
resource "aws_instance" "sonarqube-server" {
  ami                       = var.ami
  vpc_security_group_ids    = var.security_group
  instance_type             = var.instance_type2
  key_name                  = var.key_name
  subnet_id                 = var.subnet_id
  associate_public_ip_address = true
  user_data                  = local.sonarqube_user_data

  tags = {
    Name = var.tags
  }
}