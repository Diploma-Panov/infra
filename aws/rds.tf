resource "aws_db_instance" "auth_db" {
  identifier        = "auth-db-instance"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  db_name              = "auth_service_database"
  username          = "authdbuser"
  password          = random_password.rds_auth.result
  vpc_security_group_ids = [
    module.vpc.default_security_group_id,
    aws_security_group.managed_services_sg.id
  ]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  publicly_accessible    = false
  skip_final_snapshot    = true
}

resource "aws_db_instance" "shortener_db" {
  identifier        = "shortener-db-instance"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  db_name              = "shortener_service_database"
  username          = "shortenerdbuser"
  password          = random_password.rds_shortener.result
  vpc_security_group_ids = [
    module.vpc.default_security_group_id,
    aws_security_group.managed_services_sg.id
  ]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  publicly_accessible    = false
  skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "rds_subnets" {
  name       = "rds-subnets"
  subnet_ids = module.vpc.private_subnets
}

resource "random_password" "rds_auth" {
  length  = 16
  special = true
  override_special = "!#$%^&*()-_=+[]{}|:,.?<>~"
}

resource "random_password" "rds_shortener" {
  length  = 16
  special = true
  override_special = "!#$%^&*()-_=+[]{}|:,.?<>~"
}
