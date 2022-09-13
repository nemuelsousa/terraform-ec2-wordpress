# RDS DB Instance
resource "aws_db_instance" "rds" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t3.medium"
  db_name                 = "wp"
  username                = "admin"
  password                = "password"
  parameter_group_name    = aws_db_parameter_group.db_pg.name
  option_group_name       = aws_db_option_group.db_og.name
  multi_az                = true
  db_subnet_group_name    = aws_db_subnet_group.subnet_db_group.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  backup_retention_period = "7"
  backup_window           = "23:29-23:59"
  skip_final_snapshot     = true
  max_allocated_storage   = 200
  identifier              = "wp"

  tags = {
    Name = "wp"
  }
}

# RDS DB Option Group
resource "aws_db_option_group" "db_og" {
  name                 = "wp-db-og"
  engine_name          = "mysql"
  major_engine_version = "5.7"
}

# RDS DB Parameter Group
resource "aws_db_parameter_group" "db_pg" {
  name   = "wp-db-pg"
  family = "mysql5.7"
}