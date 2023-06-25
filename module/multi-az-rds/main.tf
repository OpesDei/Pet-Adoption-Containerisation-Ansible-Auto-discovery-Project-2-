#create db subnet group
resource "aws_db_subnet_group" "rds_db_subnet_group" {
  name       = var.name
  subnet_ids = var.public-subnet
}

#create RDS(database)
resource "aws_db_instance" "multi_az_rds" {
  allocated_storage           = 10
  db_subnet_group_name        = aws_db_subnet_group.rds_db_subnet_group.name
  engine                      = "mysql"
  engine_version              = "5.7"
  identifier                  = "mysql-rds"
  instance_class              = "db.t2.micro"
 # multi_az                    = true
  db_name                     = "petclinic"
  password                    = var.password
  username                    = var.username
  storage_type                = "gp2"
  vpc_security_group_ids      = var.vpc_security_group_ids
  publicly_accessible         = false
  skip_final_snapshot         = true
  parameter_group_name        = "default.mysql5.7"
}