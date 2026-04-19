# Prompt Commands

Slash commands for Platform Engineering Guardian workflows.

## How to use

In Copilot Chat, type `/` and choose one of the commands below.

## Commands

- `/guardian-audit` -> Diagnostico amplo com priorizacao de gaps (entrada padrao para planejamento).
- `/guardian-docs` -> Documentacao, indices e cobertura de runbooks.
- `/guardian-scripts` -> Qualidade tecnica de scripts shell (padrao, naming e estrutura).
- `/guardian-cicd` -> Revisao e padronizacao de pipelines e gates de qualidade.
- `/guardian-standalone-categorization` -> Organizacao de instaladores independentes em standalone.
- `/guardian-multi-distro-consolidation` -> Consolidacao de instaladores por distro em script unico.
- `/guardian-agent-sync` -> Sincronizacao de prompts e instrucoes do agent entre `.github` e `ai`.

## Synchronization Policy

- Qualquer alteracao em prompts deve ser espelhada entre `.github/prompts/` e `ai/agents/platform-engineering-guardian/prompts/`.
- Qualquer alteracao em instrucoes do agent deve ser espelhada entre `.github/agents/platform-engineering-guardian.agent.md` e `ai/agents/platform-engineering-guardian/platform-engineering-guardian.agent.md`.
- Alteracoes de catalogo e uso tambem devem atualizar `ai/agents/platform-engineering-guardian/platform-engineering-guardian.agent_USAGE.md`.

## Purpose

Provide reusable, guided entry points for frequent platform engineering tasks.
