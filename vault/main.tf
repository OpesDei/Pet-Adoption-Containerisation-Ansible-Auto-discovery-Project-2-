provider "aws" {
  region    = var.region
  profile   = var.profile
}

#EC2 keypair
resource "aws_key_pair" "vault-keypair" {
  key_name = "vault-keypair"
  public_key = file(var.public-key)
}

#Security group for Vault
resource "aws_security_group" "Vault-SG" {
  name          = "Vault-SG"
  description   = "Allow TLS inbound traffic"

  ingress {
    description      = "http access"
    from_port        = var.port_http
    to_port          = var.port_http
    protocol         = var.sg-protocol
    cidr_blocks      = [var.all_cidr]
  }

  ingress {
    description      = "https access"
    from_port        = var.port_https
    to_port          = var.port_https
    protocol         = var.sg-protocol
    cidr_blocks      = [var.all_cidr]
  }

    ingress {
    description      = "vault access"
    from_port        = var.port_vault
    to_port          = var.port_vault
    protocol         = var.sg-protocol
    cidr_blocks      = [var.all_cidr]
  }

    ingress {
    description      = "ssh access"
    from_port        = var.port_ssh
    to_port          = var.port_ssh
    protocol         = var.sg-protocol
    cidr_blocks      = [var.all_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.all_cidr]
  }

  tags = {
    Name = "Vault-SG"
  }
}

#EC2 for Terraform Vault
resource "aws_instance" "vault" {
  ami                       = var.vault-ami
  instance_type             = var.instance_type
  vpc_security_group_ids    = [aws_security_group.Vault-SG.id]
  key_name                  = aws_key_pair.vault-keypair.key_name
  iam_instance_profile      = aws_iam_instance_profile.vault-kms-unseal.id
  associate_public_ip_address = true
  user_data                 = local.vault_user_data
  
  tags = {
    Name = "vault-server"
  }
}

# KMS key
resource "aws_kms_key" "vault" {
  description             = "vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "Vault-KMS-unseal"
  }
}

# Route 53 and Record 
data "aws_route53_zone" "vault" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "vault_record" {
  zone_id = data.aws_route53_zone.vault.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.vault.public_ip]
}