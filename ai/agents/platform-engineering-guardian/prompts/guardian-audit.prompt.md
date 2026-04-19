---
mode: agent
description: "Use when: realizar diagnostico amplo do repositorio com priorizacao de gaps, sem executar refatoracao transversal por padrao."
---

Execute um diagnostico amplo do repositório com o agente Platform Engineering Guardian.

Use when:

- Precisa de visao geral de qualidade estrutural, scripts, docs, CI/CD e governanca.
- Quer backlog priorizado antes de decidir o plano de execucao.

Avoid when:

- O objetivo ja estiver fechado em um dominio especifico (use `/guardian-docs`, `/guardian-scripts` ou `/guardian-cicd`).
- A expectativa for executar uma migracao especializada (use `/guardian-standalone-categorization` ou `/guardian-multi-distro-consolidation`).

Scope default:

- Repositorio inteiro, salvo quando `scope` for informado.

Output format:

1. Findings (ordem por severidade, com referencias de arquivo).
2. Recommended actions (reusaveis e escalaveis).
3. Applied changes (o que foi alterado e impacto esperado).
4. Next steps (1-3 proximos passos).

Contexto opcional:

- Escopo: ${input:scope:Ex.: scripts, docs, ci-cd, ou repositorio inteiro}
- Restricoes: ${input:constraints:Ex.: sem mudancas destrutivas, sem refatoracao ampla}
- Resultado esperado: ${input:outcome:Ex.: lista de gaps com correcoes aplicadas}
