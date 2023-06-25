# jenkins server public ip
output "jenkins_server_ip" {
    value = aws_instance.Jenkin_server.public_ip

}