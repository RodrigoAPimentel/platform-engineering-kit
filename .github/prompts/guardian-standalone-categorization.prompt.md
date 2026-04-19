---
mode: agent
description: "Use when: classificar e organizar instaladores independentes em scripts/install/standalone com documentacao completa."
---

Analise scripts de aplicações independentes e organize na categoria standalone.

Use when:

- Precisa mover/ajustar instaladores independentes para `scripts/install/standalone`.
- Precisa alinhar READMEs e runbooks apos categorizacao standalone.

Avoid when:

- A tarefa principal for consolidacao multi-distro de um instalador (use `/guardian-multi-distro-consolidation`).
- A tarefa principal for melhoria geral de scripts sem recorte standalone (use `/guardian-scripts`).

Scope default:

- `scripts/install/standalone/`, `scripts/install/README.md`, `scripts/README.md` e runbooks relacionados.

Output format:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps

Objetivo:

- Mover instaladores independentes para scripts/install/standalone.
- Atualizar scripts/README.md, scripts/install/README.md e scripts/install/standalone/README.md.
- Criar runbooks dedicados.

Critérios:

- Preservar funcionalidade.
- Melhorar legibilidade e reuso.
- Padronizar interface CLI e mensagens operacionais.
