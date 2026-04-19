# Oh My Zsh Installation (Ubuntu/Debian)

Runbook for installing Oh My Zsh, plugins, and Powerlevel10k on apt-based systems.

## Related script

- scripts/install/install-oh-my-zsh-ubuntu.sh

## Prerequisites

- Ubuntu/Debian.
- Root access via sudo.
- Valid target user.

## Quick usage

```bash
sudo bash scripts/install/install-oh-my-zsh-ubuntu.sh
```

## Main options

```bash
--user <username>
--theme <theme>
--p10k-config <file>
--skip-fonts
--reboot
```

## Examples

```bash
sudo bash scripts/install/install-oh-my-zsh-ubuntu.sh --user devops
sudo bash scripts/install/install-oh-my-zsh-ubuntu.sh --theme powerlevel10k/powerlevel10k
sudo bash scripts/install/install-oh-my-zsh-ubuntu.sh --skip-fonts
```

## Expected result

- zsh installed and set as default shell for target user.
- Oh My Zsh installed with essential plugins.
- Powerlevel10k and .p10k.zsh configuration applied.

## Validation

```bash
getent passwd <username> | cut -d: -f7
sudo -u <username> zsh -ic 'echo $ZSH_VERSION'
sudo -u <username> test -f ~/.p10k.zsh && echo ok
```

## Troubleshooting

- Theme not applied:
  - Validate ZSH_THEME and .zshrc file permissions.
- Broken terminal font rendering:
  - Install powerline-compatible fonts on the terminal client.
