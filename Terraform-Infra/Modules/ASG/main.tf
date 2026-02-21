resource "aws_launch_template" "app_tier_launch_template" {
  name = var.app_tier_launch_template_name
  description = var.app_tier_launch_template_description
  image_id = var.app_tier_launch_template_image_id
  instance_type = var.app_tier_launch_template_instance_type
  vpc_security_group_ids = [var.app_tier_launch_template_SG_ids]

  iam_instance_profile {
    name = var.app_tier_launch_template_instance_profile_name
  }

  user_data = base64encode(templatefile("${path.module}/Scripts/app_tier.sh", {
    db_RDS_endpoint = var.db_RDS_endpoint
    db_user         = var.db_user
    db_password     = var.db_password
    db_name         = var.db_name
  }))
}

resource "aws_autoscaling_group" "app_tier_ASG" {
  name                      = var.app_tier_ASG_name
  max_size                  = var.app_tier_max_size
  min_size                  = var.app_tier_min_size
  desired_capacity          = var.app_tier_desired_capacity
  force_delete              = var.app_tier_ASG_force_delete
  vpc_zone_identifier       = var.app_tier_ASG_vpc_zone_identifier
  target_group_arns         = [var.app_tier_ASG_tg_arn]
  health_check_type         = var.app_tier_ASG_health_check_type

  launch_template {
    id      = aws_launch_template.app_tier_launch_template.id
    version = "$Latest"
  }

  depends_on = [ var.app_tier_depends_on ]
}

#Creating Web tier launch template and asg
resource "aws_launch_template" "web_tier_launch_template" {
  name = var.web_tier_launch_template_name
  description = var.web_tier_launch_template_description
  image_id = var.web_tier_launch_template_image_id
  instance_type = var.web_tier_launch_template_instance_type
  vpc_security_group_ids = [var.web_tier_launch_template_SG_ids]

  iam_instance_profile {
    name = var.web_tier_launch_template_instance_profile_name
  }

  user_data = base64encode(templatefile("${path.module}/Scripts/web_tier.sh", {
   external_lb_dns = var.external_lb_dns
  }))
}

resource "aws_autoscaling_group" "web_tier_ASG" {
  name                      = var.web_tier_ASG_name
  max_size                  = var.web_tier_max_size
  min_size                  = var.web_tier_min_size
  desired_capacity          = var.web_tier_desired_capacity
  force_delete              = var.web_tier_ASG_force_delete
  vpc_zone_identifier       = var.web_tier_ASG_vpc_zone_identifier
  target_group_arns         = [var.web_tier_ASG_tg_arn]
  health_check_type         = var.web_tier_ASG_health_check_type

  launch_template {
    id      = aws_launch_template.web_tier_launch_template.id
    version = "$Latest"
  }
  
  depends_on = [ var.web_tier_depends_on ]
}