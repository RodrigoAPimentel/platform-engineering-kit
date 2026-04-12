# Manual de Utilizacao do Platform Engineering Guardian

Este manual explica como usar o agente Platform Engineering Guardian no repositorio para manter padrao, qualidade e evolucao continua.

## Onde esta o agente

- Arquivo de agente customizado: `.github/agents/platform-engineering-guardian.agent.md`
- Arquivo de referencia conceitual: `ai/agents/platform-engineering-guardian.md`

Use o arquivo em `.github/agents` para execucao no seletor de agentes do Copilot.

## O que este agente faz

- Audita estrutura de pastas e aderencia ao proposito de cada diretorio.
- Verifica cobertura e qualidade de READMEs.
- Revisa padroes de IaC, CI/CD, scripts, seguranca e observabilidade.
- Sugere e implementa melhorias com foco em reutilizacao e escalabilidade.
- Prioriza recomendacoes por impacto em confiabilidade e DevEx.

## Como usar no dia a dia

1. Abra o chat do Copilot no VS Code.
2. Selecione o agente Platform Engineering Guardian.
3. Escreva um objetivo claro, com escopo e restricoes.
4. Revise o resultado no formato padrao:
   1. Findings
   2. Recommended actions
   3. Applied changes
   4. Next steps

## Prompts prontos

### Auditoria geral do repositorio

```text
Faça um health check completo do repositório e priorize gaps por severidade.
```

### Padronizacao de CI/CD

```text
Revise ci-cd e proponha padronização reutilizável entre github-actions e azure-devops.
```

### Documentacao e READMEs

```text
Audite documentação e READMEs: identifique lacunas, melhore clareza e alinhe com a estrutura atual.
```

### IaC e governanca

```text
Avalie infrastructure e recomende melhorias de modularização, naming e governança.
```

### Seguranca e observabilidade

```text
Revise security e observability e proponha melhorias práticas, padronizadas e automáveis.
```

## Quando usar este agente em vez do agente padrao

Use Platform Engineering Guardian quando o foco for:

- Organizacao e consistencia do repositorio.
- Governanca tecnica cross-cutting.
- Padroes corporativos de plataforma.
- Melhorias estruturais com rastreabilidade.

Para tarefas puramente de feature de aplicacao, prefira o agente padrao.

## Nivel de autonomia

- Pode aplicar mudancas completas quando necessario.
- Para mudancas estruturais de alto impacto, apresenta justificativa curta e impacto esperado antes de aplicar.
- Nao remove conteudo sem explicar impacto e racional.

## Boas praticas de uso

- Defina escopo por pasta para reduzir ruido.
- Informe restricoes de prazo e risco no prompt.
- Peça plano incremental quando a mudanca for ampla.
- Execute revisao do agente antes de abrir PRs importantes.

## Fluxo recomendado para PR

1. Rodar auditoria de estrutura e docs.
2. Aplicar melhorias de baixo risco.
3. Solicitar revisao final de padroes (IaC, CI/CD, seguranca, observabilidade).
4. Registrar decisoes relevantes em docs/decisions quando aplicavel.

## Solucao de problemas

- Agente nao aparece no seletor:
  - Verifique se o arquivo existe em `.github/agents/platform-engineering-guardian.agent.md`.
  - Confira se o frontmatter YAML esta valido.
- Resposta muito generica:
  - Informe pasta-alvo, objetivo e criterio de sucesso no prompt.
- Mudanca ampla demais:
  - Peça explicitamente "execute em fases" ou "apenas propostas, sem aplicar".
