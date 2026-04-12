#!/bin/bash

set -e

echo "🚀 Creating platform-engineering-kit (full README version)..."

create_readme() {
  dir=$1
  mkdir -p "$dir"
  cat <<EOF > "$dir/README.md"
$2
EOF
}

mkdir -p platform-engineering-kit
cd platform-engineering-kit

# =========================
# DOCS
# =========================

create_readme docs "# 📚 Documentation

This directory contains all documentation related to the platform.

## Contents

- architecture → High-level architecture and design
- standards → Engineering standards and best practices
- runbooks → Operational procedures
- decisions → Architecture Decision Records (ADRs)

## Purpose

Provide clarity, consistency and guidance for building and operating the platform."

create_readme docs/architecture "# 🏛 Architecture

This directory contains high-level architecture definitions and system design.

## Contents

- Architecture diagrams
- System design documents
- Data flow and integration patterns

## Purpose

Provide a clear understanding of how the platform is structured and how components interact."

create_readme docs/standards "# 📏 Standards

This directory defines engineering standards and best practices.

## Contents

- Naming conventions
- Coding standards
- Infrastructure guidelines
- CI/CD standards

## Purpose

Ensure consistency, quality and maintainability across all platform components."

create_readme docs/runbooks "# 📘 Runbooks

This directory contains operational procedures.

## Contents

- Incident response guides
- Deployment procedures
- Rollback instructions
- Troubleshooting steps

## Purpose

Provide clear instructions for operating and maintaining the platform."

create_readme docs/decisions "# 🧠 Decisions

This directory contains Architecture Decision Records (ADRs).

## Contents

- Technology choices
- Design decisions
- Trade-offs and rationale

## Purpose

Document the reasoning behind important technical decisions."

# =========================
# BOOTSTRAP
# =========================

create_readme bootstrap "# 🚀 Bootstrap

This directory contains scripts and configurations to initialize environments.

## Contents

- local → Local development setup
- cloud → Cloud provisioning
- workstation → Developer machine setup

## Purpose

Enable fast and standardized environment setup from scratch."

create_readme bootstrap/local "# 💻 Local Bootstrap

Setup for local development environments.

## Contents

- Tool installation scripts
- Local environment configuration

## Purpose

Enable developers to quickly set up a consistent local environment."

create_readme bootstrap/cloud "# ☁️ Cloud Bootstrap

Initial cloud environment provisioning.

## Contents

- Resource initialization scripts
- Base cloud configuration

## Purpose

Prepare foundational cloud resources for the platform."

create_readme bootstrap/workstation "# 🖥 Workstation Setup

Developer machine configuration.

## Contents

- OS setup scripts
- Required tools installation

## Purpose

Standardize developer workstations for productivity and consistency."

# =========================
# INFRA
# =========================

create_readme infrastructure "# 🏗 Infrastructure

Infrastructure as Code (IaC) definitions.

## Contents

- terraform → Multi-cloud provisioning
- bicep → Azure-native IaC
- ansible → Configuration management

## Purpose

Ensure scalable, repeatable and version-controlled infrastructure."

create_readme infrastructure/terraform "# 🌍 Terraform

Infrastructure provisioning using Terraform.

## Contents

- Modules
- Environments
- Resource definitions

## Purpose

Provision and manage infrastructure in a scalable and repeatable way."

create_readme infrastructure/bicep "# 🔷 Bicep

Azure infrastructure definitions using Bicep.

## Contents

- Templates
- Modules

## Purpose

Manage Azure resources using native infrastructure as code."

create_readme infrastructure/ansible "# ⚙️ Ansible

Configuration management and automation.

## Contents

- Playbooks
- Roles

## Purpose

Automate system configuration and operational tasks."

# =========================
# CI/CD
# =========================

create_readme ci-cd "# 🔄 CI/CD

Continuous Integration and Continuous Delivery pipelines.

## Contents

- azure-devops → Pipelines
- github-actions → Workflows
- templates → Reusable pipelines

## Purpose

Standardize build, test and deployment automation."

create_readme ci-cd/azure-devops "# 🔷 Azure DevOps

CI/CD pipelines for Azure DevOps.

## Contents

- Pipeline definitions
- Templates

## Purpose

Automate build and deployment workflows."

create_readme ci-cd/github-actions "# ⚡ GitHub Actions

CI/CD workflows using GitHub Actions.

