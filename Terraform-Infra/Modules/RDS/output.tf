output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet.name
}

output "rds_endpoint" {
  value = aws_db_instance.my_db.endpoint
}

output "db_name" {
  value = aws_db_instance.my_db.db_name
}

output "db_username" {
  value = aws_db_instance.my_db.username
}

output "db_password" {
  value = aws_db_instance.my_db.password
}