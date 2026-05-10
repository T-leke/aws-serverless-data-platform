# How Everything is Connected

This document explains how all components of the AWS Data Platform are connected together from both:

1. Infrastructure perspective
2. CI/CD and deployment perspective

The goal of this document is to explain not only *what* was built, but *how the entire platform works together as a complete system*.

---

# 1. Big Picture

This project consists of four major layers:

```text
1. Developer Layer
2. CI/CD Layer
3. Infrastructure Layer
4. Data Processing Layer
```

Each layer interacts with the others to provide a secure, automated, production-style cloud platform.

---

# 2. End-to-End System Flow

```text
Developer
    ↓
GitHub Repository
    ↓
GitHub Actions CI/CD
    ↓
HCP Terraform
    ↓
AWS OIDC Federation
    ↓
AWS Infrastructure Provisioning
    ↓
Data Platform Resources Created
    ↓
CSV Uploaded to S3
    ↓
Lambda Validation
    ↓
Step Functions Orchestration
    ↓
Glue ETL Processing
    ↓
Bronze / Silver / Gold Data Lake
    ↓
Athena Analytics
```

---

# 3. Infrastructure Provisioning Flow

The infrastructure lifecycle begins from the developer workstation.

---

# Step 1 — Developer Writes Terraform Code

The developer creates Terraform code locally.

Example:

```text
modules/
envs/dev
envs/stage
envs/prod
```

This Terraform code defines:

- Networking
- IAM
- S3 buckets
- Lambda
- Glue
- Step Functions
- Athena
- Monitoring

---

# Step 2 — Code is Pushed to GitHub

The repository acts as the central source of truth.

```text
Developer
    ↓
Git Push
    ↓
GitHub Repository
```

GitHub now stores:
- Terraform code
- Glue scripts
- Lambda code
- GitHub workflows
- Documentation

---

# Step 3 — GitHub Actions CI/CD Starts

When a Pull Request is opened:

```text
GitHub Actions
    ↓
terraform fmt
terraform validate
tflint
checkov
terraform plan
```

This ensures:
- Terraform syntax is valid
- Security checks pass
- Infrastructure changes are reviewed before deployment

---

# Step 4 — GitHub Authenticates to HCP Terraform

GitHub does not deploy directly to AWS.

Instead:

```text
GitHub Actions
    ↓
HCP Terraform
```

GitHub authenticates to HCP Terraform using:

```text
TF_API_TOKEN
```

stored securely in GitHub Secrets.

---

# Step 5 — HCP Terraform Authenticates to AWS

HCP Terraform then authenticates to AWS using OIDC federation.

This is one of the most important security concepts in the project.

---

## Traditional Authentication (Not Used)

Old-style authentication uses:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Problems:
- Long-lived credentials
- Security risk
- Hard to rotate
- Can leak

---

## Modern Authentication (Used Here)

This project uses:

```text
OIDC Federation
```

Flow:

```text
HCP Terraform
    ↓
OIDC Token
    ↓
AWS STS
    ↓
Temporary Credentials
    ↓
Terraform Provisions Resources
```

---

# Step 6 — AWS IAM Trust Policy

AWS trusts HCP Terraform through an IAM trust relationship.

The trust policy allows:

```text
app.terraform.io
```

to assume an AWS IAM role.

Example:

```text
HCP Terraform
    ↓
AssumeRoleWithWebIdentity
    ↓
hcp-terraform-role
```

This role provides permissions to create infrastructure.

---

# 4. Environment Separation

The platform separates environments using:

```text
dev
stage
prod
```

Each environment has:

- Separate Terraform state
- Separate HCP Terraform workspace
- Separate GitHub deployment environment
- Independent deployment lifecycle

---

# Environment Mapping

| GitHub Environment | Terraform Folder | HCP Workspace |
|---|---|---|
| dev | envs/dev | aws-data-platform-dev |
| stage | envs/stage | aws-data-platform-stage |
| prod | envs/prod | aws-data-platform-prod |

---

# Why Environment Separation Matters

Environment isolation prevents:

- Accidental production changes
- Shared Terraform state corruption
- Cross-environment interference

It also enables:

- Safe testing
- Controlled promotion
- Independent scaling
- Different security controls

---

# 5. Terraform Module Architecture

The project uses modular Terraform design.

---

# Why Modules Exist

Modules provide:

- Reusability
- Separation of concerns
- Easier maintenance
- Team scalability
- Cleaner code organization

---

# Module Relationships

```text
Root Environment
    ↓
Calls Modules
```

Example:

```text
envs/dev/main.tf
    ↓
modules/networking
modules/s3-data-lake
modules/iam
modules/lambda-validator
modules/glue
modules/step-functions
```

---

# Module Dependency Flow

```text
Networking
    ↓
S3 + IAM
    ↓
Lambda
    ↓
Step Functions
    ↓
Glue
    ↓
Athena
```

Terraform automatically builds a dependency graph.

Example:

```text
Lambda needs IAM role
Step Functions needs Glue job
Glue needs S3 buckets
```

Terraform determines deployment order automatically.

---

# 6. Networking Architecture

The networking module provisions:

- VPC
- Public subnets
- Private subnets
- Route tables
- Internet Gateway

---

# Public vs Private Subnets

## Public Subnets

Contain:
- Internet-facing resources
- NAT gateways (future enhancement)

Public subnets can access the internet directly.

---

## Private Subnets

Contain:
- Internal workloads
- Data processing services
- Backend infrastructure

Private subnets improve security by limiting direct internet exposure.

---

# Why NAT Gateway Was Skipped

NAT Gateways incur ongoing cost.

For learning purposes:
- Private subnets were created
- NAT Gateway intentionally excluded

This reduces AWS costs while preserving architecture understanding.

---

# 7. Data Platform Architecture

This project implements a modern data lake architecture.

---

# Source Layer

Raw files are uploaded to:

```text
S3 Source Bucket
```

Example:

```text
transactions/transactions_2026_05_03.csv
```

This represents incoming business data.

---

# Lambda Validation Layer

S3 upload events trigger Lambda automatically.

Flow:

```text
S3 Upload
    ↓
Lambda Trigger
```

Lambda validates:
- File location
- File extension
- Schema
- Header structure

If validation succeeds:

```text
Lambda
    ↓
Start Step Function Execution
```

---

# Step Functions Orchestration

Step Functions coordinates the ETL workflow.

Responsibilities:
- Workflow orchestration
- Execution management
- Retry handling
- Error handling
- Service coordination

Flow:

```text
Lambda
    ↓
Step Functions
    ↓
Glue Job
```

---

# Glue ETL Processing

Glue performs:
- Data ingestion
- Transformation
- Cleansing
- Aggregation

Glue converts:
- CSV
→ Parquet

This improves:
- Query performance
- Compression
- Analytics efficiency

---

# Bronze / Silver / Gold Layers

---

## Bronze Layer

Purpose:
- Raw immutable ingestion layer

Characteristics:
- Minimal transformation
- Historical preservation
- Source fidelity

---

## Silver Layer

Purpose:
- Cleaned and standardized datasets

Transformations:
- Remove duplicates
- Data type casting
- Null handling
- Basic quality checks

---

## Gold Layer

Purpose:
- Business-ready analytics

Transformations:
- Aggregations
- KPIs
- Reporting datasets

This layer is optimized for BI and analytics.

---

# Athena Analytics Layer

Athena queries curated data directly from S3.

Advantages:
- Serverless
- No infrastructure management
- Pay-per-query
- Fast analytics

Athena is connected to:
- Glue Data Catalog
- Gold data layer

---

# 8. Security Architecture

Security is integrated throughout the platform.

---

# IAM Roles and Least Privilege

