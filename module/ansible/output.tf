output "ansible-ip" {
    value = aws_instance.Ansible_Host.public_ip
}
