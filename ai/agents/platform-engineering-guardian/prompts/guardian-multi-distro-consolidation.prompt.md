---
mode: agent
description: "Consolida instaladores por distro em script unico com deteccao de sistema operacional e package manager."
---

Consolide variantes de instaladores distro-específicos em um único script reutilizável.

Escopo típico:

- scripts/install
- scripts/install/standalone

Critérios:

- Um script único por ferramenta sempre que viável.
- Detecção por apt/dnf/yum e ajustes por arquitetura quando necessário.
- Sem remoção de funcionalidades existentes.
- Atualização de README e runbook correspondente.

Saída:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps
