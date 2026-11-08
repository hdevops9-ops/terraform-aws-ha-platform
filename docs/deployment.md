# Deployment and pipeline setup

1. Create the state backend using the dedicated bootstrap procedure.
2. Issue an ACM certificate in the target region and establish DNS ownership.
3. Create an SNS topic and confirm a real responder subscription.
4. Build and scan an application compatible with uid 101, port 8080, read-only root,
   and writable `/tmp`; publish an immutable digest. A matching private ECR repository
   is named `ha-web-dev` or `ha-web-production`. Application IAM permissions default
   to none; add narrowly scoped policies when the app actually needs AWS access.
5. Supply values in each environment's tfvars; run and review a local plan first.
6. Configure GitHub environments `dev-plan`, `dev`, `production-plan`, `production`.
   Require production reviewers, prevent self-approval, and restrict deployment
   branches to protected main. These settings are not created by a YAML comment.
7. Establish GitHub OIDC trust: audience `sts.amazonaws.com`, subject exactly
   `repo:OWNER/REPO:environment:production-plan` for the plan role and
   `repo:OWNER/REPO:environment:production` for apply. Repeat with dev subjects.
   Do not use a wildcard organization/repository subject.
8. Set environment variables `AWS_REGION`, `STATE_BUCKET`, `STATE_KMS_KEY`,
   `PLAN_ROLE_ARN`/`APPLY_ROLE_ARN`, and `DEPLOYMENT_INPUTS_JSON` (the environment's
   nonsecret Terraform input object). Restrict plan role infrastructure actions to
   read-only data retrieval; apply privileges need a reviewed, resource-scoped policy
   for the provisioned services and pass-role only for the exact task roles.
9. Dispatch deployment on main, inspect the saved plan, and approve the protected
   environment. The binary plan digest is verified; apply does not regenerate it.

Plan files may contain sensitive state even when text output redacts values.
Artifact retention is one day. Restrict repository/Actions access. Provider lockfile,
Terraform version, source commit, and saved plan stay consistent between plan/apply.
Do not add runtime credentials to artifacts. GitHub's plan artifact and digest provide
integrity in this workflow; they do not substitute for trusted workflows/reviewers.

The policy rejects deletion/replacement. Legitimate replacement requires a separate
reviewed change procedure rather than bypassing the guard during an incident.
A failed rollout uses ECS deployment circuit-breaker rollback. Infrastructure rollback
is a new reviewed plan; restoring old state is not an infrastructure rollback.

The supplied CD workflow is not cloud-tested until you connect an AWS sandbox and
run it. It does not modify AWS merely by being committed.

Set `DEPLOYMENT_GUARDS_CONFIRMED=true` in the plan and apply environments only after reviewers, branch restrictions, and OIDC trust are verified. The workflow fails closed without it. This is an explicit setup acknowledgment, not an API check that protection rules exist. The examples in `policies/` scope state access and OIDC trust; they are not an automatically applied deployment-role policy.
