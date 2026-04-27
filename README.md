# 🚀 Platform Engineering Kit

![Platform Engineering](https://img.shields.io/badge/platform-engineering-blue)
![IaC](https://img.shields.io/badge/IaC-Terraform%20%7C%20Bicep-purple)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Azure%20DevOps%20%7C%20GitHub%20Actions-green)
![Observability](https://img.shields.io/badge/observability-monitoring%20%7C%20logging-orange)
![Security](https://img.shields.io/badge/security-devsecops-red)
![AI Powered](https://img.shields.io/badge/AI-enabled-black)

<!-- DYNAMIC BADGE EXAMPLES (ENABLE LATER) -->

<!--
![Build](https://github.com/USER/REPO/actions/workflows/main.yml/badge.svg)
![Last Commit](https://img.shields.io/github/last-commit/USER/REPO)
![Repo Size](https://img.shields.io/github/repo-size/USER/REPO)
-->

> An opinionated platform engineering kit focused on automation, standardization and developer experience (DevEx), enabling scalable, secure and self-service cloud platforms.

---

## 📑 Table of Contents

- Overview
- Architecture
- Project Structure
- Core Capabilities
- AI Capabilities
- Developer Experience (DevEx)
- Governance & Standards
- Getting Started
- Local Validation
- Troubleshooting
- Value & Impact
- Philosophy
- Roadmap
- Contributing

---

## 🧭 Overview

This repository is a **Platform Engineering Kit** designed to act as a reusable foundation for:

- Environment provisioning
- Infrastructure standardization
- CI/CD automation
- Observability and security
- AI-driven workflows

---

## 🏗 Architecture

```mermaid
flowchart LR

Dev[Developer] --> CI[CI/CD]
CI --> IaC[Infrastructure as Code]
IaC --> Cloud[Cloud Platform]

Cloud --> Obs[Observability]
Cloud --> Sec[Security]

Dev --> AI[AI Agents]
AI --> CI
AI --> IaC

Obs --> Feedback[Feedback Loop]
Sec --> Feedback
Feedback --> Dev
```

---

## 📁 Project Structure

> Modular, scalable and product-oriented structure

- docs → Documentation and decisions
- bootstrap → Environment initialization
- infrastructure → IaC definitions
- ci-cd → Pipelines and automation
- scripts → Utilities and helpers
- scripts/install/standalone → Independent application/runtime installers
- observability → Monitoring and logging
- security → Security and compliance
- templates → Reusable blueprints
- ai → Agents, prompts and workflows
- tools → Core platform tooling

---

## ⚙️ Core Capabilities

### 🚀 Platform Bootstrap

- Local and cloud environments
- Developer onboarding automation

### 🏗 Infrastructure as Code

- Terraform / Bicep modularization
- Multi-environment support

### 🔄 CI/CD Standardization

- Reusable pipelines
- Multi-platform support

### 📊 Observability

- Metrics, logs and alerting
- Production readiness

### 🔐 Security

- Secrets management
- Policy enforcement
- DevSecOps practices

---

## 🤖 AI Capabilities

- Infrastructure generation
- Pipeline automation
- Troubleshooting assistance
- Intelligent workflows

---

## 💡 Developer Experience (DevEx)

This repository is designed to:

- Reduce onboarding time
- Provide self-service capabilities
- Standardize workflows
- Minimize cognitive load

---

## 🏛 Governance & Standards

Defined under:

- docs/standards
- docs/decisions (ADR)

Includes:

- Naming conventions
- Pipeline standards
- Security policies
- Architecture guidelines

---

## 🚀 Getting Started

```bash
git clone <repository-url>
cd platform-engineering-kit
```

Prerequisites:

- Git
- Bash (`bash --version`)
- Ripgrep (`rg --version`) for local validators

Start with:

- bootstrap/local
- infrastructure/terraform
- ci-cd/templates

Recommended onboarding flow:

1. Read [`docs/README.md`](docs/README.md) for the documentation map.
2. Read [`docs/standards/README.md`](docs/standards/README.md) for repository standards.
3. Use operational procedures in [`docs/runbooks/README.md`](docs/runbooks/README.md).
4. Follow CI guidance in [`ci-cd/ci-setup-and-usage.md`](ci-cd/ci-setup-and-usage.md).

---

## ✅ Local Validation

Run these checks from repository root before opening a PR:

```bash
bash -n scripts/utils/lib/ci/validate-script-naming.sh
bash -n scripts/utils/lib/ci/validate-english-content.sh
bash -n scripts/utils/lib/ci/validate-docker-compose-config.sh
bash scripts/utils/lib/ci/validate-script-naming.sh
bash scripts/utils/lib/ci/validate-english-content.sh
bash scripts/utils/lib/ci/validate-docker-compose-config.sh
```

If any validator script is missing in your branch, use the checks that are available and keep PR notes explicit about what could not be executed.

---

## 🛠 Troubleshooting

- CI did not run: confirm changed files match workflow `paths` filters.
- Mirror mismatch: if a workflow changes in `.github/workflows/`, apply the same change in `ci-cd/github-actions/`.
- Validation error for script naming: align shell scripts to `kebab-case` under `scripts/`.
- Validation error for language policy: keep governed docs, CI labels, and prompts in English.

---

## 📊 Value & Impact

- Faster environment setup
- Reduced operational overhead
- Improved consistency
- Increased security posture
- Better developer productivity

---

## 🧠 Philosophy

> Treat your platform as a product

- Automation First
- Everything as Code
- DevEx Driven
- Secure by Design
- Observable by Default

---

## 🛣 Roadmap

- Terraform modules
- Kubernetes baseline
- CI/CD templates
- AI agents (DevOps assistant)
- Observability stack
- Internal Developer Platform (IDP)

---

## 🤝 Contributing

Follow:

- Standards in [`docs/standards/README.md`](docs/standards/README.md)
- Contribution guide in [`docs/standards/contribution-and-pr-guidelines.md`](docs/standards/contribution-and-pr-guidelines.md)
- ADR process in [`docs/decisions/README.md`](docs/decisions/README.md)
- Keep documentation updated in the same PR as code/script changes

---

## 📄 License

MIT
