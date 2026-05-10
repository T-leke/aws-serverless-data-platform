# AWS Data Platform IaC

Production-style AWS data platform provisioned using Terraform and deployed using GitHub Actions and HCP Terraform.

This project demonstrates modern Platform Engineering and DevOps practices including:

- Infrastructure as Code (Terraform)
- Modular Terraform architecture
- Multi-environment deployments (dev/stage/prod)
- CI/CD with GitHub Actions
- HCP Terraform remote execution
- AWS OIDC federation (no long-lived access keys)
- Data lake architecture (Bronze / Silver / Gold)
- AWS Lambda orchestration
- AWS Step Functions workflows
- AWS Glue ETL processing
- Amazon Athena analytics
- Security scanning and policy enforcement
- Infrastructure testing with Terratest

---

# Project Goals

This repository was built as both:

1. A hands-on learning project for Terraform, AWS, CI/CD, and Platform Engineering
2. A production-style portfolio project demonstrating enterprise infrastructure engineering concepts

---

# High-Level Architecture

```text
Source CSV Upload
        ↓
S3 Source Bucket
        ↓
Lambda Validator
        ↓
Step Functions
        ↓
Glue ETL Job
        ↓
Bronze Layer (Raw)
        ↓
Silver Layer (Cleaned)
        ↓
Gold Layer (Business Ready)
        ↓
Athena Analytics
```

---

# Data Lake Layers

| Layer | Purpose |
|---|---|
| Source | Original uploaded files |
| Bronze | Raw immutable ingestion layer |
| Silver | Cleaned and validated datasets |
| Gold | Aggregated business-ready analytics |

---

# AWS Services Used

| Service | Purpose |
|---|---|
| Amazon S3 | Data lake storage |
| AWS Lambda | File validation |
| AWS Step Functions | Workflow orchestration |
| AWS Glue | ETL processing |
| AWS Glue Data Catalog | Metadata management |
| Amazon Athena | Querying curated datasets |
| IAM | Security and permissions |
| CloudWatch | Logging and monitoring |
| SNS | Alerting |
| HCP Terraform | Remote Terraform execution |
| GitHub Actions | CI/CD automation |

---

# Repository Structure

```text
aws-data-platform-iac/
│
├── .github/workflows/
├── envs/
│   ├── dev/
│   ├── stage/
│   └── prod/
│
├── modules/
│   ├── networking/
│   ├── s3-data-lake/
│   ├── iam/
│   ├── lambda-validator/
│   ├── step-functions/
│   ├── glue/
│   ├── athena/
│   └── monitoring/
│
├── lambda/
├── glue/
├── policies/
├── tests/
└── docs/
```

---

# Environment Strategy

| Environment | Purpose |
|---|---|
| dev | Development and testing |
| stage | Pre-production validation |
| prod | Production deployment |

Each environment has:
- Separate Terraform workspace
- Separate Terraform state
- Separate GitHub deployment environment
- Independent infrastructure lifecycle

---

# CI/CD Workflow

## Pull Request Workflow

Every pull request runs:

- Terraform fmt
- Terraform validate
- TFLint
- Checkov security scan
- Terraform plan

---

## Merge to Main

After merge:
- Dev environment auto-deploys

---

## Stage/Production Promotion

Stage and production deployments:
- Require manual promotion
- Require approval gates
- Use GitHub Environments protections

---

# Security Model

This project uses modern cloud security practices:

- AWS OIDC federation
- No long-lived AWS access keys
- IAM least privilege principles
- S3 public access blocking
- Encryption at rest
- Policy-as-code validation
- Security scanning in CI/CD

---

# Why HCP Terraform

HCP Terraform provides:

- Remote Terraform execution
- Remote Terraform state management
- Workspace isolation
- Policy enforcement
- Team collaboration
- Secure variable management
- Auditability

---

# Tooling Used

| Tool | Purpose |
|---|---|
| Terraform | Infrastructure provisioning |
| HCP Terraform | Remote execution and state |
| GitHub Actions | CI/CD automation |
| TFLint | Terraform linting |
| Checkov | Security scanning |
| Terratest configuration | Infrastructure testing |
| Sentinel / OPA | Policy-as-code |
| AWS OIDC Federation | Secure authentication |

---

# Local Development

## Initialize Terraform

```bash
cd envs/dev

terraform init
```

---

## Validate Terraform

```bash
terraform validate
```

---

## Run Terraform Plan

```bash
terraform plan
```

---

## Deploy Infrastructure

```bash
terraform apply
```

---

# Testing

## Run TFLint

```bash
tflint --init
tflint --recursive
```

---

## Run Checkov

```bash
checkov -d .
```

---

## Run Terratest

```bash
cd tests/terratest

go mod tidy
go test -v
```

---

# Deployment Flow

```text
Feature Branch
    ↓
Pull Request
    ↓
CI/CD Validation
    ↓
Terraform Plan Review
    ↓
Merge to Main
    ↓
Dev Auto Deployment
    ↓
Manual Promotion to Stage
    ↓
Approval Gate
    ↓
Production Deployment
```

---

# Future Improvements

Planned enhancements include:

- Redshift integration
- Lake Formation governance
- Private networking for Glue
- KMS-managed encryption
- Drift detection
- Cost optimization dashboards
- Automated rollback strategies
- Advanced monitoring and alerting
- Blue/Green infrastructure deployments

---

# Documentation

Additional documentation can be found in the `docs/` directory.

---

# Learning Objective

This project demonstrates understanding of:

- Terraform module design
- Infrastructure lifecycle management
- CI/CD pipelines
- AWS serverless architecture
- Cloud security best practices
- Infrastructure testing
- Platform Engineering workflows
- Multi-environment deployment strategies
- Enterprise cloud governance

---

# Disclaimer

This project is designed for learning and portfolio purposes.

Some configurations prioritize:
- Cost optimization
- Simplicity
- Educational clarity

rather than full enterprise-scale production hardening