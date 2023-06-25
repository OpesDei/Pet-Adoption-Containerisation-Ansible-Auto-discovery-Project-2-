#!/bin/bash
# update and upgrade yum packages, install yum-utils, config manager and docker
sudo yum update -y
sudo yum upgrade -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y

#This configuration file will allow docker communicate with nexus repo over HTTP connection
sudo cat <<EOT>> /etc/docker/daemon.json
{
  "insecure-registries" : ["${var1}:8085"]
}
EOT

#Enable and start docker engine and assign ec2-user to docker group
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

#Install New relic
echo "license_key: ${var2}" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y --nobest
sudo hostnamectl set-hostname stage-instance