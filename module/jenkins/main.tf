resource "aws_instance" "Jenkin_server" {
  ami                       = var.ami
  vpc_security_group_ids    = var.security-group
  instance_type             = var.instance_type
  key_name                  = var.key_name
  subnet_id                 =  var.subnetid
  associate_public_ip_address = true
  user_data                 = local.jenkins_user_data
  tags = {
    Name = var.tags
  }
}