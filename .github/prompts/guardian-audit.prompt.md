---
mode: agent
description: "Auditoria estrutural completa do repositório com achados priorizados. Use quando quiser revisar tudo com foco em padrão de plataforma."
---

Execute uma auditoria completa do repositório com o agente Platform Engineering Guardian.

Contexto opcional:

- Escopo: ${input:scope:Ex.: scripts, docs, ci-cd, ou repositorio inteiro}
- Restricoes: ${input:constraints:Ex.: sem mudancas destrutivas, sem refatoracao ampla}
- Resultado esperado: ${input:outcome:Ex.: lista de gaps com correcoes aplicadas}

Regras de saida obrigatorias:

1. Findings (ordem por severidade, com referencias de arquivo).
2. Recommended actions (reusaveis e escalaveis).
3. Applied changes (o que foi alterado e impacto esperado).
4. Next steps (1-3 proximos passos).
