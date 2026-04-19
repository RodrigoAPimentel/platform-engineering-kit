---
mode: agent
description: "Use when: sincronizar prompts e instrucoes do Platform Engineering Guardian entre .github e ai com rastreabilidade."
---

Revise e sincronize definições do Platform Engineering Guardian em todos os pontos oficiais.

Use when:

- Houve alteracao em prompt, agent definition ou usage manual em uma das pastas.
- Precisa validar paridade entre execucao no VS Code e pacote versionado em `ai/`.

Avoid when:

- A tarefa principal for auditoria de codigo/repositorio (use outro prompt do catalogo Guardian).

Scope default:

- `.github/agents/`, `.github/prompts/`, `ai/agents/platform-engineering-guardian/` e `ai/agents/platform-engineering-guardian/prompts/`.

Output format:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps

Objetivo:

- Garantir paridade entre `.github/agents` e `ai/agents`.
- Garantir paridade entre `.github/prompts` e `ai/agents/platform-engineering-guardian/prompts`.
- Atualizar manuais de uso e prompts relacionados.
- Registrar versão no pacote do agent quando houver mudanças relevantes.

Checklist:

1. Comparar definições atuais.
2. Aplicar mesmas regras nos arquivos de agent das duas pastas.
3. Aplicar as mesmas alteracoes de prompts nas duas pastas.
4. Atualizar usage e indice/catalogo de prompts.
5. Publicar snapshot de versão quando necessário.
