#1.Security group for allow traffic from internet to External Load balancer
resource "aws_security_group" "External_ALB_SG" {
  name        = "External_ALB_SG"
  description = "External Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "External_ALB_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.External_ALB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.External_ALB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#2.Security group for allow traffic from External Load balancer to Web Tier Instances
resource "aws_security_group" "Web_Tier_SG" {
  name        = "Web_Tier_SG"
  description = "Allowing traffic from external load balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "Web_Tier_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_to_web" {
  security_group_id            = aws_security_group.Web_Tier_SG.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
  referenced_security_group_id = aws_security_group.External_ALB_SG.id
}

#3.Security group for allow traffic from Web Tier Instances to Internal Load balancer

resource "aws_security_group" "Internal_ALB_SG" {
  name        = "Internal_ALB_SG"
  description = "Allowing traffic from Web Tier Instances to Internal ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "Internal_ALB_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_Web_to_Internal_alb" {
  security_group_id            = aws_security_group.Internal_ALB_SG.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
  referenced_security_group_id = aws_security_group.Web_Tier_SG.id
}

#4.Security group for allow traffic from Internal Load balancer to App Tier Instances
resource "aws_security_group" "App_Tier_SG" {
  name        = "App_Tier_SG"
  description = "Allowing traffic from Internal ALB to App Tier Instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "App_Tier_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_internal_alb_to_app" {
  security_group_id            = aws_security_group.App_Tier_SG.id
  from_port                    = 4000
  ip_protocol                  = "tcp"
  to_port                      = 4000
  referenced_security_group_id = aws_security_group.Internal_ALB_SG.id
}

#5.Security group for allow traffic from App Tier Instances to DB Tier
resource "aws_security_group" "DB_Tier_SG" {
  name        = "DB_Tier_SG"
  description = "Allowing traffic from Internal ALB to App Tier Instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "DB_Tier_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_app_to_DB" {
  security_group_id            = aws_security_group.DB_Tier_SG.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.App_Tier_SG.id
}