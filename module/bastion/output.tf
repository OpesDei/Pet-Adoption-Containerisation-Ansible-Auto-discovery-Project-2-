output "bastion" {
  value = aws_instance.Bastion-Host.public_ip
}