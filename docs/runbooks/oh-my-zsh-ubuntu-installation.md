# Oh My Zsh Installation (Ubuntu/Debian)

Runbook para instalação de Oh My Zsh, plugins e Powerlevel10k em sistemas apt.

## Script relacionado

- scripts/install/install-oh-my-zsh-ubuntu.sh

## Pré-requisitos

- Ubuntu/Debian.
- Acesso root via sudo.
- Usuário alvo válido.

## Uso rápido

```bash
sudo bash scripts/install/install-oh-my-zsh-ubuntu.sh
```

## Opções principais

```bash
--user <usuario>
--theme <tema>
--p10k-config <arquivo>
--skip-fonts
--reboot
```

## Exemplos

```bash
sudo bash scripts/install/install-oh-my-zsh-ubuntu.sh --user devops
sudo bash scripts/install/install-oh-my-zsh-ubuntu.sh --theme powerlevel10k/powerlevel10k
sudo bash scripts/install/install-oh-my-zsh-ubuntu.sh --skip-fonts
```

## Resultado esperado

- zsh instalado e definido como shell padrão do usuário alvo.
- Oh My Zsh instalado com plugins essenciais.
- Powerlevel10k e configuração .p10k.zsh aplicados.

## Validação

```bash
getent passwd <usuario> | cut -d: -f7
sudo -u <usuario> zsh -ic 'echo $ZSH_VERSION'
sudo -u <usuario> test -f ~/.p10k.zsh && echo ok
```

## Troubleshooting

- Tema não aplicado:
  - Valide ZSH_THEME e permissões do arquivo .zshrc.
- Fonte quebrada no terminal:
  - Instale fontes powerline no cliente terminal.
