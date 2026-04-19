---
mode: agent
description: "Use when: revisar pipelines CI/CD, gates de qualidade e padroes de validacao para scripts e infraestrutura."
---

Audite e padronize CI/CD com o agente Platform Engineering Guardian.

Use when:

- Precisa evoluir pipelines, checks e templates de validacao.
- Precisa melhorar confiabilidade, velocidade de feedback e cobertura multi-distro.

Avoid when:

- A tarefa principal for qualidade de scripts fora de pipeline (use `/guardian-scripts`).
- A tarefa principal for documentacao e indices (use `/guardian-docs`).

Scope default:

- `ci-cd/github-actions/`, `ci-cd/azure-devops/` e `ci-cd/templates/`.

Output format:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps

Contexto opcional:

- Escopo: ${input:scope:Ex.: ci-cd/github-actions, ci-cd/templates}
- Objetivo: ${input:goal:Ex.: ampliar testes de scripts multi-distro}

Criticidade:

- Priorizar confiabilidade, reaproveitamento e feedback rapido.
- Verificar cobertura de validacoes de naming/sintaxe/scripts.
