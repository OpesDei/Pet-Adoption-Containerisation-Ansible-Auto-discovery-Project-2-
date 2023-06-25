locals {
  name = "aad-eu2"
}

# provider "vault" {
#   token   = "s.KGqGspjsv4lE4M4YTTVc2KXj"
#   address = "https://thinkeod.com"
# }

module "vpc" {
  source                 = "./module/vpc"
  vpc_cidr               = "10.0.0.0/16"
  tag-vpc                = "${local.name}-vpc"
  public_subnet_1_cidr   = "10.0.1.0/24"
  az_1                   = "eu-west-1a"
  tag-Public_subnet_1    = "${local.name}-Public_subnet_1"
  public_subnet_2_cidr   = "10.0.2.0/24"
  az_2                   = "eu-west-1b"
  tag-Public_subnet_2    = "${local.name}-Public_subnet_2"
  private_subnet_1_cidr  = "10.0.3.0/24"
  tag-Private_subnet_1   = "${local.name}-Private_subnet_1"
  private_subnet_2_cidr  = "10.0.4.0/24"
  tag-Private_subnet_2   = "${local.name}-Private_subnet_2"
  tag-igw                = "${local.name}-igw"
  key_name               = "keypairs"
  keypair_path           = "~/Keypairs/pacpujpeu2.pub"
  tag-natgw              = "${local.name}-natgw"
  RT_cidr                = "0.0.0.0/0"
  tag-public_RT          = "${local.name}-public_RT"
  tag-private_RT         = "${local.name}-private_RT"
  port_ssh               = 22
  tag-Bastion-Ansible_SG = "${local.name}-Bastion-Ansible_SG"
  port_proxy             = 8080
  port_http              = 80
  port_https             = 443
  tag-Docker-SG          = "${local.name}-Docker-SG"
  tag-Jenkins_SG         = "${local.name}-Jenkins_SG"
  port_sonar             = 9000
  tag-Sonarqube_SG       = "${local.name}-Sonarqube_SG"
  port_proxy_nex         = 8081
  port_proxy_nex_2       = 8085
  tag-Nexus_SG           = "${local.name}-Nexus_SG"
  port_mysql             = 3306
  RT_cidr_2              = ["10.0.3.0/24", "10.0.4.0/24"]
  tag-MySQL-SG           = "${local.name}-MySQL-SG"
}

module "bastion" {
  source               = "./module/bastion"
  ami                  = "ami-00b1c9efd33fda707"
  instance_type        = "t2.micro"
  security-group       = [module.vpc.bastion-sg]
  key_name             = module.vpc.keypair-name
  subnetid             = module.vpc.public-subnet1
  private_keypair_path = "C"
  tags                 = "${local.name}-bastion-host"
}

module "ansible" {
  source               = "./module/ansible"
  ami                  = "ami-00b1c9efd33fda707"
  instance_type        = "t2.micro"
  security-group       = [module.vpc.bastion-sg]
  key_name             = module.vpc.keypair-name
  subnet_id            = module.vpc.public-subnet1
  private_keypair_path = "~/Keypairs/pacpujpeu2"
  tags                 = "${local.name}-ansible-host"
  stage-playbook       = "${path.root}/module/ansible/stage-playbook.yml"
  prod-playbook        = "${path.root}/module/ansible/prod-playbook.yml"
  stage-bash-script    = "${path.root}/module/ansible/stage-bash-script.sh"
  prod-bash-script     = "${path.root}/module/ansible/prod-bash-script.sh"
  stage-trigger        = "${path.root}/module/ansible/stage-trigger.yml"
  prod-trigger         = "${path.root}/module/ansible/prod-trigger.yml"
  password             = "${path.root}/module/ansible/password.yml"
  private-key          = "~/Keypairs/pacpujpeu2"
  nexus-ip             = module.nexus_server.nexus_public-ip
}

module "nexus_server" {
  source                 = "./module/nexus"
  ami                    = "ami-00b1c9efd33fda707"
  instance_type          = "t2.medium"
  vpc_security_group_ids = [module.vpc.nexus-sg]
  key_name               = module.vpc.keypair-name
  subnet_id              = module.vpc.public-subnet1
  nexus-server           = "${local.name}-nexus-server"
}

