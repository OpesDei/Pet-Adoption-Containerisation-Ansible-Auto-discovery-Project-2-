# creating Bastian Host for ec2 instance target servers
resource "aws_instance" "Bastion-Host" {
  ami                       = var.ami
  vpc_security_group_ids    = var.security-group
  instance_type             = var.instance_type
  key_name                  = var.key_name
  subnet_id                 = var.subnetid
  associate_public_ip_address = true
  user_data                 = <<-EOF
  #!/bin/bash
  echo "${var.private_keypair_path}" >> /home/ec2-user/aadpeut2 
  chmod 400  /home/ec2-user/aadpeut2
  sudo hostnamectl set-hostname Bastion
  EOF 
  tags = {
    Name = var.tags
  }
}