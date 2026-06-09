#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <vault_user_file> [extra ansible-playbook args...]" >&2
  echo "Example: $0 vault/users/newuser.vault.yml -u infra" >&2
  exit 2
fi

vault_user_file="$1"
shift || true

if [[ ! -f "$vault_user_file" ]]; then
  echo "Vault user file not found: $vault_user_file" >&2
  exit 2
fi

current_umask="$(umask)"
umask_value=$((8#$current_umask))

# If owner write/execute bits are masked (0o300), ansible temp files can fail.
if (( (umask_value & 0300) != 0 )); then
  echo "Current umask is too restrictive: $current_umask" >&2
  echo "Run: umask 022" >&2
  exit 2
fi

exec ansible-playbook -i hosts-infra create-user-vault.yml -e "vault_user_file=$vault_user_file" "$@"
