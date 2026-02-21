resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_subnet"
  subnet_ids = var.db_subnet_group_subnet_ids

  tags = {
    name = "db_subnet_group"
  }
}

resource "aws_db_instance" "my_db" {
  allocated_storage      = var.storage
  db_name                = var.db_name
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [var.db_security_id]
  skip_final_snapshot    = var.skip_final_snapshot
  multi_az               = var.multi_az

  depends_on = [aws_db_subnet_group.db_subnet]
}

