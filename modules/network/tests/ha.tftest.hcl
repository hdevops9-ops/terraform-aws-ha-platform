mock_provider "aws" {}
variables {
  region          = "us-east-1"
  name            = "test-ha"
  vpc_cidr        = "10.40.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  log_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000"
}
run "per_az_network" {
  command = plan
  assert {
    condition     = length(aws_nat_gateway.this) == 2 && length(aws_subnet.private) == 2
    error_message = "Each AZ needs a private subnet and NAT gateway."
  }
  assert {
    condition     = alltrue([for s in aws_subnet.private : !s.map_public_ip_on_launch])
    error_message = "Private subnets cannot assign public IPs."
  }
  assert {
    condition     = aws_flow_log.this.traffic_type == "ALL"
    error_message = "VPC flow logging is required."
  }
}
run "reject_same_az" {
  command = plan
  variables { azs = ["us-east-1a", "us-east-1a"] }
  expect_failures = [var.azs]
}
