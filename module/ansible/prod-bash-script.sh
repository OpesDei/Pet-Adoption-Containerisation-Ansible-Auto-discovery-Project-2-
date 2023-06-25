#!/bin/bash
# This script automatically update ansible host inventory

AWSBIN='/usr/local/bin/aws'
awsDiscovery() {
        \$AWSBIN ec2 describe-instances --filters Name=tag:aws:autoscaling:groupName,Values=aad-eu2-prod-ASG \\
                --query Reservations[*].Instances[*].NetworkInterfaces[*].{PrivateIpAddresses:PrivateIpAddress} > /etc/ansible/prod-ips.list
        }
inventoryUpdate() {
        echo > /etc/ansible/hosts
        echo "[webservers]" > /etc/ansible/prod-hosts
        for instance in \`cat /etc/ansible/prod-ips.list\`
        do
                ssh-keyscan -H \$instance >> ~/.ssh/known_hosts
echo "\$instance ansible_user=ec2-user ansible_ssh_private_key_file=/etc/ansible/key.pem" >> /etc/ansible/prod-hosts
       done
}
instanceUpdate() {
  sleep 30
  ansible-playbook prod-trigger.yml
  sleep 30
}

awsDiscovery
inventoryUpdate
instanceUpdate