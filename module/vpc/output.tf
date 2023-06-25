output "vpc-id" {
  value = aws_vpc.vpc.id
}
output "public-subnet1" {
  value = aws_subnet.public_subnet_1.id
}
output "public-subnet2" {
  value = aws_subnet.public_subnet_2.id
}
output "private-subnet1" {
  value = aws_subnet.private_subnet_1.id
}
output "private-subnet2" {
  value = aws_subnet.private_subnet_2.id
}
output "bastion-sg" {
  value = aws_security_group.Bastion_Ansible_SG.id
}
output "jenkin-sg" {
  value = aws_security_group.Jenkins_SG.id
}
output "nexus-sg" {
  value = aws_security_group.Nexus_SG.id
}
output "sonarqube-sg" {
  value = aws_security_group.Sonarqube_SG.id
}
output "docker-sg" {
  value = aws_security_group.Docker_SG.id
}
output "rds-sg" {
  value = aws_security_group.MySQL_RDS_SG.id
}
output "keypair-name" {
  value = aws_key_pair.keypair.key_name
}
output "keypair-id" {
  value = aws_key_pair.keypair.id
}