## Contents

- Workflow files
- Automation pipelines

## Purpose

Enable automated build, test and deployment."

create_readme ci-cd/templates "# 📦 Pipeline Templates

Reusable CI/CD pipeline templates.

## Purpose

Promote reuse and standardization."

# =========================
# SCRIPTS
# =========================

create_readme scripts "# 🧰 Scripts

Utility scripts for automation and operations.

## Contents

- install → Tool installation
- utils → Helper scripts
- maintenance → Cleanup and maintenance

## Purpose

Automate repetitive tasks and improve efficiency."

create_readme scripts/install "# 📥 Install Scripts

Scripts for installing tools and dependencies.

## Purpose

Automate tool installation and environment setup."

create_readme scripts/utils "# 🧪 Utilities

Helper scripts for daily operations.

## Purpose

Simplify common tasks."

create_readme scripts/maintenance "# 🧹 Maintenance

Scripts for maintenance tasks.

## Contents

- Cleanup
- Backup
- Health checks

## Purpose

Maintain system stability."

# =========================
# OBSERVABILITY
# =========================

create_readme observability "# 📊 Observability

Monitoring, logging and alerting configurations.

## Contents

- monitoring → Metrics and dashboards
- logging → Log aggregation
- alerting → Alerts and notifications

## Purpose

Provide visibility into system health."

create_readme observability/monitoring "# 📈 Monitoring

Metrics collection and visualization.

## Purpose

Track performance and health."

create_readme observability/logging "# 📜 Logging

Log collection and analysis.

## Purpose

Enable troubleshooting and auditing."

create_readme observability/alerting "# 🚨 Alerting

Alert rules and notifications.

## Purpose

Detect and respond to issues."

# =========================
# SECURITY
# =========================

create_readme security "# 🔐 Security

Security practices and configurations.

## Contents

- secrets → Secret management
- policies → Governance
- scanning → Vulnerability scans

## Purpose

Ensure secure platform operations."

create_readme security/secrets "# 🔑 Secrets

Secret management practices.

## Purpose

Secure sensitive data."

create_readme security/policies "# 📜 Policies

Security and governance policies.

## Purpose

Ensure compliance and control."

create_readme security/scanning "# 🔍 Scanning

Security scanning tools.

## Purpose

Identify vulnerabilities."

# =========================
# TEMPLATES
# =========================

create_readme templates "# 🧩 Templates

Reusable templates for services and infrastructure.

## Contents

- microservices → Service templates
- api → API templates
- infra → Infra templates

## Purpose

Accelerate development and standardization."

create_readme templates/microservices "# 🧱 Microservices Templates

Templates for microservice-based applications.

## Purpose

Standardize microservice development."

create_readme templates/api "# 🔌 API Templates

Templates for API services.

## Purpose

Standardize API development."

create_readme templates/infra "# 🏗 Infra Templates

Reusable infrastructure templates.

## Purpose

Accelerate provisioning."

# =========================
# AI
# =========================

create_readme ai "# 🤖 AI

AI-powered components for automation and intelligence.

## Contents

- agents → AI agents
- prompts → Reusable prompts
- workflows → Automation flows
- tools → AI integrations

## Purpose

Enhance platform with AI capabilities."

create_readme ai/agents "# 🤖 Agents

Definitions of AI agents.

## Purpose

Enable intelligent automation and assistance."

create_readme ai/prompts "# 💬 Prompts

Reusable prompts.

## Purpose

Standardize AI interactions."

create_readme ai/workflows "# 🔄 Workflows

AI-driven workflows.

## Purpose

Automate complex processes."

create_readme ai/tools "# 🧰 AI Tools

AI integrations and utilities.

## Purpose

Extend platform capabilities."

# =========================
# TOOLS
# =========================

create_readme tools "# 🛠 Tools

Core tools and configurations.

## Contents

- docker → Containers
- kubernetes → Orchestration
- cli → CLI tools

## Purpose

Centralize tooling."

create_readme tools/docker "# 🐳 Docker

Containerization setup.

## Purpose

Standardize container usage."

create_readme tools/kubernetes "# ☸️ Kubernetes

Orchestration configurations.

## Purpose

Manage container workloads."

create_readme tools/cli "# 💻 CLI Tools

Command-line utilities.

## Purpose

Improve productivity."

echo "✅ Full structure with detailed READMEs created!"