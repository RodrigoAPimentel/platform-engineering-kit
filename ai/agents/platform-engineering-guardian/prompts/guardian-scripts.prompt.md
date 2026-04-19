---
mode: agent
description: "Use when: revisar scripts shell com foco em padrao tecnico, naming, estrutura e impacto documental minimo necessario."
---

Revise scripts de automacao e aplique correcoes de padrao com o agente Platform Engineering Guardian.

Use when:

- Precisa corrigir shebang, strict mode, convencao de nomes e organizacao de scripts.
- Precisa revisar contratos CLI, mensagens operacionais e reaproveitamento em scripts.

Avoid when:

- O foco principal for reorganizacao de runbooks e indices de docs (use `/guardian-docs`).
- O foco principal for CI/CD (use `/guardian-cicd`).

Scope default:

- `scripts/install/`, `scripts/maintenance/`, `scripts/utils/` e `scripts/install/standalone/`.

Output format:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps

Contexto opcional:

- Escopo: ${input:scope:Ex.: scripts/install, scripts/maintenance, scripts/install/standalone}
- Restricoes: ${input:constraints:Ex.: sem remocao de funcionalidades}

Checklist minimo:

- Shebang e strict mode.
- Naming kebab-case em scripts/.
- Estrutura correta (install, maintenance, standalone, utils/lib).
- Um runbook por script criado/alterado.
- Atualizacao dos READMEs afetados.
