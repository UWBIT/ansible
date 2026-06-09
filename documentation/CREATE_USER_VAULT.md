# Create User Playbook (Vault-Only)

This guide explains how to use `create-user-vault.yml` with Ansible Vault only (no interactive prompts).

`create-user-vault.yml` is generic. The account to create is defined in a vault file you pass at runtime via `-e vault_user_file=...`.

## Files Used

- Playbook: `create-user-vault.yml`
- Vault vars file (encrypted): per-user file path you pass at runtime (example: `vault/users/kevin.vault.yml`)
- Vault password file: `vault/.vault-pass.txt`
- Vault password helper script: `vault/.vault-pass.sh`
- Ansible config using helper: `ansible.cfg`
- Example vars template: `create-user.vault.yml.example`

## Prerequisite

Before running any commands in this guide, confirm the playbook exists:

```bash
cd /infra/ansible
ls -l create-user-vault.yml
```

If the file is missing, restore it from your repo history (or from the branch where it was created) before continuing.

## Run the Playbook

Before each run, edit the vault file for the account you want to create:

```bash
cd /infra/ansible
EDITOR=nano ansible-vault edit vault/users/newuser.vault.yml
```

Set these values in the vault file:

```yaml
vault_create_user_name: "newuser"
vault_create_user_ssh_keys:
  - "files/certs/newuser.pub"
```

```bash
cd /infra/ansible
bash run-create-user-vault.sh vault/users/newuser.vault.yml -u infra
```

The helper script checks `umask` before running Ansible and exits with a clear message if it is too restrictive.

Direct command (without helper):

```bash
cd /infra/ansible
ansible-playbook -i hosts-infra create-user-vault.yml -e "vault_user_file=vault/users/newuser.vault.yml" -u infra
```

No `--ask-vault-pass` is needed because `ansible.cfg` is configured to use `vault/.vault-pass.sh`.

## Verify Configuration

Check the configured vault password helper:

```bash
cd /infra/ansible
ansible-config dump | grep -i vault_password_file
```

Expected output includes `vault/.vault-pass.sh`.

Check playbook syntax:

```bash
ansible-playbook --syntax-check create-user-vault.yml
```

## Update User Data Later

1. Edit the vault file with the next account values:

```bash
EDITOR=nano ansible-vault edit vault/users/newuser.vault.yml
```

2. Save changes and rerun the playbook with that same file:

```bash
bash run-create-user-vault.sh vault/users/newuser.vault.yml -u infra
```

## Notes

- The playbook expects values only from the file passed in `vault_user_file`.
- Use `run-create-user-vault.sh` to guard against restrictive `umask` values.
- Preferred invocation is `bash run-create-user-vault.sh ...`.
- You can use `./run-create-user-vault.sh ...` after setting execute permission (`chmod 700 run-create-user-vault.sh`).
- Default SSH key type in the playbook is `ed25519`.
- If you switch to RSA, size is only applied for RSA and defaults to 3072.

## Initial Setup (Run Once)

1. Go to the ansible directory.

```bash
cd /infra/ansible
```

2. Create your vault password file.

```bash
printf '%s\n' 'YOUR_VAULT_PASSWORD' > vault/.vault-pass.txt
chmod 600 vault/.vault-pass.txt
```

If you previously ran `umask 177` in your shell, reset it before running Ansible:

```bash
umask 022
```

3. Create a per-user vault vars file from the example.

```bash
mkdir -p vault/users
cp create-user.vault.yml.example vault/users/kevin.vault.yml
```

4. Edit `vault/users/kevin.vault.yml` and set values.

```yaml
vault_create_user_name: "kevin"
vault_create_user_ssh_keys:
  - "files/certs/kevin.pub"
```

5. Encrypt the vars file.

```bash
ansible-vault encrypt vault/users/kevin.vault.yml
```
