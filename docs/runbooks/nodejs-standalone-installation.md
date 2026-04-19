# Node.js Standalone Installation

⚠️ **Warning:** This procedure requires root privileges (`sudo`) and may handle secrets/passwords. Review commands before execution and avoid exposing credentials in command line, shell history, or logs. See [security/secrets/README.md](../security/secrets/README.md) for best practices.

Runbook for installing Node.js (via NVM) as a standalone runtime for a target user.

## Related script

- scripts/install/standalone/install-nodejs-standalone.sh

## Prerequisites

- Root access via sudo.
- Existing target user.
- Internet connectivity to download NVM/Node.js.

## Quick usage

```bash
sudo bash scripts/install/standalone/install-nodejs-standalone.sh
```

## Main options

```bash
--user <username>
--node-version <version>
--skip-system-update
--reboot
```

## Examples

```bash
sudo bash scripts/install/standalone/install-nodejs-standalone.sh --user devops
sudo bash scripts/install/standalone/install-nodejs-standalone.sh --node-version 20
```

## Expected result

- NVM installed in target user home.
- Node.js and npm installed and configured as default in NVM.

## Validation

```bash
sudo -u <username> bash -lc 'export NVM_DIR="$HOME/.nvm" && source "$NVM_DIR/nvm.sh" && node --version && npm --version'
```

## Troubleshooting

- node not found in session:
  - Open a new user session or source nvm.sh manually.
- NVM download error:
  - Check network connectivity and CA certificates.
