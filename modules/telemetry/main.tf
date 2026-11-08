variable "name" { type = string }
variable "account_id" { type = string }
variable "region" { type = string }
resource "aws_kms_key" "logs" {
  description             = "CloudWatch logs for ${var.name}"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Sid = "AccountAdministration", Effect = "Allow", Principal = { AWS = "arn:aws:iam::${var.account_id}:root" }, Action = "kms:*", Resource = "*" },
    { Sid = "RegionalCloudWatch", Effect = "Allow", Principal = { Service = "logs.${var.region}.amazonaws.com" }, Action = ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"], Resource = "*", Condition = { ArnLike = { "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.region}:${var.account_id}:log-group:/platform/${var.name}/*" } } }
  ] })
}
output "kms_key_arn" { value = aws_kms_key.logs.arn }
