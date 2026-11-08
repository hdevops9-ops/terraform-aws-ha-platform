# Infrastructure delivery stages

| Stage | Gate | Evidence/output |
| --- | --- | --- |
| Pull request CI | Terraform formatting and seven-root/module validation | Failing job blocks acceptance |
| Behavior | Six mocked Terraform tests and four plan-policy tests | Actual CI log output |
| Secrets | Gitleaks current-tree scan, redacted findings | Nonzero on detection |
| IaC security | Trivy HIGH/CRITICAL gate | Two scoped, expiring exceptions documented |
| Workflow syntax | Actionlint on CI and CD | YAML/expression/action input validation |
| Main-only manual CD | Environment setup acknowledgement, contract/security checks | No AWS calls from PR workflows |
| Authenticated plan | Exact environment-bound OIDC plan role; S3 lock | Saved binary plan and provider lockfile |
| Plan review | Reject deletes/replacements; inspect human-readable plan | Short-lived artifact and SHA256 |
| Approval | Configured GitHub environment reviewers and branch limits | External setup required; YAML cannot create reviewers |
| Apply | Separate environment-bound OIDC apply role; digest verification | Apply the same binary plan, no replan |
| Health | Wait for ECS service stability | Application smoke/SLO acceptance must be added for the real application |

This is an infrastructure delivery pipeline. Application SAST/SCA, container image/SBOM signing, and DAST belong in the real application's build/release pipeline; this code consumes its immutable image digest. The repository does not label those stages as implemented when no application source/build is present. Deployments are not enabled simply by committing this workflow: AWS roles, account-specific inputs, state bootstrap, and protected environments must be configured and verified.
