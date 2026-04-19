---
mode: agent
description: "Use when: auditar e atualizar documentacao, README e cobertura de runbooks com foco em discoverability e consistencia."
---

Revise e atualize documentacao e READMEs com o agente Platform Engineering Guardian.

Use when:

- Precisa corrigir navegacao, indices e consistencia entre scripts e documentacao.
- Precisa garantir cobertura de runbook para scripts operacionais e atualizar `docs/runbooks/README.md`.

Avoid when:

- A tarefa principal for padronizacao tecnica de scripts shell (use `/guardian-scripts`).
- A tarefa principal for pipelines CI/CD (use `/guardian-cicd`).

Scope default:

- `docs/`, `scripts/README.md`, `scripts/install/README.md`, `scripts/install/standalone/README.md` e `docs/runbooks/`.

Output format:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps

Contexto opcional:

- Escopo: ${input:scope:Ex.: docs/runbooks, scripts/README.md, README raiz}
- Objetivo: ${input:goal:Ex.: fechar gaps de runbooks e alinhar indices}

Criterios:

- Garantir consistencia entre scripts e runbooks.
- Atualizar indices locais e navegacao.
- Evitar markdown operacional no root quando deve estar em docs/runbooks.
