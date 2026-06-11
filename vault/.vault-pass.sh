#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS_FILE="${ANSIBLE_VAULT_PASS_FILE:-$SCRIPT_DIR/.vault-pass.txt}"

if [[ ! -f "$PASS_FILE" ]]; then
  echo "Vault password file not found: $PASS_FILE" >&2
  echo "Create it securely:" >&2
  echo "  mkdir -p \"$(dirname \"$PASS_FILE\")\"" >&2
  echo "  chmod 700 \"$(dirname \"$PASS_FILE\")\"" >&2
  echo "  umask 177 && printf '%s\\n' 'your-vault-password' > \"$PASS_FILE\"" >&2
  exit 1
fi

cat "$PASS_FILE"
