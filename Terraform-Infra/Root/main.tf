module "vpc" {
  source                       = "../Modules/VPC"
  region                       = var.region
  project_name                 = var.project_name
  vpc_cidr                     = var.vpc_cidr
  public_subnet_az1_cidr       = var.public_subnet_az1_cidr
  public_subnet_az2_cidr       = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr  = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr  = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr
}

module "nat" {
  source = "../Modules/NAT"

  public_subnet_az1_id       = module.vpc.public_subnet_az1_id
  public_subnet_az2_id       = module.vpc.public_subnet_az2_id
  private_app_subnet_az1_id  = module.vpc.private_app_subnet_az1_id
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_app_subnet_az2_id  = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id
  vpc_id                     = module.vpc.vpc_id
  IGW                        = module.vpc.IGW
}

module "SG" {
  source = "../Modules/SG"
  vpc_id = module.vpc.vpc_id
}

module "IAM_Role" {
  source    = "../Modules/IAM_Role"
  role_name = var.role_name
}

module "RDS" {
  source                     = "../Modules/RDS"
  db_subnet_group_subnet_ids = [module.vpc.private_data_subnet_az1_id, module.vpc.private_data_subnet_az2_id]
  storage                    = var.storage
  db_name                    = var.db_name
  engine                     = var.engine
  engine_version             = var.engine_version
  instance_class             = var.instance_class
  db_username                = var.db_username
  db_password                = var.db_password
  db_security_id             = module.SG.DB_Tier_SG_id
  skip_final_snapshot        = var.skip_final_snapshot
  multi_az                   = var.multi_az

}

#creating external LB
module "LB" {
  source                        = "../Modules/LB"
  external_tg_name              = var.external_tg_name
  external_tg_port              = var.external_tg_port
  external_tg_protocol          = var.external_tg_protocol
  external_vpc_id               = module.vpc.vpc_id
  external_lb_name              = var.external_lb_name
  ext_internal                  = var.ext_internal
  external_lb_type              = var.external_lb_type
  external_lb_sg                = module.SG.External_ALB_SG_id
  external_lb_subnet            = [module.vpc.public_subnet_az1_id, module.vpc.public_subnet_az2_id]
  external_lb_listener_port     = var.external_lb_listener_port
  external_lb_listener_protocol = var.external_lb_listener_protocol
  internal_tg_name              = var.internal_tg_name
  internal_tg_port              = var.internal_tg_port
  internal_tg_protocol          = var.internal_tg_protocol
  internal_vpc_id               = module.vpc.vpc_id
  internal_lb_name              = var.internal_lb_name
  int_internal                  = var.int_internal
  internal_lb_type              = var.internal_lb_type
  internal_lb_sg                = module.SG.Internal_ALB_SG_id
  internal_lb_subnet            = [module.vpc.private_app_subnet_az1_id, module.vpc.private_app_subnet_az2_id]
  internal_lb_listener_port     = var.internal_lb_listener_port
  internal_lb_listener_protocol = var.internal_lb_listener_protocol

}

#creating launch template and ASG
module "ASG" {
  source                                         = "../Modules/ASG"
  app_tier_launch_template_name                  = var.app_tier_launch_template_name
  app_tier_launch_template_description           = var.app_tier_launch_template_description
  app_tier_launch_template_image_id              = var.app_tier_launch_template_image_id
  app_tier_launch_template_instance_type         = var.app_tier_launch_template_instance_type
  app_tier_launch_template_SG_ids                = module.SG.App_Tier_SG_id
  app_tier_launch_template_instance_profile_name = module.IAM_Role.instance_profile_name
  external_lb_dns                                = module.LB.external_lb_dns
  app_tier_ASG_name                              = var.app_tier_ASG_name
  app_tier_min_size                              = var.app_tier_min_size
  app_tier_max_size                              = var.app_tier_max_size
  app_tier_desired_capacity                      = var.app_tier_desired_capacity
  app_tier_ASG_force_delete                      = var.app_tier_ASG_force_delete
  app_tier_ASG_vpc_zone_identifier               = [module.vpc.private_app_subnet_az1_id, module.vpc.private_app_subnet_az2_id]
  app_tier_ASG_tg_arn                            = module.LB.internal_lb_tg_arn
  app_tier_ASG_health_check_type                 = var.app_tier_ASG_health_check_type
  web_tier_launch_template_name                  = var.web_tier_launch_template_name
  web_tier_launch_template_description           = var.web_tier_launch_template_description
  web_tier_launch_template_image_id              = var.web_tier_launch_template_image_id
  web_tier_launch_template_instance_type         = var.web_tier_launch_template_instance_type
  web_tier_launch_template_SG_ids                = module.SG.Web_Tier_SG_id
  web_tier_launch_template_instance_profile_name = module.IAM_Role.instance_profile_name
  db_RDS_endpoint                                = module.RDS.rds_endpoint
  db_user                                        = module.RDS.db_username
  db_password                                    = module.RDS.db_password
  db_name                                        = module.RDS.db_name
  web_tier_ASG_name                              = var.web_tier_ASG_name
  web_tier_min_size                              = var.web_tier_min_size
  web_tier_max_size                              = var.web_tier_max_size
  web_tier_desired_capacity                      = var.web_tier_desired_capacity
  web_tier_ASG_force_delete                      = var.web_tier_ASG_force_delete
  web_tier_ASG_vpc_zone_identifier               = [module.vpc.public_subnet_az1_id, module.vpc.public_subnet_az2_id]
  web_tier_ASG_tg_arn                            = module.LB.external_lb_tg_arn
  web_tier_ASG_health_check_type                 = var.web_tier_ASG_health_check_type
  app_tier_depends_on                            = [module.LB]
  web_tier_depends_on                            = [module.LB]
}