output "external_lb_tg_arn" {
  value = aws_lb_target_group.external-lb-tg.arn
}

output "internal_lb_tg_arn" {
  value = aws_lb_target_group.internal-lb-tg.arn
}

output "external_lb_dns" {
  value = aws_lb.external_lb.dns_name
}