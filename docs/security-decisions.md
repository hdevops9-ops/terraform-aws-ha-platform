# Reviewed scanner exceptions

Two scoped, expiring exceptions are recorded inline and must be reviewed by 2027-02-01:

- AVD-AWS-0053, only the public ALB: an internet-facing web entrypoint is part of the design. TLS, access logs, private targets, and restricted task security groups remain enabled.
- AVD-AWS-0132, only ALB access-log encryption: AWS ALB log delivery requires SSE-S3. State and CloudWatch logs use customer-managed KMS keys. Reference: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html

These do not suppress other findings globally. Tasks have no unrestricted internet egress: HTTPS is limited to private ECR/CloudWatch endpoints and the S3 managed prefix list. The per-AZ NAT routes are present for approved future workloads; granting internet egress requires a separate reviewed policy change. Endpoint charges must be included in cost review.
