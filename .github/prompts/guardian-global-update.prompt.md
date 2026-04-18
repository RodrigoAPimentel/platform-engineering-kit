---
mode: agent
description: "Executa atualizacao global no repositorio para manter padroes de plataforma e documentacao em dia."
---

Execute uma atualizacao global no repositorio com o agente Platform Engineering Guardian.

Objetivo:

- Manter repositorio atualizado e aderente ao padrao estabelecido.

Contexto opcional:

- Escopo: ${input:scope:Ex.: repositorio inteiro}
- Limites: ${input:constraints:Ex.: sem mudancas destrutivas, preservar funcionalidades}

Passos esperados:

1. Mapear gaps de estrutura/documentacao/scripts.
2. Corrigir inconsistencias e referencias legadas.
3. Validar nomeacao, sintaxe e integridade dos arquivos alterados.
4. Atualizar indexes/READMEs para discoverability.

Formato de resposta:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps
