output "External_ALB_SG_id" {
  value = aws_security_group.External_ALB_SG.id
}

output "Web_Tier_SG_id" {
  value = aws_security_group.Web_Tier_SG.id
}

output "Internal_ALB_SG_id" {
  value = aws_security_group.Internal_ALB_SG.id
}

output "App_Tier_SG_id" {
  value = aws_security_group.App_Tier_SG.id
}

output "DB_Tier_SG_id" {
  value = aws_security_group.DB_Tier_SG.id
}