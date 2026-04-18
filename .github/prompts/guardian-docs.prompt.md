---
mode: agent
description: "Audita e atualiza documentacao e READMEs com foco em discoverability e consistencia."
---

Revise e atualize documentacao e READMEs com o agente Platform Engineering Guardian.

Contexto opcional:

- Escopo: ${input:scope:Ex.: docs/runbooks, scripts/README.md, README raiz}
- Objetivo: ${input:goal:Ex.: fechar gaps de runbooks e alinhar indices}

Criterios:

- Garantir consistencia entre scripts e runbooks.
- Atualizar indices locais e navegacao.
- Evitar markdown operacional no root quando deve estar em docs/runbooks.

Regras de saida:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps
