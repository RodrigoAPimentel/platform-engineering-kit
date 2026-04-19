# 🔑 Secrets

Secret management practices.

## Purpose

Secure sensitive data.

## Boas práticas de uso de sudo e secrets

- Sempre que possível, evite passar senhas ou secrets diretamente na linha de comando.
- Prefira variáveis de ambiente, arquivos temporários protegidos ou ferramentas de cofre (ex: Ansible Vault, HashiCorp Vault).
- Scripts que exigem sudo devem alertar sobre riscos de exposição de credenciais em histórico de shell ou logs.
- Nunca compartilhe comandos com secrets em chats, tickets ou documentação pública.
- Limpe variáveis de ambiente sensíveis após uso (`unset SECRET_VAR`).
