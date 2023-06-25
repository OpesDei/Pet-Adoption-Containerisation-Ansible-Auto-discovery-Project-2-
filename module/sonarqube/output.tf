# sonarqube public ip
output "sonarqube_ip" {
    value = aws_instance.sonarqube-server.public_ip
}
