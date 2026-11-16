# pleros-infra

Infrastructure as code for **pleros.org**, the digital platform of Fullness of Christ Church.
A fresh Ubuntu server becomes a running, hardened Pleros server with two commands.

| Piece | What it does |
| --- | --- |
| `playbooks/bootstrap.yml` | First run as root: creates the `deploy` user with your SSH key, then disables root and password login |
| `playbooks/site.yml` | Everything else: base packages, swap, firewall, fail2ban, auto security updates, Docker, the app, cron jobs |
| `roles/app` | Clones the app repo, writes `.env` from the encrypted vault, builds and runs Pleros + Caddy (automatic HTTPS) with Docker Compose |
| `roles/cron` | Recreates the two Vercel cron jobs (`sogp-reminders` daily 04:20 UTC, `reminder-dispatch` every 5 min) |
| `inventory/group_vars/all/vault.yml` | All app secrets, **encrypted** with ansible-vault (template: `vault.yml.example`) |

Database stays on Neon. The app code is not modified: it is built with `npm ci && npm run build` as on Vercel.

## One-time setup on your machine (WSL)

```bash
pipx install --include-deps ansible && pipx inject ansible ansible-lint
sudo apt install -y sshpass jq          # sshpass: only for the first, password-based login
ssh-keygen -t ed25519 -f ~/.ssh/pleros_ed25519          # skip if it exists
openssl rand -base64 32 > ~/.pleros-vault-pass && chmod 600 ~/.pleros-vault-pass   # skip if it exists
make hooks                                               # blocks committing an unencrypted vault
```

## Bring up a server

1. Put the server IP in `inventory/hosts.yml` (replace `SERVER_IP`).
2. Secrets: `make vault-init` then `make vault-edit` (paste the production values).
3. First login: `make bootstrap` (asks for the root password from Contabo's email) or `make bootstrap-key` if your key was added at order time.
4. `make ping` then `make deploy`.
5. Test at `https://new.pleros.org` (needs a DNS record, see `docs/cutover-checklist.md`).
6. Cutover: follow `docs/cutover-checklist.md`.

Run `make` to list every command. Day-to-day operations: `docs/runbook.md`.
