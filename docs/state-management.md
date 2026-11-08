# Remote state lifecycle

Use separate AWS accounts and separate state buckets/keys for production and dev
where possible. Never place credentials in backend HCL or tfvars.

## Bootstrap

1. In `bootstrap`, run `terraform init -backend=false`.
2. Use an authorized bootstrap role and run `terraform plan` with `region`,
   `aws_account_id`, and a globally unique `bucket_name`; review costs and apply.
3. Record the bucket and KMS outputs. Protect the initial local state as sensitive.
4. Create a private `backend.hcl` with the new bucket, region, KMS key ARN,
   `key = "bootstrap/terraform.tfstate"`, `encrypt = true`, `use_lockfile = true`.
5. Run `terraform init -migrate-state -backend-config=backend.hcl` and verify
   `terraform state list` before retiring local copies.

A backend cannot store its own initial state before it exists. Keep bootstrap
ownership and permissions separate from application deployment roles.

## Environment initialization

Copy `backend.hcl.example` in each environment to `backend.hcl`, fill the values,
and run `terraform init -backend-config=backend.hcl`. Dev and production use
different roots and state keys. Do not use workspaces as an account isolation boundary.

Terraform 1.10+ uses S3 lockfiles (`use_lockfile=true`). No DynamoDB lock table is
required. Concurrent deploys are also serialized by the workflow concurrency group;
S3 locking remains the authority across CI and workstations.

## Minimum state permissions

Scope each role to its environment prefix. It needs ListBucket with a prefix
condition, GetObject/PutObject on its state object, and GetObject/PutObject/DeleteObject
on that object's `.tflock`. It needs KMS Encrypt/Decrypt/GenerateDataKey on the exact
state key and any required cross-account key policy grant. State deletion is not
needed for ordinary Terraform operation. A plan role still needs state-lock write
permissions even when infrastructure permissions are read-only.

Bucket versioning and a 30-day KMS deletion window support recovery. `prevent_destroy`
is a Terraform guard, not protection against a privileged AWS console/API deletion;
production governance needs IAM/SCP controls and audited break-glass procedures.

## Restore and lock handling

Stop writers. Record the current S3 version ID and back up current state. Inspect
the intended prior version; restore through a controlled S3 version copy. Pull state,
verify lineage/serial and resources, and run a refresh-only plan. State restore does
not restore real infrastructure. Do not force-unlock until the owning operation is
confirmed stopped; record the lock ID and the approval in the incident record.

Reference: https://developer.hashicorp.com/terraform/language/backend/s3
