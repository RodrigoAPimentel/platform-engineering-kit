---
mode: agent
description: "Migra scripts da pasta de contexto para estrutura oficial, com padronizacao, nomes legiveis e atualizacao de READMEs."
---

Analise os scripts da pasta de contexto e execute migracao completa para o padrao do repositório.

Objetivo:

- Padronizar scripts shell.
- Renomear para legibilidade (kebab-case).
- Mover para diretórios corretos.
- Atualizar READMEs de índice.

Checklist:

1. Detectar arquivos legados em staging/contexto.
2. Modernizar (strict mode, libs compartilhadas, flags).
3. Mover para scripts/install, scripts/install/standalone ou scripts/maintenance.
4. Atualizar índices de scripts e runbooks.
5. Validar naming e sintaxe.

Saída:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps
