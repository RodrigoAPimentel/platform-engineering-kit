# common role

Aplica baseline de sistema operacional e utilitarios comuns.

## Notas

- Prefere modulos `ansible.builtin.*` para maior legibilidade.
- Evita `state: latest` para execucoes mais deterministicas.