Separate IAM roles exist for:
- Lambda
- Glue
- Step Functions
- Terraform provisioning

This prevents:
- Excessive permissions
- Service misuse
- Credential sharing

---

# OIDC Federation

OIDC removes the need for:
- AWS access keys
- Long-lived credentials

Benefits:
- Temporary credentials
- Automatic rotation
- Reduced credential exposure

---

# S3 Security

All S3 buckets use:
- Public access blocking
- Encryption at rest
- Versioning

This protects:
- Uploaded datasets
- ETL outputs
- Analytical data

---

# Policy-as-Code

Security and compliance validation include:
- TFLint
- Checkov
- Sentinel
- OPA

These tools help detect:
- Misconfigurations
- Public exposure
- Missing encryption
- Weak IAM policies

before deployment.

---

# 9. CI/CD Pipeline Architecture

---

# Pull Request Workflow

When a PR is opened:

```text
terraform fmt
terraform validate
tflint
checkov
terraform plan
```

This ensures:
- Infrastructure quality
- Security compliance
- Deployment safety

before merge.

---

# Dev Deployment

After merge to main:

```text
terraform apply
```

runs automatically for dev.

This enables rapid iteration.

---

# Stage/Production Promotion

Stage and production deployments require:
- Manual promotion
- Approval gates
- Environment protection rules

This prevents accidental production deployments.

---

# 10. Terraform State Management

Terraform state is stored remotely in HCP Terraform.

Benefits:
- Centralized state
- State locking
- Team collaboration
- Auditability
- Reduced local state corruption

Each environment has:
- Separate state
- Separate workspace

---

# 11. Testing Strategy

Infrastructure testing includes:

---

## Terraform Validate

Checks Terraform syntax and configuration correctness.

---

## TFLint

Checks:
- Terraform best practices
- AWS-specific configuration issues

---

## Checkov

Performs security scanning.

Detects:
- Public S3 buckets
- Missing encryption
- Weak security controls

---

## Terratest

Runs infrastructure validation using Go.

Validates:
- Resource existence
- Deployment correctness
- Infrastructure behavior

---

# 12. Operational Lifecycle

Infrastructure management does not stop after deployment.

This project also considers:

- Scaling
- Upgrades
- Performance tuning
- Security patching
- Cost optimization
- Drift detection

---

# Example Lifecycle Operations

## Scaling Glue

Increase:
- Worker count
- Worker size

when processing larger datasets.

---

## Lambda Performance Tuning

Adjust:
- Memory
- Timeout

to improve execution speed.

---

## Terraform Provider Upgrades

Regularly update:
- Terraform versions
- AWS provider versions

to receive:
- Security fixes
- New features
- Bug fixes

---

# 13. Cost Optimization Strategy

This project intentionally avoids expensive services where possible.

Examples:

| Optimization | Reason |
|---|---|
| No NAT Gateway | Reduce ongoing cost |
| Athena over Redshift | Serverless analytics |
| Small Glue workers | Lower ETL cost |
| Dev-only auto deployment | Reduce unnecessary environments |

---

# 14. Why This Architecture Matters

This project demonstrates real-world engineering concepts:

- Infrastructure as Code
- Platform Engineering
- Cloud Security
- CI/CD Automation
- Data Engineering
- Environment Isolation
- Governance
- Infrastructure Testing
- Operational Awareness

It is intentionally designed to reflect modern enterprise cloud engineering practices rather than simple Terraform scripting.

---

# 15. Final End-to-End Flow Summary

```text
Developer
    ↓
GitHub
    ↓
GitHub Actions
    ↓
HCP Terraform
    ↓
AWS OIDC Federation
    ↓
Terraform Provisioning
    ↓
AWS Infrastructure
    ↓
CSV Uploaded to S3
    ↓
Lambda Validation
    ↓
Step Functions
    ↓
Glue ETL
    ↓
Bronze / Silver / Gold
    ↓
Athena Analytics
```