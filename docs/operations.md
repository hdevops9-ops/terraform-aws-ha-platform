# Operations and readiness

After applying in a sandbox, create DNS pointing a certificate-covered name to the
ALB. Verify HTTPS, HTTP redirect, target health, task distribution across AZs, flow
logs, ALB access log delivery, CloudWatch logs, and confirmed SNS alert delivery.
The ALB-generated DNS name will not match your custom ACM certificate; use your
certificate-covered application hostname for HTTPS checks.

Record commands, timestamps, observed outcomes, and run links for:

- Stop one ECS task under bounded synthetic traffic; observe replacement and errors.
- Deploy an intentionally unhealthy image in sandbox; confirm circuit-breaker rollback.
- Test an approved AZ failure scenario and verify the egress path in the surviving AZ.
- Attempt concurrent Terraform writers; observe state-lock contention, not two applies.
- Restore a prior S3 state version with writers paused; verify infrastructure drift.

No task or AZ experiment has been run by authoring this repository. Two NAT gateways
and two task subnets are a design choice, not failure-recovery evidence.

Production deletion protection intentionally blocks casual ALB teardown; disabling it
is a separate reviewed change. The versioned access log bucket is not force-deleted.
State bucket and state KMS key have `prevent_destroy`; retention and deletion require
an approved data lifecycle procedure. Dev still uses two NAT gateways and incurs costs.
