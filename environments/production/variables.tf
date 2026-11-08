variable "aws_account_id" {
  type = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "Supply the target 12-digit AWS account ID."
  }
}
variable "region" { type = string }
variable "azs" { type = list(string) }
variable "image" { type = string }
variable "certificate_arn" { type = string }
variable "log_bucket_name" { type = string }
variable "alarm_topic_arn" { type = string }
