output "ansible" {
  value = module.ansible.ansible-ip
}
output "sonarqube" {
  value = module.sonarqube.sonarqube_ip
}
output "bastion" {
  value = module.bastion.bastion
}
output "nexus" {
  value = module.nexus_server.nexus_public-ip
}
output "jenkins" {
  value = module.jenkins.jenkins_server_ip
}
output "prod-loadbalancer-" {
  value = module.prod-high-availability.prod-lb-dns
}
output "stage-loadbalancer" {
  value = module.stage-lb.stage-lb-dns
}
