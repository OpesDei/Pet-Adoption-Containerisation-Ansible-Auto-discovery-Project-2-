locals {
  vault_user_data = <<-EOF
#!/bin/bash
sudo apt update
sudo wget https://releases.hashicorp.com/consul/1.7.3/consul_1.7.3_linux_amd64.zip
sudo apt install unzip -y
sudo unzip consul_1.7.3_linux_amd64.zip
sudo mv consul /usr/bin/
sudo cat <<EOT>> /etc/systemd/system/consul.service
[Unit]
Description=Consul 
Documentation=https://www.consul.io/

[Service]
ExecStart=/usr/bin/consul agent -server -ui -data-dir=/temp/consul -bootstrap-expect=1 -node=vault -bind=$(hostname -i) -config-dir=/etc/consul.d/ 
ExecReload=/bin/kill -HUP $MAINPID 
LimitNOFILE=65536 

[Install]
WantedBy=multi-user.target
EOT

sudo mkdir /etc/consul.d
sudo cat <<EOT>> /etc/consul.d/ui.json
{
    "addresses":{
    "http": "0.0.0.0"
    }
}
EOT

sudo systemctl daemon-reload
sudo systemctl start consul
sudo systemctl enable consul
sudo apt update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo apt-get install certbot -y
sudo certbot certonly --standalone -d thinkeod.com --email eodinvsltd@gmail.com --agree-tos --non-interactive
sudo wget https://releases.hashicorp.com/vault/1.5.0/vault_1.5.0_linux_amd64.zip
sudo unzip vault_1.5.0_linux_amd64.zip
sudo mv vault /usr/bin/
sudo mkdir /etc/vault/
sudo cat <<EOT>> /etc/vault/config.hcl
storage "consul" {
        address = "127.0.0.1:8500"
        path ="vault/"
}
listener "tcp"{
          address = "0.0.0.0:443"
          tls_disable = 0
          tls_cert_file = "/etc/letsencrypt/live/thinkeod.com/fullchain.pem"
          tls_key_file = "/etc/letsencrypt/live/thinkeod.com/privkey.pem"
}
seal "awskms" {
  region     = "${var.aws_region}"
  kms_key_id = "${aws_kms_key.vault.id}"
}
ui = true
EOT

sudo cat <<EOT>> /etc/systemd/system/vault.service
[Unit]
Description=Vault
Documentation=https://www.vault.io/

[Service]
ExecStart=/usr/bin/vault server -config=/etc/vault/config.hcl
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload
export VAULT_ADDR="https://thinkeod.com:443"
cat << EOT > /etc/profile.d/vault.sh
export VAULT_ADDR="https://thinkeod.com:443"
export VAULT_SKIP_VERIFY=true
EOT
vault -autocomplete-install
complete -C /usr/bin/vault vault
sudo systemctl start vault
sudo systemctl enable vault
EOF
}