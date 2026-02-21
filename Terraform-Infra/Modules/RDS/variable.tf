variable "db_subnet_group_subnet_ids" {}
variable "storage" {}
variable "db_name" {}
variable "engine" {}
variable "engine_version" {}
variable "instance_class" {}
variable "db_username" {}
variable "db_password" {}
variable "db_security_id" {}
variable "skip_final_snapshot" {
  type = bool
}
variable "multi_az" {
  type = bool
}