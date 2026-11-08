variable "name" { type = string }
variable "vpc_cidr" { type = string }
variable "azs" {
  type = list(string)
  validation {
    condition     = length(var.azs) == 2 && length(distinct(var.azs)) == 2
    error_message = "Exactly two distinct availability zones are required."
  }
}
variable "log_kms_key_arn" { type = string }

variable "region" { type = string }
