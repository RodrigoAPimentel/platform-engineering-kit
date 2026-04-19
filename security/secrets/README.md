# 🔑 Secrets

Secret management practices.

## Purpose

Secure sensitive data.

## Best practices for sudo and secrets

- Whenever possible, avoid passing passwords or secrets directly in command-line arguments.
- Prefer environment variables, protected temporary files, or secret vault tools (for example: Ansible Vault, HashiCorp Vault).
- Scripts that require sudo should warn about credential exposure risks in shell history or logs.
- Never share commands containing secrets in chats, tickets, or public documentation.
- Clear sensitive environment variables after use (`unset SECRET_VAR`).
