provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
  default_tags {
    tags = { Project = "terraform-aws-ha-platform", Environment = "dev", ManagedBy = "Terraform" }
  }
}
locals { name = "ha-web-dev" }
module "telemetry" {
  source     = "../../modules/telemetry"
  name       = local.name
  account_id = var.aws_account_id
  region     = var.region
}
module "network" {
  source          = "../../modules/network"
  name            = local.name
  vpc_cidr        = "10.60.0.0/16"
  region          = var.region
  azs             = var.azs
  log_kms_key_arn = module.telemetry.kms_key_arn
}
module "service" {
  source                     = "../../modules/service"
  name                       = local.name
  region                     = var.region
  account_id                 = var.aws_account_id
  endpoint_security_group_id = module.network.endpoint_security_group_id
  s3_prefix_list_id          = module.network.s3_prefix_list_id
  vpc_id                     = module.network.vpc_id
  public_subnet_ids          = module.network.public_subnet_ids
  private_subnet_ids         = module.network.private_subnet_ids
  log_kms_key_arn            = module.telemetry.kms_key_arn
  image                      = var.image
  certificate_arn            = var.certificate_arn
  log_bucket_name            = var.log_bucket_name
  alarm_topic_arn            = var.alarm_topic_arn
  desired_count              = 2
  deletion_protection        = false
}
output "load_balancer_dns" { value = module.service.load_balancer_dns }
output "cluster_name" { value = module.service.cluster_name }
output "service_name" { value = module.service.service_name }