module "jenkins" {
  source               = "./module/jenkins"
  ami                  = "ami-00b1c9efd33fda707"
  instance_type        = "t3.medium"
  security-group       = [module.vpc.jenkin-sg]
  key_name             = module.vpc.keypair-name
  subnetid             = module.vpc.public-subnet1
  private_keypair_path = "~/Keypairs/pacpujpeu2"
  tags                 = "${local.name}-jenkin-server"
  nexus-ip             = module.nexus_server.nexus_public-ip
}

module "sonarqube" {
  source         = "./module/sonarqube"
  ami            = "ami-00b1c9efd33fda707"
  instance_type2 = "t2.medium"
  key_name       = module.vpc.keypair-name
  security_group = [module.vpc.sonarqube-sg]
  subnet_id      = module.vpc.public-subnet2
  tags           = "${local.name}-sonarqube-server"
}

module "asg-stage" {
  source              = "./module/asg-stage"
  stage-lt-name       = "${local.name}-stage-LT"
  ami-redhat-id       = "ami-013d87f7217614e10"
  instance_type       = "t2.medium"
  stage-lt-sg         = [module.vpc.docker-sg]
  keypair_name        = module.vpc.keypair-name
  stage-asg-name      = "${local.name}-stage-ASG"
  vpc-zone-identifier = [module.vpc.private-subnet1, module.vpc.private-subnet2]
  tg-arn              = [module.stage-lb.stage-tg-arn]
  asg-policy          = "${local.name}-stage-asg-policy"
  nexus-ip            = module.nexus_server.nexus_public-ip
  nr_key              = "eu01xx20f683825c611d81edb12afbed7d23NRAL"
}

module "asg-prod" {
  source              = "./module/asg-prod"
  prod-lt-name        = "${local.name}-prod-LT"
  ami-redhat-id       = "ami-013d87f7217614e10"
  instance_type       = "t2.medium"
  prod-lt-sg          = [module.vpc.docker-sg]
  keypair_name        = module.vpc.keypair-name
  prod-asg-name       = "${local.name}-prod-ASG"
  vpc-zone-identifier = [module.vpc.private-subnet1, module.vpc.private-subnet2]
  tg-arn              = [module.prod-high-availability.lb-arn]
  asg-policy          = "${local.name}-prod-asg-policy"
  nexus-ip            = module.nexus_server.nexus_public-ip
  nr_key              = "eu01xx39cb97fdfc64378971c3a3f94eda8bNRAL"
}

data "vault_generic_secret" "my-db-secret" {
  path = "secret/database"
}

# module "multi_az_rds" {
#   source                 = "./module/multi-az-rds"
#   name                   = "${local.name}-rds_db_subnet_group"
#   public-subnet          = [module.vpc.private-subnet1, module.vpc.private-subnet2]
#   password               = data.vault_generic_secret.my-db-secret.data["password"]
#   username               = data.vault_generic_secret.my-db-secret.data["username"]
#   vpc_security_group_ids = [module.vpc.rds-sg]
# }

# module "ssl-cert" {
#   source       = "./module/ssl-cert"
#   domain_name  = "thinkeod.com"
#   domain_name2 = "*.thinkeod.com"
# }

# module "route53" {
#   source            = "./module/route53"
#   domain-name       = "thinkeod.com"
#   stage_lb_dns_name = module.stage-lb.stage-lb-dns
#   prod_lb_dns_name  = module.prod-high-availability.prod-lb-dns
#   domain-name1      = "stage.thinkeod.com"
#   domain-name2      = "prod.thinkeod.com"
#   stage_lb_zoneid   = module.stage-lb.stage-zone-id
#   prod_lb_zoneid    = module.prod-high-availability.prod-lb-zone-id
# }

module "prod-high-availability" {
  source          = "./module/prod-high-availability"
  vpc             = module.vpc.vpc-id
  certificate     = module.ssl-cert.certificate_arn
  security_groups = [module.vpc.docker-sg]
  subnets         = [module.vpc.public-subnet1, module.vpc.public-subnet2]
  tags            = "${local.name}-alb"
}

module "stage-lb" {
  source          = "./module/loadbalancer-stage"
  vpc_id          = module.vpc.vpc-id
  certificate_arn = module.ssl-cert.certificate_arn
  security_groups = [module.vpc.docker-sg]
  subnets         = [module.vpc.public-subnet1, module.vpc.public-subnet2]
}  