---
mode: agent
description: "Use when: consolidar instaladores distro-especificos em um script unico com deteccao de sistema e package manager."
---

Consolide variantes de instaladores distro-específicos em um único script reutilizável.

Use when:

- Existem scripts separados por distro para a mesma ferramenta.
- O objetivo e reduzir duplicacao mantendo cobertura apt/dnf/yum.

Avoid when:

- A tarefa principal for apenas reorganizacao de pasta standalone (use `/guardian-standalone-categorization`).
- A tarefa principal for auditoria ampla sem execucao especializada (use `/guardian-audit`).

Scope default:

- `scripts/install/` e `scripts/install/standalone/`.

Output format:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps

Escopo típico:

- scripts/install
- scripts/install/standalone

Critérios:

- Um script único por ferramenta sempre que viável.
- Detecção por apt/dnf/yum e ajustes por arquitetura quando necessário.
- Sem remoção de funcionalidades existentes.
- Atualização de README e runbook correspondente.
