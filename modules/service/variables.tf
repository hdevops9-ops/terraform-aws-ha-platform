variable "name" { type = string }
variable "region" { type = string }
variable "account_id" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "log_kms_key_arn" { type = string }
variable "certificate_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:acm:[a-z0-9-]+:[0-9]{12}:certificate/.+$", var.certificate_arn))
    error_message = "An issued ACM certificate ARN in the deployment region is required."
  }
}
variable "image" {
  type = string
  validation {
    condition     = can(regex("@sha256:[a-f0-9]{64}$", var.image))
    error_message = "Use an immutable image reference pinned by SHA256 digest."
  }
}
variable "desired_count" {
  type    = number
  default = 2
  validation {
    condition     = var.desired_count >= 2 && floor(var.desired_count) == var.desired_count
    error_message = "HA services require at least two tasks."
  }
}
variable "log_bucket_name" { type = string }
variable "deletion_protection" { type = bool }
variable "alarm_topic_arn" {
  description = "Existing SNS topic with confirmed responders."
  type        = string
}

variable "endpoint_security_group_id" { type = string }
variable "s3_prefix_list_id" { type = string }
