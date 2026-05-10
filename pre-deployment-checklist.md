# Pre-Deployment Checklist

This checklist ensures all required infrastructure, authentication, CI/CD, and Terraform configurations are properly configured before the first deployment.

---

# Phase 1 — Local Machine Setup

## Required Tools Installed

Verify the following tools are installed:

```bash
terraform version
git --version
python --version
aws --version
go version
```

---

## TFLint Installed

Verify:

```bash
tflint --version
```

Initialize plugins:

```bash
tflint --init
```

---

## Checkov Installed

Verify:

```bash
checkov --version
```

---

# Phase 2 — AWS Configuration

# AWS Account Access

- [ ] AWS Console access verified
- [ ] Correct AWS account selected
- [ ] Correct region selected (`ca-central-1`)

---

# OIDC Identity Provider

Verify OIDC provider exists:

```text
IAM
↓
Identity Providers
```

Provider configuration:

| Setting | Value |
|---|---|
| Provider Type | OpenID Connect |
| Provider URL | https://app.terraform.io |
| Audience | aws.workload.identity |

---

# HCP Terraform IAM Role

Verify IAM role exists:

```text
hcp-terraform-role
```

---

# IAM Trust Policy Configured

Verify trust policy contains:

- HCP Terraform organization
- HCP Terraform project
- HCP Terraform workspace permissions

---

# IAM Permissions Attached

For learning environment:

- [ ] `AdministratorAccess` attached temporarily

---

# IAM Role ARN Saved

Example:

```text
arn:aws:iam::<ACCOUNT_ID>:role/hcp-terraform-role
```

---

# Phase 3 — HCP Terraform Configuration

# HCP Terraform Organization Created

- [ ] Organization exists

---

# HCP Terraform Project Created

Verify project exists:

```text
sales-data-platform
```

---

# HCP Terraform Workspaces Created

Verify these workspaces exist:

- [ ] aws-data-platform-dev
- [ ] aws-data-platform-stage
- [ ] aws-data-platform-prod

---

# Workspace Variables Configured

For EACH workspace verify:

## Environment Variable 1

| Key | Value |
|---|---|
| TFC_AWS_PROVIDER_AUTH | true |

---

## Environment Variable 2

| Key | Value |
|---|---|
| TFC_AWS_RUN_ROLE_ARN | <ROLE_ARN> |

---

# HCP Terraform API Token Generated

Verify API token created.

---

# Phase 4 — GitHub Configuration

# Repository Created

- [ ] Repository pushed to GitHub

---

# GitHub Repository Secret Added

Verify repository secret exists:

| Secret | Purpose |
|---|---|
| TF_API_TOKEN | HCP Terraform authentication |

---

# GitHub Environments Created

Verify environments exist:

- [ ] dev
- [ ] stage
- [ ] prod

---

# GitHub Environment Protection Rules

## DEV

- [ ] No approval required

---

## STAGE

- [ ] Approval required

---

## PROD

- [ ] Approval required

---

# Phase 5 — Terraform Configuration Validation

# Organization Name Updated

Verify all provider files contain correct organization name.

---

# Workspace Names Verified

Verify:

## dev

```hcl
workspace {
  name = "aws-data-platform-dev"
}
```

---

## stage

```hcl
workspace {
  name = "aws-data-platform-stage"
}
```

---

## prod

```hcl
workspace {
  name = "aws-data-platform-prod"
}
```

---

# Region Verified

Verify all environments use:

```hcl
aws_region = "ca-central-1"
```

---

# Lambda Code Exists

Verify:

```text
lambda/validator/lambda_function.py
```

---

# Glue Script Exists

Verify:

```text
glue/jobs/sales_etl.py
```

---

# GitHub Workflow Files Exist

Verify:

```text
.github/workflows/
```

Contains:

- [ ] terraform-pr.yml
- [ ] terraform-apply-dev.yml
- [ ] terraform-promote.yml

---

# Phase 6 — Local Terraform Validation

# Terraform Format

Run:

```bash
terraform fmt -recursive .
```

Verify no formatting errors.

---

# Terraform Init

Run:

```bash
cd envs/dev

terraform init
```

---

# Terraform Validate

Run:

```bash
terraform validate
```

Verify validation succeeds.

---

# Terraform Plan

Run:

```bash
terraform plan
```

Verify:
- No errors
- Expected resources shown

---

# TFLint Validation

Run:

```bash
tflint --recursive
```

Verify no critical issues.

---

# Checkov Security Scan

Run:

```bash
checkov -d .
```

Review security findings.

---

# Phase 7 — GitHub Actions Validation

# Pull Request Workflow Tested

Verify PR workflow runs successfully.

Expected checks:

- [ ] Terraform fmt
- [ ] Terraform validate
- [ ] Terraform plan
- [ ] TFLint
- [ ] Checkov

---

# Merge Workflow Tested

Verify merge to main triggers:

- [ ] Dev environment deployment

---

# Phase 8 — First Deployment Validation

# VPC Created

Verify:
- VPC
- Public subnets
- Private subnets
- Route tables

---

# S3 Buckets Created

Verify:
- Source bucket
- Bronze bucket
- Silver bucket
- Gold bucket

---

# Lambda Created

Verify Lambda function deployed successfully.

---

# Step Function Created

Verify state machine exists.

---

# Glue Job Created

Verify Glue ETL job exists.

---

# Upload Sample CSV

Upload file:

```text
transactions/transactions_2026_05_03.csv
```

to source bucket.

---

# Pipeline Trigger Validation

Verify:
- Lambda triggered
- Step Function executed
- Glue job started

---

# Data Lake Validation

Verify data written to:
- Bronze layer
- Silver layer
- Gold layer

---

# Optional Cost Optimization

Before full ETL testing:

- [ ] Replace Step Function with Pass state only
- [ ] Reduce Glue workers if necessary

---

# Cleanup

To avoid unnecessary AWS charges:

```bash
terraform destroy
```

Run from deployed environment directory.

---

# Final Readiness Checklist

## AWS

- [ ] OIDC provider configured
- [ ] IAM role configured
- [ ] Trust policy configured

---

## HCP Terraform

- [ ] Project created
- [ ] Workspaces created
- [ ] Workspace variables configured

---

## GitHub

- [ ] Repository secrets configured
- [ ] Environments configured
- [ ] Approval gates configured

---

## Terraform

- [ ] Terraform validate successful
- [ ] Terraform plan successful
- [ ] TFLint successful
- [ ] Checkov successful

---

## Deployment

- [ ] GitHub Actions successful
- [ ] Infrastructure deployed successfully
- [ ] Pipeline executed successfully