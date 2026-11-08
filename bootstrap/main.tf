variable "region" { type = string }
variable "aws_account_id" { type = string }
variable "bucket_name" { type = string }
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}
module "state" {
  source      = "../modules/state-backend"
  bucket_name = var.bucket_name
}
output "bucket_name" { value = module.state.bucket_name }
output "kms_key_arn" { value = module.state.kms_key_arn }
