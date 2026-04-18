---
mode: agent
description: "Revisa pipelines CI/CD e padroes de validacao para scripts e infraestrutura."
---

Audite e padronize CI/CD com o agente Platform Engineering Guardian.

Contexto opcional:

- Escopo: ${input:scope:Ex.: ci-cd/github-actions, ci-cd/templates}
- Objetivo: ${input:goal:Ex.: ampliar testes de scripts multi-distro}

Criticidade:

- Priorizar confiabilidade, reaproveitamento e feedback rapido.
- Verificar cobertura de validacoes de naming/sintaxe/scripts.

Regras de saida:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps
