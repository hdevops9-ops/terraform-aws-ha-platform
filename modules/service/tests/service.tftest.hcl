mock_provider "aws" {}
variables {
  endpoint_security_group_id = "sg-0123456789abcdef0"
  s3_prefix_list_id          = "pl-0123456789abcdef0"
  name                       = "test-ha"
  region                     = "us-east-1"
  account_id                 = "123456789012"
  vpc_id                     = "vpc-0123456789abcdef0"
  public_subnet_ids          = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  private_subnet_ids         = ["subnet-0123456789abcdef2", "subnet-0123456789abcdef3"]
  log_kms_key_arn            = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000"
  certificate_arn            = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
  image                      = "example.invalid/service@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  log_bucket_name            = "test-ha-access-logs"
  deletion_protection        = true
  alarm_topic_arn            = "arn:aws:sns:us-east-1:123456789012:test-alerts"
}
run "service_contract" {
  command = plan
  assert {
    condition     = aws_ecs_service.this.desired_count >= 2 && aws_ecs_service.this.availability_zone_rebalancing == "ENABLED"
    error_message = "HA needs multiple tasks and AZ rebalancing."
  }
  assert {
    condition     = !aws_ecs_service.this.network_configuration[0].assign_public_ip
    error_message = "Tasks must have private IPs only."
  }
  assert {
    condition     = aws_ecs_service.this.deployment_circuit_breaker[0].rollback
    error_message = "Deployment failure rollback must be enabled."
  }
  assert {
    condition     = aws_lb_listener.https.protocol == "HTTPS" && aws_lb.this.enable_deletion_protection
    error_message = "Production entrypoint requires TLS and deletion protection."
  }
}
run "reject_mutable_image" {
  command = plan
  variables { image = "nginx:latest" }
  expect_failures = [var.image]
}
run "reject_single_task" {
  command = plan
  variables { desired_count = 1 }
  expect_failures = [var.desired_count]
}
