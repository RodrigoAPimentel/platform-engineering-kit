---
mode: agent
description: "Revisa scripts shell, naming convention, estrutura e runbook coverage."
---

Revise scripts de automacao e aplique correcoes de padrao com o agente Platform Engineering Guardian.

Contexto opcional:

- Escopo: ${input:scope:Ex.: scripts/install, scripts/maintenance, scripts/install/standalone}
- Restricoes: ${input:constraints:Ex.: sem remocao de funcionalidades}

Checklist minimo:

- Shebang e strict mode.
- Naming kebab-case em scripts/.
- Estrutura correta (install, maintenance, standalone, utils/lib).
- Um runbook por script criado/alterado.
- Atualizacao dos READMEs afetados.

Regras de saida:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps
